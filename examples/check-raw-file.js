const LibRaw = require('../lib/index');
const path = require('path');
const fs = require('fs');

/**
 * 检查文件是否为 LibRaw 支持的 RAW 格式的示例
 */
async function checkRawFiles() {
  console.log('🔍 LibRaw.isRawFile() 方法演示\n');
  console.log('=' .repeat(60));
  
  // 测试文件列表
  const testFiles = [
    // RAW 文件
    '../raw-samples-repo/ARW/DSC02975.ARW',
    '../raw-samples-repo/NEF/RAW_NIKON_D90.NEF',
    '../raw-samples-repo/CR2/sample_canon_400d1.cr2',
    '../raw-samples-repo/DNG/RAW_LEICA_M8.DNG',
    '../raw-samples-repo/RW2/RAW_PANASONIC_G1.RW2',
    
    // 非 RAW 文件 (用于测试)
    '../package.json',
    '../README.md',
    './check-raw-file.js',
  ];

  console.log('\n📋 测试文件列表：');
  console.log('=' .repeat(60));
  
  let rawCount = 0;
  let nonRawCount = 0;
  
  for (const filePath of testFiles) {
    const fullPath = path.resolve(__dirname, filePath);
    const fileName = path.basename(fullPath);
    const ext = path.extname(fullPath).toUpperCase();
    
    console.log(`\n📄 检查文件: ${fileName}`);
    console.log(`   扩展名: ${ext || '(无扩展名)'}`);
    
    // 检查文件是否存在
    if (!fs.existsSync(fullPath)) {
      console.log(`   ⚠️  文件不存在，跳过`);
      continue;
    }
    
    try {
      // 使用 isRawFile 方法检查
      const result = LibRaw.isRawFile(fullPath);
      
      if (result.isRawFile) {
        console.log(`   ✅ ${result.message}`);
        rawCount++;
        
        // 对于 RAW 文件，可以进一步获取详细信息
        try {
          const processor = new LibRaw();
          await processor.loadFile(fullPath);
          const metadata = await processor.getMetadata();
          
          console.log(`   📷 相机: ${metadata.make || '未知'} ${metadata.model || '未知'}`);
          console.log(`   📐 尺寸: ${metadata.width} x ${metadata.height}`);
          
          await processor.close();
        } catch (e) {
          // 识别为 RAW 但无法加载的情况
        }
      } else {
        console.log(`   ❌ ${result.message}`);
        if (result.errorCode) {
          console.log(`   错误代码: ${result.errorCode}`);
        }
        nonRawCount++;
      }
    } catch (error) {
      console.log(`   ❌ 检查失败: ${error.message}`);
      nonRawCount++;
    }
  }
  
  console.log('\n' + '=' .repeat(60));
  console.log('📊 检查结果统计：');
  console.log('=' .repeat(60));
  console.log(`✅ RAW 文件: ${rawCount}`);
  console.log(`❌ 非 RAW 文件: ${nonRawCount}`);
  console.log(`📁 总计: ${rawCount + nonRawCount}`);
  
  console.log('\n💡 提示：');
  console.log('   - isRawFile() 检查文件是否为 LibRaw 支持的 RAW 格式');
  console.log('   - 使用 LibRaw 内部机制，支持 100+ 种 RAW 格式');
  console.log('   - 无需手动维护扩展名列表');
  console.log('   - 轻量级检查，不完全加载文件内容');
}

/**
 * 批量检查目录中的所有文件
 */
async function checkDirectory(dirPath) {
  console.log('\n🔍 批量检查目录中的文件\n');
  console.log('=' .repeat(60));
  console.log(`📁 目录: ${dirPath}\n`);
  
  if (!fs.existsSync(dirPath)) {
    console.log('❌ 目录不存在');
    return;
  }
  
  const files = fs.readdirSync(dirPath, { withFileTypes: true });
  let rawFiles = [];
  let otherFiles = [];
  
  for (const file of files) {
    if (file.isDirectory()) continue;
    
    const fullPath = path.join(dirPath, file.name);
    
    try {
      const result = LibRaw.isRawFile(fullPath);
      
      if (result.isRawFile) {
        rawFiles.push(file.name);
      } else {
        otherFiles.push(file.name);
      }
    } catch (error) {
      otherFiles.push(file.name);
    }
  }
  
  console.log(`✅ 找到 ${rawFiles.length} 个 RAW 文件：`);
  rawFiles.forEach(name => console.log(`   📷 ${name}`));
  
  console.log(`\n📄 找到 ${otherFiles.length} 个其他文件：`);
  otherFiles.slice(0, 5).forEach(name => console.log(`   📄 ${name}`));
  if (otherFiles.length > 5) {
    console.log(`   ... 以及其他 ${otherFiles.length - 5} 个文件`);
  }
}

// 运行示例
(async () => {
  try {
    // 示例1：检查特定文件列表
    await checkRawFiles();
    
    // 示例2：检查整个目录（如果存在）
    const sampleDir = path.resolve(__dirname, '../raw-samples-repo/ARW');
    if (fs.existsSync(sampleDir)) {
      await checkDirectory(sampleDir);
    }
    
    console.log('\n✅ 演示完成！\n');
  } catch (error) {
    console.error('❌ 错误:', error.message);
    process.exit(1);
  }
})();

