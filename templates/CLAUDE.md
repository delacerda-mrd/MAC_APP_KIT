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

## Known traps (project-specific — kit-generic ones live in the kit)

- {{add as discovered}}
