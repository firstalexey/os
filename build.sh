#!/bin/bash
# ============================================================
#  ApOS build.sh — сборка live-ISO образа ApOS на базе Debian
#  Запускать на чистой Debian/Ubuntu (host-машина или VM),
#  НЕ внутри самого ApOS. Нужен интернет.
# ============================================================
set -e
# Флаг --non-interactive используется в GitHub Actions — просто игнорируем его,
# скрипт и так ничего не спрашивает.

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
# package-lists/*.list.chroot и includes.chroot/* уже подготовлены заранее —
# live-build подхватит их автоматически из папки config/

echo ">>> [4/6] Даём права hook-скриптам..."
chmod +x config/hooks/normal/*.hook.chroot 2>/dev/null || true

echo ">>> [5/6] Собираем образ (это займёт от 20 минут до пары часов)..."
sudo lb build 2>&1 | tee build.log

echo ">>> [6/6] Готово!"
ls -lh *.iso 2>/dev/null || echo "Файл .iso не найден — смотри build.log на предмет ошибок."
echo ""
echo "Итоговый ISO: live-image-amd64.hybrid.iso"
echo "Переименуй его в ApOS.iso и записывай на флешку (см. README.md)."
