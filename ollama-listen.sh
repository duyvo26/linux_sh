#!/bin/bash

echo "🔄 Bắt đầu cấu hình Ollama host..."

SERVICE_FILE="/etc/systemd/system/ollama.service"

echo "📂 Kiểm tra file dịch vụ Ollama..."
if [ ! -f "$SERVICE_FILE" ]; then
    echo "❌ Không tìm thấy $SERVICE_FILE — thoát!"
    exit 1
fi

echo "📝 Cập nhật OLLAMA_HOST=0.0.0.0..."
sudo sed -i '/Environment="OLLAMA_HOST=/d' "$SERVICE_FILE"
sudo sed -i '/\[Service\]/a Environment="OLLAMA_HOST=0.0.0.0"' "$SERVICE_FILE"

echo "♻️ Reload systemd..."
sudo systemctl daemon-reload

echo "🚀 Restart dịch vụ Ollama..."
sudo systemctl restart ollama

echo "🔍 Kiểm tra trạng thái dịch vụ..."
sudo systemctl status ollama --no-pager

echo "✅ Hoàn tất! Ollama đang lắng nghe trên 0.0.0.0:11434"
