#!/bin/bash

# 构建所有平台的预构建文件
# 注意：这需要 Docker 支持

echo "开始构建所有平台的预构建文件..."

# 清理之前的构建
rm -rf prebuilds
mkdir -p prebuilds

# 当前平台（macOS ARM64）
echo "构建 macOS ARM64..."
npm run prebuildify:darwin-arm64

# 使用 Docker 构建其他平台
echo "使用 Docker 构建 Windows..."
docker run --rm -v "$(pwd)":/app -w /app node:18-windowsservercore bash -c "
  npm ci &&
  node scripts/build-libraw.js &&
  npm run prebuildify:windows
" || echo "Windows 构建失败，需要 Windows 环境"

echo "使用 Docker 构建 Linux..."
docker run --rm -v "$(pwd)":/app -w /app node:18-alpine bash -c "
  apk add --no-cache python3 make g++ &&
  npm ci &&
  node scripts/build-libraw.js &&
  npm run prebuildify:linux
" || echo "Linux 构建失败"

echo "构建完成！"
echo "预构建文件："
find prebuilds -name "*.node" -type f
