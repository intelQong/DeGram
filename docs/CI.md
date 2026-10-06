# CI

## Current state

The only workflow is `.github/workflows/release.yml` ("Create Portable Cross-Platform Release").

- **Triggers:** `workflow_dispatch` (build + draft release) and `pull_request` to `dev`/`main` (build and package only; the publish job is skipped). Docs-only changes don't trigger PR builds.
- **Jobs:** build and package Linux x86_64 and Windows x64 using `scripts/build_portable.sh` and `scripts/build_portable_windows.ps1`. macOS is not supported.
- **Publish job:** reads the version from `Telegram/build/version`, then creates a **draft** GitHub release tagged `v<version>` with the packages and `SHA256SUMS.txt`.

## What each job does

Build logic is ported from upstream tdesktop v7.0.9 (`.github/workflows/linux.yml`, `win.yml`), changed from Debug to Release. Every job builds with `-D DESKTOP_APP_DISABLE_AUTOUPDATE=ON -D DESKTOP_APP_DISABLE_CRASH_REPORTS=ON` (DeGram must not use Telegram's updater or crash server), then packages the result and uploads it. If the binary is missing the packaging scripts exit 1, so a failed build never produces a placeholder release.

| Job | Steps |
| :--- | :--- |
| `build-linux-portable` (x86_64 on `ubuntu-24.04`) | Generates the Dockerfile from `Telegram/build/docker/centos_env` (`DEBUG= LTO=`, so no debug libraries and no LTO), builds the Rocky Linux 8 image with Buildx and caches layers and mounts (`actions/cache`), runs `build.sh` in it with `CONFIG=Release` and a ccache volume, then runs `scripts/build_portable.sh "" <arch> out/Release/DeGram .`. |
| `build-windows-portable` | Sets up `TBuild` next to the checkout like upstream, installs the VS toolset 14.44 and the SDK named in `docs/building-win.md`, restores ThirdParty/Libraries/Qt caches, runs `Telegram/build/prepare/win.bat silent` (without upstream's `skip-release`, because Release libraries are needed), `configure.bat x64 ...`, `cmake --build ..\out --config Release`, then `scripts/build_portable_windows.ps1 -BinaryPath out\Release\DeGram.exe`. |
| `publish-release` | Unchanged. Reads the version, collects artifacts, writes `SHA256SUMS.txt`, creates a **draft** release `v<version>`. |

## Required secrets

Repository secrets `API_ID` and `API_HASH` (see [api_credentials.md](api_credentials.md)). If either is missing the builds log a warning and use the test credentials (`-D TDESKTOP_API_TEST=ON`, as upstream CI does). Packages built that way are not suitable for release.

## Status and limits

- **Untested until the first run.** Expect to fix things on the first one or two runs.
- **Run time:** the first run with cold caches is long, roughly 2 to 5 hours per job, and Windows and Linux can approach the 360 minute limit set on each job. Later runs with warm caches should take well under an hour. Caches are evicted after 7 days of disuse and are limited to 10 GB per repository, which the library caches may exceed.
- Linux arm64 is not built. It was tried on `ubuntu-24.04-arm` and failed in the Docker library stage: the pinned rnnoise v0.2 includes a missing `os_support.h` from `src/vec_neon.h`. Upstream only builds x86_64, so arm64 would need patches to the upstream library recipes.
- Windows deletes unused preinstalled toolchains (Android SDK, CodeQL, Java, Go, PyPy, Ruby, ...) before compiling: a Release build ran out of disk on the free runner. The step logs free space before and after.
- Windows installs the ATL component for the MSVC 14.44 toolset before building (breakpad needs `atlbase.h`). Upstream builds on a Depot runner that ships it; the free `windows-latest` image does not.
- Windows library prep uses MSYS2 UCRT packages (`mingw-w64-ucrt-x86_64-*`), ported from upstream tdesktop `dev`: MSYS2 dropped `mingw-w64-x86_64-diffutils`, which broke the old recipe.
- The ccache is only saved on the default branch.
- No LTO on Linux, unlike an official release build.
- Windows is x64 only. macOS was dropped on 2026-10-06 (owner decision); its job and `scripts/build_portable_macos.sh` were removed.
- Upstream's Windows job uses `Eden-CI/msvc-dev-cmd@master` and a pinned `free-disk-space` action. They are copied as is.

## Running it

1. GitHub > Actions > "Create Portable Cross-Platform Release".
2. Run workflow, on the branch you want.
3. When it finishes, review the draft release (name `v<version>`), check the files and `SHA256SUMS.txt`, then publish by hand.

Bump the version first with `cd Telegram/build && python3 set_version.py X.Y.Z` (needs a matching top entry in `changelog.txt`).

## Re-enabling tag triggers

Only after a manual run has produced working packages (and you have tested them):

```yaml
on:
  workflow_dispatch:
  push:
    tags:
      - 'v*'
```

Check that the tag matches `Telegram/build/version`. Keep the release as a draft until the first tagged run is verified.
