#!/bin/bash
set -e
set -x

echo ">>> [1/6] Устанавливаем live-build и зависимости..."
sudo apt update
sudo apt install -y live-build live-config live-boot debootstrap \
    syslinux-utils xorriso squashfs-tools

WORKDIR="$(cd "$(dirname "$0")" && pwd)"
cd "$WORKDIR"

echo ">>> [2/6] Конфигурируем сборку (Debian stable, XFCE, гибридный ISO)..."
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

echo ">>> [3/6] Копируем списки пакетов и кастомные файлы (уже лежат в config/)..."

echo ">>> [4/6] Даём права hook-скриптам..."
chmod +x config/hooks/normal/*.hook.chroot 2>/dev/null || true

echo ">>> [5/6] Собираем образ (это займёт от 20 минут до пары часов)..."
sudo lb build 2>&1 | tee build.log

echo ">>> [6/6] Готово!"
ls -lh *.iso 2>/dev/null || echo "Файл .iso не найден — смотри build.log на предмет ошибок."
