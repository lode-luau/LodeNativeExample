param(
    [Parameter(Mandatory = $true)]
    [string] $Runtime,

    [Parameter(Mandatory = $true)]
    [string] $ArchivePath
)

$ErrorActionPreference = "Stop"

$packageRoot = (Resolve-Path (Join-Path $PSScriptRoot ".." )).Path
$runtimePath = (Resolve-Path $Runtime).Path
$archive = [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $ArchivePath))
$archiveDirectory = Split-Path -Parent $archive
$checksum = "$archive.sha256"
$workRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("lode-package-" + [guid]::NewGuid().ToString("N"))
$stageRoot = Join-Path $workRoot "stage"
$extractRoot = Join-Path $workRoot "extract"

function Invoke-Lode {
    param([string[]] $Arguments)

    & $runtimePath @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Lode command failed with exit code $LASTEXITCODE."
    }
}

function Copy-PackageFile {
    param([string] $RelativePath)

    $source = Join-Path $packageRoot $RelativePath
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
        throw "Required package file is missing: $RelativePath"
    }

    $destination = Join-Path $stageRoot $RelativePath
    $destinationDirectory = Split-Path -Parent $destination
    New-Item -ItemType Directory -Force $destinationDirectory | Out-Null
    Copy-Item -LiteralPath $source -Destination $destination
}

try {
    New-Item -ItemType Directory -Force $workRoot, $stageRoot, $extractRoot, $archiveDirectory | Out-Null

    Write-Host "Validating source package..."
    Invoke-Lode @("ci", "validate", "--artifact", $packageRoot)

    Copy-PackageFile "lode.json"
    Copy-PackageFile "init.luau"
    Copy-PackageFile "LICENSE"

    foreach ($optionalFile in @("README.md", "NOTICE")) {
        $optionalPath = Join-Path $packageRoot $optionalFile
        if (Test-Path -LiteralPath $optionalPath -PathType Leaf) {
            Copy-PackageFile $optionalFile
        }
    }

    Get-ChildItem -LiteralPath $packageRoot -Recurse -File |
        Where-Object {
            $relativePath = [System.IO.Path]::GetRelativePath($packageRoot, $_.FullName)
            $inLibraries = $relativePath.StartsWith("libs$([System.IO.Path]::DirectorySeparatorChar)", [System.StringComparison]::OrdinalIgnoreCase)
            $isRuntimeLibrary = $_.Extension.ToLowerInvariant() -in @(".dll", ".so", ".dylib")
            $isLuauSource = $_.Extension.ToLowerInvariant() -in @(".lua", ".luau") -and
                $relativePath -ne ".config.luau" -and
                -not $relativePath.StartsWith("tests$([System.IO.Path]::DirectorySeparatorChar)", [System.StringComparison]::OrdinalIgnoreCase)
            ($inLibraries -and $isRuntimeLibrary) -or $isLuauSource
        } |
        ForEach-Object {
            $relativePath = [System.IO.Path]::GetRelativePath($packageRoot, $_.FullName)
            $destination = Join-Path $stageRoot $relativePath
            New-Item -ItemType Directory -Force (Split-Path -Parent $destination) | Out-Null
            Copy-Item -LiteralPath $_.FullName -Destination $destination
        }

    if (Test-Path -LiteralPath $archive -PathType Leaf) {
        Remove-Item -LiteralPath $archive -Force
    }

    Write-Host "Creating archive..."
    Push-Location $stageRoot
    try {
        & cmake -E tar cf $archive .
        if ($LASTEXITCODE -ne 0) {
            throw "CMake archive creation failed with exit code $LASTEXITCODE."
        }
    }
    finally {
        Pop-Location
    }

    $hash = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant()
    "$hash  $([System.IO.Path]::GetFileName($archive))" | Set-Content -LiteralPath $checksum -Encoding ascii

    Write-Host "Testing clean extraction..."
    Push-Location $extractRoot
    try {
        & cmake -E tar xf $archive
        if ($LASTEXITCODE -ne 0) {
            throw "CMake archive extraction failed with exit code $LASTEXITCODE."
        }
    }
    finally {
        Pop-Location
    }
    Invoke-Lode @("ci", "validate", "--artifact", $extractRoot)

    Write-Host "Package archive: $archive"
    Write-Host "SHA-256 file: $checksum"
}
finally {
    if (Test-Path -LiteralPath $workRoot) {
        Remove-Item -LiteralPath $workRoot -Recurse -Force
    }
}
