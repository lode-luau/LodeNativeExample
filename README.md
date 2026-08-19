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

The optional OpenSSL validation uses the build machine's OpenSSL installation
without adding a dependency field to `lode.json`:

```powershell
cmake -S . -B build-openssl `
  -G "Visual Studio 17 2022" -A x64 `
  -DCMAKE_PREFIX_PATH="<lode-sdk-prefix>" `
  -DOPENSSL_ROOT_DIR="<openssl-prefix>" `
  -DLODE_NATIVE_EXAMPLE_WITH_OPENSSL=ON `
  -DLODE_RUNTIME="<lode-sdk-prefix>/bin/Debug/lode.exe"
cmake --build build-openssl --config Debug
ctest --test-dir build-openssl -C Debug --output-on-failure
```

When enabled on Windows, the OpenSSL crypto DLL is copied beside the native
module under `libs/windows/x64/<configuration>/`. A release package must also
provide the required third-party notice in its root `NOTICE` file.

The generated library is written to:

```text
libs/windows/x64/<configuration>/native_example.dll
```

To create one package archive containing the validated Debug and Release
artifacts, run the packaging script with a matching Lode executable:

```powershell
./ci/package.ps1 `
  -Runtime "<lode-sdk-prefix>/bin/Release/lode.exe" `
  -ArchivePath "./out/native_example-1.0.0-windows-x64.zip"
```

The script validates the source package, stages only package files and Luau
sources plus `libs/`, writes a SHA-256 sidecar, extracts into a clean temporary
directory, and validates the extracted package again. The archive name is
supplied by the caller until the release naming convention is finalized.
