#!/bin/bash

# 使用 Docker 构建 Windows 预构建包
# 需要先安装 Docker Desktop

echo "开始使用 Docker 构建 Windows 预构建包..."

# 创建临时目录
mkdir -p temp-windows-build

# 复制项目文件到临时目录
cp -r . temp-windows-build/
cd temp-windows-build

# 创建 Dockerfile
cat > Dockerfile << 'EOF'
FROM node:18-windowsservercore

# 安装 Windows 构建工具
RUN npm install -g windows-build-tools

# 设置工作目录
WORKDIR /app

# 复制项目文件
COPY . .

# 安装依赖
RUN npm ci

# 构建 LibRaw
RUN node scripts/build-libraw.js

# 构建预构建包
RUN npm run prebuildify

# 输出预构建文件
CMD ["cmd", "/c", "dir prebuilds /s"]
EOF

# 构建 Docker 镜像
echo "构建 Docker 镜像..."
docker build -t librawspeed-windows .

# 运行容器并复制预构建文件
echo "运行容器并构建..."
docker run --name librawspeed-windows-build librawspeed-windows

# 复制预构建文件
echo "复制预构建文件..."
docker cp librawspeed-windows-build:/app/prebuilds ./prebuilds-windows

# 清理
docker rm librawspeed-windows-build
docker rmi librawspeed-windows

echo "Windows 预构建包构建完成！"
echo "预构建文件位置: ./prebuilds-windows"
