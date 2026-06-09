const assert = require("assert");
const fs = require("fs");
const path = require("path");

function readProjectFile(relativePath) {
  return fs.readFileSync(path.join(__dirname, "..", relativePath), "utf8");
}

function testPackageContentsConfig() {
  const pkg = require("../package.json");
  const publishedTriples = pkg.napi.triples.additional;

  assert.strictEqual(
    pkg.scripts.install,
    'node-gyp-build "node scripts/prepare-libraw.js"',
    "install 脚本应该在源码编译前先准备 LibRaw 静态库"
  );

  assert(
    pkg.files.includes("prebuilds/**/*"),
    "npm 包必须包含 prebuilds 目录"
  );

  assert(
    pkg.files.includes("scripts/**/*"),
    "npm 包必须包含安装时需要的脚本"
  );

  assert.strictEqual(
    pkg.scripts["verify:release-prebuilds"],
    "node scripts/verify-release-prebuilds.js",
    "发布前必须验证 4 个官方平台预编译产物是否齐全"
  );

  assert(
    pkg.files.includes("deps/LibRaw-Source/**/*"),
    "npm 包必须包含源码回退构建所需的 LibRaw 源码"
  );

  assert.deepStrictEqual(
    publishedTriples,
    [
      "x64-apple-darwin",
      "arm64-apple-darwin",
      "x64-pc-windows-msvc",
      "x64-unknown-linux-gnu",
    ],
    "napi 发布目标应与正式预编译发布平台保持一致"
  );
}

function testReleaseWorkflowSupportsPublishedPlatforms() {
  const workflow = readProjectFile(".github/workflows/release.yml");

  const requiredSnippets = [
    "platform: linux",
    "runner: ubuntu-24.04",
    "prebuilds/linux-x64/librawspeed-full.node",
    "asset_name: librawspeed-full-linux-x64.node",
    "prebuilds/darwin-x64/librawspeed-full.node",
    "asset_name: librawspeed-full-darwin-x64.node",
    "npm install librawspeed-full",
    "Windows x64",
    "Linux x64",
    "macOS x64",
    "macOS ARM64",
  ];

  requiredSnippets.forEach((snippet) => {
    assert(
      workflow.includes(snippet),
      `release workflow 缺少必须的平台发布配置: ${snippet}`
    );
  });

  assert(
    workflow.includes("npm publish --ignore-scripts"),
    "CI 发布必须跳过本地 prepublishOnly，直接发布聚合后的完整产物"
  );
}

function testPublishGuardScriptExists() {
  const publishGuard = readProjectFile("scripts/verify-release-prebuilds.js");

  [
    "prebuilds/linux-x64/librawspeed-full.node",
    "prebuilds/darwin-x64/librawspeed-full.node",
    "prebuilds/darwin-arm64/librawspeed-full.node",
    "prebuilds/win32-x64/librawspeed-full.node",
    "GitHub Actions release workflow",
  ].forEach((snippet) => {
    assert(
      publishGuard.includes(snippet),
      `发布校验脚本缺少关键提示: ${snippet}`
    );
  });
}

function runPackagingTests() {
  console.log("📦 Packaging Regression Tests");
  console.log("=".repeat(40));

  testPackageContentsConfig();
  console.log("✅ package.json 打包配置正确");

  testReleaseWorkflowSupportsPublishedPlatforms();
  console.log("✅ release workflow 包含 Linux/macOS/Windows 发布配置");

  testPublishGuardScriptExists();
  console.log("✅ 本地发布保护已启用");
}

if (require.main === module) {
  try {
    runPackagingTests();
  } catch (error) {
    console.error(`❌ Packaging test failed: ${error.message}`);
    process.exit(1);
  }
}

module.exports = {
  runPackagingTests,
};
