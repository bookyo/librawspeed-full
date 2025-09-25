# 使用示例

**版本 1.0.34** - 现已在 [npmjs.com](https://www.npmjs.com/package/librawspeed) 上可用！🎉

## 基础 RAW 文件处理

```javascript
const LibRaw = require('librawspeed');

async function basicExample() {
  const processor = new LibRaw();
  
  try {
    await processor.loadFile('photo.nef');
    const metadata = await processor.getMetadata();
    const size = await processor.getImageSize();
    
    console.log(`📷 ${metadata.make} ${metadata.model}`);
    console.log(`📐 ${size.width}x${size.height} 像素`);
    console.log(`⚙️  ISO ${metadata.iso}, f/${metadata.aperture}`);
    
  } finally {
    await processor.close();
  }
}
```

## 批量处理多个文件

```javascript
const fs = require('fs');
const path = require('path');

async function batchProcess(directory) {
  const files = fs.readdirSync(directory)
    .filter(file => ['.nef', '.cr3', '.arw'].includes(path.extname(file).toLowerCase()));
  
  const results = [];
  
  for (const file of files) {
    const processor = new LibRaw();
    try {
      await processor.loadFile(path.join(directory, file));
      const metadata = await processor.getMetadata();
      const size = await processor.getImageSize();
      
      results.push({
        filename: file,
        camera: `${metadata.make} ${metadata.model}`,
        megapixels: (size.width * size.height / 1000000).toFixed(1),
        iso: metadata.iso,
        captureDate: new Date(metadata.timestamp * 1000)
      });
      
    } catch (error) {
      console.error(`处理 ${file} 失败: ${error.message}`);
    } finally {
      await processor.close();
    }
  }
  
  return results;
}
```

## 照片画廊元数据提取

```javascript
async function extractGalleryMetadata(photoPath) {
  const processor = new LibRaw();
  
  try {
    await processor.loadFile(photoPath);
    const metadata = await processor.getMetadata();
    const size = await processor.getImageSize();
    
    return {
      // 基本信息
      camera: {
        make: metadata.make,
        model: metadata.model
      },
      
      // 技术设置
      settings: {
        iso: metadata.iso,
        aperture: metadata.aperture,
        shutterSpeed: metadata.shutterSpeed,
        focalLength: metadata.focalLength
      },
      
      // 图像规格
      image: {
        width: size.width,
        height: size.height,
        megapixels: Number((size.width * size.height / 1000000).toFixed(1)),
        aspectRatio: (size.width / size.height).toFixed(2)
      },
      
      // 拍摄信息
      capture: {
        timestamp: metadata.timestamp,
        date: new Date(metadata.timestamp * 1000).toISOString(),
        artist: metadata.artist,
        copyright: metadata.copyright
      }
    };
    
  } finally {
    await processor.close();
  }
}
```

## 性能监控

```javascript
async function monitoredProcessing(filepath) {
  const processor = new LibRaw();
  const startTime = Date.now();
  
  try {
    console.time('总处理时间');
    
    console.time('文件加载');
    await processor.loadFile(filepath);
    console.timeEnd('文件加载');
    
    console.time('元数据提取');
    const metadata = await processor.getMetadata();
    console.timeEnd('元数据提取');
    
    console.time('尺寸检测');
    const size = await processor.getImageSize();
    console.timeEnd('尺寸检测');
    
    console.timeEnd('总处理时间');
    
    const fileStats = require('fs').statSync(filepath);
    const throughput = fileStats.size / (Date.now() - startTime) * 1000 / 1024 / 1024;
    
    console.log(`📊 吞吐量: ${throughput.toFixed(2)} MB/s`);
    
    return { metadata, size };
    
  } finally {
    await processor.close();
  }
}
```

## 错误处理最佳实践

```javascript
async function robustProcessing(filepath) {
  const processor = new LibRaw();
  
  try {
    // 验证文件存在
    if (!require('fs').existsSync(filepath)) {
      throw new Error(`文件未找到: ${filepath}`);
    }
    
    // 检查文件扩展名
    const ext = require('path').extname(filepath).toLowerCase();
    const supported = ['.nef', '.cr2', '.cr3', '.arw', '.raf', '.rw2', '.dng'];
    if (!supported.includes(ext)) {
      throw new Error(`不支持的格式: ${ext}`);
    }
    
    await processor.loadFile(filepath);
    
    // 带超时的提取
    const timeout = new Promise((_, reject) => 
      setTimeout(() => reject(new Error('处理超时')), 30000)
    );
    
    const processing = Promise.all([
      processor.getMetadata(),
      processor.getImageSize()
    ]);
    
    const [metadata, size] = await Promise.race([processing, timeout]);
    
    return { metadata, size, success: true };
    
  } catch (error) {
    console.error(`处理 ${filepath} 时出错:`, error.message);
    return { error: error.message, success: false };
  } finally {
    try {
      await processor.close();
    } catch (closeError) {
      console.warn('警告: 关闭处理器失败:', closeError.message);
    }
  }
}
```

## 与 Express.js 集成

```javascript
const express = require('express');
const multer = require('multer');
const LibRaw = require('librawspeed');

const app = express();
const upload = multer({ dest: 'uploads/' });

app.post('/analyze-raw', upload.single('rawFile'), async (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: '未上传文件' });
  }
  
  const processor = new LibRaw();
  
  try {
    await processor.loadFile(req.file.path);
    const metadata = await processor.getMetadata();
    const size = await processor.getImageSize();
    
    res.json({
      success: true,
      data: {
        camera: `${metadata.make} ${metadata.model}`,
        resolution: `${size.width}x${size.height}`,
        settings: {
          iso: metadata.iso,
          aperture: metadata.aperture,
          shutterSpeed: metadata.shutterSpeed,
          focalLength: metadata.focalLength
        },
        captureDate: new Date(metadata.timestamp * 1000).toISOString()
      }
    });
    
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  } finally {
    await processor.close();
    // 清理上传的文件
    require('fs').unlinkSync(req.file.path);
  }
});
```
