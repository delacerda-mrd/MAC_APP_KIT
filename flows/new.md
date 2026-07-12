# Flow — New macOS app from scratch

Reached from /app (State E). Bootstrap this folder as a new app project
using `~/Claude_Code/MAC_APP_KIT/templates/`. Follow exactly.

## Step 1 — Gather facts

Read `~/Claude_Code/MAC_APP_KIT/PLAYBOOK.md` and the machine ref
(`machines/NEO.md` or the one matching `hostname`; if none matches, run the
probe in `_TEMPLATE_MACHINE.md` and create it).

**Interview for the spec** — ask until `templates/docs/SPEC.md` can be
filled honestly:
- **What it does**: the app in one paragraph; every screen/state and what
  each control does
- **Assets & data**: bundled media, what persists between launches, sizes
- **UI language** (FlamencoCompas was Spanish — never assume English)
- **Targets as numbers**: latency/timing/size expectations that matter
- **Machines**: which Macs it must run on (drives universal-binary need)
- **Stack preference**, if any (else recommend via the playbook Step 1 tree)

Genuine unknowns become numbered open questions (OQ-n) in SPEC.md — never
resolve one by assuming.

## Step 2 — Instantiate the docs

Copy from `MAC_APP_KIT/templates/` and replace every `{{...}}` with real
facts:
- `templates/CLAUDE.md` → repo root `CLAUDE.md`
- `templates/docs/{SPEC,JOURNAL,MILESTONES}.md` → `docs/`
- `echo 0.0.0 > VERSION`; create `CHANGELOG.md` with an `[Unreleased]` section

Trim `docs/MILESTONES.md` to THIS app: delete items for capabilities the
spec doesn't use (audio, etc.), add items for everything in the spec.

`docs/DEV_PLAN.md` is NOT copied by hand — app-architect writes it in
pipeline Phase A.

## Step 3 — Verify the environment

- `git init` if needed; confirm/ask about a remote (cross-machine sync).
- Confirm `swiftc --version` and (Stack A) the jsc path from the machine ref.
- Create the skeleton per the playbook (build.sh + empty shell) and run
  `bash build/build.sh` once. Record the result as the first journal entry.

## Step 4 — Enter the pipeline

Adopt the orchestrator role from
`~/Claude_Code/MAC_APP_KIT/agents/ORCHESTRATOR_PROMPT.md` (the block after
its `---`) and start Phase A (app-architect on the fresh SPEC.md).

## Step 5 — Commit and confirm

Commit docs + skeleton (`Bootstrap macOS app project from MAC_APP_KIT`),
push if a remote exists, then confirm to the user: **"Say 'wrap it up'
anytime to save the session. Type /app in this folder on any machine to
resume."**
