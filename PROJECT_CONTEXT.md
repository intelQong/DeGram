# Project context

Fork map for agents and developers. Coding conventions are in [AGENTS.md](AGENTS.md); user-facing docs are in [README.md](README.md); how the subsystems work is in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

> **Rule:** update this file and [docs/MAINTENANCE_LOG.md](docs/MAINTENANCE_LOG.md) when changing fork features or pipelines.

## Identity

- DeGram Desktop 7.0.22, a fork of [AyuGram Desktop](https://github.com/AyuGram/AyuGramDesktop), which is a fork of [Telegram Desktop](https://github.com/telegramdesktop/tdesktop).
- C++20, Qt 6, CMake. The CMake target is still `Telegram`; the output binary is `DeGram`.
- GPL-3.0 with the OpenSSL exception.
- Source headers in `ayu/` keep the AyuGram attribution ("modified for DeGram", Copyright @Radolyn).

## Directory map

| Path | Contents |
| :--- | :--- |
| `Telegram/SourceFiles/ayu/` | AyuGram/DeGram module |
| `ayu/ayu_settings.{h,cpp}` | `AyuSettings`, ghost settings, `executePanicWipe()` |
| `ayu/ayu_worker.cpp`, `ayu_state.cpp`, `ayu_url_handlers.cpp` | Background worker, state, URL handlers |
| `ayu/data/` | SQLite storage (`ayu_database.*`, `messages_storage.*`) |
| `ayu/features/` | `forward/`, `filters/`, `translator/`, `message_shot/`, `streamer_mode/` |
| `ayu/ui/` | Settings, message history, context menu, boxes |
| `ayu/utils/` | `rc_manager.cpp` (offline-only), `telegram_helpers.cpp`, `ayu_mapper.cpp` |
| `Telegram/SourceFiles/core/launcher.cpp` | Portable folder detection |
| `Telegram/SourceFiles/window/window_lock_widgets.cpp` | KABOOM triggers |
| `Telegram/SourceFiles/window/window_main_menu.cpp` | Drawer: DeGram Preferences, Kill the App |
| `Telegram/SourceFiles/data/data_{channel,chat,user,story}.cpp` | Restriction bypass |
| `Telegram/build/` | `set_version.py`, `version`, Docker build env |
| `scripts/` | `build_portable.sh`, `build_portable_macos.sh`, `build_portable_windows.ps1` |
| `.github/workflows/release.yml` | Manual compile and packaging workflow ([docs/CI.md](docs/CI.md)) |
| `docs/` | Architecture, CI, maintenance log, build guides |

## Features

| Feature | Key files | Default |
| :--- | :--- | :--- |
| Deleted/edited message history | `ayu/data/`, `ayu/ui/message_history/` | On |
| Ghost mode | `ayu/ayu_settings.h`, `api/api_*.cpp` | Off (per account) |
| Restriction bypass | `history/history_item_helpers.cpp`, `data/data_{channel,chat,user}.cpp`, `ayu/features/forward/ayu_forward.cpp` | Always on |
| KABOOM | `window/window_lock_widgets.cpp`, `ayu/ayu_settings.cpp` | On: 10 bad passcode tries (editable in app) |
| Kill the App | `window/window_main_menu.cpp` | Menu item |
| No sponsored messages | `data/components/sponsored_messages.cpp` | On (`disableAds`) |
| 100 accounts | `main/main_domain.h` (`kMaxAccounts`) | Always |
| Streamer mode | `ayu/features/streamer_mode/` | Off |
| Portable mode | `core/launcher.cpp`, `scripts/` | Auto-detected |
| Crash reporting | n/a | Off |

## Commands

Build (see [docs/building-linux.md](docs/building-linux.md), [building-win](docs/building-win.md), [building-mac](docs/building-mac.md)):

```bash
cmake --build out --config Debug --target Telegram
```

Package (empty version = read `Telegram/build/version`; each script exits 1 if the binary is missing):

```bash
./scripts/build_portable.sh [VERSION] [ARCH] [BINARY] [OUTDIR]
./scripts/build_portable_macos.sh [VERSION] [APP] [OUTDIR]
pwsh ./scripts/build_portable_windows.ps1 -Version X -BinaryPath P -OutputDir D
```

Each package contains `DeGramForcePortable/` and a `README.txt`. Linux also gets `DeGram.sh` (launches with `-workdir DeGramForcePortable`), a `.desktop` file and an SVG icon.

Version: add a matching top entry to `changelog.txt`, then:

```bash
cd Telegram/build && python3 set_version.py X.Y.Z
```

This updates `build/version`, `core/version.h`, `winrc/*.rc` and the AppX manifest. `scripts/bump_version.py` and the pre-commit hook script no longer exist.

Release: Actions > "Create Portable Cross-Platform Release" > Run workflow. It creates a draft release `v<version>`. It compiles Release builds (Linux x86_64, Windows x64, macOS) and packages them. It is untested until its first run; see [docs/CI.md](docs/CI.md).

AGENTS.md says not to compile in agent sessions.
