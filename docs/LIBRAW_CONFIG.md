# LibRaw 配置选项说明

## 当前配置

### 基础配置
```bash
--enable-static      # 启用静态库构建
--disable-shared     # 禁用动态库构建
--disable-openmp     # 禁用 OpenMP 并行处理
--disable-examples   # 禁用示例程序
--disable-lcms       # 禁用 LCMS 色彩管理
--disable-jasper     # 禁用 JPEG 2000 支持
```

### 平台特定配置
```bash
# macOS 和 Windows
--disable-thumbnail  # 禁用缩略图生成
```

## 配置选项详解

### 已禁用的功能

| 选项 | 作用 | 禁用原因 | 影响 |
|------|------|----------|------|
| `--disable-shared` | 动态库 | 我们只需要静态库 | 无影响 |
| `--disable-openmp` | 并行处理 | 避免多线程问题 | 可能影响性能 |
| `--disable-examples` | 示例程序 | 不需要示例 | 无影响 |
| `--disable-lcms` | 色彩管理 | 减少依赖 | 可能影响色彩准确性 |
| `--disable-jasper` | JPEG 2000 | 减少依赖 | 不影响 RAW 处理 |
| `--disable-thumbnail` | 缩略图 | 减少构建时间 | 不影响核心功能 |

### 保留的功能

| 功能 | 作用 | 重要性 |
|------|------|--------|
| **dcraw 兼容性** | 与 dcraw 工具兼容 | ⭐⭐⭐ 高 |
| **rawspeed 解码器** | 支持更多相机格式 | ⭐⭐⭐ 高 |
| **JPEG 支持** | 处理嵌入的 JPEG | ⭐⭐ 中 |
| **静态库** | 便于分发 | ⭐⭐⭐ 高 |

## 性能影响

### 构建时间
- **当前配置**: 约 3-5 分钟
- **如果启用所有功能**: 约 8-12 分钟
- **如果禁用更多功能**: 约 2-3 分钟

### 运行时性能
- **dcraw 兼容性**: 提高兼容性，轻微性能影响
- **rawspeed**: 提高格式支持，可能提升性能
- **JPEG 支持**: 处理嵌入 JPEG 时有用

## 建议

### 当前配置是平衡的
1. **保留核心功能**: dcraw 兼容性、rawspeed 解码器
2. **禁用非必要功能**: 缩略图、示例程序
3. **减少依赖**: 禁用 LCMS、Jasper

### 如果需要更快的构建
可以添加：
```bash
--disable-dcraw      # 禁用 dcraw 兼容性
--disable-rawspeed   # 禁用 rawspeed 解码器
```

### 如果需要更多功能
可以移除：
```bash
--disable-lcms       # 启用色彩管理
--disable-jasper     # 启用 JPEG 2000
```

## 测试建议

1. **功能测试**: 确保 RAW 文件能正常处理
2. **性能测试**: 测试不同配置的性能差异
3. **兼容性测试**: 确保与现有代码兼容
