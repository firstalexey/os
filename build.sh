#!/bin/bash
set -e
set -o pipefail
set -x

apt update
apt install -y live-build live-config live-boot debootstrap \
    syslinux-utils xorriso squashfs-tools

lb clean --purge || true

lb config \
  --distribution bookworm \
  --archive-areas "main contrib non-free non-free-firmware" \
  --binary-images iso-hybrid \
  --architectures amd64 \
  --linux-flavours amd64 \
  --debian-installer live \
  --iso-application "ApOS" \
  --iso-volume "ApOS Live" \
  --iso-publisher "ApOS Project" \
  --bootappend-live "boot=live components username=apos hostname=apos locales=ru_RU.UTF-8 keyboard-layouts=ru"

chmod +x config/hooks/normal/*.hook.chroot 2>/dev/null || true

lb build 2>&1 | tee build.log

ls -lh *.iso
