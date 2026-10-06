# Maintenance log

## 2026-10-06: Review & cleanup pass (PR #1)

### Bugs found and fixed

- **Fake CI binaries.** Packaging scripts and workflows created placeholder binaries when the real one was missing, and the workflows published them on `v*` tags. The scripts now exit 1 if the binary is missing.
- **Version mismatch.** Some files said 7.0.9 or 7.0.16 while the real version is 7.0.22. All are now 7.0.22.
- **Misleading KABOOM settings text.** The settings screen hardcoded "10" regardless of the configured value. It now shows the actual setting.
- **Dead paths in `executePanicWipe()`.** Removed paths that did not exist; it now deletes `tdata` under the working directory only.

### Removed

- 3 duplicate workflows: `build_linux_portable.yml`, `build_macos_portable.yml`, `build_windows_portable.yml`. `release.yml` remains.
- `scripts/bump_version.py` and `scripts/install_git_hooks.sh` (pre-commit hook). Use `Telegram/build/set_version.py`.
- Kangram handling in portable detection.
- Placeholder-binary logic in the packaging scripts.
- `README-RU.md`.

### Docs

- README rewritten.
- AyuGram attribution restored in 141 `ayu/` source headers.
- `docs/ARCHITECTURE.md` rewritten, `PROJECT_CONTEXT.md` rewritten, `docs/CI.md` added.

### Verification

Not compiled, per AGENTS.md. `scripts/build_portable.sh` was tested manually.

## 2026-10-06 — Open issues fixed (PR #1, second pass)

1. **KABOOM in-app editor.** Settings > DeGram Preferences > DeGram > "Duress Passcode / KABOOM Wipe" opens `KaboomBox` (`ayu/ui/settings/settings_ayu.cpp`): wrong passcodes before wipe (0 = off, max 100, default 10, still on by default), a duress passcode field (empty keeps the current one) and a "Remove duress" button. A duress passcode equal to the local passcode is rejected. The row shows "Wipe after N bad tries" or "Bad tries wipe off", plus ", duress passcode set".
2. **Duress passcode hashed.** `ayu_settings.json` stores `duressPasscodeHash` (PBKDF2-SHA512, 100000 iterations, base64) and `duressPasscodeSalt` (32 random bytes, base64). A legacy plain `duressPasscode` key is migrated on load and removed. A short numeric PIN can still be brute-forced offline from the hash.
3. **Overwrite before delete.** `executePanicWipe()` zeroes every file in `tdata` before deleting it, skipping symlinks and `user_data*/`, `emoji/`, `dictionaries/` (the media cache is encrypted with keys that are zeroed). Best effort: SSDs and copy-on-write or journaling filesystems may keep old copies. Then `std::_Exit(0)`.
4. **No outside servers.** `ayu/ayu_lang.{cpp,h}` deleted (no jsDelivr download; AyuGram strings use built-in English from `lang.strings`). `RCManager` is offline-only: no requests to `update.ayugram.one` or `api.exteragram.app`, built-in developer and channel lists, no supporter badges. The only optional outside connection is Google/Yandex translate when selected.
5. **Translatable strings.** KABOOM and "Kill the App" UI strings are `degram_*` keys in `Telegram/Resources/langs/lang.strings`.
6. **CI compiles.** `.github/workflows/release.yml` builds Release on Linux (x86_64 and arm64, upstream Docker `centos_env`), Windows x64 and macOS, ported from upstream tdesktop v7.0.9 workflows, then packages. Manual trigger only, draft release, `DESKTOP_APP_DISABLE_AUTOUPDATE=ON` and `DESKTOP_APP_DISABLE_CRASH_REPORTS=ON`. Needs repo secrets `API_ID` and `API_HASH` (falls back to test credentials, not releasable). Details: [CI.md](CI.md).

## Open issues / next steps

- CI is untested until its first run; arm64 Linux is the most likely to need fixes ([CI.md](CI.md)).
- The PBKDF2 hash of a short PIN is brute-forceable offline; use a longer duress passcode.
- The wipe overwrite is best effort on SSDs and copy-on-write filesystems.
- KABOOM is still on by default at 10 bad tries (deliberate).
- The new `degram_*` strings only exist in English.
- Not compiled locally (AGENTS.md).
