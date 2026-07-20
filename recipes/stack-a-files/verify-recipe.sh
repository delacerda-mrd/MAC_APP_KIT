#!/usr/bin/env bash
# Verify the Stack A recipe is self-contained: every file build.sh needs from
# the kit exists here, and the vendored libs match vendor/MANIFEST.md.
# Run after touching the recipe. Exit 0 = the recipe can bootstrap a project.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

fail=0
check() { if [ -e "$1" ]; then echo "  OK      $1"; else echo "  MISSING $1"; fail=1; fi; }

echo "Kit-supplied files build.sh references:"
for f in build.sh jsc-shim.js jsc-transform.js main.swift Info.plist.template \
         index.html vendor/babel.min.js vendor/react.production.min.js \
         vendor/react-dom.production.min.js vendor/MANIFEST.md; do
  check "$f"
done

# Project-supplied, correctly absent here: src/app.jsx, VERSION, ASSETS[].

echo
echo "Vendored lib integrity vs MANIFEST.md:"
while read -r sum file; do
  name="$(basename "$file")"
  if grep -q "$sum" vendor/MANIFEST.md; then
    echo "  OK      $name"
  else
    echo "  HASH MISMATCH — $name is not the version MANIFEST.md records"
    fail=1
  fi
done < <(shasum -a 256 vendor/*.js)

echo
if [ $fail -eq 0 ]; then
  echo "RESULT: recipe is self-contained and vendored libs match the manifest."
else
  echo "RESULT: FAILED — see above."
fi
exit $fail
