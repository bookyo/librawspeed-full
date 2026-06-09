#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

const requiredPrebuilds = [
  "prebuilds/linux-x64/librawspeed-full.node",
  "prebuilds/darwin-x64/librawspeed-full.node",
  "prebuilds/darwin-arm64/librawspeed-full.node",
  "prebuilds/win32-x64/librawspeed-full.node",
];

const projectRoot = path.join(__dirname, "..");
const missing = requiredPrebuilds.filter(
  (relativePath) => !fs.existsSync(path.join(projectRoot, relativePath))
);

if (missing.length > 0) {
  console.error("❌ 发布包缺少完整的官方预编译产物:");
  missing.forEach((relativePath) => {
    console.error(`   - ${relativePath}`);
  });
  console.error("");
  console.error("本地 npm publish 只会发布当前工作区已有的 prebuilds 目录内容。");
  console.error("如果你是在 macOS ARM 机器上本地发布，通常只会带上 darwin-arm64。");
  console.error("");
  console.error("请改用 GitHub Actions release workflow 聚合 4 个平台产物后再发布，");
  console.error("或者先把 4 个平台的 prebuilds 全部同步到当前工作区。");
  process.exit(1);
}

console.log("✅ 官方发布所需的 4 个预编译平台产物都已存在");
