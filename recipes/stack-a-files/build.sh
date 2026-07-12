#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

VERSION=$(cat VERSION)
JSC=/System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Helpers/jsc
APPNAME="FlamencoCompas-DS"
APPDIR="dist/${APPNAME}.app"
APPRES="$APPDIR/Contents/Resources"
APPMAC="$APPDIR/Contents/MacOS"

echo "=== Building ${APPNAME} v${VERSION} ==="

# 1. Clean and create bundle skeleton
rm -rf "$APPDIR"
mkdir -p "$APPRES" "$APPMAC"

# 2. Stamp version into a temp copy of app.jsx, then compile with jsc
TMP_JSX=$(mktemp -t app-jsx)
sed "s/__APP_VERSION__/$VERSION/" src/app.jsx > "$TMP_JSX"

# Generate a jsc runner that reads the version-stamped source
TMP_JSC=$(mktemp -t jsc-runner)
cat > "$TMP_JSC" << JSCEOF
var src = readFile("$TMP_JSX");
try {
  print(Babel.transform(src, { presets: [["react", { runtime: "classic" }]] }).code);
} catch (e) {
  debug ? debug(e.message) : 0;
  quit(1);
}
JSCEOF

"$JSC" build/jsc-shim.js vendor/babel.min.js "$TMP_JSC" > "$APPRES/app.js"
rm -f "$TMP_JSX" "$TMP_JSC"

# Sanity check
if [ ! -s "$APPRES/app.js" ]; then
  echo "ERROR: JSX compile produced empty output"
  exit 1
fi
if ! grep -q "ReactDOM.createRoot" "$APPRES/app.js"; then
  echo "ERROR: compiled app.js does not contain ReactDOM.createRoot"
  exit 1
fi
echo "  JSX compiled OK ($(wc -c < "$APPRES/app.js") bytes)"

# 3. Compile Swift as a universal binary (Apple Silicon + Intel)
swiftc -O -target arm64-apple-macos12.0  build/main.swift -o "$APPMAC/$APPNAME.arm64"
swiftc -O -target x86_64-apple-macos12.0 build/main.swift -o "$APPMAC/$APPNAME.x86_64"
lipo -create "$APPMAC/$APPNAME.arm64" "$APPMAC/$APPNAME.x86_64" -output "$APPMAC/$APPNAME"
rm -f "$APPMAC/$APPNAME.arm64" "$APPMAC/$APPNAME.x86_64"
echo "  Swift compiled OK ($(lipo -archs "$APPMAC/$APPNAME"))"

# 4. Copy resources
cp src/index.html "$APPRES/"
cp vendor/react.production.min.js "$APPRES/"
cp vendor/react-dom.production.min.js "$APPRES/"
cp assets/claras.m4a "$APPRES/"
cp assets/sordas.m4a "$APPRES/"

# 5. Info.plist from template
sed "s/__VERSION__/$VERSION/" build/Info.plist.template > "$APPDIR/Contents/Info.plist"

# 6. Ad-hoc code sign
codesign --force -s - "$APPDIR"
echo "  Code signed OK"

echo "=== Built ${APPNAME}.app v${VERSION} ==="
