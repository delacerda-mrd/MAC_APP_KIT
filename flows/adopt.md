# Flow — Adopt an in-flight app project

Reached from /app (State S: the user's own project exists but lacks kit
markers). Adopt WITHOUT breaking what works.

## Step 1 — Characterize what exists

Read the existing CLAUDE.md/STATE.md/docs, `git log`, and the source layout.
Establish: what stack it is (playbook A/B/C), what builds, what's verified
working, existing version/changelog conventions. Do NOT refactor anything.

## Step 2 — Fill the gaps only

- No SPEC? Reverse-engineer a draft `docs/SPEC.md` from the code + a short
  interview; unknowns become OQ-n entries the user confirms.
- Merge kit session protocols into the existing root `CLAUDE.md` (add the
  SESSION START PROTOCOL and wrap-up sections from `templates/CLAUDE.md`);
  preserve every project-specific rule already there — existing known-traps
  lists stay authoritative.
- Instantiate `docs/JOURNAL.md` (first entry = the characterization from
  Step 1) and `docs/MILESTONES.md` (pre-check items already verified).
- Keep the project's VERSION/CHANGELOG conventions if it has them.

## Step 3 — Harvest for the kit

Anything in the existing project's docs that is a GENERIC macOS trap or
pattern (not project-specific) belongs in
`~/Claude_Code/MAC_APP_KIT/TROUBLESHOOTING.md` or `PLAYBOOK.md` — tell the
user what you'd add and add it on approval.

## Step 4 — Commit, then route

Commit the new docs (`Adopt project into MAC_APP_KIT`). If further feature
work is planned, enter the pipeline (Phase A: app-architect writes
DEV_PLAN.md for the remaining work). Confirm: **"Say 'wrap it up' anytime
to save. /app here resumes."**
