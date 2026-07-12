# Recipe — Stack A: WKWebView shell (proven, copy verbatim)

Source of these files: FlamencoCompas-DS v1.1.0
(`~/Claude_Code/Spencer_Compas_DS`), working on macOS 26 / Swift 6.3,
universal binary, fully offline. Start every Stack A project from
`recipes/stack-a-files/`, then adapt names/assets — do NOT rewrite them
from scratch.

## Files

- `stack-a-files/build.sh` — full pipeline: jsc+babel compile of
  `src/app.jsx`, .app bundle assembly, per-arch swiftc + `lipo`, ad-hoc
  codesign. Adapt: app name, bundle id, asset copy list.
- `stack-a-files/main.swift` — WKWebView shell with the `app://`
  URLSchemeHandler (the fetch()-under-file:// fix), window, menu, quit.
  Adapt: window title/size, bundle resource lookups.
- `stack-a-files/jsc-shim.js` + `jsc-transform.js` — the console/window shim
  and Babel driver for the system jsc. Use unchanged.

## Also needed

- `vendor/babel.min.js` — copy from
  `~/Claude_Code/Spencer_Compas_DS/vendor/babel.min.js` (offline JSX
  compiler; ~2 MB, bundled per-project, never fetched from a CDN).

## In-app patterns (enforced by TROUBLESHOOTING.md)

- All resource loads through `app://` URLs.
- `AudioContext` lazy-created on first user gesture (`ensureGraph()`).
- `decodeAudioData(buf.slice(0))` — always a copy.
