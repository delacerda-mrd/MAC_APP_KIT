# Machine — ArcTrooper

Jeremy's MacBook, hostname `ArcTrooper` (`ArcTrooper.local`). Formerly
documented as NEO — same physical machine; the NEO file is merged here.

Verification history: 2026-07-12 (as NEO.md, then macOS 26.5.1 / Swift 6.3.3);
2026-07-17 (as NEO.md, after CLT update to macOS 27 beta / Swift 6.4);
2026-07-18 (as ArcTrooper.md); **2026-07-19 (this merge, full probe re-run)**.

| Fact | Value |
|---|---|
| macOS | 27.0 (build 26A5378n), arm64 (Apple Silicon) |
| Xcode | **Not installed** — Command Line Tools only (`/Library/Developer/CommandLineTools`; `xcodebuild` unusable) |
| Swift | 6.4 (swiftlang-6.4.0.25.4, swift-driver 1.168.4) — `swiftc` works |
| Node / npm | **present** — `/opt/homebrew/bin/node`, `/opt/homebrew/bin/npm`. Kit apps must still NOT depend on Node (kit policy, not a machine fact). Earlier "MISSING" note (2026-07-12) is obsolete — Node was installed sometime before 2026-07-18. |
| Homebrew | `/opt/homebrew/bin/brew` (present; do not add runtime deps via it) |
| python3 | `/opt/homebrew/bin/python3` |
| jsc | `/System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Helpers/jsc` |
| git | `/usr/bin/git` |

## Known quirks

- 2026-07-17: after a Command Line Tools update to macOS 27 beta / Swift 6.4,
  universal (`lipo`) builds broke — the x86_64 `swiftc` link step fails with
  an undefined `__swift_FORCE_LOAD_$_swiftCompatibility56` symbol because the
  CLT's Swift back-deployment compat libs no longer ship an x86_64 slice.
  Fix: add `-runtime-compatibility-version none` to both `swiftc` invocations
  in `build.sh` (now baked into the recipe build.sh). See TROUBLESHOOTING.md
  "Build / toolchain" for detail. (found via Nancy's Menu WI-2)
