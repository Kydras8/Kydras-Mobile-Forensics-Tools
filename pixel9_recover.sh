#!/usr/bin/env bash
set -Eeuo pipefail
# Pixel 9 Deleted-Data Recovery (Non-Root) – pull with resume + live ETA, extract, optional PhotoRec

NO_EXTRACT=0; NO_PHOTO=0; CLEANUP=0
for a in "$@"; do
  case "$a" in
    --no-extract) NO_EXTRACT=1 ;;
    --no-photorec) NO_PHOTO=1 ;;
    --cleanup-phone) CLEANUP=1 ;;
    *) echo "[!] Unknown option: $a" >&2; exit 2 ;;
  esac
done

need(){ command -v "$1" >/dev/null 2>&1 || { echo "[!] Missing: $1" >&2; exit 1; }; }
need adb; need tar

TS="$(date +%Y%m%d-%H%M%S)"
CASE="$HOME/pixel9_cases/case-$TS"
mkdir -p "$CASE"/{tar,sdcard_extracted_ok,deleted_carve,logs,fallback_pull}
LOG="$CASE/logs/run.log"
exec > >(tee -a "$LOG") 2>&1

echo "[*] Case: $CASE"
adb start-server >/dev/null || true
STATE="$(adb get-state 2>/dev/null || true)"
if [[ "$STATE" != "device" ]]; then
  echo "[!] ADB not authorized/connected. Pair USB or Wireless debugging, approve prompt, then re-run."
  exit 1
fi

adb shell svc power stayon usb || true
adb shell 'input keyevent KEYCODE_WAKEUP; input keyevent KEYCODE_MENU' || true
echo "[*] Device:"; adb shell 'getprop ro.product.model; getprop ro.build.version.release' | tr -d '\r' | sed 's/^/    /'
adb shell 'ls -ld /storage/emulated/0' || { echo "[!] /storage/emulated/0 not found"; exit 1; }

REMOTE_TAR="/sdcard/_sd_dump.tar"; REMOTE_ERR="/sdcard/_sd_dump.err"
echo "[*] Building tar ON PHONE at $REMOTE_TAR (this can take a while)…"
adb shell "sh -c 'cd /storage/emulated/0 && (toybox tar -cf $REMOTE_TAR . 2>$REMOTE_ERR || tar -cf $REMOTE_TAR . 2>$REMOTE_ERR)'" || true
echo "[*] On-phone tar status:"; adb shell "ls -lh $REMOTE_TAR $REMOTE_ERR 2>/dev/null" || true

REMOTE_SZ="$(adb shell "stat -c %s $REMOTE_TAR 2>/dev/null" | tr -d '\r' || echo 0)"
if [[ -z "$REMOTE_SZ" || "$REMOTE_SZ" -lt 102400 ]]; then
  echo "[!] On-phone tar missing or tiny. Error log:"; adb shell "head -n 120 $REMOTE_ERR 2>/dev/null" || echo "(no $REMOTE_ERR)"
  echo "[*] Fallback: pulling directory (slower)…"; adb pull /storage/emulated/0 "$CASE/fallback_pull/sdcard" || true
  du -sh "$CASE/fallback_pull/sdcard" 2>/dev/null || true; exit 0
fi

LOCAL_TAR="$CASE/tar/_sd_dump.tar"
echo "[*] Pulling to: $LOCAL_TAR (with resume if interrupted)…"
adb pull "$REMOTE_TAR" "$LOCAL_TAR" & PULL_PID=$!
while [ ! -f "$LOCAL_TAR" ]; do sleep 1; done
if command -v pv >/dev/null; then
  echo "[*] Monitoring progress (Ctrl+C stops monitor, not the pull)…"
  pv -pterb "$LOCAL_TAR" & PV_PID=$!; wait $PULL_PID || true; kill $PV_PID 2>/dev/null || true
else
  echo "[!] 'pv' not installed. Install with: sudo apt install pv"; wait $PULL_PID || true
fi

REMOTE_SZ="$(adb shell "stat -c %s $REMOTE_TAR" | tr -d '\r')"
LOCAL_SZ="$(stat -c %s "$LOCAL_TAR" 2>/dev/null || echo 0)"
if [[ "$LOCAL_SZ" -lt "$REMOTE_SZ" ]]; then
  echo "[!] Resuming copy via dd…"; BLK=4194304; SKIP=$(( LOCAL_SZ / BLK ))
  adb shell "dd if=$REMOTE_TAR bs=$BLK skip=$SKIP status=none" | dd of="$LOCAL_TAR" bs=$BLK seek=$SKIP conv=notrunc status=progress
fi

REMOTE_SZ="$(adb shell "stat -c %s $REMOTE_TAR" | tr -d '\r')"; LOCAL_SZ="$(stat -c %s "$LOCAL_TAR")"
echo "[*] Size check: remote=$REMOTE_SZ local=$LOCAL_SZ"
if [[ "$REMOTE_SZ" != "$LOCAL_SZ" ]]; then echo "[!] Size mismatch. Re-run to resume or free disk space."; exit 1; fi

[[ "$CLEANUP" -eq 1 ]] && { echo "[*] Cleaning up on phone…"; adb shell "rm -f $REMOTE_TAR $REMOTE_ERR" || true; }

if [[ "$NO_EXTRACT" -eq 0 ]]; then
  echo "[*] Extracting to: $CASE/sdcard_extracted_ok …"; tar -xf "$LOCAL_TAR" -C "$CASE/sdcard_extracted_ok"
  echo "[*] Extracted top sizes:"; du -sh "$CASE/sdcard_extracted_ok"/* 2>/dev/null | sort -h | tail || true
else
  echo "[i] --no-extract used; skipping extraction."
fi

if [[ "$NO_PHOTO" -eq 0 ]]; then
  if command -v photorec >/dev/null 2>&1; then
    mkdir -p "$CASE/deleted_carve"; echo "=== PhotoRec ==="; echo "Source: $LOCAL_TAR"; echo "Output: $CASE/deleted_carve"
    photorec "$LOCAL_TAR" || true
  else
    echo "[i] photorec not found. Install with: sudo apt install testdisk"
  fi
fi

echo; echo "=== SUMMARY ==="; du -sh "$CASE" || true
echo "Case:       $CASE"; echo "Tar:        $LOCAL_TAR"; echo "Extracted:  $CASE/sdcard_extracted_ok"; echo "Carved:     $CASE/deleted_carve"; echo "Log:        $LOG"; echo "[*] Done."
