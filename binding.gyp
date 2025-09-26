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
        "deps/LibRaw-Source/LibRaw-0.21.4/libraw",
        "deps/lcms2-source/lcms2-2.17/include"
      ],
      "defines": [
        "NAPI_DISABLE_CPP_EXCEPTIONS",
        "LIBRAW_NO_MEMPOOL_CHECK",
        "USE_LCMS2"
      ],
      "conditions": [
        ["OS=='win'", {
          "libraries": [
            "<!(node -e \"const p=require('path');process.stdout.write(p.resolve('deps/LibRaw-Source/LibRaw-0.21.4/build/windows-x64/lib/libraw.a'));\")",
            "<!(node -e \"const p=require('path');process.stdout.write(p.resolve('deps/lcms2-source/build/windows-x64/lib/lcms2.lib'));\")"
          ],
          "msvs_settings": {
            "VCCLCompilerTool": {
              "ExceptionHandling": 1,
              "RuntimeLibrary": 2
            }
          },
          "copies": [
            {
              "destination": "<(module_root_dir)/build/Release/",
              "files": [
                "<!(node -e \"const p=require('path');const plat=process.platform;const arch=process.arch;const m=(plat==='win32'?'windows':plat);const a=(arch==='arm64'?'arm64':'x64');process.stdout.write(p.resolve('deps/LibRaw-Source/LibRaw-0.21.4/build/'+m+'-'+a+'/bin/libraw.dll'));\")"
              ]
            }
          ]
        }],
        ["OS=='mac'", {
          "libraries": [
            "<!(node -e \"const p=require('path');process.stdout.write(p.resolve('deps/LibRaw-Source/LibRaw-0.21.4/lib/.libs/libraw.a'));\")",
            "<!(node -e \"const p=require('path');process.stdout.write(p.resolve('deps/lcms2-source/lcms2-2.17/src/.libs/liblcms2.a'));\")"
          ]
        }],
        ["OS=='linux'", {
          "cflags": ["-fPIC"],
          "libraries": [
            "<!(node -e \"const p=require('path');process.stdout.write(p.resolve('deps/LibRaw-Source/LibRaw-0.21.4/build/linux-arm64/lib/libraw.a'));\")",
            "<!(node -e \"const p=require('path');process.stdout.write(p.resolve('deps/lcms2-source/build/linux-arm64/lib/liblcms2.a'));\")"
          ]
        }]
      ]
    }
  ]
}