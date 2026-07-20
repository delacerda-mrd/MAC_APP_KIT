# KIT_CHANGELOG

Every kit-modifying session appends a dated entry here: what changed, and
which project session prompted it. Newest first.

## 2026-07-20 — Re-audit follow-up (prompted by: direct maintenance session on ArcTrooper)

13-point coherence audit of the post-overhaul kit: 12 checks passed, one
minor defect fixed.

- **TROUBLESHOOTING runtime-compat entry now points at the recipe master.**
  The entry read as an instruction to add `-runtime-compatibility-version none`
  to build.sh, but `recipes/stack-a-files/build.sh` has carried the flag since
  2026-07-19. Noted that the entry applies to pre-kit projects and any build.sh
  not generated from the recipe, so nobody re-applies it or assumes the recipe
  is stale.

## 2026-07-19 — Kit overhaul (prompted by: direct maintenance session on ArcTrooper)

Audit-driven redesign pass on the kit itself, not on any app project.

- **Audit defects fixed.** `recipes/stack-a-files/build.sh` now carries
  `-runtime-compatibility-version none` on both `swiftc` lines (it previously
  contradicted TROUBLESHOOTING.md's Nancy's Menu WI-2 entry). Added the
  standing rule that a recipe contradicting TROUBLESHOOTING.md is a kit bug.
- **Machine files merged.** `machines/NEO.md` and `machines/ArcTrooper.md`
  described the same machine and disagreed about Node. Merged into
  `machines/ArcTrooper.md` (named by `hostname -s`) with a fresh probe:
  Node/npm ARE present. `_TEMPLATE_MACHINE.md` gained the one-file-per-machine
  rule.
- **Kit is self-contained.** `Info.plist.template`, `index.html`, and
  `vendor/{babel,react,react-dom}` are now inside `recipes/stack-a-files/`
  with versions + SHA-256 in `vendor/MANIFEST.md`. Spencer_Compas_DS is
  provenance only, not a dependency. build.sh parameterized (APPNAME,
  BUNDLE_ID, ASSETS, SANITY_GREP). Verified by building a hello-world app
  from kit files only.
- **MODELS.md** added as the single role→model registry; agent frontmatter
  now carries `# role:` comments pointing at it. Mirrored into FW_PORT_KIT.
- **Architect model is asked, not assumed** — Phase A opens with
  "Fable or Opus?" every time; "whatever" → Opus.
- **Executability bar recalibrated** from "Sonnet at medium" to the cheapest
  executor in the implementer rotation (MiMo-V2.5-class). Plan reviewer gained
  a literalism check.
- **Risk-tiered pipeline depth** (L/M/H) replaces the uniform Phase B loop;
  promotion allowed with a stated reason, demotion needs Jeremy. Escalation
  ceilings unchanged. Skips are journaled.
- **Proportional verification** added to app-tester and app-debugger.
- **Games are first-class**: Stack A-G in the PLAYBOOK tree,
  `recipes/stack-a-game.md` (marked UNPROVEN where it is), SPEC §5b and a
  MILESTONES game phase.
- **Self-maintenance**: this changelog, `install.sh` pulls before installing
  and prints the installed version, `install.sh --push` one-command backup,
  secrets hygiene in `.gitignore` + README.
- **Long-term**: `DECISIONS.md` (ADR log), post-project retro hook,
  token-spend reporting, `evals/` executor benchmark, restore drill.
