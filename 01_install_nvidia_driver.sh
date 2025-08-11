#!/usr/bin/env bash
set -euo pipefail

echo "[1/5] Update hệ thống"
sudo apt update && sudo apt -y upgrade

echo "[2/5] Gỡ sạch NVIDIA cũ (nếu có)"
sudo apt -y remove --purge '^nvidia-.*' || true
sudo apt -y autoremove
sudo apt -y clean

echo "[3/5] Cài tiện ích & thêm PPA"
sudo apt -y install software-properties-common dkms build-essential
sudo add-apt-repository -y ppa:graphics-drivers/ppa
sudo apt update

echo "[4/5] Cài driver NVIDIA (khuyến nghị cho RTX 3060)"
sudo apt -y install nvidia-driver-535

echo "[5/5] Hoàn tất driver. KHÔNG reboot lúc này (sẽ reboot ở script 02)."
echo "Bạn có thể kiểm tra sau khi reboot bằng: nvidia-smi"
