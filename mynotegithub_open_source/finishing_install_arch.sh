#!/bin/bash
# ========================================================
# 🐧 Tahap 13: Smart Install AUR Helper (yay & paru)
# ========================================================

set -e

echo -e "\n🔍 \033[1mDeteksi Username Non-Root...\033[0m"

# Deteksi user non-root (jangan root)
USERNAME=$(logname 2>/dev/null || echo "$SUDO_USER")

if [[ -z "$USERNAME" || "$USERNAME" == "root" ]]; then
    echo -e "❌ \033[1;31mGagal deteksi user non-root.\033[0m Jalankan dengan: \033[1msudo ./script.sh\033[0m"
    exit 1
fi

echo "✅ Username terdeteksi: $USERNAME"

# Validasi tools penting
echo -e "\n🔎 Cek dependency tool penting..."

for cmd in sudo git makepkg; do
    if ! command -v $cmd &>/dev/null; then
        echo "❌ Perintah '$cmd' tidak ditemukan. Install dulu!"
        exit 1
    fi
done

# Cek koneksi internet
echo -e "\n🌐 Cek koneksi internet..."
if ! ping -c 2 archlinux.org &>/dev/null; then
    echo "❌ Tidak ada koneksi internet. Pastikan kamu online."
    exit 1
fi

# Cek akses sudo user
if ! sudo -lU "$USERNAME" | grep -q '(ALL) ALL'; then
    echo "❌ User '$USERNAME' belum punya akses sudo. Tambahkan ke grup wheel!"
    exit 1
fi

echo -e "\n📦 Install dependency: base-devel & git"
sudo pacman -S --noconfirm --needed base-devel git

# Fungsi instalasi helper
install_aur_helper() {
    local HELPER=$1
    local URL="https://aur.archlinux.org/${HELPER}.git"

    if command -v "$HELPER" &>/dev/null; then
        echo -e "✅ $HELPER sudah terinstall. Skip instalasi."
        return
    fi

    echo -e "\n🚀 Install AUR Helper: \033[1m$HELPER\033[0m"

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
        echo "❌ Gagal install $HELPER. Cek errornya manual."
    fi
}

# Eksekusi instalasi
install_aur_helper yay
install_aur_helper paru

echo -e "\n✅ \033[1mSelesai!\033[0m AUR Helper yay & paru berhasil di-install untuk user: \033[1m$USERNAME\033[0m"
