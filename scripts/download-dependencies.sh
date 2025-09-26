#!/bin/bash
set -euo pipefail

# 下载 LibRaw 源码的统一脚本
# 用于本地开发和 GitHub Actions

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
echo "📦 下载 LibRaw 源码..."
echo "================================"

# 下载 LibRaw
echo "🔽 下载 LibRaw 源码..."
bash "$ROOT_DIR/scripts/download-libraw.sh"

echo ""
echo "✅ LibRaw 源码下载完成！"
echo "================================"
