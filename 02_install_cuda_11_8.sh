#!/usr/bin/env bash
set -euo pipefail

CUDA_DEB="cuda-repo-ubuntu2204-11-8-local_11.8.0-520.61.05-1_amd64.deb"
CUDA_URL="https://developer.download.nvidia.com/compute/cuda/11.8.0/local_installers/${CUDA_DEB}"

echo "[1/6] Tải CUDA 11.8 local repo"
wget -c "${CUDA_URL}"

echo "[2/6] Cài repo CUDA 11.8"
sudo dpkg -i "${CUDA_DEB}"
sudo cp /var/cuda-repo-ubuntu2204-11-8-local/cuda-*-keyring.gpg /usr/share/keyrings/ || true
sudo apt update

echo "[3/6] Cài CUDA 11.8"
sudo apt -y install cuda-11-8

echo "[4/6] Thiết lập biến môi trường (nếu chưa có)"
BASHRC="${HOME}/.bashrc"
grep -q '\/usr\/local\/cuda-11\.8\/bin' "$BASHRC" || echo 'export PATH=/usr/local/cuda-11.8/bin${PATH:+:${PATH}}' >> "$BASHRC"
grep -q '\/usr\/local\/cuda-11\.8\/lib64' "$BASHRC" || echo 'export LD_LIBRARY_PATH=/usr/local/cuda-11.8/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}' >> "$BASHRC"

# (Tùy chọn) cài cuDNN 8 cho CUDA 11.x qua apt nếu bạn đã thêm repo ML của NVIDIA
# sudo apt -y install libcudnn8 libcudnn8-dev

echo "[5/6] Hoàn tất cài CUDA 11.8."
echo "Sau khi máy khởi động lại, kiểm tra bằng:"
echo "  nvcc --version   # thông tin CUDA"
echo "  nvidia-smi       # thông tin driver/GPU"

echo "[6/6] Reboot để áp dụng driver + CUDA"
sudo reboot
