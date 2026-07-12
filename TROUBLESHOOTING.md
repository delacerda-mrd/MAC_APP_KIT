# TROUBLESHOOTING — solved problems, symptom-indexed

Rule: search this file before debugging ANY build, WKWebView, audio, or
packaging problem. Append new entries (symptom → cause → fix + provenance)
in the same session a problem is solved.

## Build / toolchain

**Symptom:** `xcodebuild` errors about missing Xcode / "requires Xcode".
**Cause:** Only Command Line Tools installed; `xcode-select -p` →
`/Library/Developer/CommandLineTools`.
**Fix:** Never use xcodebuild or .xcodeproj. Build with `swiftc` directly in
`build/build.sh`. (FlamencoCompas-DS)

**Symptom:** Babel under jsc throws `TypeError: undefined is not an object`.
**Cause:** `babel.min.js` expects `console` and `window` globals jsc lacks.
**Fix:** Prepend a shim file defining them (`build/jsc-shim.js`) in the jsc
invocation. (FlamencoCompas-DS)

**Symptom:** App runs on Apple Silicon, "damaged"/won't run on Intel Mac.
**Cause:** Single-arch arm64 binary.
**Fix:** Compile both `-target arm64-apple-macos12` and
`-target x86_64-apple-macos12`, `lipo -create` into a universal binary.
(FlamencoCompas-DS v1.1.0)

## WKWebView

**Symptom:** `fetch()` of a bundled asset rejects/fails silently.
**Cause:** Page loaded via `file://` — fetch is blocked under file URLs.
**Fix:** Register a `WKURLSchemeHandler` for `app://` and load everything
through it. Do NOT "simplify" to `loadFileURL`. (FlamencoCompas-DS)

## Web Audio

**Symptom:** Second decode of the same ArrayBuffer throws / buffer is empty.
**Cause:** `decodeAudioData` detaches (neuters) the ArrayBuffer it's given.
**Fix:** Always pass a copy: `decodeAudioData(buf.slice(0))`. (FlamencoCompas-DS)

**Symptom:** No sound until reload, or `AudioContext was not allowed to start`.
**Cause:** AudioContext created at page load instead of after a user gesture.
**Fix:** Lazy-create on first play tap — the `ensureGraph()` pattern.
(FlamencoCompas-DS)

## Packaging / launch

**Symptom:** Freshly built .app won't open ("cannot be opened") on another Mac.
**Cause:** Missing/invalid signature or quarantine attribute.
**Fix:** `codesign --force --deep -s -` in build.sh; on the receiving Mac
`xattr -dr com.apple.quarantine <app>` if downloaded. (FlamencoCompas-DS)
