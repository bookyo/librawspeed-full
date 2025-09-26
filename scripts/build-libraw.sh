#!/bin/bash
set -euo pipefail

# LibRaw 构建脚本
# 确保使用 -fPIC 编译选项来支持共享对象链接

# 默认不跳过 configure
SKIP_CONFIGURE=false

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
  # macOS 优化配置 - 禁用一些功能以减少构建时间
  CONFIGURE_OPTS="$CONFIGURE_OPTS --disable-thumbnail --disable-djpeg --disable-lcms"
  echo "🍎 macOS 优化: 禁用缩略图、djpeg 和 lcms 以减少构建时间"
  echo "   保留的功能: dcraw 兼容性, rawspeed 解码器, jpeg 支持"
elif [ "$PLATFORM" = "windows" ]; then
  # Windows 特殊配置 - 使用 MSVC 构建
  echo "🪟 Windows 构建: 使用 MSVC 和 Makefile.msvc"
  echo "   保留的功能: dcraw 兼容性, rawspeed 解码器, jpeg 支持"
  echo "   使用 MSVC 编译器"
  
  # Windows 上使用 MSVC 构建，不需要 configure
  echo "   跳过 configure，直接使用 nmake"
  SKIP_CONFIGURE=true
else
  # 其他平台使用标准 configure
  SKIP_CONFIGURE=false
fi

if [ "$SKIP_CONFIGURE" != "true" ]; then
  ./configure $CONFIGURE_OPTS --prefix="$(pwd)/build/${PLATFORM}-${ARCH}"
fi

# 构建
echo "🔨 编译 LibRaw..."

# 检测实际硬件规格并保守配置
ACTUAL_CORES=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
ACTUAL_MEMORY=$(free -m 2>/dev/null | awk '/^Mem:/{print $2}' || sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1024/1024)}' || echo 4096)

echo "🖥️  实际硬件规格:"
echo "  CPU 核心数: $ACTUAL_CORES"
echo " 内存大小: ${ACTUAL_MEMORY}MB"

# 保守的并行任务配置，避免资源竞争
if [ "$PLATFORM" = "darwin" ]; then
  # macOS 使用更保守的并行任务数
  if [ "$ACTUAL_MEMORY" -gt 16384 ]; then
    JOBS=4  # macOS 16GB+ 内存使用 4 个并行任务
  elif [ "$ACTUAL_MEMORY" -gt 8192 ]; then
    JOBS=3  # macOS 8-16GB 内存使用 3 个并行任务
  else
    JOBS=2  # macOS 8GB 以下内存使用 2 个并行任务
  fi
  echo "🍎 macOS 平台，使用保守的并行任务配置"
else
  # 其他平台使用标准配置
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

# 根据平台选择构建方式
if [ "$PLATFORM" = "windows" ]; then
  # Windows 使用 nmake
  echo "🪟 使用 nmake 构建 LibRaw..."
  if ! nmake -f Makefile.msvc VERBOSE=1; then
    echo "❌ nmake 编译失败，请检查错误信息"
    kill $MONITOR_PID 2>/dev/null
    exit 1
  fi
  
  echo "🔍 搜索生成的 .lib 文件..."
  find . -name "*.lib" -o -name "*.a"
else
  # 其他平台使用 make
  if ! make -j$JOBS VERBOSE=1; then
    echo "❌ 编译失败，尝试使用单线程编译..."
    echo "🔄 单线程编译开始..."
    if ! make -j1 VERBOSE=1; then
      echo "❌ 单线程编译也失败，请检查错误信息"
      kill $MONITOR_PID 2>/dev/null
      exit 1
    fi
  fi
fi

# 停止资源监控
kill $MONITOR_PID 2>/dev/null

echo "✅ 编译成功完成！"
echo "⏰ 编译完成时间: $(date)"

# 安装
echo "📦 安装 LibRaw..."
if [ "$PLATFORM" = "windows" ]; then
  # Windows 不需要 make install，文件已经在正确位置
  echo "🪟 Windows 构建完成，文件已在正确位置"
  # 创建安装目录结构
  mkdir -p "build/${PLATFORM}-${ARCH}/lib"
  mkdir -p "build/${PLATFORM}-${ARCH}/bin"
  mkdir -p "build/${PLATFORM}-${ARCH}/include"
  
  # 动态查找并复制 .lib 文件
  LIB_FILE=$(find . -name "libraw_static.lib" -o -name "libraw.lib" | head -n 1)
  if [ -n "$LIB_FILE" ]; then
    cp "$LIB_FILE" "build/${PLATFORM}-${ARCH}/lib/"
    echo "   复制 $LIB_FILE 到 build/${PLATFORM}-${ARCH}/lib/"
  else
    echo "❌ 未找到 libraw_static.lib 或 libraw.lib 文件"
    exit 1
  fi

  if [ -f "bin/libraw.dll" ]; then
    cp "bin/libraw.dll" "build/${PLATFORM}-${ARCH}/bin/"
    echo "   复制 libraw.dll"
  fi
  if [ -d "libraw" ]; then
    cp -r "libraw" "build/${PLATFORM}-${ARCH}/include/"
    echo "   复制头文件"
  fi
else
  make install
fi

# 检查构建结果
echo "🔍 检查构建结果..."
BUILD_DIR="$(pwd)/build/${PLATFORM}-${ARCH}"
echo "📁 安装目录: $BUILD_DIR"

if [ "$PLATFORM" = "windows" ]; then
  echo "🪟 Windows 构建结果检查:"
  echo "  构建目录: $BUILD_DIR"
  echo "  检查整个构建目录结构:"
  find "$BUILD_DIR" -type f | head -20
  echo "  检查 lib 目录:"
  find "$BUILD_DIR" -name "*.lib" -o -name "*.a" | head -10
  echo "  检查 bin 目录:"
  find "$BUILD_DIR" -name "*.dll" | head -10
  echo "  检查 .libs 目录:"
  find "$BUILD_DIR" -path "*/.libs/*" -name "*.lib" -o -name "*.a" | head -10
  echo "  检查 include 目录:"
  find "$BUILD_DIR" -name "*.h" | head -5
  echo "  检查 LibRaw 源码目录:"
  find "deps/LibRaw-Source/LibRaw-0.21.4" -name "*.lib" -o -name "*.a" -o -name "*.dll" | head -10
  echo "  检查 LibRaw 源码根目录:"
  ls -la "deps/LibRaw-Source/LibRaw-0.21.4/"
  echo "  检查 LibRaw 源码 lib 目录:"
  ls -la "deps/LibRaw-Source/LibRaw-0.21.4/lib/" 2>/dev/null || echo "lib 目录不存在"
  echo "  检查 LibRaw 源码 .libs 目录:"
  ls -la "deps/LibRaw-Source/LibRaw-0.21.4/.libs/" 2>/dev/null || echo ".libs 目录不存在"
else
  echo "📁 构建文件列表:"
  find "$BUILD_DIR" -type f | head -10
fi

echo "✅ LibRaw 构建完成！"
echo "================================"
