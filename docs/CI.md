# CI

## Current state

The only workflow is `.github/workflows/release.yml` ("Create Portable Cross-Platform Release").

- **Trigger:** `workflow_dispatch` only. No tag or push triggers.
- **Jobs:** package for Linux (x86_64 and arm64), Windows x64 and macOS using `scripts/build_portable.sh`, `scripts/build_portable_windows.ps1` and `scripts/build_portable_macos.sh`.
- **Publish job:** reads the version from `Telegram/build/version`, then creates a **draft** GitHub release tagged `v<version>` with the packages and `SHA256SUMS.txt`.

## Why it fails today

The workflow does not compile DeGram. Each packaging job expects a finished binary at `out/Release/DeGram`, `out/Release/DeGram.exe` or `out/Release/DeGram.app`. Nothing produces one, so the scripts exit 1 and the job fails. This is intentional: earlier scripts and workflows created placeholder binaries and published them on `v*` tags. That bug is fixed, and the scripts now refuse to package a missing binary.

## What to add

Put a build step before each packaging step that produces the binary at the expected path.

| OS | Notes |
| :--- | :--- |
| Linux | Follow [building-linux.md](building-linux.md). The Docker environment is in `Telegram/build/docker/centos_env` (`build.sh`, `build_debug.sh`). Needs a build per architecture; arm64 uses the `ubuntu-24.04-arm` runner. |
| Windows | Follow [building-win.md](building-win.md). Output must end up as `out/Release/DeGram.exe`. |
| macOS | Follow [building-mac.md](building-mac.md). Output must end up as `out/Release/DeGram.app`. |

API credentials are needed for a working build: [api_credentials.md](api_credentials.md). Full builds are long and large, so expect to need caching of dependencies.

## Running it

1. GitHub > Actions > "Create Portable Cross-Platform Release".
2. Run workflow, on the branch you want.
3. When it finishes, review the draft release (name `v<version>`), check the files and `SHA256SUMS.txt`, then publish by hand.

Bump the version first with `cd Telegram/build && python3 set_version.py X.Y.Z` (needs a matching top entry in `changelog.txt`).

## Re-enabling tag triggers

Only after a real build step exists and a manual run has produced working packages:

```yaml
on:
  workflow_dispatch:
  push:
    tags:
      - 'v*'
```

Check that the tag matches `Telegram/build/version`. Keep the release as a draft until the first tagged run is verified.
