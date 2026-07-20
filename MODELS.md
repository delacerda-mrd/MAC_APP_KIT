# MODELS.md — single model registry for the pipeline

Model assignments are ROLES, bound here and nowhere else. Agent files keep a
concrete `model:` in frontmatter (Claude Code requires one) plus a
`# role: <role> — binding governed by MODELS.md` comment; when this table
changes, update the affected agents' frontmatter to match and rerun
`install.sh` to propagate. Implementation may also run on external cheap
executors via the multi-model pipeline — those never appear in frontmatter,
only here.

| Role        | Default binding      | Allowed alternates                                | Notes |
|-------------|----------------------|---------------------------------------------------|-------|
| architect   | ASK (fable \| opus)  | —                                                 | The orchestrator asks at Phase A start, every time; "whatever" → opus. Frontmatter carries `opus` as the concrete default. |
| plan-review | sonnet / high        | haiku / high for small plans                      | |
| implementer | sonnet / medium      | mimo-v2.5, deepseek-v4-flash (external pipeline)  | Plans must clear the cheapest-executor bar below. |
| code-review | opus / medium        | sonnet / high for M-tier WIs (per tier rules)     | Adjusted from the original "for L-risk WIs": under the risk-tier rules (ORCHESTRATOR_PROMPT Phase B), L-tier WIs skip the code-reviewer entirely, so the cheap alternate can only ever apply to M-tier. |
| tester      | haiku / low          | sonnet / low if flaky                             | Mechanical work (build, bundle checks, numbered procedures). If haiku misreads build output or produces sloppy procedures, switch to the alternate and note it here with a date. |
| debugger    | opus / high          | fable / high if opus stalls twice                 | |
| skill (/app)| cheapest capable Claude model | —                                        | Routing logic only; see the skill-economy note in skills/app/SKILL.md. |

## The executability bar (cheapest executor)

Plans are written to be **executable by the CHEAPEST model in the
implementer rotation** — currently assume a MiMo-V2.5-class executor:
excellent at literal code-gen, tool calls, and diff discipline; weak at
unstated assumptions, cross-file inference, and recovering from ambiguity.
This is a stricter bar than "executable by Sonnet", deliberately: a plan
that passes it runs on anything in the rotation.

## Rotating in a new external executor

Before adding an executor to the implementer alternates, run it against the
stored benchmark WI in `evals/` and compare behavior. Only then list it here.
