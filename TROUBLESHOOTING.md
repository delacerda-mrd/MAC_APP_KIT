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

**Symptom:** Compiled JSX throws `SyntaxError: Unexpected token 'import'` /
`Cannot use import statement` in the WKWebView.
**Cause:** Babel's automatic JSX runtime emits ESM `import` statements, which
don't work with UMD React loaded via script tags.
**Fix:** Force the classic runtime in the Babel transform options
(`runtime: "classic"` — see `build/jsc-transform.js`). (FlamencoCompas-DS)

**Symptom:** App runs on Apple Silicon, "damaged"/won't run on Intel Mac.
**Cause:** Single-arch arm64 binary.
**Fix:** Compile both `-target arm64-apple-macos12` and
`-target x86_64-apple-macos12`, `lipo -create` into a universal binary.
(FlamencoCompas-DS v1.1.0)

**Symptom:** Universal build's x86_64 `swiftc` link step fails with
`Undefined symbols for architecture x86_64: "__swift_FORCE_LOAD_$_swiftCompatibility56"`
(plus warnings that `libswiftCompatibility56.a`/`libswiftCompatibilityPacks.a`
are "fat file missing arch 'x86_64'").
**Cause:** On newer Command Line Tools/SDKs (seen on macOS 27 beta,
Swift 6.4 CLT), Apple ships the Swift back-deployment compatibility static
libs without an x86_64 slice, so the x86_64 cross-compile fails at link time
even though the arm64 build is fine. Reproduced on the stock, unmodified
`stack-a-files/build.sh`/`main.swift` (FlamencoCompas-DS's own build.sh also
fails identically on this toolchain).
**Fix:** Add `-runtime-compatibility-version none` to BOTH `swiftc` invocations
in `build.sh` (arm64 and x86_64 targets) — this skips linking the back-deploy
compatibility shims that are missing an x86_64 slice. Verified both arch
slices still compile and `lipo -create` produces a working universal binary.
(Nancy's Menu WI-2, machine ArcTrooper — then documented as NEO — after a
Command Line Tools update to macOS 27 beta / Swift 6.4 — see
`machines/ArcTrooper.md`.)

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
