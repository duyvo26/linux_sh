#!/usr/bin/env bash
set -euo pipefail

LIMIT_WATT="${1:-120}"                # cho phép truyền tham số, mặc định 120W
NSMI="$(command -v nvidia-smi || true)"

if [[ -z "${NSMI}" ]]; then
  echo "Không tìm thấy nvidia-smi. Cài driver NVIDIA trước đã."
  exit 1
fi

# Lấy số lượng GPU
GPU_COUNT="$(${NSMI} -L | wc -l | tr -d ' ')"
if [[ "${GPU_COUNT}" -eq 0 ]]; then
  echo "Không phát hiện GPU NVIDIA."
  exit 1
fi

# Kiểm tra giới hạn hợp lệ (so với min/max của GPU 0; thường các GPU giống nhau)
read -r MIN MAX < <(${NSMI} --query-gpu=power.min_limit,power.max_limit --format=csv,noheader,nounits | head -n1)
LIM_INT="${LIMIT_WATT%.*}"
if (( LIM_INT < ${MIN%.*} || LIM_INT > ${MAX%.*} )); then
  echo "LIMIT không hợp lệ. MIN=${MIN}W, MAX=${MAX}W, bạn đặt=${LIMIT_WATT}W"
  exit 1
fi

echo "[1/3] Đặt giới hạn ngay: ${LIMIT_WATT}W cho ${GPU_COUNT} GPU"
for i in $(seq 0 $((GPU_COUNT-1))); do
  ${NSMI} -i "$i" -pm 1 >/dev/null
  ${NSMI} -i "$i" -pl "${LIMIT_WATT}"
done
${NSMI} --query-gpu=index,power.limit --format=csv

echo "[2/3] Tạo script áp dụng lúc khởi động: /usr/local/bin/apply-gpu-power-limit.sh"
sudo tee /usr/local/bin/apply-gpu-power-limit.sh >/dev/null <<EOF
#!/usr/bin/env bash
set -euo pipefail
NSMI="$(command -v nvidia-smi || exit 0)"
LIMIT="${LIMIT_WATT}"
GPU_COUNT="\$(${NSMI} -L | wc -l | tr -d ' ')"
[[ "\$GPU_COUNT" -gt 0 ]] || exit 0
for i in \$(seq 0 \$((GPU_COUNT-1))); do
  \${NSMI} -i "\$i" -pm 1 >/dev/null || true
  \${NSMI} -i "\$i" -pl "\${LIMIT}" || true
done
EOF
sudo chmod +x /usr/local/bin/apply-gpu-power-limit.sh

echo "[3/3] Thêm vào crontab của root (@reboot)"
EXISTING="$(sudo crontab -l 2>/dev/null || true)"
if echo "${EXISTING}" | grep -q "/usr/local/bin/apply-gpu-power-limit.sh"; then
  echo "Crontab đã có mục @reboot. Bỏ qua bước thêm."
else
  (echo "${EXISTING}"; echo "@reboot /usr/local/bin/apply-gpu-power-limit.sh") | sudo crontab -
  echo "Đã thêm @reboot vào crontab."
fi

echo "Xong. Sau reboot, giới hạn sẽ là ${LIMIT_WATT}W. Có thể đổi mức bằng:"
echo "  sudo ./setup_gpu_power_limit_cron.sh 110   # ví dụ đặt 110W"
