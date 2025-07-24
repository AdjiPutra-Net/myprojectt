#!/bin/bash
# ================================================
# 🌐 Tahap 2: Koneksi Internet & Update Mirrorlist
# ================================================

echo -e "\n🌐 \033[1mTahap 2: Koneksi Internet & Mirror\033[0m"
echo "-----------------------------------------------"

# Sinkronisasi waktu biar keyring gak error
echo "⏳ Sinkronisasi waktu (timedatectl)..."
timedatectl set-ntp true
sleep 5

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

# ============================================
# 💽 Tahap 3: Partisi Disk - Smart Validation
# ============================================

echo -e "\n💽 \033[1mTahap 3: Partisi Disk Arch Linux\033[0m"
echo "-------------------------------------------"

# Menampilkan disk fisik real (tanpa loop & USB kecil)
echo -e "\n🧠 \033[1mDaftar Disk yang Terdeteksi:\033[0m"
lsblk -dpno NAME,SIZE,MODEL | grep -vE 'loop|boot|rpmb|mmcblk|sr0'

# Input disk target
while true; do
    echo ""
    read -rp "🖋️  Masukkan nama disk target (misal /dev/sda /dev/nvme0n1): " disk
    if [[ -b "$disk" ]]; then
        break
    else
        echo -e "❌ \033[1;31mDisk tidak valid!\033[0m Coba cek dengan lsblk."
    fi
done

# Konfirmasi user sebelum lanjut
echo -e "\n⚠️  \033[1;33mPERINGATAN!\033[0m Semua data di $disk bisa hilang kalau kamu format."
read -rp "Lanjut buat partisi manual di $disk dengan cfdisk? [y/N]: " lanjut
lanjut=${lanjut,,}
if [[ "$lanjut" != "y" && "$lanjut" != "yes" ]]; then
  echo "❎ Batalin. Keluar dari tahap partisi."
  exit 0
fi

# Jalankan cfdisk
echo -e "\n🚀 Menjalankan cfdisk di $disk..."
sleep 3
cfdisk "$disk"

# Menampilkan hasil partisi
echo -e "\n📦 \033[1mPartisi selesai. Silakan input nama partisi untuk setiap mount point:\033[0m"
lsblk "$disk" -o NAME,FSTYPE,SIZE,TYPE,MOUNTPOINT

# ===============================
# Input partisi wajib
# ===============================
function input_partisi() {
    local label=$1
    local varname=$2
    while true; do
        read -rp "🔢 Masukkan partisi $label (misal /dev/sda1): " input
        if [[ -b "$input" ]]; then
            eval "$varname=\"$input\""
            break
        else
            echo -e "❌ \033[1;31m$input bukan partisi valid!\033[0m Coba lihat hasil lsblk di atas."
        fi
    done
}

# Wajib diinput dan valid
input_partisi "EFI (vfat)" efi_part
input_partisi "ROOT (btrfs)" root_part
input_partisi "HOME (btrfs)" home_part
input_partisi "SWAP (swap)" swap_part

# Tampilkan hasil akhir
echo -e "\n✅ \033[1mSemua partisi berhasil divalidasi!\033[0m"
echo -e "📋 \033[1mHasil input partisi:\033[0m"
echo -e "📁 EFI  : $efi_part"
echo -e "📁 ROOT : $root_part"
echo -e "📁 HOME : $home_part"
echo -e "💾 SWAP : $swap_part"

echo -e "\n🚀 Lanjut ke tahap berikutnya: Format & Mount!"

#!/bin/bash

# ========================================================
# 🔁 Tahap 4 (BTRFS): Format & Mount dengan Subvolume
# ========================================================

echo -e "\n🔁 \e[1mTahap 4: Format dan Mount Partisi (BTRFS)\e[0m"
echo "----------------------------------------------------"

# ===============================
# 🔄 Fungsi input validasi partisi
# ===============================
function input_partisi() {
    local label=$1
    local varname=$2
    while true; do
        read -rp "📥 Masukkan partisi $label (misal: /dev/sdaX): " input
        if [[ -b "$input" ]]; then
            eval "$varname=\"$input\""
            break
        else
            echo -e "❌ \e[1;31m$input bukan partisi valid!\e[0m Coba cek lagi dengan lsblk."
        fi
    done
}

# ===============================
# 🧠 Auto/Manual EFI Part
# ===============================
efi_auto=$(lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT -r | grep -i "vfat" | awk '{print "/dev/"$1}' | head -n1)

if [[ -n "$efi_auto" ]]; then
    echo -e "✅ Partisi EFI terdeteksi otomatis: \e[1m$efi_auto\e[0m"
    read -rp "Gunakan partisi EFI ini? (Y/n): " use_auto
    use_auto=${use_auto,,}
    if [[ "$use_auto" == "n" || "$use_auto" == "no" ]]; then
        input_partisi "EFI" efi_part
    else
        efi_part=$efi_auto
    fi
else
    echo -e "⚠️  Tidak ditemukan partisi EFI otomatis."
    input_partisi "EFI" efi_part
fi

# ===============================
# 📥 Input partisi lainnya (wajib)
# ===============================
input_partisi "ROOT (BTRFS)" root_part
input_partisi "HOME (BTRFS)" home_part
input_partisi "SWAP" swap_part

# ===============================
# 🧹 Format partisi
# ===============================
echo -e "\n🧹 \e[1mMemformat partisi...\e[0m"
mkfs.btrfs -f "$root_part"
mkfs.btrfs -f "$home_part"
mkfs.fat -F32 "$efi_part"
mkswap "$swap_part"
swapon "$swap_part"

# ===============================
# 🧱 Buat Subvolume Wajib
# ===============================
echo -e "\n📁 Membuat subvolume BTRFS di partisi ROOT..."
mount "$root_part" /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@snapshots
umount /mnt

# ===============================
# 🔧 Mounting Subvolume
# ===============================
echo -e "\n🔧 Mounting subvolume dan partisi..."
mount -o noatime,compress=zstd,space_cache=v2,subvol=@ "$root_part" /mnt

mkdir -p /mnt/.snapshots
mount -o noatime,compress=zstd,space_cache=v2,subvol=@snapshots "$root_part" /mnt/.snapshots

mkdir -p /mnt/home
mount "$home_part" /mnt/home

mkdir -p /mnt/boot/efi
mount "$efi_part" /mnt/boot/efi

# ===============================
# ✅ Status Akhir
# ===============================
echo -e "\n✅ \e[1mSemua partisi berhasil diformat & dimount.\e[0m"
lsblk -o NAME,MOUNTPOINT,FSTYPE,SIZE | grep -E 'mnt|NAME'

echo -e "\n🚀 Siap lanjut ke tahap pacstrap install base system!"

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
default_pkgs="base linux networkmanager sudo grub efibootmgr vim nano git base-devel wget"

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
sleep 5

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
sleep 5
arch-chroot /mnt
