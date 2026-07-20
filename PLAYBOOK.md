# PLAYBOOK — building macOS apps without Xcode or Node

Read this before planning any new app. Hard constraints on Jeremy's machines
(verify against `machines/<machine>.md`): **no full Xcode** (Command Line
Tools only — `swiftc` works, `xcodebuild` does not), **no Node.js/npm**, no
new runtime dependencies, apps must work fully offline.

## Step 1 — Choose the stack

Decision tree, in order:

1. **Real-time game (canvas rendering, game loop, input latency matters)?**
   → **Stack A-G: WKWebView + canvas game loop** — Stack A's shell with a
   `<canvas>` + `requestAnimationFrame` loop instead of React UI. Same
   `app://` scheme, same audio traps, same build pipeline (set
   `SANITY_GREP=""` in build.sh for a vanilla-JS game). React optional, for
   menus only; the game loop itself is vanilla JS. See
   `recipes/stack-a-game.md`.
   SpriteKit/Metal via `swiftc` is **UNPROVEN** on these machines — treat it
   as a discovery project, not an available option.
2. **Rich/animated UI, canvas, audio, rapid iteration?** → **Stack A:
   WKWebView shell** (the FlamencoCompas pattern). React-style UI in a single
   JSX file, precompiled to plain JS at build time with the system `jsc`
   running a bundled `babel.min.js`. Swift shell ≈150 lines.
3. **Native look, menus, small utility UI?** → **Stack B: pure SwiftUI**
   compiled with `swiftc` directly (no .xcodeproj). Best when the UI is
   forms/lists/controls, not custom drawing.
4. **No GUI needed?** → **Stack C: CLI tool** — single Swift file or
   python3 script; skip the app-bundle machinery.

When in doubt between A and B: A iterates faster and is fully proven
(recipes exist); B has fewer moving parts but SwiftUI-by-swiftc has sharp
edges. Default to A for anything visual.

## Step 2 — Stack A architecture (reference: FlamencoCompas-DS)

```
src/app.jsx          ← the ONLY app source (React-less JSX or vanilla+hyperscript)
vendor/babel.min.js  ← bundled, offline JSX compiler
build/jsc-shim.js    ← console/window shim so babel runs under jsc
build/jsc-transform.js
build/main.swift     ← WKWebView shell: window, app:// scheme handler, menu
build/build.sh       ← jsc-compile JSX → dist app bundle → swiftc → codesign
assets/              ← audio/images, copied into Resources/
dist/                ← build output, never edited
```

Non-negotiables for Stack A (all learned the hard way — see TROUBLESHOOTING.md):
- Serve content via a **custom `app://` scheme handler**, never `loadFileURL`
  (fetch() is dead under `file://`).
- **AudioContext created lazily** on first user gesture (`ensureGraph` pattern).
- `decodeAudioData` gets a **`.slice(0)` copy** (it detaches ArrayBuffers).
- jsc + babel needs the console/window **shim** or it throws
  `TypeError: undefined is not an object`.

## Step 3 — Build & ship pattern (Stacks A and B)

- One `build/build.sh`, exit 0 = green. It creates the full
  `dist/<Name>.app` bundle: `Contents/{MacOS,Resources}`, minimal
  `Info.plist`, `swiftc -O` compile, `codesign --force --deep -s -` (ad-hoc).
- **Universal binary**: compile per-arch (`-target arm64-apple-macos12` and
  `-target x86_64-apple-macos12`) and `lipo -create`. Do this from v1 — it
  cost a point release on FlamencoCompas.
- Quick JSX syntax check without full build:
  `"$JSC" build/jsc-shim.js vendor/babel.min.js build/jsc-transform.js > /tmp/app.js`
  (JSC = `/System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Helpers/jsc`).

## Step 4 — Project discipline

- `docs/SPEC.md` is behavior truth; `docs/DEV_PLAN.md` is the WI list the
  pipeline executes; `docs/JOURNAL.md` + `docs/MILESTONES.md` carry state
  across sessions. Templates in `templates/docs/`.
- Walking skeleton first: empty window opens → web/UI layer renders →
  one asset loads → one interaction works. Feature WIs only after the
  skeleton is verified by launching the real app.
- Versioning: `VERSION` file + CHANGELOG `[Unreleased]` bullets, rolled at
  wrap-up. Patch = fix, minor = feature.
