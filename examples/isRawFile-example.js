const LibRaw = require('../lib/index');
const path = require('path');

/**
 * LibRaw.isRawFile() 方法完整演示
 * 检查文件是否为 LibRaw 支持的 RAW 格式
 */

console.log('📚 LibRaw.isRawFile() 方法使用指南\n');
console.log('=' .repeat(70));

// ==================== 示例 1: 基本使用 ====================
console.log('\n📝 示例 1: 基本使用');
console.log('-'.repeat(70));

const testFile = path.resolve(__dirname, '../raw-samples-repo/ARW/DSC02975.ARW');
const result = LibRaw.isRawFile(testFile);

console.log('检查文件:', path.basename(testFile));
console.log('返回结果:', JSON.stringify(result, null, 2));

if (result.isRawFile) {
  console.log('✅ 这是 LibRaw 支持的 RAW 文件！');
} else {
  console.log('❌ 不是 LibRaw 支持的 RAW 文件');
}

// ==================== 示例 2: 错误处理 ====================
console.log('\n📝 示例 2: 处理非 RAW 文件');
console.log('-'.repeat(70));

const nonRawFile = path.resolve(__dirname, '../package.json');
const result2 = LibRaw.isRawFile(nonRawFile);

console.log('检查文件:', path.basename(nonRawFile));
console.log('isRawFile:', result2.isRawFile);
console.log('message:', result2.message);
if (result2.errorCode) {
  console.log('errorCode:', result2.errorCode);
}

// ==================== 示例 3: 实际应用场景 ====================
console.log('\n📝 示例 3: 实际应用场景');
console.log('-'.repeat(70));

// 场景 1: 文件上传验证
function validateUploadedFile(filePath) {
  const result = LibRaw.isRawFile(filePath);
  
  if (!result.isRawFile) {
    throw new Error(`文件验证失败: ${result.message}`);
  }
  
  return true;
}

// 场景 2: 批量文件过滤
function filterRawFiles(files) {
  return files.filter(file => {
    const result = LibRaw.isRawFile(file);
    return result.isRawFile;
  });
}

// 场景 3: 文件类型检测
function detectFileType(filePath) {
  const result = LibRaw.isRawFile(filePath);
  
  return {
    path: filePath,
    isRaw: result.isRawFile,
    supported: result.success,
    type: result.isRawFile ? 'RAW' : 'Other',
    details: result.message
  };
}

// 演示场景 1
console.log('\n场景 1: 文件上传验证');
try {
  validateUploadedFile(testFile);
  console.log('✅ 文件验证通过');
} catch (error) {
  console.log('❌', error.message);
}

// 演示场景 2
console.log('\n场景 2: 批量文件过滤');
const fs = require('fs');
const sampleDir = path.resolve(__dirname, '../raw-samples-repo/ARW');

if (fs.existsSync(sampleDir)) {
  const allFiles = fs.readdirSync(sampleDir)
    .map(f => path.join(sampleDir, f))
    .filter(f => fs.statSync(f).isFile());
  
  const rawFiles = filterRawFiles(allFiles);
  
  console.log(`总文件数: ${allFiles.length}`);
  console.log(`RAW 文件: ${rawFiles.length}`);
  rawFiles.forEach(f => console.log(`  - ${path.basename(f)}`));
}

// 演示场景 3
console.log('\n场景 3: 文件类型检测');
const detection = detectFileType(testFile);
console.log(JSON.stringify(detection, null, 2));

// ==================== 支持的格式说明 ====================
console.log('\n📝 支持的格式说明');
console.log('-'.repeat(70));
console.log('LibRaw.isRawFile() 方法特点：');
console.log('  ✅ 支持 100+ 种 RAW 格式（CR2, CR3, NEF, ARW, RAF, RW2, DNG 等）');
console.log('  ✅ 使用 LibRaw 内部识别机制，准确可靠');
console.log('  ✅ 无需手动维护扩展名列表');
console.log('  ✅ 轻量级检查，不完全加载文件内容');
console.log('  ✅ 基于文件内容判断，不仅依赖扩展名');

console.log('\n常见 RAW 格式：');
const formats = [
  { brand: 'Canon', format: 'CR2, CR3, CRW' },
  { brand: 'Nikon', format: 'NEF, NRW' },
  { brand: 'Sony', format: 'ARW, SR2, SRF' },
  { brand: 'Fujifilm', format: 'RAF' },
  { brand: 'Panasonic', format: 'RW2, RAW' },
  { brand: 'Olympus', format: 'ORF' },
  { brand: 'Pentax', format: 'PEF' },
  { brand: 'Leica', format: 'DNG, RWL' },
  { brand: 'Adobe/通用', format: 'DNG' },
];

formats.forEach(({ brand, format }) => {
  console.log(`  ${brand.padEnd(15)} - ${format}`);
});

console.log('\n' + '='.repeat(70));
console.log('✅ 演示完成！');
console.log('=' .repeat(70));

