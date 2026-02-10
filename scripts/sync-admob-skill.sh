#!/bin/bash
# Script đồng bộ skill admob-integration từ AdSpace-Admob-SDK

SOURCE_REPO="git@github.com:maichanchinh/AdSpace-Admob-SDK.git"
TEMP_DIR=".tmp/admob-sync"
SKILL_PATH="skills/admob-integration"

# Clone repository nguồn
echo "Đang clone repository..."
rm -rf "$TEMP_DIR"
git clone --depth 1 --branch main "$SOURCE_REPO" "$TEMP_DIR"

# Xóa skill cũ và copy mới
echo "Đang đồng bộ skill..."
rm -rf "$SKILL_PATH"
cp -r "$TEMP_DIR/.claude/skills/admob-integration" "$SKILL_PATH"

# Dọn dẹp
rm -rf "$TEMP_DIR"

echo "✓ Đồng bộ hoàn tất!"
git status "$SKILL_PATH"
