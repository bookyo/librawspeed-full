#!/bin/bash
set -euo pipefail

# 开发环境设置脚本
# 配置 prebuildify 所需的构建环境

echo "🛠️  设置 LibRaw 开发环境..."
echo "=================================="

# 检测操作系统
OS=$(uname -s)
ARCH=$(uname -m)

echo "📋 检测到系统: $OS $ARCH"

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js 未安装，请先安装 Node.js"
    exit 1
fi

echo "✅ Node.js 版本: $(node --version)"
echo "✅ npm 版本: $(npm --version)"

# 检查 Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 未安装，请先安装 Python 3"
    exit 1
fi

echo "✅ Python 版本: $(python3 --version)"

# 根据操作系统安装构建工具
case "$OS" in
    "Darwin")
        echo "🍎 配置 macOS 环境..."
        
        # 检查 Xcode Command Line Tools
        if ! xcode-select -p &> /dev/null; then
            echo "📦 安装 Xcode Command Line Tools..."
            xcode-select --install
        else
            echo "✅ Xcode Command Line Tools 已安装"
        fi
        
        # 检查 Homebrew
        if ! command -v brew &> /dev/null; then
            echo "📦 安装 Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            echo "✅ Homebrew 已安装"
        fi
        
        # 安装构建工具
        echo "📦 安装构建工具..."
        brew install autoconf automake libtool pkg-config
        
        ;;
        
    "Linux")
        echo "🐧 配置 Linux 环境..."
        
        # 检测发行版
        if command -v apt-get &> /dev/null; then
            echo "📦 使用 apt 安装构建工具..."
            sudo apt-get update
            sudo apt-get install -y build-essential autoconf automake libtool pkg-config
        elif command -v yum &> /dev/null; then
            echo "📦 使用 yum 安装构建工具..."
            sudo yum groupinstall -y "Development Tools"
            sudo yum install -y autoconf automake libtool pkgconfig
        elif command -v pacman &> /dev/null; then
            echo "📦 使用 pacman 安装构建工具..."
            sudo pacman -S --needed base-devel autoconf automake libtool pkg-config
        else
            echo "❌ 不支持的 Linux 发行版"
            exit 1
        fi
        
        ;;
        
    "MINGW"*|"CYGWIN"*|"MSYS"*)
        echo "🪟 检测到 Windows 环境..."
        echo "请确保已安装："
        echo "- Visual Studio Build Tools"
        echo "- Python 3"
        echo "- Git"
        ;;
        
    *)
        echo "❌ 不支持的操作系统: $OS"
        exit 1
        ;;
esac

# 安装项目依赖
echo "📦 安装项目依赖..."
npm install

# 验证环境
echo "🔍 验证构建环境..."
if npm run build; then
    echo "✅ 构建环境配置成功！"
    echo ""
    echo "🎉 现在可以运行以下命令："
    echo "  npm run build:all    # 构建所有平台的预构建文件"
    echo "  npm run test         # 运行测试"
    echo "  npm run release      # 发布新版本"
else
    echo "❌ 构建环境配置失败，请检查错误信息"
    exit 1
fi
