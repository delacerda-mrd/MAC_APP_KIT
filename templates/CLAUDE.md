# {{APP_NAME}} — AI Session Protocol

macOS app built with MAC_APP_KIT (`~/Claude_Code/MAC_APP_KIT`). Stack:
{{A: WKWebView shell | B: SwiftUI via swiftc | C: CLI}}.

## SESSION START PROTOCOL

1. `git pull` (if a remote exists; on journal conflict keep both entries)
2. Read `docs/JOURNAL.md` — Current Status block first
3. Read `VERSION` and the `[Unreleased]` section of `CHANGELOG.md`

## Source of truth

- {{e.g. `src/app.jsx` is the ONLY app source; Swift shell is
  `build/main.swift`}} — never edit `dist/` or compiled outputs.
- `docs/SPEC.md` is behavior truth. If behavior diverges from it, update the
  spec in the same session.

## During work

- Stage user-visible changes as `[Unreleased]` bullets in `CHANGELOG.md`.
- UI text language: {{LANGUAGE}}.
- No new runtime dependencies. No CDN references. Fully offline.
- Do not install Node.js or npm. No Xcode/.xcodeproj — swiftc only.
- Before debugging any build/WKWebView/audio/packaging issue, check
  `~/Claude_Code/MAC_APP_KIT/TROUBLESHOOTING.md` first; feed new
  symptom→cause→fix entries back to it in the same session.

## Build & test

```sh
bash build/build.sh            # must exit 0; produces dist/{{APP_NAME}}.app
open dist/{{APP_NAME}}.app     # manual testing
```

## Wrap-up protocol (exit phrase: "wrap it up" / /wrap)

1. **Build**: `bash build/build.sh` must pass; fix failures first.
2. **Journal**: refresh Current Status in `docs/JOURNAL.md` (version, phase,
   known-working, known-broken, next step) + dated entry naming the machine.
   If the pipeline is in use, record the exact position (WI + stage).
3. **Milestones**: tick `docs/MILESTONES.md` items verified BY USING THE APP
   this session (compiling is not verification).
4. **Version**: bump `VERSION` (patch fix / minor feature; ask if unsure),
   roll `[Unreleased]` into a dated `[X.Y.Z]` CHANGELOG section.
5. **Commit & tag**: `git add -A && git commit -m "vX.Y.Z: <summary>" &&
   git tag vX.Y.Z`, push if a remote exists.
6. Report what was saved and the version, then stop.

### Post-project retro (only at the LAST milestone)

When the project reaches its final `docs/MILESTONES.md` item, run a
10-minute retro BEFORE the normal wrap-up. Three questions, answered
honestly and journaled **to the kit, not to this project**
(`~/Claude_Code/MAC_APP_KIT/KIT_CHANGELOG.md`, plus the specific file each
answer belongs in):

1. What did the pipeline waste tokens on? (a tier that was too deep, an
   agent re-reading what it was already given, a review round that found
   nothing)
2. What did an agent get wrong that a KIT RULE would have prevented? → the
   rule goes in the agent master or ORCHESTRATOR_PROMPT.md.
3. What recipe or trap should be added? → `recipes/` or
   `TROUBLESHOOTING.md`, with this project named as provenance.

Commit and push the kit changes in the same session. This retro is the
mechanism that grew the kit in the first place — running it deliberately is
the difference between the kit improving and the kit drifting.

## Known traps (project-specific — kit-generic ones live in the kit)

- {{add as discovered}}
