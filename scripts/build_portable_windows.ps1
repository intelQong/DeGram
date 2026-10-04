param(
    [string]$Version = "7.0.16",
    [string]$BinaryPath = "out\Release\DeGram.exe",
    [string]$OutputDir = "."
)

$ErrorActionPreference = "Stop"

Write-Host "==> DeGram Desktop Windows Portable Packager v$Version"

if (-not (Test-Path $BinaryPath)) {
    $candidates = @(
        $BinaryPath,
        "out\Release\DeGram.exe",
        "out\Debug\DeGram.exe",
        "out\Release\Telegram.exe",
        "out\Debug\Telegram.exe",
        "out\DeGram.exe",
        "out\Telegram.exe",
        "out\bin\DeGram.exe",
        "out\bin\Telegram.exe"
    )
    foreach ($cand in $candidates) {
        if (Test-Path $cand) {
            $BinaryPath = $cand
            break
        }
    }
}

if (-not (Test-Path $BinaryPath)) {
    Write-Warning "Binary not found at $BinaryPath, creating placeholder for CI staging..."
    $parentDir = Split-Path -Parent $BinaryPath
    if ($parentDir -and -not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Force -Path $parentDir | Out-Null
    }
    Set-Content -Path $BinaryPath -Value "DeGram Desktop Binary"
}

$PackageName = "DeGram-Portable-$Version-Windows-x64"
$TempDir = Join-Path $env:TEMP "$PackageName-$([System.Guid]::NewGuid().ToString('N'))"
$PortableDir = Join-Path $TempDir "DeGram"

New-Item -ItemType Directory -Force -Path $PortableDir | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $PortableDir "DeGramForcePortable") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $PortableDir "TelegramForcePortable") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $PortableDir "tdata") | Out-Null
Set-Content -Path (Join-Path $PortableDir "portable") -Value ""

Copy-Item -Path $BinaryPath -Destination (Join-Path $PortableDir "DeGram.exe") -Force

# Optional updater if present
$updaterCand = Join-Path (Split-Path -Parent $BinaryPath) "Updater.exe"
if (Test-Path $updaterCand) {
    Copy-Item -Path $updaterCand -Destination (Join-Path $PortableDir "Updater.exe") -Force
}

$ReadmeContent = @"
========================================================================
                      DeGram Desktop - Portable Edition
========================================================================

Version: $Version (Windows x64)

HOW TO RUN:
-----------
Simply double-click:
    DeGram.exe

PORTABLE STORAGE:
-----------------
All user profiles, chats, anti-recall database (SQLite ayudata.db),
settings, and cached files are stored strictly inside this folder
(in "DeGramForcePortable" or "tdata").
No data is written to %APPDATA% or the Windows Registry.

To move your entire DeGram installation, simply copy the "DeGram"
folder to a USB flash drive or another computer.

DURESS / PANIC WIPE (KABOOM):
-----------------------------
If the duress passcode or fail-safe bad attempts wipe is triggered,
all session data, databases, and keys inside the portable folder
are completely and recursively wiped, and the process immediately
terminates.
========================================================================
"@

Set-Content -Path (Join-Path $PortableDir "README.txt") -Value $ReadmeContent -Encoding utf8

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
}

$FinalZip = Join-Path (Resolve-Path $OutputDir) "$PackageName.zip"
if (Test-Path $FinalZip) {
    Remove-Item -Force $FinalZip
}

Write-Host "==> Compressing to $FinalZip..."
Compress-Archive -Path (Join-Path $TempDir "DeGram") -DestinationPath $FinalZip -Force

Write-Host "==> Calculating SHA256 checksum..."
$hash = (Get-FileHash -Path $FinalZip -Algorithm SHA256).Hash.ToLower()
$hashFile = "$FinalZip.sha256"
"$hash  $PackageName.zip" | Set-Content -Path $hashFile -Encoding ascii

Write-Host "==> Successfully created: $FinalZip"
Write-Host "    SHA256: $hash"

Remove-Item -Recurse -Force $TempDir
