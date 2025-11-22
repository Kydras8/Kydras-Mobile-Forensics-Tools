<!-- Kydras Repo Header -->
<p align="center">
  <strong>Kydras Systems Inc.</strong><br/>
  <em>Nothing is off limits.</em>
</p>

---

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

Phone: Developer options → USB debugging (ON) and approve the ADB prompt
(Or use Wireless debugging to pair/connect over Wi-Fi.)

🚦 Quick Start

git clone https://github.com/Kydras8/Kydras-Mobile-Forensics-Tools.git
cd Kydras-Mobile-Forensics-Tools
chmod +x pixel9_recover.sh pixel9_diag_dump.sh

# Optional: see what’s on the phone
./pixel9_diag_dump.sh

# One-shot recovery (build tar on-phone, pull with resume, extract, optional PhotoRec)
./pixel9_recover.sh --cleanup-phone

Useful flags

./pixel9_recover.sh --no-extract      # keep only the tar; extract later
./pixel9_recover.sh --no-photorec     # skip launching PhotoRec
./pixel9_recover.sh --cleanup-phone   # delete on-phone tar after successful pull

📂 Output Structure

~/pixel9_cases/case-YYYYMMDD-HHMMSS/
 ├── tar/_sd_dump.tar           # Raw phone dump
 ├── sdcard_extracted_ok/       # Extracted files (if enabled)
 ├── deleted_carve/             # PhotoRec outputs (if run)
 ├── fallback_pull/             # Directory pull if tar fails
 └── logs/run.log               # Script log

🧰 Troubleshooting

    adb devices shows unauthorized
    Revoke USB debugging on phone → toggle USB debugging OFF/ON → replug → approve prompt.
    You can also pair via Wireless debugging (Developer options).

    Copy seems stuck
    It’s usually building the on-phone tar or waiting on ADB. Keep the screen unlocked.
    You can watch the local file grow: pv -pterb ~/pixel9_cases/.../_sd_dump.tar

    Permission errors under /sdcard/Android/data
    Normal on Android 11+ (scoped storage). Prefer /sdcard/Android/media, DCIM, Pictures, Download.

🔖 Versioning & Releases

Tag a version so others can pin it:

git tag -a v1.0.0 -m "Initial public release"
git push origin v1.0.0

Clone a specific version:

git clone --branch v1.0.0 https://github.com/Kydras8/Kydras-Mobile-Forensics-Tools.git

🌐 Project Website (GitHub Pages)



