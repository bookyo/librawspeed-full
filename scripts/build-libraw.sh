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
elif [[ "$PLATFORM" == *"mingw"* ]] || [[ "$PLATFORM" == *"msys"* ]] || [[ "$PLATFORM" == *"cygwin"* ]] || [[ "$PLATFORM" == *"win32"* ]]; then
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
CONFIGURE_OPTS="--enable-static --disable-shared --disable-openmp --disable-examples --disable-lcms --disable-jasper"

# 为不同平台添加优化
if [ "$PLATFORM" = "darwin" ]; then
  # macOS 只禁用真正不必要的功能
  CONFIGURE_OPTS="$CONFIGURE_OPTS --disable-thumbnail"
  echo "🍎 macOS 优化: 禁用缩略图生成以减少构建时间"
  echo "   保留的功能: dcraw 兼容性, rawspeed 解码器, jpeg 支持"
elif [ "$PLATFORM" = "windows" ]; then
  # Windows 只禁用真正不必要的功能
  CONFIGURE_OPTS="$CONFIGURE_OPTS --disable-thumbnail"
  echo "🪟 Windows 优化: 禁用缩略图生成以减少构建时间"
  echo "   保留的功能: dcraw 兼容性, rawspeed 解码器, jpeg 支持"
  echo "   使用 MSVC 编译器"
fi

./configure $CONFIGURE_OPTS --prefix="$(pwd)/build/${PLATFORM}-${ARCH}"

# 构建
echo "🔨 编译 LibRaw..."

# 检测实际硬件规格并保守配置
ACTUAL_CORES=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
ACTUAL_MEMORY=$(free -m 2>/dev/null | awk '/^Mem:/{print $2}' || sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1024/1024)}' || echo 4096)

echo "🖥️  实际硬件规格:"
echo "  CPU 核心数: $ACTUAL_CORES"
echo " 内存大小: ${ACTUAL_MEMORY}MB"

# 保守的并行任务配置，避免资源竞争
if [ "$ACTUAL_MEMORY" -gt 16384 ]; then
  # 16GB+ 内存
  JOBS=$((ACTUAL_CORES > 6 ? 6 : ACTUAL_CORES))
elif [ "$ACTUAL_MEMORY" -gt 8192 ]; then
  # 8-16GB 内存
  JOBS=$((ACTUAL_CORES > 4 ? 4 : ACTUAL_CORES))
else
  # 8GB 以下内存
  JOBS=$((ACTUAL_CORES > 2 ? 2 : ACTUAL_CORES))
fi

echo "📊 使用 $JOBS 个并行任务进行编译 (基于实际硬件: ${ACTUAL_MEMORY}MB 内存 + $ACTUAL_CORES 核心)"
echo "💡 保守配置，避免资源竞争和系统不稳定"

# 添加构建状态监控
echo "⏰ 开始时间: $(date)"
echo "🔄 开始编译 LibRaw，这可能需要几分钟..."

# 后台监控资源使用情况
monitor_resources() {
  while true; do
    echo "📊 资源使用情况:"
    if command -v free >/dev/null 2>&1; then
      echo "  内存: $(free -h | awk '/^Mem:/{print $3"/"$2}')"
    fi
    echo "  CPU: $(top -l 1 | grep "CPU usage" | awk '{print $3}' 2>/dev/null || echo 'N/A')"
    echo "  负载: $(uptime | awk -F'load average:' '{print $2}' 2>/dev/null || echo 'N/A')"
    sleep 30
  done
}

# 启动资源监控（后台运行）
monitor_resources &
MONITOR_PID=$!

# 使用更详细的构建输出
if ! make -j$JOBS VERBOSE=1; then
  echo "❌ 编译失败，尝试使用单线程编译..."
  echo "🔄 单线程编译开始..."
  if ! make -j1 VERBOSE=1; then
    echo "❌ 单线程编译也失败，请检查错误信息"
    kill $MONITOR_PID 2>/dev/null
    exit 1
  fi
fi

# 停止资源监控
kill $MONITOR_PID 2>/dev/null

echo "✅ 编译成功完成！"
echo "⏰ 编译完成时间: $(date)"

# 安装
echo "📦 安装 LibRaw..."
make install

# 检查构建结果
echo "🔍 检查构建结果..."
BUILD_DIR="$(pwd)/build/${PLATFORM}-${ARCH}"
echo "📁 安装目录: $BUILD_DIR"

if [ "$PLATFORM" = "windows" ]; then
  echo "🪟 Windows 构建结果检查:"
  echo "  检查 lib 目录:"
  find "$BUILD_DIR" -name "*.lib" -o -name "*.a" | head -10
  echo "  检查 bin 目录:"
  find "$BUILD_DIR" -name "*.dll" | head -10
  echo "  检查 include 目录:"
  find "$BUILD_DIR" -name "*.h" | head -5
else
  echo "📁 构建文件列表:"
  find "$BUILD_DIR" -type f | head -10
fi

echo "✅ LibRaw 构建完成！"
echo "================================"
