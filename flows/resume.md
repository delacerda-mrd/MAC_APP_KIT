# Flow — Resume a bootstrapped app project

Reached from /app (State R). The kit is already in place — do not
re-bootstrap anything.

## Step 1 — Session start protocol

Run the SESSION START PROTOCOL from the project's CLAUDE.md: `git pull` if
a remote exists (on journal conflict keep both sides' entries), read
`docs/JOURNAL.md`, `VERSION`, and the top of `CHANGELOG.md`.

## Step 2 — Detect the working mode

- **Pipeline mode** if `docs/DEV_PLAN.md` exists or the journal records a
  pipeline position (WI + stage).
- **Inline mode** otherwise (small fixes, no plan needed).

## Step 3 — Resume

- **Inline:** report Current Status in 3–5 lines (version, known-working,
  known-broken, next step per the journal) and continue the journal's next
  step if unambiguous — otherwise ask.
- **Pipeline:** adopt the orchestrator role from
  `~/Claude_Code/MAC_APP_KIT/agents/ORCHESTRATOR_PROMPT.md` (block after its
  `---`). Report the pipeline position, then continue the state machine.
  All human gates still apply.

Remind the user once: "wrap it up" saves the session at any point.
