# 硬件规格配置说明

## 🖥️ 固定硬件规格配置

### 高性能构建环境 (10核心 32GB)

| 平台 | Runner | 固定硬件规格 | 并行任务 | 说明 |
|------|--------|-------------|----------|------|
| Linux x64 | `ubuntu-22.04` | 10-core CPU, 32GB RAM | 8 个 | 高性能 Linux 环境 |
| Linux ARM64 | `ubuntu-22.04` | 10-core CPU, 32GB RAM | 8 个 | 高性能 ARM64 环境 |
| macOS x64 | `macos-13` | 10-core CPU, 32GB RAM | 8 个 | 高性能 Intel Mac 环境 |
| macOS ARM64 | `macos-13` | 10-core CPU, 32GB RAM | 8 个 | 高性能 Apple Silicon 环境 |
| Windows x64 | `windows-2022` | 10-core CPU, 32GB RAM | 8 个 | 高性能 Windows 环境 |

### 配置特点

- **固定规格**: 所有平台统一使用 10 核心 32GB 内存
- **并行任务**: 使用 8 个并行任务，为系统保留 2 个核心
- **高性能**: 专为快速构建优化的配置
- **一致性**: 所有平台使用相同的硬件规格，确保构建一致性

### 动态构建优化

构建脚本会根据实际硬件规格动态调整编译参数：

#### 内存基准
- **> 8GB**: 最多使用 8 个并行任务
- **4-8GB**: 最多使用 6 个并行任务  
- **< 4GB**: 最多使用 4 个并行任务

#### 核心数限制
- 并行任务数不会超过实际 CPU 核心数
- 确保至少使用 1 个任务

### 固定构建参数

```bash
# 高性能构建环境 (所有平台统一配置)
CPU 核心数: 10 (固定配置)
内存大小: 32768MB (32GB 固定配置)
并行任务数: 8 (为系统保留 2 核心)
配置类型: 高性能构建环境

# 构建输出示例
🖥️  固定硬件规格:
  CPU 核心数: 10
 内存大小: 32768MB (32GB)
 配置类型: 高性能构建环境
📊 使用 8 个并行任务进行编译 (固定配置: 32GB 内存 + 10 核心)
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
