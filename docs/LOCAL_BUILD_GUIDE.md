# 本地构建和发布指南

## 🎯 核心理念

**完全本地化构建** - 不需要复杂的 CI/CD，所有预构建文件都在本地生成！

## 🚀 本地开发流程

### 1. 环境设置
```bash
# 安装依赖
npm install
```

### 2. 本地构建
```bash
# 构建当前平台
npm run build

# 构建所有平台的预构建文件
npm run build:all
```

### 3. 测试
```bash
# 运行测试
npm test

# 快速测试
npm run test:quick
```

## 📦 发布流程

### 方法一：使用 bumpp 自动发布
```bash
# 自动构建所有平台 + 更新版本号 + 发布
npm run release        # 自动选择版本类型
npm run release:patch  # 补丁版本 (1.0.0 -> 1.0.1)
npm run release:minor  # 小版本 (1.0.0 -> 1.1.0)
npm run release:major  # 大版本 (1.0.0 -> 2.0.0)
```

### 方法二：使用发布脚本
```bash
# 交互式发布脚本
bash scripts/publish.sh
```

### 方法三：分步发布
```bash
# 1. 构建所有平台的预构建文件
npm run build:all

# 2. 运行测试
npm test

# 3. 使用 bumpp 更新版本号
bumpp patch  # 或 minor, major

# 4. 推送到 Git
git push --follow-tags

# 5. 发布到 npm
npm publish
```

## 🔧 预构建文件管理

### 生成的文件结构
```
prebuilds/
├── darwin-arm64/
│   └── libraw_addon.node
├── darwin-x64/
│   └── libraw_addon.node
├── linux-x64/
│   └── libraw_addon.node
├── win32-x64/
│   └── libraw_addon.node
└── win32-ia32/
    └── libraw_addon.node
```

### 验证预构建文件
```bash
# 查看生成的文件
find prebuilds -name "*.node" -type f

# 检查文件大小
du -sh prebuilds/
```

## 🎉 优势

### ✅ 本地构建的优势
1. **完全控制**: 在您的开发环境中构建
2. **快速迭代**: 无需等待 CI/CD
3. **调试方便**: 可以直接调试构建过程
4. **成本低**: 不需要 CI/CD 资源
5. **可靠性高**: 避免网络和 CI 环境问题

### ✅ Prebuildify 的优势
1. **跨平台**: 一次构建，所有平台
2. **标准化**: 使用 Node.js 标准工具链
3. **自动化**: 自动处理平台差异
4. **兼容性**: 支持所有主流平台

## 🔄 工作流程

### 开发阶段
```bash
# 日常开发
npm run build
npm test
```

### 发布阶段
```bash
# 发布新版本
npm run release:patch  # 补丁版本
npm run release:minor  # 小版本
npm run release:major  # 大版本
```

### CI/CD 阶段
- **GitHub Actions**: 只负责测试和发布
- **本地构建**: 所有预构建文件在本地生成
- **自动发布**: CI 自动发布到 npm

## 🛠️ 故障排除

### 常见问题

#### 1. 构建失败
```bash
# 清理并重新构建
npm run clean
npm run build:all
```

#### 2. 预构建文件缺失
```bash
# 检查 package.json 配置
cat package.json | grep -A 10 "napi"

# 重新生成
npx prebuildify --napi --all
```

#### 3. 平台兼容性问题
```bash
# 检查支持的目标平台
node -e "console.log(require('node-abi').supportedTargets.slice(0, 5))"
```

## 📋 检查清单

发布前请确认：
- [ ] 所有平台的预构建文件已生成
- [ ] 测试通过
- [ ] 版本号已更新
- [ ] CHANGELOG.md 已更新
- [ ] README.md 已更新（如需要）

## 🎯 总结

通过使用 prebuildify 的本地构建能力，我们实现了：
- **简化的 CI/CD**: 只需要测试和发布
- **本地化构建**: 所有预构建文件在本地生成
- **跨平台支持**: 一次构建，所有平台
- **开发效率**: 快速迭代，无需等待 CI

这就是现代 Node.js 原生模块的最佳实践！
