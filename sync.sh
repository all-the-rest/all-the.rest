#!/usr/bin/env bash
# =============================================================================
# sync.sh — all-the.rest via rsync/ssh auf root@reisinger.pictures spiegeln
# =============================================================================
#
# Ersetzt die frühere rclone-SFTP-Variante (Remote "reisinger.pictures").
# Hintergrund und Migrations-Reihenfolge: strato-vps/README.md
#
# Warum rsync und nicht scp: rclone sync war ein MIRROR (inkl. Löschen).
# Der Build erzeugt content-hashed Assets (_astro/*.css), jeder Deploy muss
# den alten Hash entfernen — scp -r hat kein --delete und würde die Dateien
# für immer liegen lassen.
# =============================================================================
set -euo pipefail
cd "$(dirname "$0")"

# --- GNU-rsync-Pflicht -------------------------------------------------------
# macOS liefert per Default /usr/bin/rsync = openrsync (Protokoll 29), das weder
# --chown noch --chmod im benoetigten Umfang unterstuetzt.
# WICHTIG: nicht per `rsync --version | grep -q ...` pruefen. Unter `set -o
# pipefail` beendet `grep -q` den Upstream vorzeitig per SIGPIPE, die Pipeline
# gilt dann als fehlgeschlagen und der Guard schlaegt IMMER an. Deshalb die
# Ausgabe zuerst in eine Variable ziehen.
RSYNC_BIN="${RSYNC_BIN:-$(command -v rsync || true)}"
_rsync_version="$("$RSYNC_BIN" --version 2>/dev/null | head -1 || true)"
if [[ "$_rsync_version" != "rsync  version"* ]]; then
  echo "FEHLER: GNU-rsync benoetigt (macOS-Default ist openrsync)." >&2
  echo "       Install:  brew install rsync" >&2
  echo "       Oder:     RSYNC_BIN=/opt/homebrew/bin/rsync ./sync.sh" >&2
  exit 1
fi
unset _rsync_version

# --- Ziele ------------------------------------------------------------------
# Achtung: der SFTP-Chroot ist weg, daher der volle Pfad.
REMOTE="root@reisinger.pictures:/home/webadmin/websites/all-the.rest/"

# Connection-Reuse: verhindert 6+ TCP/SSH-Handshakes bei vielen kleinen Dateien.
SSH_OPTS="-o ControlMaster=auto -o ControlPath=/tmp/ssh-sync-%r@%h:%p -o ControlPersist=60"

# --chown/--chmod: Das Rechte-Modell der Sites ist bewusst 1002:webgroup mit
# Dateien 666 und Verzeichnern 2777. Ein reines -a wuerde die LOKALEN Rechte
# des Build-Outputs (644/755) durchdruecken und das Modell zerstoeren.
#   --chown  setzt Eigentuemer/Grupfe (1002/webgroup) explizit
#   --chmod  D2777 = Verzeichnisse rwxrwsrwx (setgid! erbt die Gruppe an neue
#            Dateien weiter), F666 = Dateien rw-rw-rw-
# Verzeichnisse und Dateien duerfen NICHT auf lokale 644/755 zurueckfallen.

echo "🚀 Synchronisiere all-the.rest via rsync/ssh..."
"$RSYNC_BIN" dist/ "$REMOTE" \
  --archive \
  --delete \
  --chown=1002:webgroup \
  --chmod=D2777,F666 \
  --info=progress2 \
  --rsh="ssh $SSH_OPTS"
echo "🎉 Upload fuer all-the.rest erfolgreich abgeschlossen!"
