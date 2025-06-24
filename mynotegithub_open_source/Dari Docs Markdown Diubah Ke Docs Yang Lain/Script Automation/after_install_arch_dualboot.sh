#!/bin/bash
# ============================================
# 🔚 Tahap 12: Final Setup Setelah Arch Install
# ============================================

set -e

echo "🔧 Setting DNS via NetworkManager..."
mkdir -p /etc/NetworkManager/conf.d
cat <<EOF > /etc/NetworkManager/conf.d/dns.conf
[main]
dns=none
EOF

echo "📡 Set DNS manual ke /etc/resolv.conf..."
chattr -i /etc/resolv.conf 2>/dev/null || true
cat <<EOF > /etc/resolv.conf
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF
chattr +i /etc/resolv.conf

echo "🚀 Enable + Start NetworkManager..."
systemctl enable --now NetworkManager

# Tunggu sebentar biar NetworkManager siap
sleep 5

chattr -i /etc/resolv.conf

# Cek koneksi
echo ""
echo "🌐 Cek koneksi internet..."
if ping -c 2 archlinux.org &>/dev/null; then
  echo "✅ Koneksi internet OK!"
else
  echo "❌ Tidak ada koneksi. Cek NetworkManager dan interface."
fi

sleep 180

# Update dan install reflector
echo "🔁 Update sistem & install reflector..."
pacman -Syyu --noconfirm
pacman -S --noconfirm reflector

echo "🪞 Enable & Start Reflector Timer..."
systemctl enable --now reflector.timer

# =============================
# GPU Driver (Otomatis & Manual)
# =============================

echo ""
echo "🖥️ Deteksi GPU otomatis..."
gpu_info=$(lspci | grep -Ei 'vga|3d')
echo "🔍 GPU Terdeteksi:"
echo "$gpu_info"

echo ""
echo "🧠 Pilih driver GPU:"
echo "1. AMD"
echo "2. Intel"
echo "3. NVIDIA"
echo "4. Lewatin (tidak install)"
read -rp "Masukkan pilihan [1-4]: " GPU_CHOICE

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
    echo "⏭️  Lewatin install VGA driver."
    ;;
  *)
    echo "❌ Pilihan tidak valid. Lewatin VGA driver."
    ;;
esac

# =============================
# SSH Setup
# =============================
echo ""
echo "🔐 Install & Aktifkan SSH..."
pacman -S --noconfirm openssh
systemctl unmask sshd
systemctl enable --now sshd

# =============================
# 🎯 Finishing
# =============================

echo -e "\n🎉 \e[1mTahap 13 selesai!\e[0m"
echo "✅ Arch Linux sudah siap digunakan!"

echo -e "\n💡 \e[1mSaran Selanjutnya:\e[0m"
echo "   ➤ Install Desktop Environment (misal: Gnome, KDE, XFCE, dll)"
echo "   ➤ Install AUR helper (misal: yay, paru)"
echo "   ➤ Lakukan snapshot awal / backup konfigurasi sistem"
echo "   ➤ Tambahkan user ke grup penting (wheel, video, audio, dll jika perlu)"

echo -e "\n📌 \e[1mContoh cepat:\e[0m"
echo "   sudo pacman -Syu gnome gdm"
echo "   sudo systemctl enable gdm"
echo "   sudo pacman -S yay"

echo -e "\n🚀 \e[1mGood luck! Nikmati Arch Linux lo sekarang!\e[0m 🔥"
