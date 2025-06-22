#!/bin/bash
# ========================================================
# 🐧 Tahap 13: Smart Install AUR Helper (yay & paru)
# ========================================================

set -e

echo
echo "🔍 Deteksi Username Non-Root..."

# Deteksi user non-root
USERNAME=$(logname 2>/dev/null || echo "$SUDO_USER")

if [[ -z "$USERNAME" || "$USERNAME" == "root" ]]; then
    echo "❌ Gagal deteksi user non-root."
    echo "➡️  Jalankan script ini pakai: sudo ./install_aur_helpers.sh"
    exit 1
fi

echo "✅ Username terdeteksi: $USERNAME"

# Validasi tools penting
echo
echo "🔎 Cek dependency tool penting..."
for cmd in sudo git makepkg; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "❌ Perintah '$cmd' tidak ditemukan. Install dulu!"
        exit 1
    fi
done

# Cek koneksi internet
echo
echo "🌐 Cek koneksi internet..."
if ! ping -c 2 archlinux.org &>/dev/null; then
    echo "❌ Tidak ada koneksi internet. Pastikan kamu online."
    exit 1
fi

# Cek akses sudo user
if ! sudo -lU "$USERNAME" | grep -q '(ALL) ALL'; then
    echo "❌ User '$USERNAME' belum punya akses sudo. Tambahkan ke grup wheel!"
    exit 1
fi

# Install dependency
echo
echo "📦 Install base-devel & git..."
sudo pacman -S --noconfirm --needed base-devel git

# Fungsi install helper
install_aur_helper() {
    local HELPER=$1
    local URL="https://aur.archlinux.org/${HELPER}.git"

    if command -v "$HELPER" &>/dev/null; then
        echo "✅ $HELPER sudah terinstall. Lewati instalasi."
        return
    fi

    echo
    echo "🚀 Install AUR Helper: $HELPER"

    sudo -u "$USERNAME" bash <<EOF
cd ~
rm -rf $HELPER
git clone $URL
cd $HELPER
makepkg -si --noconfirm
EOF

    if command -v "$HELPER" &>/dev/null; then
        echo "✅ $HELPER berhasil di-install. Versi: $($HELPER --version | head -n1)"
    else
        echo "❌ Gagal install $HELPER. Cek log error-nya."
    fi
}

# Eksekusi instalasi
install_aur_helper yay
install_aur_helper paru

echo
echo "✅ Selesai! AUR Helper yay & paru berhasil di-install untuk user: $USERNAME"
