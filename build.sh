#!/usr/bin/env bash
set -euo pipefail

TOML_FILE="gradle/libs.versions.toml"

# Extract current version code from libs.versions.toml
CURRENT_CODE=$(grep -E '^appVersionCode = ' "$TOML_FILE" | sed -E 's/.*"([^"]+)".*/\1/')

VERSION_CODE="${1:-}"

if [ -z "$VERSION_CODE" ]; then
    read -rp "Enter version code (current: ${CURRENT_CODE}): " VERSION_CODE
fi

if [ -n "$VERSION_CODE" ]; then
    if ! [[ "$VERSION_CODE" =~ ^[0-9]+$ ]]; then
        echo "Error: Version code must be a positive integer." >&2
        exit 1
    fi
    sed -i "s/^appVersionCode = \".*\"/appVersionCode = \"$VERSION_CODE\"/" "$TOML_FILE"
    echo "Updated appVersionCode to $VERSION_CODE in $TOML_FILE"
fi

nix-shell --run "./gradlew :app:assembleFdroidRelease"

OUTPUT_DIR="$(pwd)/app/build/outputs/apk/fdroid/release"
echo ""
echo "Output APK directory:"
echo "$OUTPUT_DIR"
if ls "$OUTPUT_DIR"/*.apk 1> /dev/null 2>&1; then
    echo ""
    echo "Output APK file(s):"
    ls -1 "$OUTPUT_DIR"/*.apk
fi
