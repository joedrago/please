#!/bin/bash
# Generates AppIcon.icns from icon_1024.png
# Uses sips for resizing and iconutil for .icns creation.
set -euo pipefail

cd "$(dirname "$0")"

SOURCE="icon_1024.png"
ICONSET="AppIcon.iconset"
OUTPUT="../Sources/Please/Resources/AppIcon.icns"

if [ ! -f "$SOURCE" ]; then
    echo "Error: $SOURCE not found. Run generate-icon.swift first."
    exit 1
fi

rm -rf "$ICONSET"
mkdir -p "$ICONSET"

# Required icon sizes (points x scale)
declare -a SIZES=(
    "16:1"
    "16:2"
    "32:1"
    "32:2"
    "128:1"
    "128:2"
    "256:1"
    "256:2"
    "512:1"
    "512:2"
)

for entry in "${SIZES[@]}"; do
    pts="${entry%%:*}"
    scale="${entry##*:}"
    pixels=$((pts * scale))
    if [ "$scale" -eq 1 ]; then
        name="icon_${pts}x${pts}.png"
    else
        name="icon_${pts}x${pts}@${scale}x.png"
    fi
    sips -z "$pixels" "$pixels" "$SOURCE" --out "$ICONSET/$name" >/dev/null
done

iconutil -c icns "$ICONSET" -o "$OUTPUT"
rm -rf "$ICONSET"

echo "Generated $OUTPUT"
