#!/bin/bash
# ========================================================
# 🐧 Tahap 12: Smart Install AUR Helper (yay & paru)
# ========================================================

set -e

echo
echo "🔍 Deteksi Username Non-Root..."

USERNAME=$(logname 2>/dev/null || echo "$SUDO_USER")

if [[ -z "$USERNAME" || "$USERNAME" == "root" ]]; then
    echo "❌ Gagal deteksi user non-root."
    echo "➡️  Jalankan script ini pakai: sudo ./script.sh"
    exit 1
fi

echo "✅ Username terdeteksi: $USERNAME"

# Cek user valid
if ! id "$USERNAME" &>/dev/null; then
    echo "❌ User '$USERNAME' tidak ditemukan."
    exit 1
fi

# Cek koneksi internet
echo
echo "🌐 Cek koneksi internet..."
if ! ping -q -c 2 archlinux.org &>/dev/null; then
    echo "❌ Tidak ada koneksi internet."
    exit 1
fi

# Cek dependency
echo
echo "🔎 Cek tools penting..."
DEPS=(sudo git makepkg)
for cmd in "${DEPS[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "❌ '$cmd' tidak ditemukan. Install manual dulu ya!"
        exit 1
    fi
done

# Tambah ke grup wheel jika belum
if ! groups "$USERNAME" | grep -qw wheel; then
    echo "🔧 Menambahkan user '$USERNAME' ke grup wheel..."
    usermod -aG wheel "$USERNAME"
    echo "✅ Grup wheel ditambahkan."
fi

# Aktifkan sudo untuk wheel
if ! grep -qE '^%wheel\s+ALL=\(ALL:ALL\)\s+ALL' /etc/sudoers; then
    echo "⚙️  Mengaktifkan sudo untuk wheel group..."
    sed -i 's/^# %wheel/%wheel/' /etc/sudoers
    echo "✅ Sudo wheel group aktif."
fi

# Install base-devel jika belum
echo
echo "📦 Install base-devel & git..."
pacman -Sy --noconfirm
pacman -S --needed --noconfirm base-devel git

# Buat direktori config/cache biar gak error
sudo -u "$USERNAME" mkdir -p /home/$USERNAME/.cache /home/$USERNAME/.config
chown -R "$USERNAME":"$USERNAME" "/home/$USERNAME/.cache" "/home/$USERNAME/.config"

# Fungsi install AUR helper
install_aur_helper() {
    local HELPER=$1
    local URL="https://aur.archlinux.org/${HELPER}.git"

    if command -v "$HELPER" &>/dev/null; then
        echo "✅ $HELPER sudah terinstall. Lewati."
        return
    fi

    echo
    echo "🚀 Instalasi AUR helper: $HELPER..."

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
        echo "❌ Instalasi $HELPER gagal. Cek error log."
    fi
}

# Eksekusi install
install_aur_helper yay
install_aur_helper paru

# Konfigurasi yay opsional
YAY_CONF="/home/$USERNAME/.config/yay/config.json"
if [[ -f "$YAY_CONF" ]]; then
    echo "🛠️  Konfigurasi yay: auto-clean dan update-check aktif..."
    sudo -u "$USERNAME" jq '.+={"cleanAfter":true,"updateCheck":true}' "$YAY_CONF" > /tmp/yay_config && mv /tmp/yay_config "$YAY_CONF"
    chown "$USERNAME":"$USERNAME" "$YAY_CONF"
fi

# Auto update yay & paru setelah install
for HELPER in yay paru; do
    if command -v "$HELPER" &>/dev/null; then
        echo "🔁 Update $HELPER database..."
        sudo -u "$USERNAME" "$HELPER" -Sy --noconfirm || true
    fi
done

echo
echo "✅ Instalasi selesai! yay & paru siap dipakai oleh user '$USERNAME'."

#!/bin/bash

# ========================================================
# 🖥️  Tahap 13: Install Desktop Environment - Cinnamon
# ========================================================

set -e

echo -e "\n🖥️ \033[1mTahap 13: Install DE Cinnamon di Arch Linux\033[0m"
echo "--------------------------------------------------------"

# =========================
# 🌐 Cek koneksi internet
# =========================
echo -e "\n🌐 Mengecek koneksi internet..."
if ! ping -c 1 archlinux.org &>/dev/null; then
  echo "❌ Tidak ada koneksi internet. Script dihentikan."
  exit 1
fi

# =========================
# 🔍 Cek apakah Cinnamon sudah terinstall
# =========================
if pacman -Qi cinnamon &>/dev/null; then
  echo "✅ Cinnamon sudah terinstall. Melewati tahap ini."
  exit 0
fi

# =========================
# 🔄 Update mirrorlist & sistem
# =========================
echo -e "\n🔄 Update repository & sistem..."
pacman -Sy --noconfirm

# =========================
# 📦 Install Cinnamon + Apps
# =========================
echo -e "\n📦 Install Cinnamon dan komponen penting..."
pacman -S --noconfirm cinnamon cinnamon-translations \
xdg-user-dirs xdg-utils gvfs gvfs-mtp gnome-keyring gnome-themes-extra \
gnome-terminal file-roller gnome-disk-utility pavucontrol blueman

# =========================
# 🖼️ Install Display Manager
# =========================
echo -e "\n🖼️ Install LightDM dan greeter..."
pacman -S --noconfirm lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings

echo -e "\n⚙️ Enable LightDM service..."
systemctl enable lightdm.service

# =========================
# 🎨 Theme & Icon Pack
# =========================
echo -e "\n🎨 Install tema dan ikon..."
pacman -S --noconfirm arc-gtk-theme papirus-icon-theme

# Deteksi user non-root (jika dijalankan pakai sudo)
USERNAME=$(logname 2>/dev/null || echo "$SUDO_USER")

if [[ -n "$USERNAME" && "$USERNAME" != "root" ]]; then
  echo -e "\n🎨 Terapkan tema & ikon default untuk user '$USERNAME'..."
  sudo -u "$USERNAME" bash <<EOF
gsettings set org.cinnamon.desktop.interface gtk-theme 'Arc'
gsettings set org.cinnamon.desktop.interface icon-theme 'Papirus'
gsettings set org.cinnamon.desktop.wm.preferences theme 'Arc'
EOF
else
  echo "⚠️  Tidak bisa atur tema karena user non-root tidak terdeteksi."
fi

# =========================
# 🌐 Browser & tools ringan
# =========================
echo -e "\n🌐 Install tools ringan dan browser..."
pacman -S --noconfirm firefox nano neofetch network-manager-applet

# =========================
# 🔌 Enable NetworkManager
# =========================
echo -e "\n🔌 Aktifkan NetworkManager..."
systemctl enable NetworkManager.service

# =========================
# 📁 Setup user folder
# =========================
echo -e "\n📁 Membuat direktori XDG (Downloads, Documents, dsb)..."
if command -v xdg-user-dirs-update &>/dev/null; then
  sudo -u "$USERNAME" xdg-user-dirs-update
else
  echo "⚠️  xdg-user-dirs-update tidak ditemukan."
fi

# =========================
# 🎉 Finishing
# =========================
echo -e "\n✅ \033[1;32mCinnamon DE berhasil di-install!\033[0m"
echo -e "🚀 Setelah keluar dari chroot, jalankan:"
echo -e "\n\033[1mexit\033[0m"
echo -e "\033[1mumount -R /mnt\033[0m"
echo -e "\033[1mreboot\033[0m"
echo -e "\nLalu login ke lingkungan Cinnamon dan nikmati Arch Linux kamu! 🍃"

#!/bin/bash

# ========================================================
# 🚀 Tahap 14: Install Aplikasi Penunjang Produktivitas
# ========================================================

set -e

# Fungsi untuk cetak header
function section() {
  echo -e "\n\033[1;34m==> $1\033[0m"
}

# =========================
# 📦 Update sistem
# =========================
section "Update sistem & upgrade paket..."
sudo pacman -Syu --noconfirm

# =========================
# 🗃️ File & System Tools
# =========================
section "Install file manager dan system utilities..."
sudo pacman -S --noconfirm \
  thunar gnome-disk-utility gparted file-roller p7zip unrar ranger nnn

# =========================
# 🌐 Browser & Internet
# =========================
section "Install aplikasi browser dan internet..."
sudo pacman -S --noconfirm \
  firefox thunderbird transmission-gtk qbittorrent uget aria2

yay -S --noconfirm brave-bin persepolis librewolf-bin

# =========================
# 📝 Office & Note Apps
# =========================
section "Install office suite dan note-taking..."
sudo pacman -S --noconfirm \
  libreoffice-fresh evince okular zathura xournalpp

yay -S --noconfirm obsidian joplin-desktop simplenote marktext

# =========================
# 👨‍💻 Coding Tools
# =========================
section "Install tools buat ngoding..."
sudo pacman -S --noconfirm \
  git neovim geany terminator kitty alacritty tilix

yay -S --noconfirm visual-studio-code-bin lazygit gitkraken

# =========================
# 🎨 Multimedia & Desain
# =========================
section "Install software multimedia dan desain..."
sudo pacman -S --noconfirm \
  gimp krita pinta inkscape vlc mpv kdenlive shotcut audacity \
  flameshot spectacle

# =========================
# ⚙️ Utilities & Tools
# =========================
section "Install utilities tambahan..."
sudo pacman -S --noconfirm \
  neofetch screenfetch htop btop tlp powertop blueman bluez \
  timeshift deja-dup baobab ncdu copyq parcellite

# =========================
# 🧠 Fokus & Produktivitas
# =========================
section "Install tools untuk fokus dan manajemen waktu..."
sudo pacman -S --noconfirm \
  gnome-pomodoro ktimer gnome-calendar

yay -S --noconfirm freemind vym

# =========================
# 🎉 Selesai
# =========================
echo -e "\n✅ \033[1;32mSemua aplikasi produktivitas berhasil diinstall!\033[0m"
echo -e "\n💡 Jalankan aplikasi dari menu DE kamu atau terminal. Enjoy! 🐧"
