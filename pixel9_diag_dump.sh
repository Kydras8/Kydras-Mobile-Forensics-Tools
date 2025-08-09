#!/usr/bin/env bash
set -Eeuo pipefail
adb devices
adb shell svc power stayon usb || true
adb shell 'input keyevent KEYCODE_WAKEUP; input keyevent KEYCODE_MENU' || true
adb shell 'id; getprop ro.product.model; getprop ro.build.version.release' || true
adb shell 'ls -ld /sdcard /storage/emulated/0' || true
adb shell 'ls -la /storage/emulated/0 | head -n 80' || true
adb shell 'du -sh /storage/emulated/0/{DCIM,Pictures,Download,Movies,Music,Documents,Android,Android/media} 2>/dev/null' || true
adb shell 'find /storage/emulated/0 -maxdepth 3 -type f 2>/dev/null | head -n 40' || true
adb shell 'ls -l /storage/emulated' || true
