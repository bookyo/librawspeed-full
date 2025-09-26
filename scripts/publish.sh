#!/bin/bash
set -euo pipefail

# 本地发布脚本
# 完全本地化构建和发布流程

echo "🚀 开始本地发布流程..."
echo "=================================="

# 检查 Git 状态
echo "📋 检查 Git 状态..."
if [ -n "$(git status --porcelain)" ]; then
    echo "❌ 工作目录不干净，请先提交所有更改"
    exit 1
fi

# 检查是否在正确的分支
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ] && [ "$CURRENT_BRANCH" != "master" ]; then
    echo "⚠️  当前分支: $CURRENT_BRANCH"
    echo "建议在 main 或 master 分支上发布"
    read -p "是否继续？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 运行测试
echo "🧪 运行测试..."
npm test

# 确认发布
echo ""
echo "🎯 准备发布到 npm..."
echo "当前版本: $(node -p "require('./package.json').version")"

read -p "确认发布？(y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 发布已取消"
    exit 1
fi

# 使用 bumpp 更新版本号并发布
echo "📦 使用 bumpp 更新版本号并发布..."
echo "请选择版本类型："
echo "1) patch (补丁版本，如 1.0.0 -> 1.0.1)"
echo "2) minor (小版本，如 1.0.0 -> 1.1.0)"
echo "3) major (大版本，如 1.0.0 -> 2.0.0)"
echo "4) 手动指定版本号"

read -p "请选择 (1-4): " -n 1 -r
echo

case $REPLY in
    1)
        echo "🚀 发布补丁版本..."
        npm run release:patch
        ;;
    2)
        echo "🚀 发布小版本..."
        npm run release:minor
        ;;
    3)
        echo "🚀 发布大版本..."
        npm run release:major
        ;;
    4)
        read -p "请输入版本号 (如 1.2.3): " VERSION
        echo "🚀 发布版本 $VERSION..."
        npm run build:all && bumpp $VERSION && git push --follow-tags
        ;;
    *)
        echo "❌ 无效选择，发布已取消"
        exit 1
        ;;
esac

echo ""
echo "✅ 发布成功！"
echo "=================================="
echo "🎉 所有平台的预构建文件已发布到 npm"
echo "用户现在可以通过 npm install 自动下载对应平台的预构建文件"
