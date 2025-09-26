{
  "targets": [
    {
      "target_name": "libraw_addon",
      "sources": [
        "src/addon.cpp",
        "src/libraw_wrapper.cpp"
      ],
      "include_dirs": [
        "<!@(node -p \"require('node-addon-api').include\")",
        "deps/LibRaw-Source/LibRaw-0.21.4/libraw"
      ],
      "defines": [
        "NAPI_DISABLE_CPP_EXCEPTIONS",
        "LIBRAW_NO_MEMPOOL_CHECK"
      ],
      "conditions": [
        ["OS=='win'", {
          "defines": [
            "LIBRAW_NODLL"
          ],
          "libraries": [
            "<!(node -e \"const p=require('path');const fs=require('fs');const basePath='deps/LibRaw-Source/LibRaw-0.21.4/build/windows-x64';const possiblePaths=[p.resolve(basePath,'lib/libraw_static.lib'),p.resolve(basePath,'lib/libraw.lib'),p.resolve(basePath,'libraw_static.lib'),p.resolve(basePath,'libraw.lib')];let foundPath=null;for(const path of possiblePaths){if(fs.existsSync(path)){foundPath=path;break;}}if(foundPath){process.stdout.write(foundPath);}else{console.error('LibRaw library not found. Searched paths:',possiblePaths);process.exit(1);} \")",
            "ucrt.lib",
            "vcruntime.lib",
            "oldnames.lib",
            "legacy_stdio_definitions.lib"
          ],
          "msvs_settings": {
            "VCCLCompilerTool": {
              "ExceptionHandling": 1,
              "RuntimeLibrary": 3
            }
          }
        }],
        ["OS=='mac'", {
          "libraries": [
            "<!(node -e \"const p=require('path');const plat=process.platform;const arch=process.arch;const m=(plat==='win32'?'windows':plat);const a=(arch==='arm64'?'arm64':'x64');process.stdout.write(p.resolve('deps/LibRaw-Source/LibRaw-0.21.4/build/'+m+'-'+a+'/lib/libraw.a'));\")"
          ]
        }],
        ["OS=='linux'", {
          "cflags": ["-fPIC"],
          "cxxflags": ["-fPIC"],
          "ldflags": ["-fPIC"],
          "libraries": [
            "<!(node -e \"const p=require('path');const plat=process.platform;const arch=process.arch;const m=(plat==='win32'?'windows':plat);const a=(arch==='arm64'?'arm64':'x64');process.stdout.write(p.resolve('deps/LibRaw-Source/LibRaw-0.21.4/build/'+m+'-'+a+'/lib/libraw.a'));\")"
          ]
        }]
      ]
    }
  ]
}