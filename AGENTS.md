# AGENTS.md

## Nur Regeln, keine Entscheidungen

Diese Datei enthält ausschließlich Regeln — Anweisungen, die für jede Arbeit in diesem
Repo gelten. Dauerhafte Entscheidungen, Begründungen, Messwerte und Historie gehören
nicht hierher, sondern in `docs/`/`features/` bzw. die Projekt-Doku; offene Punkte nach
`Agents.todo.md`; Erledigtes in die Git-Historie.

## Gates

Regeln dieser Ebene. Was nur ein Verzeichnis betrifft, gehört in die
`AGENTS.md` **dieses** Verzeichnisses — sie wird geladen, wenn eine Datei
daraus gelesen wird.

Ein Plan in `docs/plans/` beginnt mit `**Status:** Plan | In Arbeit | Done |
Empfehlung, nicht implementiert`.

Die kanonischen Agent-Regeln laufen über `ratchet` (Preset `agent-rules`):
`ratchet check` vor jedem Commit und in der CI.
