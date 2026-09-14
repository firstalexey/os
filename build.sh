name: Build ApOS ISO

# Запускается вручную (кнопка "Run workflow" во вкладке Actions)
# или автоматически при пуше в ветку main.
on:
  workflow_dispatch:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-22.04
    timeout-minutes: 120
    steps:
      - name: Checkout repo
        uses: actions/checkout@v4

      - name: Install live-build and deps
        run: |
          sudo apt-get update
          sudo apt-get install -y live-build live-config live-boot debootstrap \
            syslinux-utils xorriso squashfs-tools

      - name: Free up disk space (нужно много места)
        run: |
          sudo rm -rf /usr/share/dotnet /opt/ghc /usr/local/lib/android
          df -h

      - name: Build ISO
        working-directory: .
        run: |
          chmod +x build.sh
          sudo ./build.sh --non-interactive

      - name: Upload ISO as build artifact
        uses: actions/upload-artifact@v4
        with:
          name: ApOS-iso
          path: "*.iso"
          retention-days: 14
