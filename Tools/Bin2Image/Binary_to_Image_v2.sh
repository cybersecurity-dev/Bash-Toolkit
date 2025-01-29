#!/bin/bash

# Required commands: od, convert
if ! command -v od &>/dev/null || ! command -v convert &>/dev/null; then
    echo "Required tools (od, convert) are not installed. Please install them first."
    exit 1
fi

# Input file and target size
BINARY_FILE="$1"
TARGET_SIZE=$((256 * 256))  # Target size in bytes for 256x256 image
OUTPUT_IMAGE="output.png"

if [ -z "$BINARY_FILE" ]; then
    echo "Usage: $0 <binary_file>"
    exit 1
fi

if [ ! -f "$BINARY_FILE" ]; then
    echo "File not found: $BINARY_FILE"
    exit 1
fi

# Read binary data and adjust size
TEMP_FILE="temp_binary_data.dat"
dd if="$BINARY_FILE" of="$TEMP_FILE" bs=1 count=$TARGET_SIZE 2>/dev/null  # Truncate
if [ $(stat -c%s "$TEMP_FILE") -lt $TARGET_SIZE ]; then
    # Pad if necessary
    dd if=/dev/zero bs=1 count=$((TARGET_SIZE - $(stat -c%s "$TEMP_FILE"))) >> "$TEMP_FILE" 2>/dev/null
fi

# Create the image (grayscale, 8-bit depth)
convert -size 256x256 -depth 8 gray:"$TEMP_FILE" "$OUTPUT_IMAGE"

# Cleanup
rm "$TEMP_FILE"

echo "Generated $OUTPUT_IMAGE"
