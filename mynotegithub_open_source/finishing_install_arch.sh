#!/bin/bash
# =============================================
# 🐧 Tahap 13: Install AUR Helper (yay & paru)
# =============================================

set -e

echo "🔎 Deteksi username saat ini..."

# Deteksi user yang bukan root
USERNAME=$(logname 2>/dev/null || echo "$SUDO_USER")

# Validasi user
if [[ -z "$USERNAME" || "$USERNAME" == "root" ]]; then
    echo "❌ Gagal deteksi user non-root. Jalankan script ini pakai: sudo ./script.sh"
    exit 1
fi

echo "✅ Username terdeteksi: $USERNAME"

# Cek koneksi internet
echo ""
echo "🌐 Cek koneksi internet sebelum lanjut..."
if ! ping -c 2 archlinux.org &>/dev/null; then
    echo "❌ Tidak ada koneksi internet. Pastikan kamu online."
    exit 1
fi

# Pastikan user punya akses sudo
echo ""
if ! sudo -lU "$USERNAME" | grep -q '(ALL) ALL'; then
    echo "❌ User $USERNAME belum punya akses sudo. Tambahkan ke grup wheel dulu!"
    exit 1
fi

echo "📦 Install base-devel & git..."
sudo pacman -S --noconfirm --needed base-devel git

# Fungsi helper
install_aur_helper() {
    local HELPER=$1
    local URL="https://aur.archlinux.org/${HELPER}.git"

    echo ""
    echo "🐧 Install $HELPER..."

    sudo -u "$USERNAME" bash <<EOF
cd ~
rm -rf $HELPER
git clone $URL
cd $HELPER
makepkg -si --noconfirm
$HELPER --version
EOF
}

# Install yay
install_aur_helper yay

# Install paru
install_aur_helper paru

echo ""
echo "✅ AUR Helper yay & paru sukses di-install untuk user: $USERNAME"
