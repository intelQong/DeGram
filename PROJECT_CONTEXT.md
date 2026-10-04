# PROJECT CONTEXT: DeGram Desktop

> **Note for AI Agents & Developers**: This document provides immediate context, architectural history, component mappings, and operational guidelines for **DeGram Desktop**. Always update this file when modifying core features, adding patches, or changing build pipelines.

---

## 1. Project Overview & Identity

* **Project Name**: DeGram Desktop
* **Repository**: `intelQong/DeGram`
* **Base Codebase**: Telegram Desktop fork (C++20 / Qt6) with enhanced privacy, anti-recall, and custom UI
* **Reference & Feature Origin**: Telegraher (Android fork by Nikita S. / nikitasius) & Kangram Desktop
* **License**: GNU General Public License v3.0 (GPL-3.0)
* **Target Platforms & Packages**:
  * **Portable Edition (Primary / Official)**:
    * **Linux**: Self-contained portable tarball (`DeGram-Portable-<version>-<arch>.tar.xz`) with automatic `DeGramForcePortable` local isolation.
    * **Windows**: Self-contained portable executable (`DeGram.exe` / `DeGram-Portable-<version>-Windows-x64.zip`) with local `DeGramForcePortable` / `tdata`.
    * **macOS**: Self-contained portable application bundle (`DeGram.app` / `.zip`).
  * **CI/CD Build System**: GitHub Actions workflows building and testing portable releases for Linux, Windows, and macOS.

---

## 2. Core Philosophy & Value Proposition

DeGram Desktop restores **total local control, sovereignty, and privacy** to the user on desktop devices:
1. **No remote deletions**: Messages deleted or edited by other participants remain intact in local storage with clear visual indicators and timestamps.
2. **No arbitrary restrictions**: `noforwards`, `restrict_saving_content`, and TTL timers cannot block saving media, copying text, or forwarding.
3. **Plausible deniability & duress protection (KABOOM)**: A secondary Duress Passcode or repeated failed unlock attempts triggers an immediate recursive wipe of local data ("KABOOM") and process termination.
4. **No surveillance or advertisements**: Stripped of telemetry, trackers, and sponsored channel ads.
5. **Multi-account scale**: Supports up to 100 simultaneous accounts with client/device spoofing.
6. **Complete portability**: Portable versions on Linux, Windows, and macOS keep all data strictly in `DeGramForcePortable` without leaving traces in user or system directories.

---

## 3. Directory Layout & Architecture Map

```
/
├── .github/
│   ├── workflows/
│   │   ├── build_linux_portable.yml   # CI/CD: Packages Linux portable tarball
│   │   ├── build_windows_portable.yml # CI/CD: Packages Windows portable zip
│   │   ├── build_macos_portable.yml   # CI/CD: Packages macOS portable zip
│   │   └── release.yml                # CI/CD: Publishes cross-platform releases on git tags
│   └── art/                           # Branding assets
├── scripts/
│   ├── build_portable.sh              # Linux portable packaging script (.tar.xz)
│   ├── build_portable_windows.ps1     # Windows portable packaging script (.zip)
│   ├── build_portable_macos.sh        # macOS portable packaging script (.zip)
│   ├── bump_version.py                # Automated version increment utility
│   └── install_git_hooks.sh           # Git pre-commit hook installer
├── lib/xdg/
│   ├── com.degram.desktop.desktop     # Freedesktop desktop specification
│   ├── com.degram.desktop.metainfo.xml# AppStream metainfo metadata
│   └── com.degram.desktop.service     # D-Bus activation service
├── Telegram/
│   ├── CMakeLists.txt                 # Main CMake target definitions (output_name: DeGram)
│   ├── Resources/
│   │   ├── art/ayu/default/           # Clean application icons (app.svg, app_icon.ico)
│   │   └── langs/lang.strings         # Localization strings (rebranded to DeGram)
│   ├── SourceFiles/
│   │   ├── core/
│   │   │   ├── launcher.cpp           # CheckPortableVersionFolder (DeGramForcePortable)
│   │   │   └── version.h              # AppName = "DeGram Desktop", AppFile = "DeGram", Version 7.0.16
│   │   ├── ayu/                       # DeGram custom subsystem
│   │   │   ├── ayu_settings.h         # Settings state, duress methods & panic wipe
│   │   │   ├── ayu_settings.cpp       # JSON persistence and panic execution
│   │   │   ├── ayu_lang.cpp           # Dynamic localization and DeGram sanitization
│   │   │   ├── data/                  # SQLite database layer for anti-recall
│   │   │   └── ui/settings/           # Custom DeGram Settings UI panels
│   │   ├── data/
│   │   │   ├── data_channel.cpp       # allowsForwarding() -> true (restriction bypass)
│   │   │   ├── data_chat.cpp          # allowsForwarding() -> true
│   │   │   ├── data_user.cpp          # allowsForwarding() -> true
│   │   │   └── data_story.cpp         # forbidsForward() -> false
│   │   ├── history/
│   │   │   ├── history_item.cpp       # forbidsForward() -> false
│   │   │   └── history.cpp            # Deletion hook & message retention
│   │   ├── window/
│   │   │   ├── window_lock_widgets.cpp # Duress Passcode & bad tries panic hook
│   │   │   └── window_main_menu.cpp    # Drawer menus, Kill App button, & DeGram links
│   │   └── boxes/
│   │       └── about_box.cpp          # About DeGram dialog
│   └── build/
│       ├── version                    # Version 7.0.16 (AppVersion 7000016)
│       └── setup.iss                  # Inno Setup Windows installer script
└── docs/
    ├── ARCHITECTURE.md                # Deep technical subsystem specifications
    └── BRAINSTORM_SUPERPOWERS.md      # Future superpowers roadmap
```

---

## 4. DeGram Desktop Feature & Security Matrix

| Feature | DeGram Implementation (C++20/Qt) | Status | Key Files |
| :--- | :--- | :--- | :--- |
| **Duress Passcode / KABOOM** | `AyuSettings::isDuressPasscode()`, `PasscodeLockWidget::submit()` panic hook | ✅ Active | `window_lock_widgets.cpp`, `ayu_settings.cpp` |
| **Fail-Safe Bad Tries Wipe** | `cPasscodeBadTries()` >= 10 -> `AyuSettings::executePanicWipe()` | ✅ Active | `window_lock_widgets.cpp` |
| **Kill the App Button** | Direct drawer button invoking ungraceful exit (`std::_Exit(0)`) | ✅ Active | `window_main_menu.cpp` |
| **Native Portable Mode** | Auto-detection of `DeGramForcePortable` on Linux, Win, macOS | ✅ Active | `launcher.cpp` |
| **Anti-Recall (Deleted Messages)** | Intercept delete updates -> SQLite persistent message storage | ✅ Active | `ayu/data/ayu_database.cpp`, `history.cpp` |
| **No-Forwards Bypass** | Unconditional `true` in `allowsForwarding()` across all peer types | ✅ Active | `data_channel.cpp`, `data_chat.cpp`, `data_user.cpp` |
| **Protected Story Saving** | `Story::forbidsForward()` returns `false` | ✅ Active | `data_story.cpp` |
| **No Advertisements** | `Data::Session::sponsoredMessages()` returns empty list | ✅ Active | `ayu_settings.cpp`, `data_session.cpp` |
| **Ghost Mode** | Suppress read receipts, typing packets, and online presence | ✅ Active | `ayu_settings.cpp`, `data_send_action_manager.cpp` |
| **100+ Accounts Support** | `Main::Domain::kMaxAccounts = 100` | ✅ Active | `main_domain.h`, `main_domain.cpp` |

---

## 5. Build, Package & Release Commands

### Packaging Portable Tarball (`.tar.xz`) Locally:
```bash
./scripts/build_portable.sh "7.0.16" "x86_64" "out/Release/DeGram" "."
./scripts/build_portable.sh "7.0.16" "arm64" "out/Release/DeGram" "."
```

### Packaging Windows Portable ZIP Locally (PowerShell):
```powershell
./scripts/build_portable_windows.ps1 -Version "7.0.16" -OutputDir "."
```

### Packaging macOS Portable ZIP Locally:
```bash
./scripts/build_portable_macos.sh "7.0.16" "out/Release/DeGram.app" "."
```

### Triggering Cloud Builds (GitHub Actions):
* **Portable Release (Linux, macOS, Windows)**: Triggered on push tags matching `v*` via `.github/workflows/release.yml`.
* **Linux Portable CI**: `.github/workflows/build_linux_portable.yml`
* **macOS Portable CI**: `.github/workflows/build_macos_portable.yml`
* **Windows Portable CI**: `.github/workflows/build_windows_portable.yml`

### Version Bumping Policy:
Version numbers are kept in sync across `Telegram/build/version` and `Telegram/SourceFiles/core/version.h`.
```bash
python3 scripts/bump_version.py patch
```
Run `./scripts/install_git_hooks.sh` to install the pre-commit hook that automatically bumps and stages the new version on every commit.

### Creating a Tagged Release:
```bash
git tag v7.0.16
git push origin v7.0.16
```
This triggers `.github/workflows/release.yml` which compiles and publishes portable assets directly to GitHub Releases.
