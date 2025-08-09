cd ~/Kydras-Mobile-Forensics-Tools

cat > README.md <<'EOF'
<p align="center">
  <a href="https://github.com/Kydras8/Kydras-Mobile-Forensics-Tools/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/Kydras8/Kydras-Mobile-Forensics-Tools?color=blue&style=for-the-badge" alt="License">
  </a>
  <a href="#">
    <img src="https://img.shields.io/badge/shell-bash-green?style=for-the-badge&logo=gnu-bash" alt="Shell">
  </a>
  <a href="https://github.com/Kydras8/Kydras-Mobile-Forensics-Tools/commits/main">
    <img src="https://img.shields.io/github/last-commit/Kydras8/Kydras-Mobile-Forensics-Tools?style=for-the-badge" alt="Last Commit">
  </a>
</p>

<h1 align="center">📱 Pixel 9 Deleted-Data Recovery Toolkit (Non-Root)</h1>

<p align="center">
  Full /sdcard imaging, resumable pulls with live ETA, optional extraction, and deleted-file carving — without rooting the device.
</p>

---

## 🚀 Features
- **Non-root full `/sdcard` dump** (tar built **on-device**)
- **Resumable transfers** with live speed/ETA via `pv`
- **Optional auto-extraction** to a timestamped case folder
- **PhotoRec integration** for **deleted file carving**
- Safe workflow (read-only; no bootloader unlock)

---

## 📁 Repo Contents
- **`pixel9_recover.sh`** — One-shot recovery:
  - Builds `/sdcard/_sd_dump.tar` on the phone
  - Pulls with resume + live ETA (`pv`)
  - Verifies sizes, optionally extracts locally
  - Can launch **PhotoRec** for carving
  - Output case at `~/pixel9_cases/case-YYYYMMDD-HHMMSS/`
- **`pixel9_diag_dump.sh`** — Fast diagnostics:
  - Keeps device awake, prints model/OS
  - Lists `/storage/emulated/0` sizes + sample files
  - Shows other emulated users (e.g., `/storage/emulated/10`)
  - Handy to confirm what exists before a big pull

---

## ✅ Requirements
Linux (Kali/Ubuntu/Debian) and:
```bash
sudo apt update
sudo apt install -y android-tools-adb testdisk pv
