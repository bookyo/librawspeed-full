#!/bin/bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
VERSION="${LIBRAW_VERSION:-0.21.4}"
SOURCE_DIR="$ROOT_DIR/deps/LibRaw-Source/LibRaw-${VERSION}"
TMP_DIR="$(mktemp -d)"
URL="https://www.libraw.org/data/LibRaw-${VERSION}.tar.gz"

echo "Downloading LibRaw ${VERSION} to ${SOURCE_DIR}"

# 如果源码目录已存在，跳过下载
if [ -d "$SOURCE_DIR" ]; then
  echo "LibRaw source already exists at $SOURCE_DIR"
  exit 0
fi

# 创建目录
mkdir -p "$(dirname "$SOURCE_DIR")"

# 下载源码
cd "$TMP_DIR"
curl -L -o "LibRaw-${VERSION}.tar.gz" "$URL"
tar xf "LibRaw-${VERSION}.tar.gz"

# 移动到目标目录
mv "LibRaw-${VERSION}" "$SOURCE_DIR"

echo "LibRaw ${VERSION} downloaded to $SOURCE_DIR"
