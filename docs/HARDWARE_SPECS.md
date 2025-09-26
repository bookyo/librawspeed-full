# 硬件规格配置说明

## 🖥️ GitHub Actions 硬件规格

### 当前配置的 Runner 类型

| 平台 | Runner | 硬件规格 | 说明 |
|------|--------|----------|------|
| Linux x64 | `ubuntu-latest` | 2-core CPU, 7GB RAM | 标准 Linux 环境 |
| Linux ARM64 | `ubuntu-latest` | 2-core CPU, 7GB RAM | ARM64 架构支持 |
| macOS x64 | `macos-latest` | 3-core CPU, 14GB RAM | Intel Mac 环境 |
| macOS ARM64 | `macos-latest` | 3-core CPU, 14GB RAM | Apple Silicon 环境 |
| Windows x64 | `windows-latest` | 2-core CPU, 7GB RAM | Windows Server 2022 |

### 动态构建优化

构建脚本会根据实际硬件规格动态调整编译参数：

#### 内存基准
- **> 8GB**: 最多使用 8 个并行任务
- **4-8GB**: 最多使用 6 个并行任务  
- **< 4GB**: 最多使用 4 个并行任务

#### 核心数限制
- 并行任务数不会超过实际 CPU 核心数
- 确保至少使用 1 个任务

### 构建参数示例

```bash
# 大内存机器 (14GB macOS)
CPU 核心数: 3
内存大小: 14336MB
使用 3 个并行任务进行编译

# 中等内存机器 (7GB Linux)
CPU 核心数: 2
内存大小: 7168MB
使用 2 个并行任务进行编译

# 小内存机器 (4GB)
CPU 核心数: 2
内存大小: 4096MB
使用 2 个并行任务进行编译
```

## 🔧 自定义硬件规格

### 使用更大的 Runner

如果需要更大的硬件规格，可以修改 `.github/workflows/release.yml`：

```yaml
# 使用更大的 macOS Runner
- os: macos-latest
  platform: darwin
  arch: x64
  runner: macos-latest
  runner-type: macos-13  # 更新的 macOS 版本

# 使用更大的 Linux Runner
- os: ubuntu-latest
  platform: linux
  arch: x64
  runner: ubuntu-latest
  runner-type: ubuntu-22.04  # 更新的 Ubuntu 版本
```

### 添加自定义 Runner

如果使用自托管 Runner，可以在矩阵中添加：

```yaml
- os: custom
  platform: linux
  arch: x64
  runner: [self-hosted, linux, x64]
  runner-type: custom-high-memory
```

## 📊 性能监控

### 构建时间统计

每次构建都会记录：
- 开始时间
- 结束时间
- 硬件规格信息
- 使用的并行任务数

### 优化建议

1. **内存不足**: 减少并行任务数
2. **CPU 利用率低**: 增加并行任务数
3. **构建超时**: 增加超时时间或优化构建配置
4. **资源竞争**: 使用更大的 Runner 或减少并行任务

## 🚀 最佳实践

1. **监控构建日志**: 查看硬件规格和构建时间
2. **调整参数**: 根据实际性能调整并行任务数
3. **使用缓存**: 利用 GitHub Actions 缓存减少构建时间
4. **分阶段构建**: 将大型构建分解为多个阶段
