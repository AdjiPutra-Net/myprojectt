#!/bin/bash
# ================================================
# 🌐 Tahap 2: Koneksi Internet & Update Mirrorlist
# ================================================

echo -e "\n🌐 \033[1mTahap 2: Koneksi Internet & Mirror\033[0m"
echo "-----------------------------------------------"

# Sinkronisasi waktu biar keyring gak error
echo "⏳ Sinkronisasi waktu (timedatectl)..."
timedatectl set-ntp true
sleep 2

# Tes koneksi ke domain arch
echo "📶 Cek koneksi internet ke archlinux.org..."
if ping -c 3 archlinux.org &>/dev/null; then
  echo "✅ Internet OK (ping ke archlinux.org sukses)"
else
  echo "⚠️  Ping ke archlinux.org gagal. Tes ping ke DNS Google..."
  if ping -c 3 8.8.8.8 &>/dev/null; then
    echo "✅ Internet aktif (ping ke 8.8.8.8 sukses), kemungkinan masalah DNS"
    echo "🔧 Setting ulang DNS ke Google..."
    rm -f /etc/resolv.conf
    echo -e "nameserver 8.8.8.8\nnameserver 1.1.1.1" > /etc/resolv.conf
    chattr +i /etc/resolv.conf
    echo "✅ DNS berhasil diset ulang ke Google"
  else
    echo "❌ Internet mati total. Mungkin belum konek atau driver WiFi belum support."

    # Cek apakah device wifi terdeteksi
    wifi_devices=$(iwctl device list | grep wlan)
    if [[ -z "$wifi_devices" ]]; then
      echo "🚫 \033[1;31mWiFi device tidak terdeteksi!\033[0m Mungkin kernel belum support driver WiFi."
      echo "💡 \033[1;33mSolusi:\033[0m Coba pakai kabel LAN atau download ISO dengan driver WiFi tambahan."
    else
      echo ""
      echo "📡 \033[1mGunakan WiFi:\033[0m"
      echo "  1. Ketik: iwctl"
      echo "  2. Di dalam shell:"
      echo "     ➤ device list"
      echo "     ➤ station wlan0 scan"
      echo "     ➤ station wlan0 connect NAMA_WIFI"
      echo "     ➤ exit"
      echo ""
      echo "💡 Ganti 'wlan0' sesuai dengan hasil device list"
    fi

    read -rp "🔁 Mau coba ulang ping setelah kamu konek WiFi? [Y/n]: " coba_ulang
    coba_ulang=${coba_ulang,,}
    if [[ "$coba_ulang" == "y" || "$coba_ulang" == "" ]]; then
      echo "⏳ Tunggu 5 detik..."
      sleep 5
      ping -c 3 8.8.8.8 && echo "✅ Internet sudah aktif!" || echo "❌ Masih belum ada koneksi!"
    fi
  fi
fi

# Update mirrorlist pakai reflector
echo ""
echo "📦 Mau update mirrorlist pakai reflector?"
read -rp "Lanjut update mirrorlist ke server Indonesia tercepat? [Y/n]: " lanjut
lanjut=${lanjut,,}
if [[ "$lanjut" == "y" || "$lanjut" == "" ]]; then
  echo "🔃 Update database dan install reflector..."
  pacman -Sy --noconfirm reflector

  echo "🪞 Menjalankan reflector..."
  reflector --country Indonesia --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

  echo "✅ Mirrorlist berhasil di-update ke server Indonesia tercepat!"
else
  echo "⏭️  Lewatin update mirrorlist."
fi

#!/bin/bash

echo -e "\n💽 \033[1mTahap 3: Partisi Disk Arch Linux\033[0m"
echo "-------------------------------------------"

# Tampilkan disk tanpa loop device
echo -e "\n🧠 Daftar disk fisik tersedia:"
lsblk -dpno NAME,SIZE,MODEL | grep -v loop

# Pilih disk target
echo ""
read -rp "Masukkan nama disk target (misal /dev/sda atau /dev/nvme0n1): " disk

# Validasi disk
if [[ ! -b "$disk" ]]; then
  echo -e "❌ \033[1;31mDisk tidak valid! Pastikan input misalnya /dev/sda atau /dev/nvme0n1.\033[0m"
  exit 1
fi

# Konfirmasi user
echo -e "\n⚠️  \033[1;33mPERHATIAN!\033[0m Semua data di $disk bisa hilang kalau kamu format."
read -rp "Lanjutkan membuat partisi di $disk? [y/N]: " lanjut
lanjut=${lanjut,,}
if [[ "$lanjut" != "y" && "$lanjut" != "yes" ]]; then
  echo "❎ Batalin. Kembali ke menu awal."
  exit 0
fi

# Deteksi apakah ada partisi EFI
echo ""
echo "🔍 Mengecek partisi EFI dari OS lain (misal Windows)..."
efi_detected=$(blkid | grep "vfat" | grep -iE "boot|efi")

if [[ -n "$efi_detected" ]]; then
  echo -e "✅ Ditemukan partisi EFI:\n$efi_detected"
  efi_exists=true
else
  echo -e "⚠️  \033[1;33mTidak ditemukan partisi EFI!\033[0m Akan dibuat manual saat partisi nanti."
  efi_exists=false
fi

# Deteksi tipe skema partisi (GPT/MBR)
part_type=$(parted -s "$disk" print | grep "Partition Table" | awk '{print $3}')
echo -e "\n📑 Skema partisi: \033[1m${part_type^^}\033[0m (rekomendasi: GPT)"

# Mulai cfdisk
echo ""
echo "📦 Membuka tool partisi interaktif: cfdisk"
echo "📌 Tips: Buat minimal partisi EFI (300MB, FAT32) dan Root (ext4)"
echo "       Tambahkan Home & Swap opsional"
sleep 2
cfdisk "$disk"

# Tampilkan hasil
echo -e "\n✅ Selesai partisi manual via cfdisk. Hasil:"
lsblk "$disk" -o NAME,FSTYPE,SIZE,TYPE,MOUNTPOINT

echo -e "\n💡 Lanjut ke tahap berikutnya: format dan mount partisi!"

# Safety check
if [[ ! -b "$disk" ]]; then
  echo "❌ Disk tidak valid!"
  exit 1
fi

#!/bin/bash
# ============================================
# 🔍 Smart EFI Partition Detection Script
# ============================================

echo ""
echo "🔎 Mendeteksi partisi EFI (vfat + ukuran cocok)..."

# Cari partisi dengan format FAT32 (vfat) dan ukuran sekitar 100MB–600MB (standar EFI)
efi_part=$(lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT -r | grep "vfat" | awk '$3 ~ /[1-6][0-9]?[0-9]?M/ || $3 ~ /1G/ { print $1 }' | head -n1)

if [[ -n "$efi_part" ]]; then
    efi_device="/dev/$efi_part"
    echo "✅ Ditemukan kandidat partisi EFI: $efi_device"

    # Cek apakah sudah di-mount
    mountpoint=$(lsblk -no MOUNTPOINT "$efi_device")
    if [[ -n "$mountpoint" ]]; then
        echo "ℹ️  Sudah ter-mount di: $mountpoint"
    else
        echo "🔧 Belum ter-mount. Mount sekarang ke /mnt/boot/efi..."
        mkdir -p /mnt/boot/efi
        mount "$efi_device" /mnt/boot/efi
        echo "✅ Berhasil di-mount ke /mnt/boot/efi"
    fi
else
    echo "❌ Gagal mendeteksi partisi EFI."
    echo "💡 Pastikan partisi sudah diformat FAT32 dan ukurannya sesuai (100MB–600MB atau ~1GB)."
fi

#!/bin/bash
# ========================================
# 🔧 Smart Manual Partitioning & Formatting
# ========================================

echo ""
echo "🔍 Deteksi disk utama lo..."
lsblk -d -o NAME,SIZE,MODEL
read -rp "Masukkan disk yang mau dipartisi (misal: /dev/sda atau /dev/nvme0n1): " disk

echo ""
read -p "Lanjutkan membuat partisi di $disk? (y/N): " lanjut
[[ "$lanjut" =~ ^[Yy]$ ]] || exit 0

# Buka partisi editor
echo ""
echo "📦 Membuka cfdisk (tool partisi interaktif)..."
echo "❗ Disarankan pilih skema GPT!"
sleep 2
cfdisk "$disk"

echo ""
echo "📄 Preview partisi setelah edit:"
lsblk "$disk"

# Deteksi EFI (vfat + size wajar)
efi_auto=$(lsblk -o NAME,FSTYPE,SIZE -r | grep -i "vfat" | awk '$3 ~ /[1-6][0-9]?[0-9]?M/ || $3 ~ /1G/ {print "/dev/"$1}' | head -n1)
efi_exists=false

if [[ -n $efi_auto ]]; then
  echo ""
  echo "✅ Terdeteksi partisi EFI: $efi_auto"
  efi_exists=true
else
  echo ""
  echo "⚠️ Tidak ditemukan partisi EFI otomatis."
fi

# Input partisi manual
echo ""
read -rp "Masukkan partisi ROOT (contoh: /dev/sda2): " root_part
read -rp "Masukkan partisi HOME (opsional): " home_part
read -rp "Masukkan partisi SWAP (opsional): " swap_part

if [[ $efi_exists == false ]]; then
  read -rp "Masukkan partisi EFI BARU (misal: /dev/sda1): " efi_part
else
  efi_part=$efi_auto
fi

# Validasi partisi ada
for part in "$root_part" "$home_part" "$swap_part" "$efi_part"; do
  [[ -n "$part" ]] && [[ ! -b "$part" ]] && echo "❌ Error: $part bukan partisi valid!" && exit 1
done

echo ""
echo "🧹 Mulai proses format partisi..."

# EFI
if [[ -n $efi_part ]]; then
  echo "📁 Format EFI: $efi_part"
  mkfs.fat -F32 "$efi_part"
fi

# ROOT
echo "📁 Format ROOT: $root_part"
mkfs.ext4 "$root_part"

# HOME
if [[ -n $home_part ]]; then
  echo "📁 Format HOME: $home_part"
  mkfs.ext4 "$home_part"
fi

# SWAP
if [[ -n $swap_part ]]; then
  echo "📁 Format SWAP: $swap_part"
  mkswap "$swap_part"
  swapon "$swap_part"
fi

echo ""
echo "✅ Semua partisi berhasil diformat!"
echo "🔜 Siap lanjut ke tahap mount dan install sistem dasar Arch Linux."

#!/bin/bash

# ===================================
# 🔁 Smart Mount Script Arch Linux
# ===================================

echo -e "\n\033[1;36m🔁 Tahap 4: Mount Partisi Arch Linux\033[0m"
echo "---------------------------------------------"

# Fungsi cek partisi valid
function cek_partisi() {
  if [[ ! -b "$1" ]]; then
    echo -e "\033[1;31m❌ Error: $1 bukan partisi valid!\033[0m"
    exit 1
  fi
}

# Input partisi
read -rp "Masukkan partisi ROOT (misal /dev/sda5): " root_part
cek_partisi "$root_part"

read -rp "Masukkan partisi HOME (enter jika tidak pakai): " home_part
[[ -n "$home_part" ]] && cek_partisi "$home_part"

read -rp "Masukkan partisi EFI (kosongkan untuk deteksi otomatis): " efi_part
if [[ -z "$efi_part" ]]; then
  efi_part=$(lsblk -o NAME,FSTYPE -r | grep -i vfat | head -n1 | awk '{print "/dev/"$1}')
  if [[ -n "$efi_part" ]]; then
    echo -e "✅ Deteksi otomatis EFI: \033[1;32m$efi_part\033[0m"
  else
    echo -e "\033[1;33m⚠️  Tidak bisa deteksi otomatis EFI.\033[0m"
    read -rp "Masukkan manual: " efi_part
  fi
fi
cek_partisi "$efi_part"

read -rp "Masukkan partisi SWAP (enter jika tidak pakai): " swap_part
[[ -n "$swap_part" ]] && cek_partisi "$swap_part"

# Konfirmasi format
echo -e "\n⚠️  \033[1;33mAkan diformat: $root_part $home_part\033[0m"
read -rp "Lanjut format partisi tersebut? (y/N): " konfirmasi
[[ "$konfirmasi" =~ ^[Yy]$ ]] || exit 0

# Mulai proses
echo -e "\n📦 Format dan mount partisi..."

# ROOT
echo -e "🔧 Format \033[1m$root_part\033[0m sebagai ext4..."
mkfs.ext4 "$root_part"
mount "$root_part" /mnt
echo "✅ ROOT mounted ke /mnt"

# EFI
mkdir -p /mnt/boot/efi
mount "$efi_part" /mnt/boot/efi
echo "✅ EFI mounted ke /mnt/boot/efi"

# HOME
if [[ -n "$home_part" ]]; then
  echo "🔧 Format $home_part sebagai ext4..."
  mkfs.ext4 "$home_part"
  mkdir -p /mnt/home
  mount "$home_part" /mnt/home
  echo "✅ HOME mounted ke /mnt/home"
else
  echo "⏩ HOME dilewati."
fi

# SWAP
if [[ -n "$swap_part" ]]; then
  echo "💾 Format & aktifkan SWAP: $swap_part"
  mkswap "$swap_part"
  swapon "$swap_part"
else
  echo "⏩ SWAP dilewati."
fi

echo -e "\n\033[1;32m✅ Semua partisi berhasil di-mount!\033[0m"
lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT

#!/bin/bash

# ================================
# 🏗️ Smart Installer Tahap 5: Base System
# ================================

echo -e "\n\033[1;36m🏗️  Tahap 5: Install Sistem Dasar Arch Linux\033[0m"
echo "-----------------------------------------------"

# Cek apakah pacstrap tersedia
if ! command -v pacstrap &> /dev/null; then
    echo -e "\033[1;31m❌ pacstrap tidak ditemukan! Pastikan lo sedang di Arch Live ISO.\033[0m"
    exit 1
fi

# Cek koneksi internet
echo -n "🌐 Cek koneksi internet... "
ping -q -c 1 archlinux.org &>/dev/null && echo -e "\033[1;32mOK\033[0m" || {
    echo -e "\033[1;31mGAGAL\033[0m"
    echo "❌ Tidak ada koneksi internet. Periksa kabel/Wi-Fi atau set DNS manual."
    exit 1
}

# Cek apakah /mnt sudah ter-mount
if ! mountpoint -q /mnt; then
    echo -e "\033[1;31m❌ /mnt belum di-mount! Mount dulu partisi ROOT ke /mnt.\033[0m"
    exit 1
fi

echo -e "\033[1;32m✅ /mnt sudah siap.\033[0m"

# Paket default
default_pkgs="base linux linux-firmware networkmanager sudo grub efibootmgr vim nano git base-devel wget"

echo -e "\n📦 \033[1mDaftar Paket Default:\033[0m"
echo "$default_pkgs"

read -rp $'\n➕ Mau nambah paket tambahan? (misal: intel-ucode pipewire) [Enter = skip]: ' extra_pkgs

# Gabungkan semua paket
all_pkgs="$default_pkgs $extra_pkgs"

echo -e "\n🚀 \033[1mMenjalankan pacstrap dengan paket:\033[0m"
echo "$all_pkgs"
echo -e "📁 Target: \033[1;34m/mnt\033[0m\n"

# Logging
logfile="pacstrap-install.log"
sleep 2

pacstrap /mnt $all_pkgs 2>&1 | tee "$logfile"

if [[ ${PIPESTATUS[0]} -eq 0 ]]; then
    echo -e "\n\033[1;32m✅ Sistem dasar berhasil di-install ke /mnt!\033[0m"
else
    echo -e "\n\033[1;31m❌ Gagal install base system!\033[0m"
    echo "📄 Lihat log di: $logfile"
    exit 1
fi

#!/bin/bash

echo -e "\n\033[1;36m🗂️  Tahap 6: Generate fstab\033[0m"
echo "-------------------------------"

# Pastikan genfstab tersedia
if ! command -v genfstab &>/dev/null; then
    echo -e "\033[1;31m❌ genfstab tidak tersedia! Pastikan kamu berada di Live ISO Arch.\033[0m"
    exit 1
fi

# Cek apakah sistem sudah di-install
if [[ ! -d /mnt/etc ]]; then
    echo -e "\033[1;31m❌ Error: /mnt/etc tidak ditemukan! Pastikan sudah menjalankan pacstrap sebelumnya.\033[0m"
    exit 1
fi

# Pilihan metode
echo -e "\n📌 \033[1mPilih metode generate fstab:\033[0m"
echo "1. UUID (default - aman & stabil)"
echo "2. LABEL (alternatif)"

read -rp $'\nPilih metode [1/2] (default: 1): ' metode
case "$metode" in
    2)
        option="-L"
        ;;
    *)
        option="-U"
        ;;
esac

echo ""

# Backup fstab kalau sudah ada
if [[ -f /mnt/etc/fstab ]]; then
    cp /mnt/etc/fstab "/mnt/etc/fstab.backup-$(date +%s)"
    echo -e "📁 Backup fstab lama dibuat: \033[1;34m/mnt/etc/fstab.backup-$(date +%s)\033[0m"
fi

# Jalankan genfstab
echo -e "\n⚙️  Menjalankan perintah: \033[1mgenfstab $option -p /mnt\033[0m"
genfstab $option -p /mnt >> /mnt/etc/fstab

# Cek hasilnya
if [[ $? -eq 0 ]]; then
    echo -e "\n✅ \033[1;32mfstab berhasil dibuat di /mnt/etc/fstab!\033[0m"
    
    line_count=$(wc -l < /mnt/etc/fstab)
    
    if [[ $line_count -lt 2 ]]; then
        echo -e "\033[1;33m⚠️  Warning: fstab hanya berisi $line_count baris. Cek lagi partisi sudah di-mount?\033[0m"
    fi

    echo -e "\n📄 \033[1mIsi fstab:\033[0m"
    echo "-------------------------------"
    cat /mnt/etc/fstab
else
    echo -e "\033[1;31m❌ Gagal generate fstab.\033[0m"
    exit 1
fi

#!/bin/bash

# =================================================
# 🛠️ Tahap 7: Chroot ke Sistem Arch Linux
# =================================================

set -e

echo -e "\n\033[1;36m🛠️  Tahap 7: Chroot ke Sistem\033[0m"
echo "----------------------------------------"

# Cek apakah dijalankan sebagai root
if [[ $EUID -ne 0 ]]; then
  echo -e "\033[1;31m❌ Script ini harus dijalankan sebagai root!\033[0m"
  exit 1
fi

# Validasi direktori chroot
if [[ ! -d /mnt/etc || ! -x /mnt/bin/bash ]]; then
  echo -e "\033[1;31m❌ Sistem target belum siap. Pastikan sudah pacstrap + fstab.\033[0m"
  exit 1
fi

# Cek ketersediaan arch-chroot
if ! command -v arch-chroot &>/dev/null; then
  echo -e "\033[1;31m❌ Perintah arch-chroot tidak ditemukan! Pastikan pakai Live Arch Linux ISO.\033[0m"
  exit 1
fi

# Konfirmasi lanjut
read -rp $'\n🔁 Mau lanjut masuk ke lingkungan chroot sekarang? [Y/n]: ' jawab
jawab=${jawab,,}
if [[ "$jawab" == "n" || "$jawab" == "no" ]]; then
  echo -e "\033[1;33m❎ Dibatalkan oleh user.\033[0m"
  exit 0
fi

# Optional: Auto jalankan script tambahan
read -rp $'\n📜 Punya script tambahan yang mau dijalankan setelah chroot? [y/N]: ' lanjut
lanjut=${lanjut,,}
if [[ "$lanjut" == "y" || "$lanjut" == "yes" ]]; then
  read -rp "🛠️  Masukkan path file script di dalam /mnt (contoh: /root/setup.sh): " script_path

  if [[ -f "/mnt$script_path" ]]; then
    echo -e "📦 Menyiapkan agar script dijalankan otomatis setelah chroot..."
    chmod +x "/mnt$script_path"
    echo "bash $script_path" >> /mnt/root/.bashrc
    echo "✅ Ditambahkan ke .bashrc: $script_path"
  else
    echo -e "\033[1;31m❌ Script tidak ditemukan. Lewatin auto-run.\033[0m"
  fi
fi

# Jalankan chroot
echo -e "\n🚪 Masuk ke sistem dengan: \033[1march-chroot /mnt\033[0m\n"
sleep 1
arch-chroot /mnt
