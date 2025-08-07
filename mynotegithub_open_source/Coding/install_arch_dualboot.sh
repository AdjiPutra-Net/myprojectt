#!/bin/bash
# ========================================
# 🧩 Tahap 8: Setting Sistem Arch Linux
# ========================================

set -e

echo -e "\n🧩 \033[1;36mTahap 8: Konfigurasi Sistem Dasar Arch\033[0m"
echo "-------------------------------------------"

# ===============================
# 8.0 Cek Root
# ===============================
if [[ $EUID -ne 0 ]]; then
  echo -e "\033[1;31m❌ Harus dijalankan sebagai root.\033[0m"
  exit 1
fi

# ===============================
# 8.1 Zona Waktu
# ===============================
read -rp "🌏 Masukkan zona waktu (default: Asia/Jakarta): " timezone
timezone=${timezone:-Asia/Jakarta}

if [[ -f "/usr/share/zoneinfo/$timezone" ]]; then
  ln -sf "/usr/share/zoneinfo/$timezone" /etc/localtime
  hwclock --systohc
  echo "✅ Zona waktu diset ke: $timezone"
else
  echo -e "\033[1;31m❌ Zona waktu tidak valid: $timezone\033[0m"
  exit 1
fi

# ===============================
# 8.2 Locale
# ===============================
read -rp "🌐 Locale utama (default: en_US.UTF-8): " locale
locale=${locale:-en_US.UTF-8}

if ! grep -q "$locale UTF-8" /etc/locale.gen; then
  echo "$locale UTF-8" >> /etc/locale.gen
else
  sed -i "s/^#\($locale UTF-8\)/\1/" /etc/locale.gen
fi

locale-gen
echo "LANG=$locale" > /etc/locale.conf
echo "✅ Locale diset: $locale"

# ===============================
# 8.3 Keymap
# ===============================
read -rp "⌨️  Keymap keyboard (default: us): " keymap
keymap=${keymap:-us}

if localectl list-keymaps | grep -qx "$keymap"; then
  echo "KEYMAP=$keymap" > /etc/vconsole.conf
  echo "✅ Keymap diset: $keymap"
else
  echo -e "\033[1;33m⚠️  Keymap tidak valid, fallback ke 'us'\033[0m"
  echo "KEYMAP=us" > /etc/vconsole.conf
  keymap="us"
fi

# ===============================
# 8.4 Optional: Font Console TTY
# ===============================
read -rp "🔤 Mau set font console TTY (contoh: ter-132n)? [y/N]: " ans_font
ans_font=${ans_font,,}

if [[ "$ans_font" == "y" ]]; then
  read -rp "🖋️  Nama font: " fontname
  if [[ -n "$fontname" ]]; then
    echo "FONT=$fontname" >> /etc/vconsole.conf
    echo "✅ Font console diset ke: $fontname"
  fi
fi

# ===============================
# 8.5 Hostname
# ===============================
read -rp "📛 Hostname sistem (default: archlinux): " hostname
hostname=${hostname:-archlinux}

echo "$hostname" > /etc/hostname

cat <<EOF > /etc/hosts
127.0.0.1       localhost
::1             localhost
127.0.1.1       $hostname.localdomain $hostname
EOF

echo "✅ Hostname diset ke: $hostname"
echo "✅ /etc/hosts dikonfigurasi"

# ===============================
# 8.6 Optional: Network Manager
# ===============================
read -rp "📶 Mau install NetworkManager sekarang? [Y/n]: " install_net
install_net=${install_net,,}

if [[ "$install_net" != "n" && "$install_net" != "no" ]]; then
  pacman -Sy --noconfirm networkmanager
  systemctl enable NetworkManager
  echo "✅ NetworkManager diinstall dan diaktifkan"
fi

# ===============================
# 8.7 Ringkasan
# ===============================
echo -e "\n📋 \033[1mRingkasan Konfigurasi:\033[0m"
echo "-------------------------------------------"
echo "🕒 Zona Waktu   : $timezone"
echo "🌍 Locale       : $locale"
echo "⌨️  Keymap       : $keymap"
[[ -n "$fontname" ]] && echo "🔤 Console Font : $fontname"
echo "💻 Hostname     : $hostname"

echo -e "\n✅ \033[1;32mTahap 8 selesai.\033[0m Lanjutkan ke tahap user setup atau bootloader install."

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

if id "$username" &>/dev/null; then
  echo "⚠️  User \033[1m$username\033[0m sudah ada. Lewatin pembuatan user baru."
  # Cek apakah sudah di grup wheel
  if ! groups "$username" | grep -qw wheel; then
    usermod -aG wheel "$username"
    echo "✅ User '$username' ditambahkan ke grup wheel"
  fi
else
  echo "📦 Membuat user baru: $username"
  useradd -m -G wheel "$username"
  echo "$username:$userpass" | chpasswd
  echo "✅ User berhasil dibuat dan ditambahkan ke grup wheel"
fi

# ========================
# 3. Pilih default shell user
# ========================
read -rp "💬 Mau set shell default? (default: /bin/bash): " usershell
usershell=${usershell:-/bin/bash}

if grep -qx "$usershell" /etc/shells; then
  chsh -s "$usershell" "$username"
  echo "✅ Shell default untuk $username diatur ke $usershell"
else
  echo "❌ Shell '$usershell' tidak valid atau belum tersedia."
fi

# ========================
# 4. Akses sudo grup wheel
# ========================
echo "🛠️  Mengaktifkan akses sudo untuk grup wheel..."

cp /etc/sudoers /etc/sudoers.bak

if grep -q '^# %wheel ALL=(ALL:ALL) ALL' /etc/sudoers; then
  sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
  echo "✅ Akses sudo grup wheel sudah diaktifkan"
else
  echo "ℹ️  Akses sudo grup wheel sudah aktif sebelumnya"
fi

if ! visudo -c &>/dev/null; then
  echo "❌ ERROR di file /etc/sudoers. Mengembalikan dari backup!"
  cp /etc/sudoers.bak /etc/sudoers
else
  echo "✅ File /etc/sudoers valid"
fi

# ========================
# 5. Optional: Disable root login
# ========================
read -rp "🔒 Nonaktifkan login root (password disabled)? (y/N): " lockroot
lockroot=${lockroot,,}
if [[ "$lockroot" == "y" ]]; then
  passwd -l root
  echo "✅ Login root dinonaktifkan (root account dikunci)"
fi

# ========================
# 6. Ringkasan
# ========================
echo ""
echo -e "✅ \033[1mSelesai Tahap 9:\033[0m"
echo -e "👤 Username        : \033[1m$username\033[0m"
echo -e "🛡️  Akses sudo      : \033[1mAktif\033[0m (via grup wheel)"
echo -e "💬 Shell default   : \033[1m$usershell\033[0m"
echo -e "🔐 Password root   : \033[1m${lockroot:+Dinonaktifkan}\033[0m"
echo -e "🔐 Password user   : Sudah diatur"

#!/bin/bash

# =====================================
# ✅ Notifikasi Langkah Setelah Install
# =====================================

echo -e "\n🎉 \e[1mTahap 10: Instalasi Arch Linux Selesai!\e[0m"
echo "--------------------------------------------------"
echo "📦 Semua konfigurasi sistem (timezone, locale, user, bootloader)"
echo "   sudah sukses diinstal ke hardisk/SSD kamu."

echo -e "\n🚀 \e[1mLangkah Selanjutnya (Manual):\e[0m"
echo -e "➤ 1. Keluar dari lingkungan chroot:"
echo -e "   \e[1mexit\e[0m"

echo -e "\n➤ 2. Unmount semua partisi dari /mnt:"
echo -e "   \e[1mumount -R /mnt\e[0m"

echo -e "\n➤ 3. Pilih salah satu opsi berikut:"
echo -e "   \e[1mreboot\e[0m           🔁 Untuk restart langsung ke Arch Linux"
echo -e "   \e[1mshutdown -P now\e[0m  🔌 Untuk matikan komputer dulu"

echo -e "\n⚠️  \e[1mPERHATIKAN:\e[0m"
echo -e "✅ Sebelum reboot/shutdown:"
echo -e "   - Cabut flashdisk bootable / detach ISO image"
echo -e "   - Kalau pakai VirtualBox / VMWare: detach ISO dari Storage Settings"

echo -e "\n📌 \e[1mRekomendasi:\e[0m"
echo -e "🖥️  Real PC Dualboot?     ➜ \e[1mCabut USB lalu reboot\e[0m"
echo -e "🖥️  VM / ISO Installer?   ➜ \e[1mshutdown -P now lalu hapus ISO\e[0m"

# =====================================
# 🧠 Tambahan: Interaktif Otomatisasi
# =====================================

read -p $'\n🤖 Ingin otomatis unmount dan reboot/shutdown sekarang? [y/N]: ' autoact
autoact=${autoact,,} # lowercase

if [[ "$autoact" == "y" ]]; then
  echo -e "\n📤 Melakukan umount semua partisi dari /mnt..."
  umount -R /mnt 2>/dev/null && echo "✅ Partisi berhasil di-unmount" || echo "⚠️  Beberapa partisi sudah di-unmount sebelumnya"

  echo ""
  read -p "🔁 Reboot sekarang? [y/N]: " rbt
  rbt=${rbt,,}
  if [[ "$rbt" == "y" ]]; then
    echo "♻️  Rebooting..."
    reboot
    exit 0
  fi

  read -p "🔌 Shutdown sekarang? [y/N]: " shut
  shut=${shut,,}
  if [[ "$shut" == "y" ]]; then
    echo "🛑 Shutting down..."
    shutdown -P now
    exit 0
  fi

  echo -e "\n⏹️  Tidak reboot/shutdown. Kamu masih di chroot."
fi

echo -e "\n✅ \e[1mSelesai. Sampai ketemu di sistem Arch Linux kamu!\e[0m 🚀"
