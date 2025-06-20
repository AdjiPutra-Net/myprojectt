#!/bin/bash
# =============================================
# 🐧 Tahap 14: Install AUR Helper (yay & paru)
# =============================================

set -e

echo "🔎 Deteksi username saat ini..."

# Coba auto-deteksi user selain root
USERNAME=$(logname 2>/dev/null || echo $SUDO_USER)

# Validasi
if [[ -z "$USERNAME" || "$USERNAME" == "root" ]]; then
    echo "❌ Tidak bisa deteksi user non-root. Pastikan jalankan script ini sebagai sudo dari user biasa."
    exit 1
fi

echo "✅ Username terdeteksi: $USERNAME"

echo ""
echo "📦 Install base-devel & git (untuk AUR helper)..."
sudo pacman -S --noconfirm --needed base-devel git

# Install yay
echo ""
echo "🐧 Install yay..."
sudo -u "$USERNAME" bash <<EOF
cd ~
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
yay --version
EOF

# Install paru
echo ""
echo "🐧 Install paru..."
sudo -u "$USERNAME" bash <<EOF
cd ~
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm
paru --version
EOF

echo ""
echo "✅ yay & paru berhasil di-install untuk user: $USERNAME"
