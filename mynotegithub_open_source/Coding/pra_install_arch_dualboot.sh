#!/bin/bash
# ========================================================
# 🌐 Tahap 2: Koneksi Internet & Update Mirrorlist
# ========================================================

# Logging semua output ke file
exec &> >(tee "/root/tahap2-koneksi.log")

echo -e "\n🌐 \033[1mTahap 2: Koneksi Internet & Mirror\033[0m"
echo "-----------------------------------------------"

# Sinkronisasi waktu
echo "⏳ Sinkronisasi waktu (timedatectl)..."
timedatectl set-ntp true
sleep 2

# Deteksi IP aktif (cek DHCP status)
echo -e "\n🔎 Status IP Address:"
ip a | grep -E "inet\s" | grep -v "127.0.0.1"

# Deteksi interface LAN
echo -e "\n🔌 Deteksi interface LAN:"
ip link show | grep -E 'eth|enp' | awk -F: '{print "  ➤ " $2}' || echo "  🚫 Tidak ada LAN interface terdeteksi."

# Tes koneksi ke archlinux.org
echo -e "\n📶 Cek koneksi internet ke archlinux.org..."
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
    echo -e "❌ \033[1;31mInternet mati total!\033[0m Mungkin belum konek atau driver WiFi belum support."

    # Cek WiFi device
    wifi_devices=$(iwctl device list | grep wlan)
    if [[ -z "$wifi_devices" ]]; then
      echo -e "🚫 \033[1;31mWiFi device tidak terdeteksi!\033[0m Mungkin kernel belum support driver WiFi."
      echo -e "💡 \033[1;33mSolusi:\033[0m Gunakan kabel LAN atau download ISO Arch dengan driver WiFi non-free."
    else
      echo -e "\n📡 \033[1mGunakan WiFi via iwctl:\033[0m"
      echo "  1. Ketik: iwctl"
      echo "  2. Lalu jalankan perintah berikut di dalam iwctl:"
      echo "     ➤ device list"
      echo "     ➤ station wlan0 scan"
      echo "     ➤ station wlan0 get-networks"
      echo "     ➤ station wlan0 connect NAMA_WIFI"
      echo "     ➤ exit"
      echo ""
      echo "💡 Ganti 'wlan0' sesuai hasil device list kamu."
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

# ========================================
# 🪞 Update Mirrorlist (optional)
# ========================================
echo ""
echo "📦 Mau update mirrorlist pakai reflector?"
read -rp "Lanjut update mirrorlist ke server Indonesia tercepat? [Y/n]: " lanjut
lanjut=${lanjut,,}

if [[ "$lanjut" == "y" || "$lanjut" == "" ]]; then
  echo "🔃 Update database dan install reflector..."
  pacman -Sy --noconfirm reflector || {
    echo "❌ Gagal install reflector! Mirrorlist tidak bisa diupdate."
    exit 1
  }

  echo "🪞 Menjalankan reflector..."
  if reflector --country Indonesia --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist; then
    echo "✅ Mirrorlist berhasil di-update ke server Indonesia tercepat!"
  else
    echo -e "⚠️  \033[1;33mReflector gagal!\033[0m Nyoba fallback mirrorlist manual..."
    cat > /etc/pacman.d/mirrorlist <<EOF
Server = https://mirror.osbeck.com/archlinux/\$repo/os/\$arch
Server = https://mirror.lesviallon.fr/archlinux/\$repo/os/\$arch
EOF
    echo "✅ Mirrorlist fallback manual berhasil diset."
  fi
else
  echo "⏭️  Lewatin update mirrorlist."
fi

echo -e "\n📁 Log lengkap tersimpan di: \033[1;34m/root/tahap2-koneksi.log\033[0m"
echo -e "🚀 Siap lanjut ke tahap berikutnya!"

#!/bin/bash

# Redirect semua output ke log file
exec &> >(tee "/root/tahap3-partisi.log")

# ================================================
# 💽 Tahap 3: Partisi Disk - Smart Validation V2
# ================================================

echo -e "\n💽 \033[1mTahap 3: Partisi Disk Arch Linux\033[0m"
echo "-------------------------------------------"

# Tampilkan disk fisik (exclude loop, sr0, USB kecil)
echo -e "\n🧠 \033[1mDaftar Disk yang Terdeteksi:\033[0m"
lsblk -dpno NAME,SIZE,MODEL | grep -vE 'loop|boot|rpmb|mmcblk|sr0'

# Input disk target
while true; do
    echo ""
    read -rp "🖋️  Masukkan nama disk target (misal /dev/sda /dev/nvme0n1): " disk
    if [[ -b "$disk" ]]; then
        # Cek apakah disk sedang digunakan
        if mount | grep "$disk" &>/dev/null; then
            echo -e "❌ \033[1;31mDisk $disk sedang termount!\033[0m Lepas dulu sebelum lanjut."
            exit 1
        fi
        break
    else
        echo -e "❌ \033[1;31mDisk tidak valid!\033[0m Cek ulang dengan lsblk."
    fi
done

# Deteksi tipe partisi (GPT/MBR)
parted -s "$disk" print | grep -q "gpt" && parttype="GPT" || parttype="MBR"
echo -e "🧾 Deteksi Tipe Partisi: \033[1;36m$parttype\033[0m"

# Konfirmasi user
echo -e "\n⚠️  \033[1;33mPERINGATAN!\033[0m Semua data di $disk bisa hilang jika diformat."
read -rp "Lanjut buat partisi manual di $disk dengan cfdisk? [y/N]: " lanjut
lanjut=${lanjut,,}
if [[ "$lanjut" != "y" && "$lanjut" != "yes" ]]; then
  echo "❎ Dibatalkan. Keluar dari tahap partisi."
  exit 0
fi

# Jalankan cfdisk
echo -e "\n🚀 Menjalankan cfdisk di $disk..."
sleep 3
cfdisk "$disk"

# Tampilkan hasil partisi setelah keluar
echo -e "\n📦 \033[1mPartisi selesai. Berikut hasil:\033[0m"
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
            echo -e "❌ \033[1;31m$input bukan partisi valid!\033[0m Coba cek lagi hasil lsblk."
        fi
    done
}

input_partisi "EFI (vfat)" efi_part
input_partisi "ROOT (btrfs)" root_part
input_partisi "HOME (btrfs)" home_part
input_partisi "SWAP (swap)" swap_part

# ===============================
# Cek tidak ada duplikat partisi
# ===============================
check_duplicate_partitions() {
    local arr=("$efi_part" "$root_part" "$home_part" "$swap_part")
    local unique=($(printf "%s\n" "${arr[@]}" | sort -u))
    if [[ "${#unique[@]}" -ne "${#arr[@]}" ]]; then
        echo -e "❌ \033[1;31mAda partisi yang diinput dua kali!\033[0m Harap input ulang."
        exit 1
    fi
}
check_duplicate_partitions

# ===============================
# Tampilkan ringkasan
# ===============================
echo -e "\n✅ \033[1mSemua partisi berhasil divalidasi!\033[0m"
echo -e "📁 EFI  : $efi_part"
echo -e "📁 ROOT : $root_part"
echo -e "📁 HOME : $home_part"
echo -e "💾 SWAP : $swap_part"

# ===============================
# Lanjut ke tahap berikutnya?
# ===============================
echo ""
read -rp "👉 Mau lanjut langsung ke tahap format & mount (Tahap 4)? [Y/n]: " next
next=${next,,}
if [[ "$next" == "y" || "$next" == "" ]]; then
    if [[ -x ./tahap4-format-mount.sh ]]; then
        echo -e "\n🚀 Menjalankan Tahap 4..."
        sleep 2
        ./tahap4-format-mount.sh
    else
        echo -e "⚠️  Script tahap4-format-mount.sh tidak ditemukan atau tidak executable."
    fi
else
    echo -e "⏭️  Tahap 3 selesai. Kamu bisa lanjut ke tahap 4 secara manual."
fi

#!/bin/bash

# ========================================================
# 🔁 Tahap 4: Format dan Mount Partisi BTRFS (Enhanced)
# ========================================================
exec &> >(tee "/root/tahap4-format-mount.log")

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
            if mount | grep -q "$input"; then
                echo -e "⚠️  \e[1;33m$input sedang digunakan/mounted. Harap unmount terlebih dahulu.\e[0m"
            else
                eval "$varname=\"$input\""
                break
            fi
        else
            echo -e "❌ \e[1;31m$input bukan partisi valid!\e[0m"
        fi
    done
}

# ===============================
# 🧠 Auto/Manual EFI
# ===============================
efi_auto=$(lsblk -o NAME,FSTYPE,MOUNTPOINT | grep -i "vfat" | awk '{print "/dev/"$1}' | head -n1)
if [[ -n "$efi_auto" ]]; then
    echo -e "✅ EFI otomatis ditemukan: \e[1m$efi_auto\e[0m"
    read -rp "Gunakan partisi ini? (Y/n): " use_auto
    [[ "${use_auto,,}" =~ ^(n|no)$ ]] && input_partisi "EFI" efi_part || efi_part=$efi_auto
else
    input_partisi "EFI" efi_part
fi

input_partisi "ROOT (BTRFS)" root_part
input_partisi "HOME (BTRFS)" home_part
input_partisi "SWAP" swap_part

# ===============================
# 🚫 Cek partisi duplikat
# ===============================
parts=("$efi_part" "$root_part" "$home_part" "$swap_part")
if [[ "${#parts[@]}" != "$(printf "%s\n" "${parts[@]}" | sort -u | wc -l)" ]]; then
    echo -e "❌ \e[1;31mAda partisi yang sama digunakan lebih dari sekali!\e[0m"
    exit 1
fi

# ===============================
# ❓ Konfirmasi Format
# ===============================
echo -e "\n⚠️  Semua partisi di bawah akan diformat:"
echo -e "  EFI : $efi_part\n  ROOT: $root_part\n  HOME: $home_part\n  SWAP: $swap_part"
read -rp "Lanjutkan format? (Y/n): " ok
[[ "${ok,,}" =~ ^(n|no)$ ]] && { echo "❎ Dibatalkan."; exit 0; }

# ===============================
# 🧹 Format partisi
# ===============================
echo -e "\n🧹 Memformat partisi..."
mkfs.fat -F32 "$efi_part"
mkfs.btrfs -f "$root_part"
mkfs.btrfs -f "$home_part"
mkswap "$swap_part"
swapon "$swap_part"

# ===============================
# 📁 Subvolume Setup
# ===============================
echo -e "\n📁 Membuat subvolume..."
mount "$root_part" /mnt

btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@pkg
btrfs subvolume create /mnt/@cache

umount /mnt

# ===============================
# 🔧 Mounting struktur BTRFS
# ===============================
echo -e "\n🔧 Mounting semua subvolume..."
mount -o noatime,compress=zstd,space_cache=v2,ssd,discard,subvol=@ "$root_part" /mnt

mkdir -p /mnt/{home,.snapshots,var/log,boot/efi,var/cache/pacman/pkg}

mount -o noatime,compress=zstd,space_cache=v2,ssd,discard,subvol=@home "$root_part" /mnt/home
mount -o noatime,compress=zstd,space_cache=v2,ssd,discard,subvol=@log "$root_part" /mnt/var/log
mount -o noatime,compress=zstd,space_cache=v2,ssd,discard,subvol=@snapshots "$root_part" /mnt/.snapshots
mount -o noatime,compress=zstd,space_cache=v2,ssd,discard,subvol=@pkg "$root_part" /mnt/var/cache/pacman/pkg
mount -o noatime,compress=zstd,space_cache=v2,ssd,discard,subvol=@cache "$root_part" /mnt/var/cache

mount "$home_part" /mnt/home
mount "$efi_part" /mnt/boot/efi

# ===============================
# ✅ Status akhir
# ===============================
echo -e "\n✅ \e[1mSemua partisi dan subvolume berhasil dimount.\e[0m"
lsblk -o NAME,MOUNTPOINT,FSTYPE,SIZE | grep -E 'mnt|NAME'

# ===============================
# 🚀 Lanjut Tahap 5?
# ===============================
echo ""
read -rp "➡️  Mau lanjut ke Tahap 5 (install base system)? (Y/n): " lanjut
[[ "${lanjut,,}" =~ ^(y|yes|)$ ]] && [[ -f "./tahap5-install-base.sh" ]] && exec ./tahap5-install-base.sh

#!/bin/bash

# =========================================
# 🏗️ Tahap 5: Install Sistem Dasar Arch Linux
# =========================================

log_file="tahap5-install.log"
exec &> >(tee "$log_file")

echo -e "\n\033[1;36m🏗️  Tahap 5: Install Sistem Dasar Arch Linux\033[0m"
echo "-----------------------------------------------"

# === 1. Validasi pacstrap ===
if ! command -v pacstrap &>/dev/null; then
    echo -e "\033[1;31m❌ pacstrap tidak ditemukan! Jalankan dari Arch ISO Live.\033[0m"
    exit 1
fi

# === 2. Validasi koneksi internet ===
echo -n "🌐 Mengecek koneksi internet... "
if ping -q -c 1 archlinux.org &>/dev/null; then
    echo -e "\033[1;32mTERHUBUNG\033[0m"
else
    echo -e "\033[1;31mTIDAK ADA KONEKSI!\033[0m Cek Wi-Fi/kabel atau set DNS."
    exit 1
fi

# === 3. Cek mount point ===
if ! mountpoint -q /mnt; then
    echo -e "\033[1;31m❌ /mnt belum ter-mount! Mount dulu partisi root ke /mnt.\033[0m"
    exit 1
fi

echo -e "\033[1;32m✅ /mnt sudah siap digunakan.\033[0m"

# === 4. Deteksi CPU microcode ===
cpu_ucode=""
if grep -q "Intel" /proc/cpuinfo; then
    cpu_ucode="intel-ucode"
elif grep -q "AMD" /proc/cpuinfo; then
    cpu_ucode="amd-ucode"
fi

# === 5. Optimasi mirrorlist ===
if command -v reflector &>/dev/null; then
    echo -e "\n🚀 Menjalankan \033[1mreflector\033[0m untuk mirror terbaik..."
    reflector --country "Indonesia,Singapore" --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
    echo -e "\033[1;32m✅ Mirrorlist diperbarui.\033[0m"
else
    echo -e "\033[1;33m⚠️ Reflector tidak tersedia. Lewati optimasi mirror.\033[0m"
fi

# === 6. Daftar paket dasar ===
default_pkgs="base linux $cpu_ucode networkmanager sudo grub efibootmgr vim nano git base-devel wget"

echo -e "\n📦 \033[1mPaket default:\033[0m"
echo "$default_pkgs"

read -rp $'\n➕ Tambahkan paket tambahan? (contoh: pipewire firefox): ' extra_pkgs
all_pkgs="$default_pkgs $extra_pkgs"

# === 7. Konfirmasi dan jalankan pacstrap ===
echo -e "\n🚀 Menjalankan \033[1;34mpacstrap\033[0m ke /mnt dengan paket:\n$all_pkgs\n"
sleep 3

# === 8. Deteksi apakah /mnt sudah ada pacman ===
if [[ -f /mnt/bin/pacman || -f /mnt/usr/bin/pacman ]]; then
    echo -e "\033[1;33m⚠️  Deteksi sistem sudah ter-install sebagian di /mnt. Lanjutkan dengan hati-hati.\033[0m"
    read -rp "Tetap jalankan pacstrap ulang? (Y/n): " confirm
    [[ "${confirm,,}" =~ ^(n|no)$ ]] && exit 0
fi

# Jalankan pacstrap
if pacstrap /mnt $all_pkgs; then
    echo -e "\n\033[1;32m✅ Sistem dasar berhasil di-install!\033[0m"
else
    echo -e "\n\033[1;31m❌ pacstrap gagal. Cek log: $log_file\033[0m"
    exit 1
fi

# === 9. Generate fstab ===
echo -e "\n📄 Men-generate fstab..."
genfstab -U /mnt >> /mnt/etc/fstab
echo -e "\033[1;32m✅ fstab dibuat di /mnt/etc/fstab\033[0m"

# === 10. Deteksi mode boot ===
boot_mode="BIOS"
if [ -d /sys/firmware/efi ]; then
    boot_mode="UEFI"
fi
echo -e "🧠 Mode Boot: \033[1;36m$boot_mode\033[0m"

# === 11. Simpan info instalasi ===
echo -e "\n💾 Menyimpan ringkasan instalasi ke /mnt/root/install-summary.log"
cat <<EOF > /mnt/root/install-summary.log
=== Ringkasan Instalasi (Tahap 5) ===
Tanggal       : $(date)
Mode Boot     : $boot_mode
CPU Ucode     : $cpu_ucode
Paket Default : $default_pkgs
Tambahan      : $extra_pkgs
EOF

# === 12. Prompt lanjut ===
echo -e "\n➡️  \033[1mTahap 5 selesai. Lanjut ke tahap chroot konfigurasi?\033[0m"
read -rp "Jalankan tahap6-chroot.sh sekarang? (Y/n): " lanjut
if [[ "${lanjut,,}" =~ ^(y|yes)?$ && -f ./tahap6-chroot.sh ]]; then
    exec ./tahap6-chroot.sh
else
    echo -e "👍 Oke. Jalankan tahap6-chroot.sh secara manual kalau siap."
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

# ===============================
# 🔍 Validasi Mount Point Penting
# ===============================
echo -e "\n🔍 Mengecek struktur mount di /mnt..."
expected_mounts=("/mnt" "/mnt/home" "/mnt/boot/efi" "/mnt/.snapshots")

for path in "${expected_mounts[@]}"; do
    if mountpoint -q "$path"; then
        echo -e "✅ $path ter-mount"
    else
        echo -e "\033[1;33m⚠️  $path belum ter-mount. fstab bisa jadi tidak lengkap.\033[0m"
    fi
done

# ===============================
# 🔄 Opsi: UUID atau LABEL
# ===============================
echo -e "\n📌 \033[1mPilih metode generate fstab:\033[0m"
echo "1. UUID (default - aman & stabil)"
echo "2. LABEL (alternatif)"

read -rp $'\nPilih metode [1/2] (default: 1): ' metode
case "$metode" in
    2) option="-L" ;;
    *) option="-U" ;;
esac

# ===============================
# 🗂️ Backup fstab lama jika ada
# ===============================
if [[ -f /mnt/etc/fstab ]]; then
    timestamp=$(date +%Y%m%d-%H%M%S)
    cp /mnt/etc/fstab "/mnt/etc/fstab.backup-$timestamp"
    echo -e "📁 Backup fstab lama: \033[1;34m/mnt/etc/fstab.backup-$timestamp\033[0m"
fi

# ===============================
# ⚙️ Jalankan genfstab & logging
# ===============================
echo -e "\n⚙️  Menjalankan perintah: \033[1mgenfstab $option -p /mnt\033[0m"
logfile="/mnt/root/genfstab.log"

genfstab $option -p /mnt | tee -a /mnt/etc/fstab | tee "$logfile"

# ===============================
# ✅ Validasi hasil
# ===============================
if [[ $? -eq 0 && -s /mnt/etc/fstab ]]; then
    echo -e "\n✅ \033[1;32mfstab berhasil dibuat di /mnt/etc/fstab!\033[0m"

    line_count=$(wc -l < /mnt/etc/fstab)
    if [[ $line_count -lt 2 ]]; then
        echo -e "\033[1;33m⚠️  Warning: fstab hanya berisi $line_count baris. Cek lagi mount point kamu.\033[0m"
    fi

    echo -e "\n📄 \033[1mIsi fstab:\033[0m"
    echo "-------------------------------"
    cat /mnt/etc/fstab

    echo -e "\n📝 Log juga disimpan di: \033[1;34m$logfile\033[0m"
else
    echo -e "\033[1;31m❌ Gagal generate fstab. Cek kembali mount dan partisi!\033[0m"
    exit 1
fi

#!/bin/bash

# =================================================
# 🛠️ Tahap 7: Chroot ke Sistem Arch Linux
# =================================================

set -e

echo -e "\n\033[1;36m🛠️  Tahap 7: Chroot ke Sistem\033[0m"
echo "----------------------------------------"

# ✅ Cek root
if [[ $EUID -ne 0 ]]; then
  echo -e "\033[1;31m❌ Script ini harus dijalankan sebagai root!\033[0m"
  exit 1
fi

# ✅ Validasi struktur /mnt
if [[ ! -d /mnt/etc || ! -x /mnt/bin/bash ]]; then
  echo -e "\033[1;31m❌ Target sistem belum lengkap! Pastikan sudah pacstrap dan genfstab.\033[0m"
  exit 1
fi

# ✅ Deteksi sistem boot
if [[ -d /sys/firmware/efi ]]; then
  echo -e "🧭 Deteksi sistem boot: \033[1;32mUEFI\033[0m"
else
  echo -e "🧭 Deteksi sistem boot: \033[1;33mBIOS/Legacy\033[0m"
fi

# ✅ Deteksi shell bawaan (kalau sudah ada user selain root)
if grep -q '/home/' /mnt/etc/passwd 2>/dev/null; then
  shell_hint=$(grep '/home/' /mnt/etc/passwd | awk -F: '{print $7}' | head -n 1)
  echo -e "🔍 Shell user terakhir: \033[1;34m${shell_hint}\033[0m"
fi

# ✅ Cek arch-chroot
if ! command -v arch-chroot &>/dev/null; then
  echo -e "\033[1;31m❌ Perintah arch-chroot tidak ditemukan!\033[0m"
  exit 1
fi

# 📁 Preview partisi /mnt
echo -e "\n📁 Cek mount /mnt:"
lsblk -o NAME,SIZE,MOUNTPOINT | grep '/mnt'

# 🔄 Konfirmasi
read -rp $'\n🔁 Masuk ke chroot sekarang? [Y/n]: ' lanjut
lanjut=${lanjut,,}
[[ "$lanjut" =~ ^(n|no)$ ]] && { echo -e "\033[1;33m❎ Dibatalkan.\033[0m"; exit 0; }

# 💡 Eksekusi script tambahan
read -rp $'\n📜 Mau auto-jalankan script setelah chroot? (bisa lebih dari 1, pisah spasi) [Enter=skip]: ' script_paths

if [[ -n "$script_paths" ]]; then
  for path in $script_paths; do
    if [[ -f "/mnt$path" ]]; then
      chmod +x "/mnt$path"
      echo "bash $path; sed -i '/bash $path/d' ~/.bashrc" >> /mnt/root/.bashrc
      echo -e "✅ Siap dijalankan otomatis: \033[1m$path\033[0m"
    else
      echo -e "\033[1;31m❌ Tidak ditemukan: /mnt$path\033[0m"
    fi
  done
fi

# ⚡️ Opsi shell alternatif
if [[ -f /mnt/bin/zsh ]]; then
  read -rp $'\n⚙️  Mau gunakan zsh saat chroot? [y/N]: ' pakai_zsh
  pakai_zsh=${pakai_zsh,,}
  if [[ "$pakai_zsh" =~ ^(y|yes)$ ]]; then
    echo "exec zsh" >> /mnt/root/.bashrc
    echo -e "🌀 Akan gunakan \033[1mzsh\033[0m saat chroot."
  fi
fi

# 🚪 Jalankan chroot
echo -e "\n🚪 Masuk ke chroot: \033[1march-chroot /mnt\033[0m\n"
sleep 2
arch-chroot /mnt

# 🏁 Keluar dari chroot
echo -e "\n📤 Keluar dari chroot."
echo -e "📝 Lanjutkan ke tahap berikutnya: \033[1mkonfigurasi user, locale, grub, dll.\033[0m"
