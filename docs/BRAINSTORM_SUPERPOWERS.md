# DeGram Desktop — Brainstorm & Superpowers Roadmap

This document outlines high-impact innovations, privacy superpowers, and operational capabilities brainstormed for future releases of **DeGram Desktop**.

---

## ⚡ Superpower 1: Zero-Trace Ephemeral Mode (RAM-Only Operation)

### Concept:
A mode where the application never writes session tokens, decrypted media, or SQLite history to the disk. Everything lives exclusively in RAM protected by memory-locking (`mlock`).

### Key Mechanics:
* Mounts a memory-backed storage (`tmpfs` / in-memory SQLite `:memory:`).
* Disables all disk crash logs and cache writing.
* On power loss, SIGKILL, or lock timeout, all session keys and message data instantly vanish without leaving forensic residue on SSD/NVMe drives.

---

## ⚡ Superpower 2: Multi-Passcode Decoy Vaults (Deniable Encryption)

### Concept:
Plausible deniability under coercion:
* **Passcode A (Primary)**: Unlocks the real account with full history, channels, and chats.
* **Passcode B (Decoy)**: Unlocks a harmless, innocent secondary account (with generic public channels and clean chat list).
* **Passcode C (Duress / KABOOM)**: Instantly erases all session files and terminates the process immediately.

---

## ⚡ Superpower 3: Traffic Morphing & DPI Evasion (Shadow TLS / Fronting)

### Concept:
Bypass strict network censorship, ISP throttling, and state-level Deep Packet Inspection (DPI):
* **TLS Fingerprint Camouflage**: Masks MTProto handshake packets to match standard Google Chrome / Cloudflare TLS signatures.
* **Domain Fronting & Multi-DC Failover**: Automatically rotates through obfuscated IP endpoints and Cloudflare Worker WebSocket tunnels when standard Telegram DCs are blocked.

---

## ⚡ Superpower 4: Autonomous Sentinel & Media Auto-Archiver

### Concept:
* **Background TTL Harvester**: Automatically intercepts view-once/expiring media before the sender can retract it, decrypting and saving to an encrypted vault.
* **Local OCR & Semantic Search**: On-device search for text inside memes, documents, and screenshots without sending any data to external servers.
* **Automated Honeypot / Anti-Phishing Guard**: Alerts the user when incoming links or bot messages match known scam/malware signatures.

---

## ⚡ Superpower 5: Dead Man's Switch & Remote Panic Trigger

### Concept:
* **Inactivity Timer**: If the client is not unlocked for $X$ days, automatically triggers local session sanitization.
* **Encrypted Webhook / Secret Command Trigger**: If a pre-shared encrypted message token is received from a trusted secret contact, the client performs silent local erasure.

---

## Roadmap Priority Matrix

| Feature | Complexity | Privacy Impact | Target Milestone |
| :--- | :--- | :--- | :--- |
| **Multi-Passcode Decoy Vault** | Medium | 🔥 Extremely High | v7.1.0 |
| **RAM-Only Ephemeral Mode** | Medium-High | 🔥 Extremely High | v7.2.0 |
| **DPI Evasion & TLS Camouflage** | High | 🚀 High | v7.3.0 |
| **Automated Media Harvester** | Low-Medium | 💡 High | v7.1.0 |
| **Remote Dead Man's Switch** | Low | 🛡️ High | v7.2.0 |
