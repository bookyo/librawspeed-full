#!/bin/bash
set -euo pipefail

# 下载所有依赖源码的统一脚本
# 用于本地开发和 GitHub Actions

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
echo "📦 下载项目依赖源码..."
echo "================================"

# 下载 lcms2
echo "🔽 下载 lcms2 源码..."
bash "$ROOT_DIR/scripts/download-lcms2.sh"

# 下载 LibRaw
echo "🔽 下载 LibRaw 源码..."
bash "$ROOT_DIR/scripts/download-libraw.sh"

echo ""
echo "✅ 所有依赖源码下载完成！"
echo "================================"
