#!/bin/bash

echo "🧩 Tahap 8: Setting Sistem"
echo "------------------------------"

# ========================
# 8.1 Set Zona Waktu
# ========================
echo "🌏 Setting zona waktu ke Asia/Jakarta..."
ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
hwclock --systohc

# ========================
# 8.2 Locale + Keymap
# ========================
echo "🗣️  Mengatur locale ke en_US.UTF-8..."

# Uncomment en_US.UTF-8 UTF-8
sed -i 's/^#\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen

# Generate locale
locale-gen

# Set default locale
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Input keymap keyboard
read -p "🧠 Mau pake keymap keyboard apa? (default: us): " keymap
keymap=${keymap:-us}
echo "KEYMAP=$keymap" > /etc/vconsole.conf
echo "✅ Keymap diset ke: $keymap"

# ========================
# 8.3 Hostname
# ========================
read -p "📛 Masukkan nama hostname sistem kamu (default: archlinux): " hostname
hostname=${hostname:-archlinux}

echo "$hostname" > /etc/hostname
echo "127.0.0.1       localhost" > /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts

echo ""
echo "✅ Hostname diset ke: $hostname"
echo "✅ File /etc/hosts telah dikonfigurasi"

#!/bin/bash

echo "🔐 Tahap 9: Buat User & Set Password"
echo "----------------------------------------"

# ========================
# 1. Set password root
# ========================
read -s -p "🔑 Masukkan password untuk root & user: " userpass
echo ""

echo "🔧 Mengatur password untuk root..."
echo "root:$userpass" | chpasswd

# ========================
# 2. Buat user baru
# ========================
read -p "👤 Masukkan nama username (default: adjiarch): " username
username=${username:-adjiarch}

# Validasi username
if [[ "$username" =~ [[:space:]] ]]; then
  echo "❌ Username tidak boleh mengandung spasi!"
  exit 1
fi

echo "📦 Membuat user: $username"
useradd -mG wheel "$username"
echo "$username:$userpass" | chpasswd

# ========================
# 3. Aktifkan akses sudo
# ========================
echo "🛠️ Mengaktifkan akses sudo untuk grup wheel..."

# Backup dulu visudo
cp /etc/sudoers /etc/sudoers.bak

# Gunakan sed untuk uncomment baris %wheel
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

echo ""
echo "✅ User $username berhasil dibuat dengan akses sudo."
echo "✅ Password root & user telah diatur."

#!/bin/bash

echo "🔌 Tahap 10: Install GRUB Bootloader"
echo "---------------------------------------"

# ==========================
# Deteksi Mode Boot
# ==========================
if [ -d /sys/firmware/efi ]; then
  echo "✅ Mode Boot: UEFI terdeteksi"
  boot_mode="UEFI"
else
  echo "✅ Mode Boot: BIOS (Legacy) terdeteksi"
  boot_mode="BIOS"
fi

# ==========================
# Konfirmasi atau Override
# ==========================
read -p "🧠 Gunakan mode boot yang terdeteksi ($boot_mode)? [Y/n]: " mode_confirm
mode_confirm=${mode_confirm,,} # to lowercase
if [[ "$mode_confirm" == "n" ]]; then
  echo "⚠️  Oke, pilih mode secara manual:"
  echo "1. UEFI"
  echo "2. BIOS (Legacy)"
  read -p "Pilih [1/2]: " manual_mode
  if [[ "$manual_mode" == "1" ]]; then
    boot_mode="UEFI"
  elif [[ "$manual_mode" == "2" ]]; then
    boot_mode="BIOS"
  else
    echo "❌ Pilihan tidak valid. Batal."
    exit 1
  fi
fi

# ==========================
# Proses Install GRUB
# ==========================
if [[ "$boot_mode" == "UEFI" ]]; then
  echo "🛠️ Menginstall GRUB untuk UEFI..."
  grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ArchLinux
else
  echo "💿 Mode BIOS - Masukkan disk utama (contoh: /dev/sda atau /dev/nvme0n1)"
  read -p "📦 Disk utama untuk install GRUB (tanpa angka): " target_disk
  if [[ ! -b "$target_disk" ]]; then
    echo "❌ Disk tidak valid. Pastikan formatnya /dev/sdX atau /dev/nvme0nX"
    exit 1
  fi
  echo "🛠️ Menginstall GRUB untuk BIOS ke $target_disk..."
  grub-install --target=i386-pc "$target_disk"
fi

# ==========================
# Generate GRUB Config
# ==========================
echo "⚙️  Menggenerate konfigurasi GRUB..."
grub-mkconfig -o /boot/grub/grub.cfg

echo ""
echo "✅ GRUB berhasil diinstall dan dikonfigurasi!"

#!/bin/bash

echo "🔌 Tahap 10: Install GRUB Bootloader"
echo "---------------------------------------"

# ==========================
# Deteksi Mode Boot
# ==========================
if [ -d /sys/firmware/efi ]; then
  echo "✅ Mode Boot: UEFI terdeteksi"
  boot_mode="UEFI"
else
  echo "✅ Mode Boot: BIOS (Legacy) terdeteksi"
  boot_mode="BIOS"
fi

# ==========================
# Konfirmasi atau Override
# ==========================
read -p "🧠 Gunakan mode boot yang terdeteksi ($boot_mode)? [Y/n]: " mode_confirm
mode_confirm=${mode_confirm,,} # to lowercase
if [[ "$mode_confirm" == "n" ]]; then
  echo "⚠️  Oke, pilih mode secara manual:"
  echo "1. UEFI"
  echo "2. BIOS (Legacy)"
  read -p "Pilih [1/2]: " manual_mode
  if [[ "$manual_mode" == "1" ]]; then
    boot_mode="UEFI"
  elif [[ "$manual_mode" == "2" ]]; then
    boot_mode="BIOS"
  else
    echo "❌ Pilihan tidak valid. Batal."
    exit 1
  fi
fi

# ==========================
# Proses Install GRUB
# ==========================
if [[ "$boot_mode" == "UEFI" ]]; then
  echo "🛠️ Menginstall GRUB untuk UEFI..."
  grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ArchLinux
else
  echo "💿 Mode BIOS - Masukkan disk utama (contoh: /dev/sda atau /dev/nvme0n1)"
  read -p "📦 Disk utama untuk install GRUB (tanpa angka): " target_disk
  if [[ ! -b "$target_disk" ]]; then
    echo "❌ Disk tidak valid. Pastikan formatnya /dev/sdX atau /dev/nvme0nX"
    exit 1
  fi
  echo "🛠️ Menginstall GRUB untuk BIOS ke $target_disk..."
  grub-install --target=i386-pc "$target_disk"
fi

# ==========================
# Generate GRUB Config
# ==========================
echo "⚙️  Menggenerate konfigurasi GRUB..."
grub-mkconfig -o /boot/grub/grub.cfg

echo ""
echo "✅ GRUB berhasil diinstall dan dikonfigurasi!"

#!/bin/bash
# =============================================
# 🧹 Tahap 12: Cleanup DNS Protect & Unmount
# =============================================

echo "🧹 Tahap 12: Cleanup DNS Protect & Unmount"
echo "--------------------------------------------"

# 🔓 Unlock /etc/resolv.conf (remove immutable flag)
echo "🔓 Menghapus proteksi file /etc/resolv.conf (jika ada)..."
if chattr -i /etc/resolv.conf 2>/dev/null; then
  echo "✅ File /etc/resolv.conf sudah tidak terkunci."
else
  echo "⚠️ Gagal unlock /etc/resolv.conf atau sudah unlocked."
fi

# 🗂️ Unmount partisi dari /mnt
echo
echo "🗂️  Unmount semua partisi dari /mnt..."
if umount -R /mnt 2>/dev/null; then
  echo "✅ Semua partisi berhasil di-unmount dari /mnt."
else
  echo "⚠️ Beberapa partisi gagal di-unmount. Coba unmount manual."
fi

# 📝 Info buat langkah selanjutnya
echo
echo "📋 Langkah selanjutnya lo harus manual:"
echo "1. exit"
echo "2. reboot"
echo
echo "⚠️ Cabut USB installer sebelum reboot kalau install di hardware asli!"
echo "🚀 GRUB akan muncul kalau semuanya sukses."

exit 0

