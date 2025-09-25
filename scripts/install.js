#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const os = require('os');
const { execSync } = require('child_process');

console.log('[LibRawSpeed 安装器] 开始安装...');

// 检测平台信息
const platform = os.platform();
const arch = os.arch();
const nodeVersion = process.version;

console.log(`[LibRawSpeed 安装器] 平台: ${platform}-${arch}`);
console.log(`[LibRawSpeed 安装器] Node.js 版本: ${nodeVersion}`);

// 检查是否已有预构建的 .node 文件
const buildDir = path.join(__dirname, '..', 'build', 'Release');
const nodeFile = path.join(buildDir, 'raw_addon.node');

if (fs.existsSync(nodeFile)) {
  console.log('[LibRawSpeed 安装器] ✅ 找到预构建的 .node 文件，跳过编译');
  console.log('[LibRawSpeed 安装器] 安装完成！');
  process.exit(0);
}

console.log('[LibRawSpeed 安装器] 未找到预构建文件，开始编译...');

try {
  // 运行 LibRaw 构建
  console.log('[LibRawSpeed 安装器] 构建 LibRaw...');
  execSync('node scripts/build-libraw.js', { 
    stdio: 'inherit',
    cwd: path.join(__dirname, '..')
  });

  // 运行 node-gyp 构建
  console.log('[LibRawSpeed 安装器] 构建 N-API 模块...');
  execSync('node-gyp rebuild', { 
    stdio: 'inherit',
    cwd: path.join(__dirname, '..')
  });

  console.log('[LibRawSpeed 安装器] ✅ 安装完成！');
} catch (error) {
  console.error('[LibRawSpeed 安装器] ❌ 安装失败:', error.message);
  process.exit(1);
}
