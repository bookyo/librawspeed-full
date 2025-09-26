#!/usr/bin/env node

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');
const os = require('os');

const platforms = [
  { platform: 'win32', arch: 'x64' },
  { platform: 'darwin', arch: 'x64' },
  { platform: 'darwin', arch: 'arm64' },
  { platform: 'linux', arch: 'x64' },
  { platform: 'linux', arch: 'arm64' }
];

function log(message) {
  console.log(`[prebuildify] ${message}`);
}

function runCommand(command, options = {}) {
  log(`Running: ${command}`);
  try {
    execSync(command, { 
      stdio: 'inherit', 
      cwd: process.cwd(),
      ...options 
    });
  } catch (error) {
    log(`Error running command: ${command}`);
    log(`Error: ${error.message}`);
    throw error;
  }
}

function buildForPlatform(platform, arch) {
  log(`Building for ${platform}-${arch}`);
  
  // 设置环境变量
  const env = {
    ...process.env,
    npm_config_arch: arch,
    npm_config_platform: platform,
    npm_config_build_from_source: 'true'
  };

  // 清理之前的构建
  runCommand('npm run clean', { env });
  
  // 构建 LibRaw 依赖
  runCommand('node scripts/build-libraw.js', { env });
  
  // 构建原生模块
  runCommand('node-gyp rebuild', { env });
  
  // 使用 prebuildify 创建预构建包
  const prebuildifyCommand = `prebuildify --platform ${platform} --arch ${arch} --napi`;
  runCommand(prebuildifyCommand, { env });
}

function main() {
  const args = process.argv.slice(2);
  const specificPlatform = args[0];
  const specificArch = args[1];

  log('开始构建 prebuildify 预构建包...');

  if (specificPlatform && specificArch) {
    // 构建特定平台
    buildForPlatform(specificPlatform, specificArch);
  } else {
    // 构建所有平台
    for (const { platform, arch } of platforms) {
      try {
        buildForPlatform(platform, arch);
        log(`✅ 成功构建 ${platform}-${arch}`);
      } catch (error) {
        log(`❌ 构建失败 ${platform}-${arch}: ${error.message}`);
        // 继续构建其他平台
      }
    }
  }

  log('prebuildify 预构建包构建完成！');
}

if (require.main === module) {
  main();
}

module.exports = { buildForPlatform, platforms };
