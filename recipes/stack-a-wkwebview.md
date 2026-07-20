# Recipe — Stack A: WKWebView shell (proven, copy verbatim)

Provenance: FlamencoCompas-DS v1.1.0 (originally `~/Claude_Code/Spencer_Compas_DS`),
working on macOS 26 / Swift 6.3 and re-verified on macOS 27 beta / Swift 6.4,
universal binary, fully offline. The kit is **self-contained**: every file a
Stack A project needs is inside `recipes/stack-a-files/` — no sibling project
directory is required. Start every Stack A project from these files, then
adapt the parameters below — do NOT rewrite them from scratch.

## Standing rule — recipes track TROUBLESHOOTING.md

When a TROUBLESHOOTING.md fix touches a recipe file, the recipe master gets
patched in the same session. A recipe that contradicts TROUBLESHOOTING.md is
a kit bug.

## Files (all in `stack-a-files/`)

Project layout they instantiate into (see PLAYBOOK.md Step 2): `build.sh`,
`jsc-shim.js`, `jsc-transform.js`, `main.swift`, `Info.plist.template` →
project `build/`; `index.html` → project `src/`; `vendor/` → project
`vendor/`. Also create a `VERSION` file (`echo 0.0.0 > VERSION`) — build.sh
reads it.

- `build.sh` — full pipeline: jsc+babel compile of `src/app.jsx`, .app bundle
  assembly, per-arch swiftc + `lipo` (with `-runtime-compatibility-version
  none`, required — see TROUBLESHOOTING.md "Build / toolchain"), ad-hoc
  codesign. **Adapt the parameter block at the top:**
  - `APPNAME` — .app name, binary name, CFBundleName (sed'd into
    Info.plist and index.html)
  - `BUNDLE_ID` — CFBundleIdentifier
  - `ASSETS` — array of bundled files copied into `Resources/` (empty for
    asset-less apps)
  - `SANITY_GREP` — string the compiled `app.js` must contain
    (`ReactDOM.createRoot` for React apps; set `""` to skip for
    non-React/vanilla-canvas apps)
- `main.swift` — WKWebView shell with the `app://` URLSchemeHandler (the
  fetch()-under-file:// fix), window, menu, quit. Adapt: window title/size,
  menu item labels, bundle resource lookups.
- `Info.plist.template` — placeholders `__APPNAME__`, `__BUNDLE_ID__`,
  `__VERSION__` are filled by build.sh. Adapt: nothing, normally.
- `index.html` — minimal skeleton loading react, react-dom, and the compiled
  `app.js` via relative URLs under the `app://` scheme; `__APPNAME__` in the
  title is filled by build.sh. Adapt: `lang` attribute (match the spec's UI
  language), extra script/style tags if the app needs them.
- `jsc-shim.js` + `jsc-transform.js` — the console/window shim and Babel
  driver for the system jsc. Use unchanged.
- `vendor/` — `babel.min.js`, `react.production.min.js`,
  `react-dom.production.min.js`, vendored into the kit with versions and
  SHA-256 hashes in `vendor/MANIFEST.md`. Copy per-project; never fetch from
  a CDN.

## In-app patterns (enforced by TROUBLESHOOTING.md)

- All resource loads through `app://` URLs.
- `AudioContext` lazy-created on first user gesture (`ensureGraph()`).
- `decodeAudioData(buf.slice(0))` — always a copy.
