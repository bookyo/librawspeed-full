#!/usr/bin/env node

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const platforms = [
  { platform: 'win32', arch: 'x64', name: 'librawspeed-win32-x64' },
  { platform: 'darwin', arch: 'x64', name: 'librawspeed-darwin-x64' },
  { platform: 'darwin', arch: 'arm64', name: 'librawspeed-darwin-arm64' },
  { platform: 'linux', arch: 'x64', name: 'librawspeed-linux-x64' },
  { platform: 'linux', arch: 'arm64', name: 'librawspeed-linux-arm64' }
];

function log(message) {
  console.log(`[publish] ${message}`);
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

function createPlatformPackage(platform, arch, name) {
  log(`创建平台包: ${name}`);
  
  const packageDir = path.join(__dirname, '..', 'prebuilds', name);
  const prebuildFile = `libraw_addon-${platform}-${arch}.node`;
  
  // 创建目录
  if (!fs.existsSync(packageDir)) {
    fs.mkdirSync(packageDir, { recursive: true });
  }
  
  // 复制预构建文件
  const sourceFile = path.join(__dirname, '..', 'prebuilds', prebuildFile);
  const targetFile = path.join(packageDir, 'index.node');
  
  if (fs.existsSync(sourceFile)) {
    fs.copyFileSync(sourceFile, targetFile);
    log(`复制预构建文件: ${prebuildFile} -> index.node`);
  } else {
    log(`警告: 未找到预构建文件 ${sourceFile}`);
    return;
  }
  
  // 创建 package.json
  const packageJson = {
    name: name,
    version: require('../package.json').version,
    description: `LibRaw native addon for ${platform}-${arch}`,
    main: 'index.node',
    os: [platform],
    cpu: [arch],
    files: ['index.node'],
    license: 'MIT',
    repository: {
      type: 'git',
      url: 'https://github.com/pixFlowTeam/librawspeed.git'
    }
  };
  
  fs.writeFileSync(
    path.join(packageDir, 'package.json'), 
    JSON.stringify(packageJson, null, 2)
  );
  
  // 创建 README
  const readme = `# ${name}

LibRaw native addon for ${platform}-${arch} platform.

This package contains the prebuilt binary for librawspeed on ${platform}-${arch}.
It is automatically installed as a dependency of librawspeed.
`;
  
  fs.writeFileSync(path.join(packageDir, 'README.md'), readme);
  
  log(`✅ 平台包创建完成: ${name}`);
}

function publishPlatformPackages() {
  log('开始创建和发布平台包...');
  
  for (const { platform, arch, name } of platforms) {
    try {
      createPlatformPackage(platform, arch, name);
    } catch (error) {
      log(`❌ 创建平台包失败 ${name}: ${error.message}`);
    }
  }
  
  log('平台包创建完成！');
  log('手动发布命令:');
  for (const { name } of platforms) {
    log(`  cd prebuilds/${name} && npm publish`);
  }
}

function main() {
  const args = process.argv.slice(2);
  
  if (args.includes('--help') || args.includes('-h')) {
    console.log(`
用法: node scripts/publish-platforms.js [选项]

选项:
  --help, -h     显示帮助信息

功能:
  为每个平台创建独立的 npm 包
    `);
    return;
  }

  publishPlatformPackages();
}

if (require.main === module) {
  main();
}

module.exports = { createPlatformPackage, platforms };
