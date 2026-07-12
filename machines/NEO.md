# Machine — NEO

Jeremy's MacBook ("the neo"), hostname `ArcTrooper.local`. Verified 2026-07-12.

| Fact | Value |
|---|---|
| macOS | 26.5.1 (build 25F80), arm64 (Apple Silicon) |
| Xcode | **Not installed** — Command Line Tools only (`/Library/Developer/CommandLineTools`) |
| Swift | 6.3.3 (`swiftc` works; `xcodebuild` present but unusable without Xcode) |
| Node / npm | **MISSING — do not install** |
| Homebrew | `/opt/homebrew/bin/brew` (present; do not add runtime deps via it) |
| python3 | `/opt/homebrew/bin/python3` |
| jsc | `/System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Helpers/jsc` |
| git | `/usr/bin/git` |

## Probe (run on any new machine, paste results into a new machines/ file)

```sh
sw_vers; xcode-select -p; swiftc --version | head -2
for t in node npm brew python3 git; do printf '%s: %s\n' "$t" "$(command -v $t || echo MISSING)"; done
ls /System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Helpers/jsc; hostname
```

## Known quirks

- (none recorded yet — add dated entries as they're discovered)
