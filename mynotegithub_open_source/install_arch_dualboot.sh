#!/bin/bash
# ========================================
# 🧩 Tahap 8: Setting Sistem Arch Linux
# ========================================

echo -e "\n🧩 \033[1mTahap 8: Konfigurasi Sistem Dasar\033[0m"
echo "-------------------------------------------"

# =========================
# 8.1 Zona Waktu (Asia/Jakarta)
# =========================
echo "🌏 Setting zona waktu ke Asia/Jakarta..."
ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
hwclock --systohc
echo "✅ Zona waktu diset & hwclock disinkron"

# =========================
# 8.2 Locale + Keymap
# =========================
echo -e "\n🗣️  Mengatur Locale ke en_US.UTF-8..."

if grep -q '^#en_US.UTF-8 UTF-8' /etc/locale.gen; then
  sed -i 's/^#\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
fi

locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "✅ Locale sudah digenerate dan diset default"

# Keymap keyboard
read -rp "⌨️  Mau pake keymap keyboard apa? (default: us): " keymap
keymap=${keymap:-us}

# Validasi keymap yang tersedia
if localectl list-keymaps | grep -qx "$keymap"; then
  echo "KEYMAP=$keymap" > /etc/vconsole.conf
  echo "✅ Keymap diset ke: $keymap"
else
  echo "⚠️  Keymap '$keymap' tidak valid, fallback ke 'us'"
  echo "KEYMAP=us" > /etc/vconsole.conf
fi

# =========================
# 8.3 Hostname + /etc/hosts
# =========================
read -rp "📛 Masukkan hostname sistem kamu (default: archlinux): " hostname
hostname=${hostname:-archlinux}

echo "$hostname" > /etc/hostname

cat <<EOF > /etc/hosts
127.0.0.1       localhost
::1             localhost
127.0.1.1       $hostname.localdomain $hostname
EOF

echo "✅ Hostname diset ke: $hostname"
echo "✅ File /etc/hosts dikonfigurasi"

# =========================
# 8.4 Ringkasan
# =========================
echo -e "\n📋 \033[1mRingkasan Konfigurasi:\033[0m"
echo "-------------------------------------------"
echo "🕒 Zona Waktu   : Asia/Jakarta"
echo "🌍 Locale       : en_US.UTF-8"
echo "⌨️  Keymap       : $keymap"
echo "💻 Hostname     : $hostname"

echo -e "\n✅ \033[1mTahap 8 selesai.\033[0m Siap lanjut ke user setup atau bootloader install."

#!/bin/bash

echo -e "\n🔐 \033[1mTahap 9: Buat User & Set Password\033[0m"
echo "--------------------------------------------"

# ========================
# 1. Set password root & user
# ========================
while true; do
  read -s -p "🔑 Masukkan password untuk root & user: " userpass
  echo ""
  read -s -p "🔁 Konfirmasi ulang password: " confirm
  echo ""
  [[ "$userpass" == "$confirm" ]] && break
  echo "❌ Password tidak cocok. Coba lagi."
done

echo "🔧 Mengatur password untuk root..."
echo "root:$userpass" | chpasswd

# ========================
# 2. Buat user baru
# ========================
read -p "👤 Masukkan nama username (default: adjiarch): " username
username=${username:-adjiarch}

# Validasi: tanpa spasi/simbol, hanya huruf/angka/underscore
if ! [[ "$username" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
  echo "❌ Username tidak valid! Gunakan huruf kecil, angka, dan underscore saja."
  exit 1
fi

# Cek apakah user sudah ada
if id "$username" &>/dev/null; then
  echo "⚠️  User $username sudah ada. Lewatin pembuatan user baru."
else
  echo "📦 Membuat user baru: $username"
  useradd -mG wheel "$username"
  echo "$username:$userpass" | chpasswd
  echo "✅ User berhasil dibuat dan ditambahkan ke grup wheel"
fi

# ========================
# 3. Akses sudo grup wheel
# ========================
echo "🛠️ Mengaktifkan akses sudo untuk grup wheel..."

# Backup sudoers
cp /etc/sudoers /etc/sudoers.bak

# Ubah hanya jika belum aktif
if grep -q '^# %wheel ALL=(ALL:ALL) ALL' /etc/sudoers; then
  sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
  echo "✅ Akses sudo grup wheel sudah diaktifkan"
else
  echo "ℹ️  Akses sudo untuk grup wheel sudah aktif sebelumnya"
fi

# Validasi sudoers
if ! visudo -c &>/dev/null; then
  echo "❌ ERROR di file /etc/sudoers. Mengembalikan dari backup!"
  cp /etc/sudoers.bak /etc/sudoers
else
  echo "✅ File /etc/sudoers valid"
fi

# ========================
# 4. Ringkasan
# ========================
echo ""
echo "✅ \033[1mSelesai Tahap 9:\033[0m"
echo "👤 Username: $username"
echo "🛡️  Akses sudo: Aktif (via grup wheel)"
echo "🔐 Password root & user sudah diset"

#!/bin/bash

echo -e "\n🔌 \033[1mTahap 10: Install GRUB Bootloader\033[0m"
echo "-------------------------------------------"

# ==============================
# Deteksi Mode Boot
# ==============================
if [ -d /sys/firmware/efi ]; then
  echo "✅ Mode Boot: UEFI terdeteksi (via /sys/firmware/efi)"
  boot_mode="UEFI"
else
  echo "✅ Mode Boot: BIOS (Legacy) terdeteksi"
  boot_mode="BIOS"
fi

# ==============================
# Konfirmasi / Override Manual
# ==============================
read -p "🧠 Gunakan mode boot yang terdeteksi ($boot_mode)? [Y/n]: " confirm
confirm=${confirm,,}
if [[ "$confirm" == "n" ]]; then
  echo "⚠️  Pilih mode manual:"
  echo "1. UEFI"
  echo "2. BIOS (Legacy)"
  read -p "🔢 Pilih [1/2]: " manual_mode
  [[ "$manual_mode" == "1" ]] && boot_mode="UEFI"
  [[ "$manual_mode" == "2" ]] && boot_mode="BIOS"
fi

# ==============================
# Validasi mount point
# ==============================
if [[ ! -d /boot ]]; then
  echo "❌ Folder /boot tidak ditemukan. Pastikan partisi sudah di-mount!"
  exit 1
fi

# ==============================
# Install GRUB Sesuai Mode
# ==============================
if [[ "$boot_mode" == "UEFI" ]]; then
  echo "🛠️ Menginstall GRUB untuk UEFI..."
  efidir=$(findmnt -no TARGET /boot/efi)
  if [[ -z "$efidir" ]]; then
    echo "❌ Partisi EFI belum di-mount ke /boot/efi. Batal."
    exit 1
  fi
  grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ArchLinux --recheck
else
  echo ""
  lsblk -dpno NAME,SIZE | grep -v loop
  read -p "💿 Masukkan disk utama (contoh: /dev/sda /dev/nvme0n1): " target_disk
  if [[ ! -b "$target_disk" ]]; then
    echo "❌ Disk tidak valid."
    exit 1
  fi
  echo "🛠️ Install GRUB ke MBR (BIOS)..."
  grub-install --target=i386-pc --recheck "$target_disk"
fi

# ==============================
# Generate Config GRUB
# ==============================
echo "⚙️  Membuat konfigurasi GRUB..."
grub-mkconfig -o /boot/grub/grub.cfg

# ==============================
# Cek os-prober (optional)
# ==============================
if [[ -f /etc/default/grub ]]; then
  if grep -q 'GRUB_DISABLE_OS_PROBER=true' /etc/default/grub; then
    echo ""
    echo "⚠️  os-prober dinonaktifkan. Aktifkan jika ingin deteksi OS lain (Windows)."
    echo "Edit /etc/default/grub dan ubah: GRUB_DISABLE_OS_PROBER=false"
    echo "Kemudian jalankan ulang: grub-mkconfig -o /boot/grub/grub.cfg"
  fi
fi

echo ""
echo "✅ \033[1mGRUB berhasil diinstall dan dikonfigurasi!\033[0m"

#!/bin/bash

echo -e "\n🧹 \033[1mTahap 12: Exit, Unmount & Reboot\033[0m"
echo "------------------------------------------"

# ✅ Deteksi apakah kita masih di dalam chroot
if grep -q '/mnt' /proc/1/mountinfo && [ "$(readlink /proc/1/root)" != "/" ]; then
    echo -e "⚠️  Saat ini lo masih berada di dalam lingkungan \033[1mchroot\033[0m (/mnt)."
    echo "🔚 Untuk melanjutkan:"
    echo "   ➜ Ketik perintah: \033[1mexit\033[0m"
    echo "   ➜ Lalu jalankan script ini lagi dari \033[1mlive ISO (di luar chroot)\033[0m"
    exit 1
fi

# Unmount semua partisi dari /mnt
if ! mountpoint -q /mnt; then
    echo "❗ /mnt sudah tidak ter-mount. Mungkin udah pernah di-unmount sebelumnya."
else
    echo "🗂️  Unmount semua partisi dari /mnt..."
    umount -R /mnt 2>/dev/null

    if [[ $? -eq 0 ]]; then
        echo "✅ Semua partisi berhasil di-unmount dari /mnt."
    else
        echo "⚠️  Beberapa partisi gagal di-unmount atau sudah tidak ter-mount."
        echo "   ➜ Cek manual dengan: mount | grep mnt"
    fi
fi

# Reminder ke user
echo -e "\n📋 \033[1mCatatan Penting Sebelum Reboot:\033[0m"
echo "✅ Instalasi Arch Linux sudah selesai dan sistem sudah terpasang di disk."
echo "🛑 Pastikan lo \033[1mCABUT USB atau detach ISO\033[0m sebelum reboot:"
echo "   - Real PC? ➜ Cabut flashdisk/USB bootable"
echo "   - VirtualBox/VMWare? ➜ Detach ISO image dari optical drive (storage setting)"

# Konfirmasi reboot
read -rp $'\n🔁 Mau reboot sekarang? [Y/n]: ' jawab
jawab=${jawab,,}

if [[ "$jawab" =~ ^(y|yes)?$ || "$jawab" == "" ]]; then
    echo -e "\n🚀 Rebooting sekarang..."
    reboot || echo "⚠️  Reboot gagal. Silakan ketik manual: \033[1mreboot\033[0m"
else
    echo "✅ Oke, lo bisa reboot nanti dengan perintah: \033[1mreboot\033[0m"
fi
