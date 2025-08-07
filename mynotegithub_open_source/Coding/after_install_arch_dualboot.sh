#!/bin/bash
# ============================================
# 🔚 Tahap 11: Final Setup Setelah Arch Install
# ============================================

set -e

LOG_FILE="/var/log/arch-final-setup.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo -e "\n🧠 Final Setup Arch Linux — Versi Lengkap"

# ----------------------------------------
# 🧬 Deteksi UEFI / BIOS
# ----------------------------------------
if [ -d /sys/firmware/efi ]; then
  echo "✅ Boot Mode: UEFI"
else
  echo "⚠️  Boot Mode: BIOS (Legacy)"
fi

# ----------------------------------------
# 🧪 Deteksi Virtual Machine
# ----------------------------------------
virt_type=$(systemd-detect-virt)
if [ "$virt_type" != "none" ]; then
  echo "🧪 Deteksi Virtual Machine: $virt_type"
fi

# ----------------------------------------
# 📦 Aktifkan Multilib (kalau belum)
# ----------------------------------------
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
  echo "📦 Mengaktifkan multilib repo..."
  sed -i '/#\[multilib\]/,/#Include/s/^#//' /etc/pacman.conf
  pacman -Sy
else
  echo "✅ Multilib sudah aktif"
fi

# ----------------------------------------
# 🔧 Setting DNS via NetworkManager
# ----------------------------------------
echo "🌐 Setting DNS manual via NetworkManager..."
mkdir -p /etc/NetworkManager/conf.d
cat <<EOF > /etc/NetworkManager/conf.d/dns.conf
[main]
dns=none
EOF

chattr -i /etc/resolv.conf 2>/dev/null || true
cat <<EOF > /etc/resolv.conf
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF
chattr +i /etc/resolv.conf

systemctl enable --now NetworkManager
sleep 5
chattr -i /etc/resolv.conf

# ----------------------------------------
# 🌐 Tes Koneksi Internet
# ----------------------------------------
echo "🔍 Tes koneksi ke archlinux.org..."
if ping -c 2 archlinux.org &>/dev/null; then
  echo "✅ Koneksi internet OK!"
else
  echo "❌ Tidak ada koneksi. Cek NetworkManager dan kabel/wifi."
fi

# ----------------------------------------
# 🔁 Update sistem & install reflector
# ----------------------------------------
echo "🔁 Update sistem dan install reflector..."
pacman -Syyu --noconfirm
pacman -S --noconfirm reflector
systemctl enable --now reflector.timer

# ----------------------------------------
# 🧠 Install Microcode CPU
# ----------------------------------------
echo ""
echo "🧠 Pilih CPU Microcode:"
echo "1. Intel"
echo "2. AMD"
echo "3. Lewati"
read -rp "Masukkan pilihan [1-3]: " ucode_choice

case "$ucode_choice" in
  1) pacman -S --noconfirm intel-ucode ;;
  2) pacman -S --noconfirm amd-ucode ;;
  *) echo "⏭️  Lewati instalasi microcode" ;;
esac

# ----------------------------------------
# 🎮 Instalasi Driver GPU
# ----------------------------------------
echo ""
echo "🖥️ Deteksi GPU..."
lspci | grep -Ei 'vga|3d'

echo "Pilih GPU Driver:"
echo "1. AMD"
echo "2. Intel"
echo "3. NVIDIA"
echo "4. Lewati"
read -rp "Masukkan pilihan [1-4]: " GPU_CHOICE

case "$GPU_CHOICE" in
  1) pacman -S --noconfirm mesa libva-mesa-driver vulkan-radeon ;;
  2) pacman -S --noconfirm mesa libva-intel-driver vulkan-intel ;;
  3) pacman -S --noconfirm nvidia nvidia-utils nvidia-settings ;;
  *) echo "⏭️  Lewati instalasi GPU driver" ;;
esac

# ----------------------------------------
# 🔐 SSH Setup
# ----------------------------------------
echo "🔐 Mengaktifkan SSH..."
pacman -S --noconfirm openssh
systemctl unmask sshd
systemctl enable --now sshd

# ----------------------------------------
# 🤖 ASUS Laptop (Optional)
# ----------------------------------------
if [ -d /sys/class/power_supply/BAT0 ]; then
  echo "🧰 Install ASUS-specific tools (optional)"
  pacman -S --noconfirm asusctl supergfxctl
  systemctl enable --now asusd
  systemctl enable --now supergfxd
  asusctl battery -m balanced
  supergfxctl --mode dedicated || true
fi

# ----------------------------------------
# 📄 Logging info system
# ----------------------------------------
echo ""
echo "📋 Info Sistem:"
uname -r
arch
hostnamectl
lscpu | grep 'Model name'

# ----------------------------------------
# ✅ Finishing
# ----------------------------------------
echo -e "\n✅ Tahap 11 selesai!"
echo "📁 Log lengkap tersimpan di: $LOG_FILE"

echo -e "\n📌 Lanjutkan dengan:"
echo "   ➤ Install DE: sudo pacman -S gnome gdm"
echo "   ➤ Aktifkan GDM: sudo systemctl enable gdm"
echo "   ➤ Install AUR helper: sudo pacman -S yay"
echo "   ➤ Tambahkan user ke grup wheel/video/audio jika belum"

echo -e "\n🚀 Good luck! Arch Linux siap digunakan!"
