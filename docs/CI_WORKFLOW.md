# CI/CD 工作流说明

## 🚀 多平台预构建文件生成

我们使用 GitHub Actions 为不同平台分别运行 prebuildify，生成所有平台的预构建文件。

### 📋 支持平台

| 平台 | 架构 | Runner | 状态 |
|------|------|--------|------|
| Linux | x64 | ubuntu-latest | ✅ |
| Linux | ARM64 | ubuntu-latest | ✅ |
| macOS | x64 | macos-latest | ✅ |
| macOS | ARM64 | macos-latest | ✅ |
| Windows | x64 | windows-latest | ✅ |

### 🔄 工作流程

#### 1. 构建预构建文件 (`build-prebuilds.yml`)

**触发条件:**
- 推送标签 (v*)
- 手动触发

**执行步骤:**
1. 为每个平台并行构建
2. 安装构建工具和依赖
3. 下载和构建 LibRaw
4. 运行 `prebuildify` 生成预构建文件
5. 上传平台特定的预构建文件

#### 2. 发布 (`release.yml`)

**触发条件:**
- 推送标签 (v*)
- 手动触发

**执行步骤:**
1. 下载所有平台的预构建文件
2. 合并到统一的 prebuilds 目录
3. 运行测试
4. 发布到 npm
5. 创建 GitHub Release

### 🛠️ 本地开发

#### 生成当前平台预构建文件
```bash
# 生成当前平台的预构建文件
npm run prebuildify

# 查看生成的文件
ls -la prebuilds/
```

#### 模拟 CI 合并过程
```bash
# 合并预构建文件（模拟 CI 过程）
bash scripts/merge-prebuilds.sh
```

### 📦 预构建文件结构

```
prebuilds/
├── darwin-arm64/
│   └── librawspeed.node
├── darwin-x64/
│   └── librawspeed.node
├── linux-arm64/
│   └── librawspeed.node
├── linux-x64/
│   └── librawspeed.node
└── win32-x64/
    └── librawspeed.node
```

### 🎯 优势

1. **真正跨平台**: 在每个平台上原生构建
2. **并行构建**: 所有平台同时构建，节省时间
3. **自动化**: 完全自动化的构建和发布流程
4. **可靠性**: 每个平台使用原生工具链构建
5. **可维护性**: 清晰的分离关注点

### 🔧 配置说明

#### GitHub Actions 配置
- **构建超时**: 30 分钟
- **发布超时**: 10 分钟
- **Node.js 版本**: 22
- **缓存**: npm 依赖缓存

#### 环境变量
- `PREBUILD_PLATFORM`: 目标平台 (linux, darwin, win32)
- `PREBUILD_ARCH`: 目标架构 (x64, arm64)

### 📊 监控和调试

#### 查看构建状态
1. 访问 GitHub Actions 页面
2. 查看 `Build Prebuilds for All Platforms` 工作流
3. 检查每个平台的构建日志

#### 常见问题
1. **构建失败**: 检查对应平台的构建工具安装
2. **预构建文件缺失**: 检查 prebuildify 配置
3. **测试失败**: 检查预构建文件兼容性

### 🚀 发布流程

1. **本地开发**: 完成功能开发和测试
2. **创建标签**: `git tag v1.0.0 && git push origin v1.0.0`
3. **自动构建**: GitHub Actions 自动构建所有平台
4. **自动发布**: 自动发布到 npm 和 GitHub Releases
5. **验证**: 检查发布结果

### 💡 最佳实践

1. **标签命名**: 使用语义化版本标签 (v1.0.0)
2. **测试覆盖**: 确保所有平台都有测试覆盖
3. **依赖管理**: 保持构建工具版本一致
4. **监控**: 定期检查构建状态和失败率
