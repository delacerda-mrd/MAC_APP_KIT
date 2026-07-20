# Machine — {{NAME}}

Verified {{DATE}} (hostname `{{HOSTNAME}}`).

**Rule: one file per physical machine, named by `hostname -s`.** If a
machine's hostname changes, RENAME its file (noting the former name inside);
never add a second file for the same hardware — two files for one machine
will contradict each other (it happened: NEO.md vs ArcTrooper.md, merged
2026-07-19).

## Probe (run on any new machine, paste results into the new file)

```sh
sw_vers; xcode-select -p; swiftc --version | head -2
for t in node npm brew python3 git; do printf '%s: %s\n' "$t" "$(command -v $t || echo MISSING)"; done
ls /System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Helpers/jsc; hostname -s
```

| Fact | Value |
|---|---|
| macOS | {{VERSION}} ({{ARCH}}) |
| Xcode | {{full Xcode or CLT-only + path}} |
| Swift | {{swiftc --version}} |
| Node / npm | {{present/MISSING}} |
| Homebrew | {{path or MISSING}} |
| python3 | {{path}} |
| jsc | {{path or MISSING}} |
| git | {{path}} |

## Known quirks

- (dated entries)
