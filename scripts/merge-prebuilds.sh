#!/bin/bash
set -euo pipefail

# 合并预构建文件脚本
# 模拟 GitHub Actions 中的预构建文件合并过程

echo "🔗 合并预构建文件..."
echo "=================================="

# 检查是否存在 prebuilds 目录
if [ ! -d "prebuilds" ]; then
    echo "❌ prebuilds 目录不存在"
    echo "请先运行 'npm run prebuildify' 生成预构建文件"
    exit 1
fi

# 创建统一的 prebuilds 目录
echo "📁 创建统一的 prebuilds 目录..."
rm -rf prebuilds-unified
mkdir -p prebuilds-unified

# 复制当前平台的预构建文件
echo "📦 复制当前平台的预构建文件..."
cp -r prebuilds/* prebuilds-unified/

# 显示最终结构
echo "📊 最终预构建文件结构:"
find prebuilds-unified -name "*.node" -type f | sort

# 统计信息
echo ""
echo "📈 统计信息:"
echo "总文件数: $(find prebuilds-unified -name "*.node" -type f | wc -l)"
echo "总大小: $(du -sh prebuilds-unified/ | cut -f1)"

echo ""
echo "✅ 预构建文件合并完成！"
echo "=================================="
echo "💡 在 CI 环境中，这个脚本会合并所有平台的预构建文件"
echo "💡 本地环境中，只包含当前平台的预构建文件"
