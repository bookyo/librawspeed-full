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
        "deps/lcms2-source/build/darwin-arm64/include"
      ],
      "defines": [
        "NAPI_DISABLE_CPP_EXCEPTIONS",
        "LIBRAW_NO_MEMPOOL_CHECK",
        "USE_LCMS2"
      ],
      "libraries": [
        "<!(node -e \"const p=require('path');process.stdout.write(p.resolve('deps/LibRaw-Source/LibRaw-0.21.4/lib/.libs/libraw.a'));\")",
        "<!(node -e \"const p=require('path');process.stdout.write(p.resolve('deps/lcms2-source/build/darwin-arm64/lib/liblcms2.a'));\")"
      ],
      "conditions": [
        ["OS=='win'", {
          "libraries": [
            "<!(node -e \"const p=require('path');process.stdout.write(p.resolve('deps/LibRaw-Source/LibRaw-0.21.4/lib/.libs/libraw.a'));\")"
          ]
        }],
        ["OS=='mac'", {
          "libraries": [
            "<!(node -e \"const p=require('path');process.stdout.write(p.resolve('deps/LibRaw-Source/LibRaw-0.21.4/lib/.libs/libraw.a'));\")"
          ]
        }],
        ["OS=='linux'", {
          "cflags": ["-fPIC"],
          "libraries": [
            "<!(node -e \"const p=require('path');process.stdout.write(p.resolve('deps/LibRaw-Source/LibRaw-0.21.4/lib/.libs/libraw.a'));\")"
          ]
        }]
      ]
    }
  ]
}