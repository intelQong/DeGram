param(
    [string]$Version = "",
    [string]$BinaryPath = "out\Release\DeGram.exe",
    [string]$OutputDir = "."
)

$ErrorActionPreference = "Stop"

if (-not $Version) {
    $versionFile = Join-Path $PSScriptRoot "..\Telegram\build\version"
    $Version = ((Get-Content $versionFile | Where-Object { $_ -match '^AppVersionStr\s' }) -split '\s+')[1]
}

Write-Host "==> DeGram Desktop Windows Portable Packager v$Version"

if (-not (Test-Path $BinaryPath)) {
    $candidates = @(
        "out\Release\DeGram.exe",
        "out\Debug\DeGram.exe",
        "out\DeGram.exe"
    )
    foreach ($cand in $candidates) {
        if (Test-Path $cand) {
            $BinaryPath = $cand
            break
        }
    }
}

if (-not (Test-Path $BinaryPath)) {
    Write-Error "Binary not found at $BinaryPath. Build DeGram first (see docs/building-win.md)."
    exit 1
}

$PackageName = "DeGram-Portable-$Version-Windows-x64"
$TempDir = Join-Path $env:TEMP "$PackageName-$([System.Guid]::NewGuid().ToString('N'))"
$PortableDir = Join-Path $TempDir "DeGram"

New-Item -ItemType Directory -Force -Path $PortableDir | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $PortableDir "DeGramForcePortable") | Out-Null

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
All user profiles, chats, the deleted-messages database (ayudata.db),
settings and cache are stored inside the "DeGramForcePortable" folder.

To move your entire DeGram installation, simply copy the "DeGram"
folder to a USB flash drive or another computer.

DURESS / PANIC WIPE (KABOOM):
-----------------------------
Entering the duress passcode, or 10 wrong local passcodes in a row
(configurable, 0 = off), deletes DeGramForcePortable\tdata and exits.
Files are deleted, not securely overwritten.
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
