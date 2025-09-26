#!/bin/bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
VERSION="${LCMS2_VERSION:-2.17}"
SOURCE_DIR="$ROOT_DIR/deps/lcms2-source/lcms2-${VERSION}"
TMP_DIR="$(mktemp -d)"
URL="https://downloads.sourceforge.net/project/lcms/lcms/${VERSION}/lcms2-${VERSION}.tar.gz"

echo "Downloading lcms2 ${VERSION} to ${SOURCE_DIR}"

# 如果源码目录已存在，跳过下载
if [ -d "$SOURCE_DIR" ]; then
  echo "lcms2 source already exists at $SOURCE_DIR"
  exit 0
fi

# 创建目录
mkdir -p "$(dirname "$SOURCE_DIR")"

# 下载源码
cd "$TMP_DIR"
curl -L -o "lcms2-${VERSION}.tar.gz" "$URL"
tar xf "lcms2-${VERSION}.tar.gz"

# 移动到目标目录
mv "lcms2-${VERSION}" "$SOURCE_DIR"

echo "lcms2 ${VERSION} downloaded to $SOURCE_DIR"
