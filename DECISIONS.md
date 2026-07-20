# DECISIONS — architecture decision record for the kit itself

Why the kit is shaped the way it is. Purpose: two years (or two model
generations) from now, the WHY survives even when the WHAT has changed. One
short entry per decision, dated, newest last. Backfilled entries are marked
as such — they reconstruct reasoning from README/PLAYBOOK content and the
projects that produced it.

## ADR-1: WKWebView over SwiftUI as the default GUI stack
*(2026-07-19, backfilled — decision made during FlamencoCompas-DS, ~2026-07)*

Stack A (a ~150-line Swift shell hosting a WKWebView, with the UI written as
a single JSX file compiled offline) is the default for anything visual;
SwiftUI-by-swiftc (Stack B) is the exception for forms-and-lists utilities.
The reason is iteration speed under our constraints: without full Xcode there
is no preview canvas, no interface builder, and no incremental build — every
SwiftUI change is a full `swiftc` cycle with errors that point into generated
code. The web layer gives us layout, animation, canvas, and Web Audio for
free, with a rebuild measured in seconds, and it is fully proven end to end
(FlamencoCompas-DS ships this way, universal and offline). The cost we
accept: a WebView's memory footprint, and a JSX toolchain that leans on the
system `jsc` plus a vendored Babel. Revisit if Apple ships a usable
CLT-only SwiftUI iteration loop.

## ADR-2: No Node.js in the build, even on machines that have it
*(2026-07-19, backfilled — constraint held since the kit's first version)*

Builds use the system JavaScriptCore (`jsc`) driving a vendored
`babel.min.js` to compile JSX, never `npm`/`npx`/a bundler. ArcTrooper does
have Node installed (verified 2026-07-19) — this is a kit policy, not a
machine fact. The point is that a project must build years from now from a
bare checkout on a machine we haven't set up yet: no `node_modules` to
restore, no registry to be online for, no transitive dependency to rot or be
compromised. `jsc` ships with macOS and Babel is a single vendored file with
a recorded SHA-256 (`recipes/stack-a-files/vendor/MANIFEST.md`). The cost:
no npm ecosystem, and JSX compilation quirks we solve once and record in
TROUBLESHOOTING.md (the console/window shim, the classic-runtime flag).

## ADR-3: Ad-hoc code signing (`codesign -s -`)
*(2026-07-19, backfilled)*

Apps are signed ad-hoc, not with a Developer ID, and are not notarized.
These are personal tools distributed by hand between Jeremy's own machines;
a paid developer account and a notarization round trip would buy nothing but
latency. The cost, which is real and must stay documented: a copied .app may
need `xattr -dr com.apple.quarantine` on the receiving machine (see
TROUBLESHOOTING.md "Packaging / launch"). If an app ever needs to go to
someone else, that is the moment to revisit — not before.

## ADR-4: Universal binaries from v1
*(2026-07-19, backfilled — learned the hard way on FlamencoCompas-DS)*

Every app compiles per-arch and `lipo`s into a universal binary from the
first build, rather than adding Intel support when needed. FlamencoCompas
shipped arm64-only, failed on an Intel Mac as "damaged", and cost a point
release. Building both from the start costs a few seconds per build and
removes an entire class of "works on my machine" failure. This decision is
what makes the `-runtime-compatibility-version none` trap load-bearing (see
TROUBLESHOOTING.md) — we hit toolchain bugs in the x86_64 cross-compile that
an arm64-only project would never see, and we accept that.

## ADR-5: Model assignments are roles, bound in one file
*(2026-07-19)*

Agent frontmatter used to hardcode opus/sonnet per agent, which meant the
model strategy lived in six files and could not express "implementation may
run on an external cheap executor." `MODELS.md` is now the single registry;
frontmatter carries a concrete model (Claude Code requires one) plus a
`# role:` comment pointing back. Two consequences worth stating: the
architect model is **asked** at Phase A rather than fixed, because that
choice trades quota against plan depth and only Jeremy can price it; and
plans are written to the **cheapest** executor's capabilities, not Sonnet's,
because a plan that survives a MiMo-V2.5-class literal executor survives
anything in the rotation. The stricter bar is the point.

## ADR-6: Pipeline depth is proportional to risk; escalation ceilings are not
*(2026-07-19)*

The Phase B loop used to run implement→review→test identically for every
work item, which spent an Opus code review on one-line copy changes. Depth
is now tiered off the architect's H/M/L rating (L skips code review; H forces
the full loop plus mandatory hardware settling). What deliberately did NOT
become flexible: the 2-round plan-review and 3-round code-review ceilings,
which are the pipeline's guard against grinding, and which were working.
Every skip is journaled in one line so a bad skip is diagnosable later
instead of invisible — the paper trail is what makes the flexibility safe.

## ADR-7: Cross-kit shared core — deferred, deliberately
*(2026-07-19)*

MAC_APP_KIT and FW_PORT_KIT now duplicate several concepts: `MODELS.md`, the
orchestrator state machine and its standing rules, the TROUBLESHOOTING
symptom→cause→fix format, the wrap-up protocol, and the retro hook. The
obvious move is a shared `KIT_CORE` both kits reference. We are **not**
doing that now: with two kits the duplication is cheap to keep in sync by
hand, while extracting a core would force both kits to agree on abstractions
neither has stress-tested (firmware review deliberately runs hotter than app
review, for instance — see the two MODELS.md files). Premature extraction
would freeze the wrong shape.

**Trigger condition: when a third kit appears, extract.** At that point the
duplication stops being two-way and the shared parts will have proven which
of them are genuinely common.
