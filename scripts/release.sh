#!/usr/bin/env bash
set -euo pipefail
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode-beta.app/Contents/Developer}"
VERSION="${1:?usage: release.sh vX.Y.Z}"
DESC="A terminal for Ainkrad — blocks, themes, SwiftTerm-backed."
AUTHOR="Ahmed M. Elhalaby"
LONG_DESC="AinkradTerminal brings a full terminal into Ainkrad's workspace: block-based command history, theme-matched colors driven by the host's DesignTokens, and a SwiftTerm-backed emulator underneath. Split panes, resize freely, and switch themes without losing your scroll history."

xcodegen generate
xcodebuild -scheme TerminalPlugin -configuration Release -derivedDataPath build -destination 'platform=macOS' build
BUNDLE="build/Build/Products/Release/TerminalPlugin.bundle"

rm -rf dist && mkdir -p dist
# Archive the bundle so the extracted tree contains TerminalPlugin.bundle at its root
# (PluginInstaller accepts root-is-bundle and .bundle-child layouts).
/usr/bin/ditto -c -k --keepParent "$BUNDLE" dist/terminal.bundle.zip
SHA="$(shasum -a 256 dist/terminal.bundle.zip | awk '{print $1}')"

cat > dist/ainkrad-plugin.json <<JSON
{ "id": "terminal", "name": "Terminal", "icon": "terminal", "description": "$DESC", "apiVersion": 6, "sha256": "$SHA",
  "author": "$AUTHOR", "longDescription": "$LONG_DESC", "screenshots": ["https://raw.githubusercontent.com/AhmedMElhalaby/AinkradTerminal/master/screenshots/terminal-1.png"], "links": [] }
JSON

gh release create "$VERSION" dist/ainkrad-plugin.json dist/terminal.bundle.zip \
  --title "Terminal $VERSION" --notes "Ainkrad Terminal plugin $VERSION"
echo "Released $VERSION (sha256 $SHA)"
