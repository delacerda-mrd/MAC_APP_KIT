#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

# ---- Adapt per project (see recipes/stack-a-wkwebview.md "adapt" list) ----
APPNAME="MyApp"                      # .app / binary / CFBundleName
BUNDLE_ID="es.jeremy.myapp"          # CFBundleIdentifier
ASSETS=()                            # files copied into Resources/, e.g. (assets/claras.m4a assets/sordas.m4a)
SANITY_GREP="ReactDOM.createRoot"    # compiled app.js must contain this; set "" to skip (non-React apps)
# ---------------------------------------------------------------------------

VERSION=$(cat VERSION)
JSC=/System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Helpers/jsc
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
if [ -n "$SANITY_GREP" ] && ! grep -q "$SANITY_GREP" "$APPRES/app.js"; then
  echo "ERROR: compiled app.js does not contain $SANITY_GREP"
  exit 1
fi
echo "  JSX compiled OK ($(wc -c < "$APPRES/app.js") bytes)"

# 3. Compile Swift as a universal binary (Apple Silicon + Intel)
# The runtime-compatibility flag on both swiftc lines is REQUIRED: on newer
# CLT (macOS 27 beta / Swift 6.4) the Swift back-deploy compat libs ship
# without an x86_64 slice and the x86_64 link fails (undefined
# __swift_FORCE_LOAD_$_swiftCompatibility56). See MAC_APP_KIT/TROUBLESHOOTING.md
# "Build / toolchain". Do NOT remove.
swiftc -O -target arm64-apple-macos12.0  -runtime-compatibility-version none build/main.swift -o "$APPMAC/$APPNAME.arm64"
swiftc -O -target x86_64-apple-macos12.0 -runtime-compatibility-version none build/main.swift -o "$APPMAC/$APPNAME.x86_64"
lipo -create "$APPMAC/$APPNAME.arm64" "$APPMAC/$APPNAME.x86_64" -output "$APPMAC/$APPNAME"
rm -f "$APPMAC/$APPNAME.arm64" "$APPMAC/$APPNAME.x86_64"
echo "  Swift compiled OK ($(lipo -archs "$APPMAC/$APPNAME"))"

# 4. Copy resources
sed "s/__APPNAME__/$APPNAME/g" src/index.html > "$APPRES/index.html"
cp vendor/react.production.min.js "$APPRES/"
cp vendor/react-dom.production.min.js "$APPRES/"
for asset in ${ASSETS[@]+"${ASSETS[@]}"}; do
  cp "$asset" "$APPRES/"
done

# 5. Info.plist from template
sed -e "s/__VERSION__/$VERSION/g" -e "s/__APPNAME__/$APPNAME/g" -e "s/__BUNDLE_ID__/$BUNDLE_ID/g" \
  build/Info.plist.template > "$APPDIR/Contents/Info.plist"

# 6. Ad-hoc code sign
codesign --force -s - "$APPDIR"
echo "  Code signed OK"

echo "=== Built ${APPNAME}.app v${VERSION} ==="
