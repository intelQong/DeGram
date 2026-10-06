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

## Open issues / next steps

- KABOOM is on by default (10 bad passcode tries) and there is no in-app editor for it.
- The duress passcode is stored in plain text in `tdata/ayu_settings.json`.
- The wipe unlinks files; it is not a secure erase.
- CI has no compile step, so no release can be produced yet ([CI.md](CI.md)).
- DeGram still contacts AyuGram and exteraGram servers (`update.ayugram.one`, `api.exteragram.app`, jsDelivr).
- UI strings for KABOOM and "Kill the App" are hardcoded English, not in `lang.strings`.
