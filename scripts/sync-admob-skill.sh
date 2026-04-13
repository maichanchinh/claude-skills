#!/bin/bash
# Script đồng bộ skill gốc adspace-integration từ AdSpace-Admob-SDK.

SOURCE_REPO="git@github.com:maichanchinh/AdSpace-Admob-SDK.git"
TEMP_DIR=".tmp/admob-sync"
UPSTREAM_SKILL_PATH=".agents/skills/adspace-integration"
PUBLISH_PATH="skills/adspace-integration"
LEGACY_PATH="skills/admob-integration"

# Clone repository nguồn
echo "Đang clone repository..."
rm -rf "$TEMP_DIR"
git clone --depth 1 --branch main "$SOURCE_REPO" "$TEMP_DIR"

# Copy skill upstream sang local publish path
echo "Đang đồng bộ skill adspace-integration..."
rm -rf "$LEGACY_PATH"
rm -rf "$PUBLISH_PATH"
cp -r "$TEMP_DIR/$UPSTREAM_SKILL_PATH" "$PUBLISH_PATH"

# Dọn dẹp
rm -rf "$TEMP_DIR"

echo "✓ Đồng bộ hoàn tất!"
git status "$PUBLISH_PATH"
