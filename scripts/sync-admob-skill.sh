#!/bin/bash
# Script đồng bộ skill adspace-integration từ AdSpace-Admob-SDK.
# Upstream vẫn có thể giữ tên admob-integration, local publish chỉ dùng adspace-integration.

SOURCE_REPO="git@github.com:maichanchinh/AdSpace-Admob-SDK.git"
TEMP_DIR=".tmp/admob-sync"
UPSTREAM_SKILL_PATH=".claude/skills/admob-integration"
PUBLISH_PATH="skills/adspace-integration"
LEGACY_PATH="skills/admob-integration"

# Clone repository nguồn
echo "Đang clone repository..."
rm -rf "$TEMP_DIR"
git clone --depth 1 --branch main "$SOURCE_REPO" "$TEMP_DIR"

# Copy skill upstream sang canonical local name
echo "Đang đồng bộ skill adspace-integration..."
rm -rf "$LEGACY_PATH"
rm -rf "$PUBLISH_PATH"
cp -r "$TEMP_DIR/$UPSTREAM_SKILL_PATH" "$PUBLISH_PATH"
perl -0pi -e 's/^name: admob-integration$/name: adspace-integration/m' "$PUBLISH_PATH/SKILL.md"

# Dọn dẹp
rm -rf "$TEMP_DIR"

echo "✓ Đồng bộ hoàn tất!"
git status "$PUBLISH_PATH"
