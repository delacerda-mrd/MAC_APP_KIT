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
| `machines/` | Verified per-machine toolchain facts (ArcTrooper.md, template; one file per physical machine, named by `hostname -s`) |
| `recipes/` | Copy-verbatim build/config patterns |
| `flows/` | Step-by-step procedures /app routes to |
| `templates/` | Skeletons instantiated into new projects |
| `agents/` | Master copies of the `app-*` pipeline agents |
| `skills/` | Master copy of the `/app` skill |

## The agent pipeline & model assignments

Token strategy: spend the expensive model **once, up front, on the plan** so
cheap implementers can execute without exploration; spend it again only on
judgment-heavy gates (review, debugging). Effort is set per role, not
globally.

Model assignments are ROLES bound in **`MODELS.md`** (the single registry —
architect, plan-review, implementer, code-review, tester, debugger, skill).
Agent frontmatter carries a concrete model that mirrors the registry; edit
MODELS.md + frontmatter together and rerun `install.sh`. Implementation may
run on Claude models OR external cheap executors (MiMo-V2.5,
DeepSeek V4 Flash) via the multi-model pipeline; plans are therefore written
to be executable by the CHEAPEST model in the implementer rotation — a
MiMo-V2.5-class executor: excellent at literal code-gen, tool calls, and
diff discipline; weak at unstated assumptions, cross-file inference, and
recovering from ambiguity. A plan that passes that bar runs on anything.

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
