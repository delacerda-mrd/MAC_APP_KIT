---
name: app
description: Start or resume a macOS app project using MAC_APP_KIT — build a new app from scratch, adopt an in-flight project, or resume a bootstrapped one. Run in the project folder; detects what the folder is and routes automatically. Trigger when the user says "start the app project", "set up this app", "resume the app", or types /app.
---

# /app — universal MAC_APP_KIT entry point

The kit lives at `~/Claude_Code/MAC_APP_KIT`. If that directory does not
exist, STOP and tell the user to restore it there, then re-run /app.

If the current directory IS the kit repo itself (its README's first line
names MAC_APP_KIT), stop and say: "/app runs in a project folder, not in
the kit — cd to the project (or a new empty folder) and run /app again."
If the folder is clearly a firmware project (platformio.ini, *.ino,
ESP32 sources), stop and point the user at /fw instead.

## Step 1 — Detect the folder state (read, don't ask yet)

Look at the current directory: `ls -a`, `git log --oneline -15` if a repo,
the root `CLAUDE.md` if present, `docs/`. Classify into exactly one state:

- **State R (resume):** root `CLAUDE.md` contains a "SESSION START PROTOCOL"
  heading AND `docs/JOURNAL.md` exists — already bootstrapped.
- **State E (empty):** no source files — empty or metadata only (`.git`,
  `README*`, `LICENSE`, `.gitignore`).
- **State S (source, no kit):** source files exist but State R's markers are
  absent — the user's own in-flight app project.

## Step 2 — Route

| State | Ask first | Then follow, exactly |
|---|---|---|
| R | nothing | `~/Claude_Code/MAC_APP_KIT/flows/resume.md` |
| E | nothing (the flow interviews for the spec) | `flows/new.md` |
| S | confirm: "Adopt this in-flight project into the kit?" | `flows/adopt.md` |

Read the selected flow file and follow it step by step. If mid-flow evidence
contradicts the classification, STOP, say so, and switch to the correct flow
from its Step 1.

## Standing rules (all flows)

- Machine facts come from `~/Claude_Code/MAC_APP_KIT/machines/` or from
  running the probe — never from memory. Solutions come from
  `TROUBLESHOOTING.md`, `PLAYBOOK.md`, and `recipes/` — never re-derived.
- The pipeline's model split is deliberate (an expensive model plans, cheap
  executors implement — per-role bindings in
  `~/Claude_Code/MAC_APP_KIT/MODELS.md`): never bypass the plan and "just
  implement" in pipeline mode — an unplanned WI costs more tokens than
  planning it.
- This skill is routing logic. Run it on a cheap model; the pipeline's
  per-role bindings (MODELS.md) govern the heavy lifting.
- Every flow ends committed (pushed if a remote exists) and with this
  confirmation: **"Say 'wrap it up' anytime to save the session. Type /app
  in this folder on any machine to resume."**
