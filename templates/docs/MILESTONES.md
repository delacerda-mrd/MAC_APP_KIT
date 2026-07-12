# MILESTONES — {{APP_NAME}}

Tick an item ONLY when verified by using the built app (compiling is not
verification). Trim/extend this list to match the spec before first commit.

## Phase 1 — Walking skeleton
- [ ] `build/build.sh` exits 0 and produces `dist/{{APP_NAME}}.app`
- [ ] App launches to a window; no crash log
- [ ] UI layer renders (Stack A: JSX compiled + served via app:// scheme)
- [ ] One bundled asset loads and is used
- [ ] One user interaction produces its specified effect
- [ ] Universal binary confirmed (`lipo -archs` → x86_64 arm64) {{if required}}

## Phase 2 — Features
{{One line per SPEC §2 capability, added when trimming this template}}
- [ ] …

## Phase 3 — Ship quality
- [ ] All SPEC §5 targets measured and met
- [ ] Persistence survives relaunch {{if applicable}}
- [ ] Runs from a fresh copy on a second machine {{if required}}
- [ ] Offline check: no network access attempted (no CDN, no fetch of remote URLs)
