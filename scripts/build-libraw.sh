#!/bin/bash
set -euo pipefail

# LibRaw 构建脚本
# 确保使用 -fPIC 编译选项来支持共享对象链接

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
VERSION="${LIBRAW_VERSION:-0.21.4}"
SOURCE_DIR="$ROOT_DIR/deps/LibRaw-Source/LibRaw-${VERSION}"

echo "🔨 构建 LibRaw ${VERSION}..."
echo "================================"

# 检查源码目录是否存在
if [ ! -d "$SOURCE_DIR" ]; then
  echo "❌ LibRaw 源码目录不存在: $SOURCE_DIR"
  echo "请先运行: npm run download"
  exit 1
fi

# 设置平台和架构
PLATFORM=$(uname -s | tr '[:upper:]' '[:lower:]')
if [ "$PLATFORM" = "darwin" ]; then
  PLATFORM="darwin"
  ARCH=$(uname -m)
  if [ "$ARCH" = "arm64" ]; then
    ARCH="arm64"
  else
    ARCH="x64"
  fi
elif [ "$PLATFORM" = "linux" ]; then
  PLATFORM="linux"
  ARCH=$(uname -m)
  if [ "$ARCH" = "aarch64" ]; then
    ARCH="arm64"
  else
    ARCH="x64"
  fi
else
  echo "❌ 不支持的平台: $PLATFORM"
  exit 1
fi

echo "📋 平台: $PLATFORM"
echo "📋 架构: $ARCH"

# 进入源码目录
cd "$SOURCE_DIR"

# 生成 configure 脚本
echo "🔧 生成 configure 脚本..."
autoreconf --install

# 设置编译选项，确保使用 -fPIC
export CFLAGS="-fPIC -O2"
export CXXFLAGS="-fPIC -O2"
export LDFLAGS="-fPIC"

# 配置构建
echo "⚙️  配置 LibRaw 构建..."
./configure \
  --enable-static \
  --disable-shared \
  --disable-openmp \
  --disable-examples \
  --disable-lcms \
  --disable-jasper \
  --disable-jpeg \
  --prefix="$(pwd)/build/${PLATFORM}-${ARCH}"

# 构建
echo "🔨 编译 LibRaw..."
make -j$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

# 安装
echo "📦 安装 LibRaw..."
make install

echo "✅ LibRaw 构建完成！"
echo "📁 安装目录: $(pwd)/build/${PLATFORM}-${ARCH}"
echo "================================"
