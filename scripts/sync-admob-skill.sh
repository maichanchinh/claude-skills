#!/bin/bash
# Script đồng bộ skill admob-integration từ AdSpace-Admob-SDK
# và tạo thêm bản publish adspace-integration không phụ thuộc symlink.

SOURCE_REPO="git@github.com:maichanchinh/AdSpace-Admob-SDK.git"
TEMP_DIR=".tmp/admob-sync"
SKILL_PATH="skills/admob-integration"
ALIAS_PATH="skills/adspace-integration"

# Clone repository nguồn
echo "Đang clone repository..."
rm -rf "$TEMP_DIR"
git clone --depth 1 --branch main "$SOURCE_REPO" "$TEMP_DIR"

# Xóa skill cũ và copy mới
echo "Đang đồng bộ skill..."
rm -rf "$SKILL_PATH"
cp -r "$TEMP_DIR/.claude/skills/admob-integration" "$SKILL_PATH"

# Tạo bản publish adspace-integration bằng copy thật để marketplace upload được.
echo "Đang tạo skill alias adspace-integration..."
rm -rf "$ALIAS_PATH"
cp -r "$SKILL_PATH" "$ALIAS_PATH"
perl -0pi -e 's/^name: admob-integration$/name: adspace-integration/m' "$ALIAS_PATH/SKILL.md"

# Dọn dẹp
rm -rf "$TEMP_DIR"

echo "✓ Đồng bộ hoàn tất!"
git status "$SKILL_PATH" "$ALIAS_PATH"
