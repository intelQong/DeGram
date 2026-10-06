<div align="center">

<img src=".github/art/degram.svg" alt="DeGram Desktop" width="112" height="112">

# DeGram Desktop

A privacy-focused, portable fork of Telegram Desktop.

[![License](https://img.shields.io/badge/license-GPL--3.0-blue?style=flat-square)](LICENSE)
[![Version](https://img.shields.io/badge/version-7.0.22-6c5ce7?style=flat-square)](changelog.txt)
[![Platforms](https://img.shields.io/badge/platforms-Linux%20%7C%20Windows%20%7C%20macOS-informational?style=flat-square)](#build)

[Architecture](docs/ARCHITECTURE.md) · [Project context](PROJECT_CONTEXT.md)

</div>

---

DeGram is built on [AyuGram Desktop](https://github.com/AyuGram/AyuGramDesktop), which is itself built on [Telegram Desktop](https://github.com/telegramdesktop/tdesktop). It keeps AyuGram's message-history and ghost-mode features and adds a portable layout, a duress/panic wipe, and client-side restriction bypasses.

> **Status:** there are no prebuilt releases yet. CI only packages binaries; it doesn't compile them (see [docs/CI.md](docs/CI.md)). Build from source for now.

## Features

| Feature | What it does | Default |
| :--- | :--- | :--- |
| **Deleted & edited messages** | Messages that other people delete stay in the chat with a deleted mark. Earlier versions of edited messages are kept too. Both are stored in `tdata/ayudata.db` (SQLite). | On |
| **Ghost mode** | Per account: stop sending read receipts, story views, online status and typing/upload status. | Off |
| **Restriction bypass** | Forwarding, copying and saving work in chats, channels and stories marked "protected content". Protected messages are re-sent rather than forwarded natively. | Always on |
| **No sponsored messages** | Hides sponsored messages in channels. | On |
| **Up to 100 accounts** | Raises the account limit to 100 (`Main::Domain::kMaxAccounts`). | — |
| **Streamer mode** | Hides DeGram windows from screen capture and recording. | Off |
| **Portable mode** | Keeps all data in a folder next to the executable. See [Portable mode](#portable-mode). | Auto |
| **KABOOM (duress wipe)** | Deletes `tdata` and exits immediately when triggered. See below. | **10 bad tries** |
| **Kill the App** | A drawer menu item that ends the process at once with `std::_Exit(0)`. Nothing is flushed to disk. | — |

### KABOOM: read this before setting a local passcode

KABOOM runs from the local-passcode lock screen. Two things trigger it:

1. **Too many wrong passcodes.** The default is **10 in a row**. This is on by default, and there's no prompt or second chance: forget your passcode and type it wrong 10 times, and every account on this device is deleted.
2. **The duress passcode,** if you set one.

When triggered, KABOOM deletes the whole `tdata` folder (all accounts, settings and `ayudata.db`) and exits. Files are **unlinked, not securely overwritten**, so forensic recovery from the disk may still be possible.

There's no in-app editor yet. To change either setting, close DeGram and edit `tdata/ayu_settings.json`:

```json
"duressPasscode": "1234",
"kaboomPinFails": 0
```

`kaboomPinFails: 0` turns off the wrong-passcode trigger. The duress passcode is stored **in plain text** in that file. Settings → DeGram Preferences → DeGram → *Duress Passcode / KABOOM Wipe* shows the current values.

### Network connections besides Telegram

DeGram doesn't include analytics, and crash reporting is **off** by default. It still makes these inherited AyuGram requests:

| Endpoint | Why |
| :--- | :--- |
| `update.ayugram.one` | Remote config: supporter badges and donation info (`ayu/utils/rc_manager.cpp`) |
| `api.exteragram.app` | Profile badges (`rc_manager.cpp`) |
| `cdn.jsdelivr.net/gh/AyuGram/Languages` | Translations for AyuGram-specific strings (`ayu/ayu_lang.cpp`) |
| Google / Yandex translate | Only if you choose that translation provider |

## Portable mode

At startup, `CheckPortableVersionFolder()` in `core/launcher.cpp` uses the first match below as the data directory:

1. `DeGramForcePortable/` next to the executable
2. `TelegramForcePortable/` next to the executable (upstream-compatible)
3. The executable's own folder, if it contains `tdata/` or a file named `portable`
4. On macOS only: `DeGram.app/Contents/Resources/{DeGram,Telegram}ForcePortable/`

If nothing matches, DeGram uses the normal per-user data directory.

The packaging scripts create `DeGramForcePortable/` for you:

```bash
./scripts/build_portable.sh  "" x86_64 out/Release/DeGram      dist/   # -> DeGram-Portable-<ver>-x86_64.tar.xz
./scripts/build_portable_macos.sh "" out/Release/DeGram.app       dist/   # -> DeGram-Portable-<ver>-macOS.zip
pwsh ./scripts/build_portable_windows.ps1 -OutputDir dist                 # -> DeGram-Portable-<ver>-Windows-x64.zip
```

An empty version argument means "read it from `Telegram/build/version`". If the binary is missing, each script exits with an error.

## Build

DeGram builds the same way as Telegram Desktop (C++20, Qt 6, CMake). The CMake target is still `Telegram`; the output file is `DeGram`.

- [Linux](docs/building-linux.md) (Docker: `Telegram/build/docker/centos_env/build_debug.sh`)
- [Windows](docs/building-win.md)
- [macOS](docs/building-mac.md)
- [API credentials](docs/api_credentials.md)

```bash
cmake --build out --config Debug --target Telegram
```

To change the version, use upstream's tool. It updates `version`, `version.h`, the `.rc` files and the AppX manifest together, and needs a matching entry at the top of `changelog.txt`:

```bash
cd Telegram/build && python3 set_version.py 7.0.23
```

## Repository map

| Path | Contents |
| :--- | :--- |
| `Telegram/SourceFiles/ayu/` | AyuGram/DeGram code: settings, SQLite storage, ghost mode, UI |
| `Telegram/SourceFiles/ayu/ayu_settings.{h,cpp}` | All DeGram settings, plus `executePanicWipe()` |
| `Telegram/SourceFiles/window/window_lock_widgets.cpp` | Duress and wrong-passcode checks |
| `Telegram/SourceFiles/window/window_main_menu.cpp` | Drawer: DeGram Preferences, Kill the App |
| `Telegram/SourceFiles/core/launcher.cpp` | Portable folder detection |
| `Telegram/SourceFiles/data/data_{channel,chat,user,story}.cpp` | Restriction bypass (`allowsForwarding`, `forbidsForward`) |
| `scripts/` | Portable packaging scripts |
| `.github/workflows/release.yml` | Manual packaging/release workflow |
| `docs/` | Architecture, build guides, CI notes, maintenance log |

## Contributing

Read [AGENTS.md](AGENTS.md) (coding conventions) and [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) (fork-specific map). The [maintenance log](docs/MAINTENANCE_LOG.md) records past cleanup passes and open issues.

## License & credits

GPL-3.0 with the OpenSSL exception. See [LICENSE](LICENSE) and [LICENSE.EXCEPTION](LICENSE.EXCEPTION).

- [Telegram Desktop](https://github.com/telegramdesktop/tdesktop) and [Desktop App Toolkit](https://github.com/desktop-app): the base client.
- [AyuGram Desktop](https://github.com/AyuGram/AyuGramDesktop) by AlexeyZavar and contributors: deleted/edited message saving, ghost mode, and most of `ayu/`.
- [Telegraher](https://github.com/nikitasius/Telegraher) by Nikita S. ([@nikitasius](https://github.com/nikitasius)): the ideas behind KABOOM, keeping view-once media, the restriction bypass, the 100-account limit and ad filtering.

DeGram is an independent project. It isn't affiliated with or endorsed by Telegram FZ-LLC.
