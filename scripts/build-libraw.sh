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
  
  # 修复 macOS 上的 libtool 路径问题
  if command -v brew >/dev/null 2>&1; then
    if [ -d "/opt/homebrew/opt/libtool/libexec/gnubin" ]; then
      export PATH="/opt/homebrew/opt/libtool/libexec/gnubin:$PATH"
      echo "🔧 修复 libtool 路径: $(which libtool)"
    fi
  fi
elif [ "$PLATFORM" = "linux" ]; then
  PLATFORM="linux"
  ARCH=$(uname -m)
  if [ "$ARCH" = "aarch64" ]; then
    ARCH="arm64"
  else
    ARCH="x64"
  fi
elif [[ "$PLATFORM" == *"mingw"* ]] || [[ "$PLATFORM" == *"msys"* ]] || [[ "$PLATFORM" == *"cygwin"* ]]; then
  PLATFORM="windows"
  ARCH="x64"
else
  echo "❌ 不支持的平台: $PLATFORM"
  exit 1
fi

echo "📋 平台: $PLATFORM"
echo "📋 架构: $ARCH"

# 进入源码目录
cd "$SOURCE_DIR"

# 检查并使用 configure 脚本
if [ ! -f "./configure" ]; then
  echo "🔧 生成 configure 脚本..."
  autoreconf --install
else
  echo "✅ 使用预生成的 configure 脚本"
fi

# 设置编译选项，确保使用 -fPIC
export CFLAGS="-fPIC -O2"
export CXXFLAGS="-fPIC -O2"
export LDFLAGS="-fPIC"

# 配置构建
echo "⚙️  配置 LibRaw 构建..."
CONFIGURE_OPTS="--enable-static --disable-shared --disable-openmp --disable-examples --disable-lcms --disable-jasper --disable-jpeg"

# 为 macOS 添加额外优化
if [ "$PLATFORM" = "darwin" ]; then
  CONFIGURE_OPTS="$CONFIGURE_OPTS --disable-djpeg --disable-thumbnail"
  echo "🍎 macOS 优化: 禁用额外功能以减少编译时间"
fi

./configure $CONFIGURE_OPTS --prefix="$(pwd)/build/${PLATFORM}-${ARCH}"

# 构建
echo "🔨 编译 LibRaw..."
# 使用较少的并行任务以避免资源限制
JOBS=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
# 限制最大并行任务数
if [ "$JOBS" -gt 4 ]; then
  JOBS=4
fi
echo "📊 使用 $JOBS 个并行任务进行编译..."

# 添加构建状态监控
echo "⏰ 开始时间: $(date)"
if ! make -j$JOBS; then
  echo "❌ 编译失败，尝试使用单线程编译..."
  if ! make -j1; then
    echo "❌ 单线程编译也失败，请检查错误信息"
    exit 1
  fi
fi
echo "⏰ 编译完成时间: $(date)"

# 安装
echo "📦 安装 LibRaw..."
make install

echo "✅ LibRaw 构建完成！"
echo "📁 安装目录: $(pwd)/build/${PLATFORM}-${ARCH}"
echo "================================"
