# LodeNativeExample

Minimal native Lode package built outside the `LodeRuntime` source tree.

The package uses the installed SDK through the standard CMake package:

```powershell
cmake -S . -B build `
  -G "Visual Studio 17 2022" -A x64 `
  -DCMAKE_PREFIX_PATH="<lode-sdk-prefix>" `
  -DLODE_RUNTIME="<lode-sdk-prefix>/bin/Debug/lode.exe"
cmake --build build --config Debug
ctest --test-dir build -C Debug --output-on-failure
```

`tests/run.luau` loads the native implementation with
`require("@native_example")`. The local `.config.luau` maps that alias to
`.`. The package's `init.luau` contains Luau types; the runtime loads the
native library selected by `lode.json`.

The generated library is written to:

```text
libs/windows/x64/<configuration>/native_example.dll
```
