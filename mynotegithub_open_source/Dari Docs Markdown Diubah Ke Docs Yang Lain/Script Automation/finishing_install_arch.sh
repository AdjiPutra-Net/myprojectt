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
    echo "➡️  Jalankan script ini pakai: sudo ./script.sh"
    exit 1
fi

echo "✅ Username terdeteksi: $USERNAME"

# Cek apakah user terdaftar
if ! id "$USERNAME" &>/dev/null; then
    echo "❌ User '$USERNAME' tidak ditemukan di sistem."
    exit 1
fi

# Cek koneksi internet
echo
echo "🌐 Cek koneksi internet..."
if ! ping -c 2 archlinux.org &>/dev/null; then
    echo "❌ Tidak ada koneksi internet. Pastikan kamu online."
    exit 1
fi

# Pastikan tools penting tersedia
echo
echo "🔎 Cek dependency tools..."
for cmd in sudo git makepkg; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "❌ '$cmd' tidak ditemukan. Install dulu ya!"
        exit 1
    fi
done

# Tambahkan user ke grup wheel jika belum
if ! groups "$USERNAME" | grep -qw wheel; then
    echo "🔧 Menambahkan user '$USERNAME' ke grup wheel..."
    usermod -aG wheel "$USERNAME"
    echo "✅ Ditambahkan ke grup wheel."
fi

# Pastikan sudo aktif untuk grup wheel
if ! grep -qE '^%wheel\s+ALL=\(ALL:ALL\)\s+ALL' /etc/sudoers; then
    echo "⚙️  Mengaktifkan akses sudo untuk grup wheel..."
    sed -i 's/^# %wheel/%wheel/' /etc/sudoers
    echo "✅ Akses sudo untuk wheel diaktifkan."
fi

# Install base-devel & git
echo
echo "📦 Install base-devel & git..."
pacman -Sy --noconfirm --needed base-devel git

# Fungsi install AUR Helper
install_aur_helper() {
    local HELPER=$1
    local URL="https://aur.archlinux.org/${HELPER}.git"

    if command -v "$HELPER" &>/dev/null; then
        echo "✅ $HELPER sudah terinstall. Skip."
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
        echo "✅ $HELPER berhasil di-install."
    else
        echo "❌ Gagal install $HELPER. Cek log error-nya."
    fi
}

# Eksekusi
install_aur_helper yay
install_aur_helper paru

echo
echo "✅ Selesai! AUR helper yay & paru sudah siap dipakai oleh user '$USERNAME'."

#!/bin/bash

# ========================================================
# 🖥️  Tahap 6: Install Desktop Environment - Cinnamon
# ========================================================
echo -e "\n🖥️ \033[1mTahap 6: Install DE Cinnamon di Arch Linux\033[0m"
echo "--------------------------------------------------------"

# =========================
# ✅ Update sistem dulu
# =========================
echo -e "\n🔄 Update mirrorlist & sistem..."
pacman -Sy --noconfirm

# =========================
# 📦 Install Cinnamon + Apps
# =========================
echo -e "\n📦 Install paket Cinnamon DE dan utilities..."
pacman -S --noconfirm cinnamon cinnamon-translations xdg-user-dirs xdg-utils gvfs gvfs-mtp gnome-keyring gnome-themes-extra gnome-terminal file-roller

# =========================
# 🖼️ Install Display Manager
# =========================
echo -e "\n🖼️ Install LightDM dan greeter..."
pacman -S --noconfirm lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings

# Enable LightDM
echo -e "\n⚙️ Enable LightDM service..."
systemctl enable lightdm.service

# =========================
# 🎨 Optional: Theme & Icon Pack (bisa di-skip)
# =========================
echo -e "\n🎨 Install tema icon tambahan (opsional)..."
pacman -S --noconfirm arc-gtk-theme papirus-icon-theme

# =========================
# 🌐 Install browser & basic tools
# =========================
echo -e "\n🌐 Install aplikasi tambahan..."
pacman -S --noconfirm firefox nano neofetch network-manager-applet

# =========================
# 🔌 Enable NetworkManager
# =========================
systemctl enable NetworkManager.service

# =========================
# 📁 Buat user folder
# =========================
echo -e "\n📁 Setup XDG user dirs..."
xdg-user-dirs-update

# =========================
# 🎉 Selesai
# =========================
echo -e "\n✅ \033[1;32mCinnamon DE berhasil di-install!\033[0m"
echo -e "🚀 Reboot setelah keluar dari chroot dan nikmati Arch Linux + Cinnamon!"


