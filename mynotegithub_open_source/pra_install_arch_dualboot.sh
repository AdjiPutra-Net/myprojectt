#!/bin/bash
# ================================================
# 🌐 Tahap 2: Koneksi Internet & Update Mirrorlist
# ================================================

echo "📶 Cek koneksi internet ke archlinux.org..."
if ping -c 3 archlinux.org &>/dev/null; then
  echo "✅ Internet OK (ping ke archlinux.org sukses)"
else
  echo "⚠️  Ping ke archlinux.org gagal. Coba ping DNS Google..."
  if ping -c 3 8.8.8.8 &>/dev/null; then
    echo "✅ Internet aktif (ping ke 8.8.8.8 sukses), kemungkinan masalah DNS"
  else
    echo "❌ Tidak ada koneksi internet. Setting DNS manual..."
    read -p "❓ Mau set DNS Google manual? [Y/n]: " jawab
    jawab=${jawab,,} # lowercase
    if [[ "$jawab" == "y" || "$jawab" == "" ]]; then
      echo "⚙️  Setting DNS Google manual..."
      rm -f /etc/resolv.conf
      echo -e "nameserver 8.8.8.8\nnameserver 1.1.1.1" > /etc/resolv.conf
      chattr +i /etc/resolv.conf
      echo "✅ DNS sudah diset manual ke Google"
    else
      echo "⏭️  Lewatin setting DNS."
    fi
  fi
fi

# Tambahan catatan buat user yang make WiFi
echo ""
echo "📡 Kalau kamu pakai WiFi dan belum connect, jalankan manual:"
echo "  iwctl"
echo "  > station wlan0 scan"
echo "  > station wlan0 connect NAMA_WIFI"
echo "Cek dulu nama devicenya: iwctl device list"
echo ""

# Update Mirrorlist pakai Reflector
echo "📦 Mau update mirrorlist pakai reflector?"
read -p "❓ Lanjut update mirrorlist ke server Indonesia? [Y/n]: " jawab
jawab=${jawab,,}
if [[ "$jawab" == "y" || "$jawab" == "" ]]; then
  pacman -Sy --noconfirm reflector
  reflector --country Indonesia --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
  echo "✅ Mirrorlist berhasil diupdate ke server Indonesia tercepat"
else
  echo "⏭️  Lewatin update mirrorlist."
fi

#!/bin/bash

echo "💽 Tahap 3: Partisi Disk Arch Linux"
echo "-----------------------------------"

# Tampilkan disk
echo ""
echo "🧠 Daftar disk fisik:"
lsblk -dpno NAME,SIZE,MODEL | grep -v loop
echo ""
read -p "Masukkan nama disk target (misal /dev/sda atau /dev/nvme0n1): " disk

# Safety check
if [[ ! -b "$disk" ]]; then
  echo "❌ Disk tidak valid!"
  exit 1
fi

# Cek apakah ada partisi EFI
echo ""
echo "🔍 Mengecek partisi EFI dari OS lain (misal Windows)..."
efi_detected=$(blkid | grep "EFI System")

if [[ -n "$efi_detected" ]]; then
  echo "✅ Ditemukan partisi EFI:"
  echo "$efi_detected"
  efi_exists=true
else
  echo "⚠️  Tidak ditemukan partisi EFI! Akan dibuat partisi EFI baru."
  efi_exists=false
fi

echo ""
read -p "Lanjutkan membuat partisi di $disk? (y/N): " lanjut
[[ "$lanjut" =~ ^[Yy]$ ]] || exit 0

# Jalankan cfdisk manual biar user bebas atur (lebih aman buat pemula)
echo ""
echo "📦 Membuka tool partisi interaktif (cfdisk)..."
echo "❗ Skema disarankan: GPT"
sleep 2
cfdisk "$disk"

echo ""
echo "✅ Selesai partisi manual via cfdisk. Lanjut ke formatting partisi."
lsblk "$disk"

# Tanya partisi mana yang dipakai untuk masing-masing
echo ""
read -p "Masukkan partisi ROOT (misal /dev/sda2): " root_part
read -p "Masukkan partisi HOME (opsional, enter kalau nggak pakai): " home_part
read -p "Masukkan partisi SWAP (opsional): " swap_part

if [[ $efi_exists == false ]]; then
  read -p "Masukkan partisi EFI BARU yang tadi kamu buat (misal /dev/sda1): " efi_part
fi

# Format partisi
echo ""
echo "⏳ Memformat partisi..."

# EFI
if [[ $efi_exists == false && -n $efi_part ]]; then
  mkfs.fat -F32 "$efi_part"
  echo "✅ EFI diformat FAT32: $efi_part"
fi

# ROOT
mkfs.ext4 "$root_part"
echo "✅ Root diformat ext4: $root_part"

# HOME
if [[ -n $home_part ]]; then
  mkfs.ext4 "$home_part"
  echo "✅ Home diformat ext4: $home_part"
fi

# SWAP
if [[ -n $swap_part ]]; then
  mkswap "$swap_part"
  swapon "$swap_part"
  echo "✅ Swap diaktifkan: $swap_part"
fi

echo ""
echo "✅ Partisi selesai diformat! Siap untuk mount dan lanjut install Arch."

#!/bin/bash

echo "🔁 Tahap 4: Mount Partisi Arch Linux"
echo "-----------------------------------"

# Input partisi yang akan digunakan
read -p "Masukkan partisi ROOT (misal /dev/sda5): " root_part
read -p "Masukkan partisi HOME (enter jika tidak ada): " home_part
read -p "Masukkan partisi EFI Windows (misal /dev/sda1): " efi_part
read -p "Masukkan partisi SWAP (enter jika tidak pakai): " swap_part

echo ""
echo "🧼 Memformat dan mount partisi..."

# Root
echo "📦 Memformat ROOT $root_part sebagai ext4..."
mkfs.ext4 "$root_part"
echo "✅ Mounting ke /mnt..."
mount "$root_part" /mnt

# EFI
echo "📁 Mount EFI $efi_part ke /mnt/boot/efi..."
mkdir -p /mnt/boot/efi
mount "$efi_part" /mnt/boot/efi

# Swap
if [[ -n $swap_part ]]; then
  echo "💾 Setup SWAP $swap_part..."
  mkswap "$swap_part"
  swapon "$swap_part"
else
  echo "⏩ Tidak menggunakan SWAP."
fi

# Home
if [[ -n $home_part ]]; then
  echo "📁 Memformat HOME $home_part sebagai ext4..."
  mkfs.ext4 "$home_part"
  echo "✅ Mounting ke /mnt/home..."
  mkdir -p /mnt/home
  mount "$home_part" /mnt/home
else
  echo "⏩ Tidak menggunakan partisi HOME terpisah."
fi

echo ""
echo "✅ Semua partisi berhasil di-mount ke /mnt!"
lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT

#!/bin/bash

echo "🏗️ Tahap 5: Install Sistem Dasar Arch Linux"
echo "--------------------------------------------"

# Cek apakah /mnt sudah ter-mount
if mountpoint -q /mnt; then
    echo "✅ /mnt ditemukan dan sudah ter-mount. Lanjut..."
else
    echo "❌ Error: /mnt belum di-mount! Pastikan partisi ROOT sudah di-mount ke /mnt."
    exit 1
fi

# Paket default
default_pkgs="base linux linux-firmware networkmanager sudo grub efibootmgr vim nano git base-devel wget"

echo ""
echo "📦 Daftar paket default:"
echo "$default_pkgs"
echo ""
read -p "Mau tambah paket lain (misal: intel-ucode, pipewire)? Pisahkan spasi (Enter jika tidak ada): " extra_pkgs

# Gabungkan paket
all_pkgs="$default_pkgs $extra_pkgs"

echo ""
echo "🚀 Menjalankan pacstrap..."
sleep 2
pacstrap /mnt $all_pkgs

if [[ $? -eq 0 ]]; then
    echo ""
    echo "✅ Sistem dasar berhasil di-install ke /mnt!"
else
    echo "❌ Terjadi kesalahan saat install dengan pacstrap."
    exit 1
fi

#!/bin/bash

echo "🗂️ Tahap 6: Generate fstab"
echo "-----------------------------"

# Cek apakah /mnt sudah terisi sistem (minimal /mnt/etc ada)
if [[ ! -d /mnt/etc ]]; then
  echo "❌ Error: Sistem belum ter-install di /mnt! Pastikan sudah menjalankan pacstrap."
  exit 1
fi

echo ""
echo "📌 Metode generate fstab:"
echo "1. UUID (rekomendasi, aman & stabil)"
echo "2. LABEL (kalau kamu suka pakai label partisi)"
echo ""
read -p "Pilih metode generate fstab [1/2] (default: 1): " metode

case "$metode" in
  2)
    option="-L"
    ;;
  *)
    option="-U"
    ;;
esac

echo ""
echo "⚙️ Menjalankan: genfstab $option /mnt >> /mnt/etc/fstab"
genfstab "$option" /mnt >> /mnt/etc/fstab

if [[ $? -eq 0 ]]; then
  echo "✅ fstab berhasil dibuat di /mnt/etc/fstab!"
  echo ""
  echo "📄 Isi fstab:"
  echo "-----------------------------"
  cat /mnt/etc/fstab
else
  echo "❌ Gagal generate fstab."
  exit 1
fi

#!/bin/bash

echo "🛠️ Tahap 7: Chroot ke Sistem"
echo "------------------------------"

# Validasi direktori target
if [[ ! -d /mnt/etc ]]; then
  echo "❌ Error: Direktori /mnt/etc tidak ditemukan. Pastikan kamu sudah menjalankan pacstrap & generate fstab."
  exit 1
fi

# Optional: Konfirmasi user
read -p "Mau lanjut masuk ke lingkungan chroot sekarang? [Y/n]: " jawab
jawab=${jawab,,} # to lowercase

if [[ "$jawab" == "n" || "$jawab" == "no" ]]; then
  echo "❎ Dibatalkan oleh user."
  exit 0
fi

# Optional: Jalankan skrip custom dari luar setelah chroot
read -p "Punya script tambahan yang mau dijalankan setelah chroot? (misal: /mnt/root/setup-lanjutan.sh) [Y/n]: " lanjut
lanjut=${lanjut,,}

if [[ "$lanjut" == "y" || "$lanjut" == "yes" ]]; then
  read -p "Masukkan path file script di dalam /mnt (contoh: /root/setup.sh): " script_path

  if [[ -f "/mnt$script_path" ]]; then
    echo "📜 Menyiapkan script untuk dijalankan otomatis setelah chroot..."
    echo "bash $script_path" >> /mnt/root/.bashrc
  else
    echo "❌ Script tidak ditemukan. Lewatin."
  fi
fi

echo ""
echo "🔧 Menjalankan: arch-chroot /mnt"
sleep 1
arch-chroot /mnt

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

