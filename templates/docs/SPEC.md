# SPEC — {{APP_NAME}}

Behavior truth for this app. The plan (DEV_PLAN.md) implements THIS document;
if reality diverges, this file gets updated in the same session.

## 1. What it does

{{One paragraph. What the app is, for whom, the core loop of using it.}}

## 2. Screens & states

{{Every screen/mode. For each: what's visible, what every control does,
how you get in and out of it.}}

## 3. Assets & data

- Bundled assets: {{audio/images/fonts, formats, approx sizes}}
- Persistence: {{what survives relaunch, where (UserDefaults/localStorage/files)}}

## 4. UI language & text

Language: {{e.g. Spanish}}. {{Any fixed terminology.}}

## 5. Targets (numbers, not adjectives)

- {{e.g. audio scheduling jitter < 10 ms; launch < 2 s; bundle < 50 MB}}

## 6. Platform requirements

- Machines/arch: {{arm64 only, or universal}}; min macOS {{12}}
- Fully offline; no runtime dependencies beyond the OS

## 7. Out of scope

- {{explicitly not building}}

## 8. Open questions

- OQ-1: {{unresolved — never answered by assumption}}
