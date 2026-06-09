#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const { spawnSync } = require("child_process");

const rootDir = path.resolve(__dirname, "..");
const version = process.env.LIBRAW_VERSION || "0.21.4";
const sourceDir = path.join(rootDir, "deps", "LibRaw-Source", `LibRaw-${version}`);

function log(message) {
  console.log(`[prepare-libraw] ${message}`);
}

function fail(message) {
  console.error(`[prepare-libraw] ${message}`);
  process.exit(1);
}

function detectBuildTarget() {
  const platform = process.platform === "win32" ? "windows" : process.platform;
  const arch = process.arch === "arm64" ? "arm64" : "x64";
  return { platform, arch };
}

function fileExists(filePath) {
  try {
    return fs.existsSync(filePath);
  } catch {
    return false;
  }
}

function resolveBuildCandidates({ platform, arch }) {
  const buildRoot = path.join(sourceDir, "build", `${platform}-${arch}`);

  if (platform === "windows") {
    return [
      path.join(buildRoot, "lib", "libraw_static.lib"),
      path.join(buildRoot, "lib", "libraw.lib"),
      path.join(sourceDir, "lib", "libraw_static.lib"),
      path.join(sourceDir, "lib", "libraw.lib"),
    ];
  }

  return [
    path.join(buildRoot, "lib", "libraw.a"),
    path.join(buildRoot, "lib", "libraw_r.a"),
  ];
}

function findPreparedLibrary(target) {
  return resolveBuildCandidates(target).find(fileExists);
}

function resolveBashExecutable() {
  if (process.platform !== "win32") {
    return "bash";
  }

  const winCandidates = [
    "bash",
    "bash.exe",
    "C:\\Program Files\\Git\\bin\\bash.exe",
    "C:\\Program Files\\Git\\usr\\bin\\bash.exe",
  ];

  return winCandidates.find((candidate) => {
    if (candidate.includes("\\") || candidate.includes("/")) {
      return fileExists(candidate);
    }

    const result = spawnSync(candidate, ["--version"], { stdio: "ignore" });
    return result.status === 0;
  });
}

function runCommand(command, args) {
  const result = spawnSync(command, args, {
    cwd: rootDir,
    stdio: "inherit",
    env: process.env,
  });

  if (result.status !== 0) {
    process.exit(result.status || 1);
  }
}

function ensureSourceDirectory() {
  if (fileExists(sourceDir)) {
    return;
  }

  const bash = resolveBashExecutable();
  if (!bash) {
    fail("LibRaw 源码缺失，且当前环境找不到 bash，无法自动下载依赖。");
  }

  log(`LibRaw 源码缺失，开始下载 ${version}...`);
  runCommand(bash, [path.join(rootDir, "scripts", "download-dependencies.sh")]);
}

function ensureBuiltLibrary() {
  const target = detectBuildTarget();
  const existingLibrary = findPreparedLibrary(target);

  if (existingLibrary) {
    log(`复用现有静态库: ${path.relative(rootDir, existingLibrary)}`);
    return;
  }

  const bash = resolveBashExecutable();
  if (!bash) {
    fail("当前环境找不到 bash，无法自动构建 LibRaw 静态库。");
  }

  log(`未找到 ${target.platform}-${target.arch} 的静态库，开始构建...`);
  runCommand(bash, [path.join(rootDir, "scripts", "build-libraw.sh")]);

  const builtLibrary = findPreparedLibrary(target);
  if (!builtLibrary) {
    fail(
      `LibRaw 构建结束后仍未找到 ${target.platform}-${target.arch} 静态库，请检查构建日志。`
    );
  }

  log(`LibRaw 静态库已准备完成: ${path.relative(rootDir, builtLibrary)}`);
}

ensureSourceDirectory();
ensureBuiltLibrary();
