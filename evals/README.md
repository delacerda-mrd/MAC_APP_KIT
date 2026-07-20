# evals — executor evaluation harness

Purpose: before rotating a new cheap executor (the next MiMo, the next
DeepSeek, a new Claude tier) into the implementer role in `MODELS.md`, run it
against a stored, known-good work item and compare its behavior to what the
pipeline already achieved. Rotate on evidence, not on a benchmark score
someone else published.

This is a manual harness. There is no runner script and deliberately so —
the interesting signal is *how* an executor behaves (does it invent files,
does it follow a step literally when the step is slightly wrong, does it stop
and report BLOCKED or improvise), and that needs a human reading the diff.

## How to run an evaluation

1. Set up a scratch copy of the benchmark project at the parent commit of the
   stored WI, so the executor sees exactly the repo state the original
   implementer saw.
2. Give the executor the **app-implementer** agent prompt plus the stored WI
   text — nothing else. No hints, no extra context. That is the real
   condition it will work under.
3. Let it run to its own stopping point. Do not coach it.
4. Compare against `expected-diff-shape` below and score the acceptance
   checks. Then read the diff for behavior, not just correctness.
5. Record the result in the table at the bottom of this file. Only then
   consider adding it to the implementer alternates in `MODELS.md`.

## What to watch for (the reason this exists)

- **Literalism divergence** — did it follow an ambiguous step literally in a
  way that diverged from intent? (This is exactly what app-plan-reviewer's
  literalism check is meant to catch upstream; an executor that diverges here
  raises the bar for plan quality.)
- **Invention** — files, functions, or dependencies not in the plan's file
  map. Disqualifying for a WI this specified.
- **Blocked-vs-improvise** — when it hit something the WI didn't cover, did
  it stop and report, or guess? Guessing is the expensive failure mode.
- **Diff discipline** — minimal scoped changes, or drive-by refactors.
- **Kit-trap compliance** — did it honor the recorded patterns (`app://`
  scheme, `.slice(0)` decode, lazy AudioContext, no CDN, no Node)?

## Benchmark task 1 — Nancy's Menu WI-3 (JS↔Swift bridge)

**Source:** `~/Claude_Code/nancys_menu`, commit `7a367fe` ("WI-3: JS↔Swift
bridge"), completed 2026-07-17, human-verified. Chosen because it is
self-contained, has a crisp observable acceptance criterion, and contains one
genuine trap (the `evaluateJavaScript` escaping) that a weak executor gets
wrong in a visible way.

**Setup:** `git clone` the project to a scratch dir, `git checkout 7a367fe~1`.

**Plan excerpt given to the executor** — the WI verbatim from
`docs/DEV_PLAN.md` at that commit:

> ### WI-3: Swift bridge — persistence + network commands
> - **Files:** `build/main.swift`, `src/app.jsx` (tiny test hook)
> - **Steps:**
>   1. In `main.swift`, create the data dirs at launch:
>      `FileManager.default.urls(for: .applicationSupportDirectory, ...)` +
>      `NancysMenu/recipes` and `NancysMenu/images`.
>   2. Add a `Bridge: NSObject, WKScriptMessageHandler` class implementing the
>      five commands from Architecture decision 1 exactly (ids, reply shape,
>      timeout, User-Agent). Register with
>      `config.userContentController.add(bridge, name: "bridge")`. All file I/O
>      on a background queue; `evaluateJavaScript` replies dispatched to main.
>   3. Extend `AppSchemeHandler` per Architecture decision 3 (`/userimage/`
>      paths → Application Support images dir).
>   4. In `app.jsx`, add the bridge client (`pending` map, `__bridgeReply`,
>      `bridge.call`) and a temporary self-test on mount: `save` a dummy
>      recipe → `loadAll` → render the count on screen → `delete` it.
>   5. Build, launch, verify the self-test shows a round-trip. Then remove the
>      dummy-save part of the self-test but KEEP `loadAll`-on-mount.
> - **Depends on:** WI-2
> - **Accept:** launching the app shows recipe count loaded from disk; a
>   manually placed valid JSON file in `recipes/` appears in the count after
>   relaunch.
> - **Risk:** M — evaluateJavaScript escaping. Escape the JSON payload by
>   JSON-encoding the string itself (encode-twice trick) rather than manual
>   quoting.

(Architecture decisions 1 and 3, referenced above, must also be supplied —
they are in `docs/DEV_PLAN.md` §3 at the same commit.)

**Expected diff shape** (the reference run — not a target to match line for
line, but a scale check):

| File | Change |
|---|---|
| `build/main.swift` | ~+224 lines: Bridge class, 5 commands, dirs at launch, scheme handler extension |
| `src/app.jsx` | ~+40 lines: pending map, `__bridgeReply`, `bridge.call`, mount self-test |
| `CHANGELOG.md`, `docs/*` | small bookkeeping edits |

A run that touches other source files, or that lands wildly outside this
scale, is a finding regardless of whether it works.

**Acceptance checks:**

1. `bash build/build.sh` exits 0.
2. `lipo -archs` on the built binary reports both `x86_64` and `arm64`.
3. App launches; the mount self-test displays a recipe count.
4. A hand-placed valid `recipes/<uuid>.json` is reflected in the count after
   relaunch; removing it drops the count.
5. The JSON payload crossing `evaluateJavaScript` is escaped by JSON-encoding
   the string (the encode-twice trick), NOT by manual quote-escaping. Check
   this by reading the code — a manual-escaping implementation can pass 1–4
   and still break on a recipe containing a quote or newline.
6. No new runtime dependencies, no CDN URLs, no Node.

Check 5 is the discriminating one. An executor that passes 1–4 but fails 5
looks fine until real data arrives.

## Results

| Date | Executor | Checks passed | Behavior notes | Rotated in? |
|---|---|---|---|---|
| 2026-07-17 | sonnet / medium (reference run) | 6/6 | Original pipeline run; human-verified counts 1/2/0 across relaunches | already default |
| | | | | |
