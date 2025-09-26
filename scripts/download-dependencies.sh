#!/bin/bash
set -euo pipefail

# 下载 LibRaw 源码的统一脚本
# 用于本地开发和 GitHub Actions

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
echo "📦 下载 LibRaw 源码..."
echo "================================"

# 下载 LibRaw，增加重试机制
echo "🔽 下载 LibRaw 源码..."
for i in {1..3}; do
  echo "Attempt $i: Downloading LibRaw..."
  if bash "$ROOT_DIR/scripts/download-libraw.sh"; then
    echo "LibRaw download successful"
    break
  else
    if [ $i -lt 3 ]; then
      echo "Download failed, retrying in 5 seconds..."
      sleep 5
    else
      echo "LibRaw download failed after 3 attempts"
      exit 1
    fi
  fi
done

echo ""
echo "✅ LibRaw 源码下载完成！"
echo "================================"
