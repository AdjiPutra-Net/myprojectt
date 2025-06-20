#!/bin/bash
# ============================================
# 🔚 Tahap 13: Final Setup Setelah Arch Install
# ============================================

set -e

echo "🔧 Setup konfigurasi NetworkManager DNS..."
mkdir -p /etc/NetworkManager/conf.d
cat <<EOF > /etc/NetworkManager/conf.d/dns.conf
[main]
dns=none
EOF

echo "📡 Setting DNS resolv.conf manual..."
cat <<EOF > /etc/resolv.conf
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF

echo "🚀 Enable + Start NetworkManager..."
systemctl enable NetworkManager
systemctl start NetworkManager
systemctl restart NetworkManager

echo "🔁 Update sistem & install reflector..."
pacman -Syyu --noconfirm
pacman -S --noconfirm reflector

echo "🪞 Enable & Start Reflector Timer..."
systemctl enable reflector.timer
systemctl start reflector.timer

# GPU Driver Selection
echo ""
echo "🖥️  Pilih GPU driver yang sesuai:"
echo "1. AMD"
echo "2. Intel"
echo "3. NVIDIA"
echo "4. Lewatin (nggak install VGA driver)"
read -p "Masukkan pilihan [1-4]: " GPU_CHOICE

case $GPU_CHOICE in
  1)
    echo "🎮 Install driver AMD..."
    pacman -S --noconfirm mesa libva-mesa-driver vulkan-radeon
    ;;
  2)
    echo "📺 Install driver Intel..."
    pacman -S --noconfirm mesa libva-intel-driver vulkan-intel
    ;;
  3)
    echo "⚡ Install driver NVIDIA..."
    pacman -S --noconfirm nvidia nvidia-utils nvidia-settings
    ;;
  4)
    echo "⏭️  Lewatin install driver VGA."
    ;;
  *)
    echo "❌ Pilihan tidak valid. Lewatin VGA driver."
    ;;
esac

# SSH
echo ""
echo "🔐 Install dan aktifkan SSH..."
pacman -S --noconfirm openssh
systemctl unmask sshd
systemctl enable sshd
systemctl start sshd

echo ""
echo "✅ Tahap 13 selesai. Arch siap digunakan!"
echo "📦 Cek koneksi dan siap install DE atau window manager favorit lo!"