# MAC_APP_KIT

Single source of truth for building macOS apps with Claude Code on Jeremy's
Macs — the same pipeline discipline as `FW_PORT_KIT`, adapted for desktop
apps built **without full Xcode and without Node.js** (swiftc CLI builds,
optional WKWebView/JS front ends compiled with the system `jsc` + bundled
Babel, as proven by FlamencoCompas-DS).

## Entry point

Type **`/app`** in any project folder. It detects the folder state (new /
in-flight / bootstrapped) and routes to the right flow in `flows/`.
Say **"wrap it up"** anytime to save the session (protocol lives in each
project's CLAUDE.md).

## Layout

| Path | What it is |
|---|---|
| `PLAYBOOK.md` | Stack decision tree + build patterns (read before planning) |
| `TROUBLESHOOTING.md` | Symptom-indexed solved problems — never re-derive these |
| `machines/` | Verified per-machine toolchain facts (NEO.md, template) |
| `recipes/` | Copy-verbatim build/config patterns |
| `flows/` | Step-by-step procedures /app routes to |
| `templates/` | Skeletons instantiated into new projects |
| `agents/` | Master copies of the `app-*` pipeline agents |
| `skills/` | Master copy of the `/app` skill |

## The agent pipeline & model assignments

Token strategy: spend the expensive model **once, up front, on the plan** so
the cheap workhorse (Sonnet) can implement without exploration; spend it
again only on judgment-heavy gates (review, debugging). Effort is set per
agent, not globally.

| Agent | Model / effort | Why |
|---|---|---|
| app-architect | opus / high | Runs 1–2× per project. Plan quality is what makes Sonnet cheap downstream — every WI must be executable without re-derivation. |
| app-plan-reviewer | sonnet / high | Checklist-driven ambiguity hunt over one doc; small context, high thinking is cheap here. |
| app-implementer | **sonnet / medium** | The workhorse, most invocations. The plan carries the intelligence; medium effort keeps per-WI cost low. |
| app-code-reviewer | opus / medium | Catching subtle correctness bugs needs ability more than long deliberation on a scoped diff. |
| app-tester | sonnet / low | Mechanical: build, launch, write the human test procedure. |
| app-debugger | opus / high | Rare, hardest cognitive task; worth full spend when invoked. |

The main session is the **orchestrator** (`agents/ORCHESTRATOR_PROMPT.md`):
it sequences agents, distills context between them (never pastes whole
transcripts), does git and journal — it does not write app code itself.

## Install / update

```sh
bash ~/Claude_Code/MAC_APP_KIT/install.sh
```

Copies `agents/app-*.md` → `~/.claude/agents/` and `skills/app` →
`~/.claude/skills/app`. Idempotent; rerun after editing masters.

## Keeping the kit alive

Same rule as FW_PORT_KIT: a problem solved in a project session that isn't
in `TROUBLESHOOTING.md` gets appended there (symptom → cause → fix, with the
project named as provenance) in the same session. Durable machine facts go
in `machines/<name>.md`. Gaps in an agent get fixed in `agents/` masters,
then `install.sh` rerun.
