<div align="center">

<img src=".github/art/degram.svg" alt="DeGram Desktop" width="112" height="112">

# DeGram Desktop

A privacy-focused, portable fork of Telegram Desktop.

[![License](https://img.shields.io/badge/license-GPL--3.0-blue?style=flat-square)](LICENSE)
[![Version](https://img.shields.io/badge/version-7.0.22-6c5ce7?style=flat-square)](changelog.txt)
[![Platforms](https://img.shields.io/badge/platforms-Linux%20%7C%20Windows-informational?style=flat-square)](#build)

[Architecture](docs/ARCHITECTURE.md) · [Project context](PROJECT_CONTEXT.md)

</div>

---

DeGram is highly inspired from [Telegraher](https://github.com/nikitasius/Telegraher)  built on top of [AyuGram Desktop](https://github.com/AyuGram/AyuGramDesktop). 

> “No problem. I’ll bend the door open.” - Bender Bending Rodríguez

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
| **KABOOM (duress wipe)** | Deletes `tdata` (overwriting files first, best effort) and exits when triggered. Configurable in the app. See below. | **10 bad tries** |
| **Kill the App** | A drawer menu item that ends the process at once with `std::_Exit(0)`. Nothing is flushed to disk. | — |

### KABOOM: read this before setting a local passcode

KABOOM runs from the local-passcode lock screen. Two things trigger it:

1. **Too many wrong passcodes.** The default is **10 in a row**. This is on by default, and there's no prompt or second chance: forget your passcode and type it wrong 10 times, and every account on this device is deleted.
2. **The duress passcode,** if you set one.

When triggered, KABOOM overwrites the files in `tdata` with zeros, deletes the whole `tdata` folder (all accounts, settings and `ayudata.db`) and exits. The overwrite skips symlinks and `user_data*/`, `emoji/` and `dictionaries/`; the media cache is encrypted with keys that get zeroed, so it becomes unreadable. This is **best effort, not a guaranteed secure erase**: SSDs (wear levelling) and copy-on-write or journaling filesystems may keep old copies.

To configure it, open Settings → DeGram Preferences → DeGram → *Duress Passcode / KABOOM Wipe*:

- **Wrong passcodes before wipe:** 0 turns the trigger off, the maximum is 100, the default is 10.
- **Duress passcode:** type a new one, or leave the field empty to keep the current one. A *Remove duress* button appears when one is set. It can't be the same as your local passcode.

The settings row shows e.g. "Wipe after 10 bad tries" or "Bad tries wipe off", plus ", duress passcode set".

The duress passcode is not stored in plain text. `tdata/ayu_settings.json` holds `duressPasscodeHash` (PBKDF2-SHA512, 100000 iterations, base64) and `duressPasscodeSalt` (32 random bytes, base64). An old plain `duressPasscode` key is migrated to the hash on load and removed from the file. A short numeric PIN can still be brute-forced offline from the hash, so use a longer passcode.

### Network connections

DeGram only talks to Telegram, with one exception: Google or Yandex translate, and only if you select it as the translation provider. There are no analytics, crash reporting is off by default, and there are no AyuGram or exteraGram servers or translation downloads. Developer and channel lists are built in, and there are no supporter badges.

## Portable mode

At startup, `CheckPortableVersionFolder()` in `core/launcher.cpp` uses the first match below as the data directory:

1. `DeGramForcePortable/` next to the executable
2. `TelegramForcePortable/` next to the executable (upstream-compatible)
3. The executable's own folder, if it contains `tdata/` or a file named `portable`

If nothing matches, DeGram uses the normal per-user data directory.

The packaging scripts create `DeGramForcePortable/` for you:

```bash
./scripts/build_portable.sh  "" x86_64 out/Release/DeGram      dist/   # -> DeGram-Portable-<ver>-x86_64.tar.xz
pwsh ./scripts/build_portable_windows.ps1 -OutputDir dist                 # -> DeGram-Portable-<ver>-Windows-x64.zip
```

An empty version argument means "read it from `Telegram/build/version`". If the binary is missing, each script exits with an error.

## Build

DeGram builds the same way as Telegram Desktop (C++20, Qt 6, CMake). The CMake target is still `Telegram`; the output file is `DeGram`.

- [Linux](docs/building-linux.md) (Docker: `Telegram/build/docker/centos_env/build_debug.sh`)
- [Windows](docs/building-win.md)
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

## Support

If DeGram is useful to you, you can support development with Bitcoin:

```
bc1qdf4rjhzrz3eezcm5dmf7w6tp369thk2xdskdjq
```

Contact: [@redditOwner](https://t.me/redditOwner) on Telegram. The same address is in the app under Settings → DeGram Preferences → Other → Support.

## License & credits

GPL-3.0 with the OpenSSL exception. See [LICENSE](LICENSE) and [LICENSE.EXCEPTION](LICENSE.EXCEPTION).

- [Telegram Desktop](https://github.com/telegramdesktop/tdesktop) and [Desktop App Toolkit](https://github.com/desktop-app): the base client.
- [AyuGram Desktop](https://github.com/AyuGram/AyuGramDesktop) by AlexeyZavar and contributors: deleted/edited message saving, ghost mode, and most of.
- [Telegraher](https://github.com/nikitasius/Telegraher) by Nikita S. ([@nikitasius](https://github.com/nikitasius)): the ideas behind KABOOM, keeping view-once media, the restriction bypass, the 100-account limit and ad filtering.

DeGram is an independent project. It isn't affiliated with or endorsed by Telegram FZ-LLC.
