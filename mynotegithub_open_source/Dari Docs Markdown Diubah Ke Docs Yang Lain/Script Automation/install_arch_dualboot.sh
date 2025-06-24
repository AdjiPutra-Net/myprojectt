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
  echo -e "\n❌ Password tidak cocok. Coba lagi.\n"
done

echo "🔧 Mengatur password untuk root..."
echo "root:$userpass" | chpasswd

# ========================
# 2. Buat user baru
# ========================
read -p "👤 Masukkan nama username (default: adjiarch): " username
username=${username:-adjiarch}

# Validasi username (lowercase, angka, underscore, dash, tidak mulai dari angka/dash)
if ! [[ "$username" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
  echo "❌ Username tidak valid! Gunakan huruf kecil, angka, dash, dan underscore. Tidak boleh mulai dari angka."
  exit 1
fi

# Cek apakah user sudah ada
if id "$username" &>/dev/null; then
  echo "⚠️  User \033[1m$username\033[0m sudah ada. Lewatin pembuatan user baru."
else
  echo "📦 Membuat user baru: $username"
  useradd -m -G wheel "$username"
  echo "$username:$userpass" | chpasswd
  echo "✅ User berhasil dibuat dan ditambahkan ke grup wheel"
fi

# ========================
# 3. Akses sudo grup wheel
# ========================
echo "🛠️  Mengaktifkan akses sudo untuk grup wheel..."

# Backup sudoers
cp /etc/sudoers /etc/sudoers.bak

# Ubah hanya jika belum aktif
if grep -q '^# %wheel ALL=(ALL:ALL) ALL' /etc/sudoers; then
  sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
  echo "✅ Akses sudo grup wheel sudah diaktifkan"
else
  echo "ℹ️  Akses sudo grup wheel sudah aktif sebelumnya"
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
echo -e "✅ \033[1mSelesai Tahap 9:\033[0m"
echo -e "👤 Username: \033[1m$username\033[0m"
echo -e "🛡️  Akses sudo: \033[1mAktif\033[0m (via grup wheel)"
echo -e "🔐 Password root & user sudah diatur dengan sukses"

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
# Konfirmasi atau Override Manual
# ==============================
read -p "🧠 Gunakan mode boot yang terdeteksi ($boot_mode)? [Y/n]: " confirm
confirm=${confirm,,}
if [[ "$confirm" == "n" ]]; then
  echo "⚠️  Pilih mode manual:"
  echo "1. UEFI"
  echo "2. BIOS (Legacy)"
  read -p "🔢 Pilih [1/2]: " manual_mode
  case "$manual_mode" in
    1) boot_mode="UEFI" ;;
    2) boot_mode="BIOS" ;;
    *) echo "❌ Pilihan tidak valid. Batal."; exit 1 ;;
  esac
fi

# ==============================
# Validasi Mount Point
# ==============================
if [[ ! -d /boot ]]; then
  echo "❌ Folder /boot tidak ditemukan. Pastikan partisi sudah di-mount!"
  exit 1
fi

# ==============================
# Install GRUB
# ==============================
if [[ "$boot_mode" == "UEFI" ]]; then
  echo "🛠️  Menginstall GRUB untuk UEFI..."
  efidir=$(findmnt -no TARGET /boot/efi)
  if [[ -z "$efidir" ]]; then
    echo "❌ Partisi EFI belum di-mount ke /boot/efi. Batal."
    exit 1
  fi
  grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ArchLinux --recheck
else
  echo ""
  echo "💽 Daftar disk fisik:"
  lsblk -dpno NAME,SIZE | grep -v loop
  echo ""
  read -p "💿 Masukkan disk utama (contoh: /dev/sda /dev/nvme0n1): " target_disk
  if [[ ! -b "$target_disk" ]]; then
    echo "❌ Disk tidak valid."
    exit 1
  fi
  echo "🛠️  Menginstall GRUB ke MBR (BIOS)..."
  grub-install --target=i386-pc --recheck "$target_disk"
fi

# ==============================
# Generate GRUB Config
# ==============================
echo "⚙️  Membuat konfigurasi GRUB..."
grub-mkconfig -o /boot/grub/grub.cfg

# ==============================
# Cek os-prober
# ==============================
if [[ -f /etc/default/grub ]]; then
  if grep -q 'GRUB_DISABLE_OS_PROBER=true' /etc/default/grub; then
    echo ""
    echo "⚠️  os-prober dinonaktifkan. Sistem lain (Windows, dsb) tidak akan terdeteksi."
    echo "➡️  Untuk mengaktifkannya:"
    echo "   1. Edit file: \033[1m/etc/default/grub\033[0m"
    echo "   2. Ubah:     \033[1mGRUB_DISABLE_OS_PROBER=false\033[0m"
    echo "   3. Jalankan: \033[1mgrub-mkconfig -o /boot/grub/grub.cfg\033[0m"
  fi
fi

# ==============================
# Output Final
# ==============================
echo -e "\n✅ \033[1mGRUB berhasil diinstall dan dikonfigurasi!\033[0m"

#!/bin/bash

# =====================================
# ✅ Notifikasi Langkah Setelah Install
# =====================================

echo -e "\n🎉 \e[1mInstalasi Arch Linux Selesai!\e[0m"
echo "--------------------------------------------------"
echo "📦 Semua konfigurasi sistem (timezone, locale, user, bootloader)"
echo "   sudah sukses diinstal ke hardisk/SSD kamu."

echo -e "\n🚀 \e[1mLangkah Selanjutnya (Manual):\e[0m"
echo -e "➤ 1. Keluar dari lingkungan chroot:"
echo -e "   \e[1mexit\e[0m"
echo -e "   🔧 Keluar dari sistem sementara (chroot), untuk balik ke Live ISO."

echo -e "\n➤ 2. Unmount semua partisi dari /mnt:"
echo -e "   \e[1mumount -R /mnt\e[0m"
echo -e "   💡 Mencopot koneksi mount dari Live ISO ke disk,"
echo -e "      karena semua data udah masuk disk."

echo -e "\n➤ 3. Pilih salah satu opsi berikut:"
echo -e "   \e[1mreboot\e[0m           🔁 Untuk restart langsung ke Arch Linux"
echo -e "   \e[1mshutdown -P now\e[0m  🔌 Untuk matikan komputer dulu"

echo -e "\n⚠️  \e[1mPERHATIKAN:\e[0m"
echo -e "✅ Sebelum reboot/shutdown:"
echo -e "   - Cabut flashdisk bootable / detach ISO image"
echo -e "   - Kalau pakai VirtualBox / VMWare: detach ISO dari Storage Settings"
echo -e "❌ Kalau tidak, sistem bisa booting balik ke installer Arch ISO lagi."

echo -e "\n📌 \e[1mRekomendasi:\e[0m"
echo -e "🖥️  Real PC Dualboot (dengan Windows)? ➜ \e[1mCabut USB lalu reboot\e[0m"
echo -e "🖥️  VM atau mau hapus ISO?            ➜ \e[1mshutdown -P now lalu hapus ISO\e[0m"

echo -e "\n✅ \e[1mSelesai. Sampai ketemu di sistem Arch Linux kamu!\e[0m 🚀"
