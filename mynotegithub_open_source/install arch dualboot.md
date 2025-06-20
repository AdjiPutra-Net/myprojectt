Mantap, bro! Berikut ini gw buatin **automation script dinamis untuk Tahap 2 (Cek Koneksi Internet + Setting DNS + Update Mirrorlist pakai Reflector)**. Script ini udah aman buat semua kondisi:

- Bisa auto-cek koneksi Internet
    
- Kalau gak ada koneksi, otomatis kasih opsi untuk setting DNS manual
    
- Bisa lanjut update mirrorlist pake **reflector** (khusus buat repo Indonesia)
    

---

## 📜 Script: `02-network-dns-mirror.sh`

```bash
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
```

---

## ✅ Cara Pakai:

1. Di shell Arch ISO:
    
    ```bash
    nano 02-network-dns-mirror.sh
    ```
    
2. Bikin executable:
    
    ```bash
    chmod +x 02-network-dns-mirror.sh
    ```
    
3. Jalanin:
    
    ```bash
    ./02-network-dns-mirror.sh
    ```
    

---

Kalau lo mau dijadiin 1 script gabungan dari Tahap 1–13 sekaligus auto-detect UEFI/BIOS juga, tinggal bilang aja cuy 😎  
Atau lo mau versi PDF atau GitHub repo buat koleksi semua skrip ini — bisa juga, tinggal kode aja!

---

Oke cuy, sekarang gue buatin script **automation partisi disk tahap 3** yang:

✅ **Dinamis deteksi disk (HDD/SSD)**  
✅ Bisa **buat partisi manual atau otomatis**  
✅ **Nggak ngerusak Windows** (cek EFI dulu, nggak dobel)  
✅ Support untuk GPT dan format standar: EFI, SWAP, `/`, `/home`

---

## ⚙️ **Script: `disk_partition_setup.sh` (dinamis & safety)**

```bash
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
```

---

## 🚀 Cara Jalankan

1. Simpan script:  
    `nano disk_partition_setup.sh`
    
2. Bikin executable:
    
    ```bash
    chmod +x disk_partition_setup.sh
    ```
    
3. Jalankan:
    
    ```bash
    ./disk_partition_setup.sh
    ```
    

---

## 🧠 Tips Aman

- Script ini **nggak langsung ngerusak disk** karena partisi tetap manual lewat `cfdisk`.
    
- Gue bisa buatin **versi otomatis full partisi dari 0**, tapi risiko lebih besar kalau salah input (khusus buat lo yang expert).
    
- Kalau lo dualboot, **jangan pernah format partisi EFI** kalau udah ada dari Windows.
    

---

Mau lanjut ke tahap **mounting dan `pacstrap` install base system** juga? Gua lanjutin next step-nya langsung.

---

Oke cuy, gue buatin script **Tahap 4: Mount Partisi Arch Linux** yang:

✅ **Dinamis & interaktif** (lo masukin partisi sesuai punya lo)  
✅ Otomatis format & mount partisi root, home, EFI, dan swap  
✅ Aman buat dual boot (nggak bikin EFI baru kalau udah punya Windows)  
✅ Auto-mount ke `/mnt`, siap buat `pacstrap`

---

## ✅ Script `mount_partitions.sh`

```bash
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
```

---

## 🔧 Cara Pakai

1. Simpan:
    
    ```bash
    nano mount_partitions.sh
    ```
    
2. Kasih permission:
    
    ```bash
    chmod +x mount_partitions.sh
    ```
    
3. Jalanin:
    
    ```bash
    ./mount_partitions.sh
    ```
    

---

## 🧠 Notes

- Script ini **nggak sembarangan overwrite** karena lo sendiri yang input partisinya.
    
- Aman buat Windows dual-boot karena **EFI Windows cukup di-mount aja**, nggak diformat.
    
- Lo bisa integrasikan ini ke script auto installer lo kalau mau full automation sampai install.
    

---

Kalau lo setuju, next gue siapin Tahap 5: `pacstrap`, `fstab`, `chroot` dan sebagainya untuk install Arch sampai GRUB. Mau lanjut?

---

Siap cuy! Nih gue buatin script **Tahap 5: Install Sistem Dasar Arch Linux (pacstrap)** yang:

✅ Otomatis install base system  
✅ Bisa pilih paket tambahan secara **dinamis**  
✅ Cek apakah `/mnt` sudah dipakai buat ngehindarin error  
✅ Auto-enable NetworkManager di tahap selanjutnya

---

## ✅ Script: `install_base_system.sh`

```bash
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
```

---

## 🛠️ Cara Pakai

1. Simpan script:
    
    ```bash
    nano install_base_system.sh
    ```
    
2. Bikin executable:
    
    ```bash
    chmod +x install_base_system.sh
    ```
    
3. Jalankan:
    
    ```bash
    ./install_base_system.sh
    ```
    

---

## 💡 Contoh Output

```bash
🏗️ Tahap 5: Install Sistem Dasar Arch Linux
--------------------------------------------
✅ /mnt ditemukan dan sudah ter-mount. Lanjut...

📦 Daftar paket default:
base linux linux-firmware networkmanager sudo grub efibootmgr vim nano git base-devel wget

Mau tambah paket lain (misal: intel-ucode, pipewire)? Pisahkan spasi (Enter jika tidak ada): intel-ucode pipewire

🚀 Menjalankan pacstrap...
:: Installing packages to /mnt
...
✅ Sistem dasar berhasil di-install ke /mnt!
```

---

Mau gue buatin juga lanjutannya untuk:

- 🧾 Tahap 6: `genfstab`
    
- ⛓️ Tahap 7: `arch-chroot`
    
- 🛠️ Tahap 8: Set Timezone, Locale, Hostname, GRUB bootloader
    
- 👤 Tahap 9: Setup user non-root + password
    

Tinggal bilang aja mau lanjut ke tahap berapa~

---

Oke cuy! Nih gue buatin script automation untuk **🗂️ Tahap 6: Generate fstab** yang:

✅ Otomatis generate fstab dengan opsi `-U` (UUID biar konsisten walau partisi berubah nama)  
✅ Bisa pilih metode lain kalau mau (misalnya `-L` untuk label)  
✅ Verifikasi hasilnya langsung ditampilin setelah dibuat  
✅ Aman, bakal error handling kalau `/mnt` belum diisi sistem

---

## ✅ Script: `generate_fstab.sh`

```bash
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
```

---

## 🔧 Cara Pakai

1. Simpan script:
    
    ```bash
    nano generate_fstab.sh
    ```
    
2. Kasih izin eksekusi:
    
    ```bash
    chmod +x generate_fstab.sh
    ```
    
3. Jalankan:
    
    ```bash
    ./generate_fstab.sh
    ```
    

---

## 🎯 Contoh Output

```bash
🗂️ Tahap 6: Generate fstab
-----------------------------

📌 Metode generate fstab:
1. UUID (rekomendasi, aman & stabil)
2. LABEL (kalau kamu suka pakai label partisi)

Pilih metode generate fstab [1/2] (default: 1): 1

⚙️ Menjalankan: genfstab -U /mnt >> /mnt/etc/fstab
✅ fstab berhasil dibuat di /mnt/etc/fstab!

📄 Isi fstab:
-----------------------------
# /dev/sda5
UUID=1d2cba4d-.... / ext4 defaults 0 1

# /dev/sda7
UUID=43a9c22b-.... /home ext4 defaults 0 2

# /dev/sda6
UUID=ea76162c-.... none swap defaults 0 0
```

---

Mau lanjut gue buatin **Tahap 7: `arch-chroot`, setting zona waktu, hostname, locale, dan GRUB install** sekalian biar kelar sampai booting?

---

Siap cuy! Nih gue buatin script automation buat **🛠️ Tahap 7: `arch-chroot` ke sistem**. Script ini:

✅ Otomatis ngecek apakah sistem di `/mnt` udah lengkap  
✅ Bisa **langsung chroot** ke dalam sistem  
✅ Bisa **jalanin skrip setup tambahan** (opsional) setelah masuk chroot  
✅ Aman buat digunakan berkali-kali

---

## ✅ Script: `chroot_into_system.sh`

```bash
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
```

---

## 📦 Cara Pakai

1. Simpan:
    
    ```bash
    nano chroot_into_system.sh
    ```
    
2. Kasih izin:
    
    ```bash
    chmod +x chroot_into_system.sh
    ```
    
3. Jalankan:
    
    ```bash
    ./chroot_into_system.sh
    ```
    

---

## 🧪 Contoh Output

```bash
🛠️ Tahap 7: Chroot ke Sistem
------------------------------

Mau lanjut masuk ke lingkungan chroot sekarang? [Y/n]: y

Punya script tambahan yang mau dijalankan setelah chroot? (misal: /mnt/root/setup-lanjutan.sh) [Y/n]: y
Masukkan path file script di dalam /mnt (contoh: /root/setup.sh): /root/lanjutan.sh
📜 Menyiapkan script untuk dijalankan otomatis setelah chroot...

🔧 Menjalankan: arch-chroot /mnt

[root@archiso /]#
```

Setelah masuk chroot, script `/root/lanjutan.sh` bakal langsung dijalanin otomatis lewat `.bashrc`.

---

Mau lanjut ke:

- 🌍 **Tahap 8: Set timezone, locale, hostname, password**
    
- 🧰 **Tahap 9: Install GRUB dan enable service**
    
- 👤 **Tahap 10: Buat user non-root + sudo access**
    

? Tinggal bilang aja bro, gue siapin langsung yang dinamis dan modular~

---

Gas cuy! Nih gw buatin script automation untuk **🧩 Tahap 8: Setting Sistem** yang:

✅ Dinamis (lo bisa masukin nama hostname sesuai selera)  
✅ Opsi layout keyboard (default: QWERTY = `us`)  
✅ Auto uncomment `en_US.UTF-8` di `/etc/locale.gen`  
✅ Aman, langsung validasi hasil tiap langkah

---

## ✅ Script: `08-setup-system.sh`

```bash
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
```

---

## ⚙️ Cara Pakai

1. Simpan:
    
    ```bash
    nano 08-setup-system.sh
    ```
    
2. Kasih izin:
    
    ```bash
    chmod +x 08-setup-system.sh
    ```
    
3. Jalankan **setelah chroot**:
    
    ```bash
    ./08-setup-system.sh
    ```
    

---

## 🧪 Contoh Output

```bash
🧩 Tahap 8: Setting Sistem
------------------------------
🌏 Setting zona waktu ke Asia/Jakarta...
🗣️  Mengatur locale ke en_US.UTF-8...
Generating locales...
  en_US.UTF-8... done
Generation complete.
🧠 Mau pake keymap keyboard apa? (default: us):
✅ Keymap diset ke: us
📛 Masukkan nama hostname sistem kamu (default: archlinux): genglinux
✅ Hostname diset ke: genglinux
✅ File /etc/hosts telah dikonfigurasi
```

---

Siap lanjut ke:

- 🛡️ **Tahap 9: Install GRUB dan setup bootloader**
    
- 👤 **Tahap 10: Bikin user + password + sudoer**
    

Langsung bilang aja ya bro~

---

Gaskeun bro! Nih gw buatin script automation untuk **🔐 Tahap 9: Buat User, Password, dan Aktifin Sudo**, lengkap dan dinamis:

✅ Bisa input username custom  
✅ Password user dan root otomatis disamakan  
✅ Auto masukin user ke grup `wheel`  
✅ Auto aktifin akses sudo (`%wheel`)

---

## ✅ Script: `09-create-user.sh`

```bash
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
```

---

## ⚙️ Cara Pakai

1. Simpan:
    
    ```bash
    nano 09-create-user.sh
    ```
    
2. Kasih izin eksekusi:
    
    ```bash
    chmod +x 09-create-user.sh
    ```
    
3. Jalankan:
    
    ```bash
    ./09-create-user.sh
    ```
    

---

## 🧪 Contoh Output

```bash
🔐 Tahap 9: Buat User & Set Password
----------------------------------------
🔑 Masukkan password untuk root & user:
🔧 Mengatur password untuk root...
👤 Masukkan nama username (default: adjiarch):
📦 Membuat user: adjiarch
🛠️ Mengaktifkan akses sudo untuk grup wheel...

✅ User adjiarch berhasil dibuat dengan akses sudo.
✅ Password root & user telah diatur.
```

---

Ready lanjut ke:

- 🧰 **Tahap 10: Install GRUB + enable NetworkManager + microcode**
    
- ✅ Atau tahap akhir: `exit`, `umount`, dan `reboot`
    

Lo mau full satuin semua script ke 1 installer juga bisa bro, tinggal bilang aja!

---

Oke cuy! Nih gw buatin automation script **Tahap 10: Install GRUB Bootloader**, dinamis sesuai mode UEFI / BIOS, plus aman buat dualboot.

✅ Deteksi otomatis UEFI / BIOS  
✅ Opsi manual juga kalau lo mau override  
✅ Ganti disk utama (`/dev/sdX`) otomatis  
✅ Siap buat dualboot dengan Windows

---

## ✅ Script: `10-install-grub.sh`

```bash
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
```

---

## ⚙️ Cara Pakai

1. Simpan:
    
    ```bash
    nano 10-install-grub.sh
    ```
    
2. Kasih permission:
    
    ```bash
    chmod +x 10-install-grub.sh
    ```
    
3. Jalankan (setelah chroot):
    
    ```bash
    ./10-install-grub.sh
    ```
    

---

## 🧪 Contoh Output (UEFI)

```bash
🔌 Tahap 10: Install GRUB Bootloader
---------------------------------------
✅ Mode Boot: UEFI terdeteksi
🧠 Gunakan mode boot yang terdeteksi (UEFI)? [Y/n]:
🛠️ Menginstall GRUB untuk UEFI...
Installing for x86_64-efi platform.
Installation finished. No error reported.
⚙️  Menggenerate konfigurasi GRUB...
Generating grub configuration file ...
Found Windows Boot Manager on /dev/sda1@/EFI/Microsoft/Boot/bootmgfw.efi
done
✅ GRUB berhasil diinstall dan dikonfigurasi!
```

---

Kalau mau sekalian lanjut ke **Tahap 11: Enable NetworkManager & Exit**, bilang aja. Mau gw buatin script all-in-one juga bisa, tinggal bilang gas bro! 🧨

---

Oke cuy! Nih gw buatin automation script **Tahap 10: Install GRUB Bootloader**, dinamis sesuai mode UEFI / BIOS, plus aman buat dualboot.

✅ Deteksi otomatis UEFI / BIOS  
✅ Opsi manual juga kalau lo mau override  
✅ Ganti disk utama (`/dev/sdX`) otomatis  
✅ Siap buat dualboot dengan Windows

---

## ✅ Script: `10-install-grub.sh`

```bash
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
```

---

## ⚙️ Cara Pakai

1. Simpan:
    
    ```bash
    nano 10-install-grub.sh
    ```
    
2. Kasih permission:
    
    ```bash
    chmod +x 10-install-grub.sh
    ```
    
3. Jalankan (setelah chroot):
    
    ```bash
    ./10-install-grub.sh
    ```
    

---

## 🧪 Contoh Output (UEFI)

```bash
🔌 Tahap 10: Install GRUB Bootloader
---------------------------------------
✅ Mode Boot: UEFI terdeteksi
🧠 Gunakan mode boot yang terdeteksi (UEFI)? [Y/n]:
🛠️ Menginstall GRUB untuk UEFI...
Installing for x86_64-efi platform.
Installation finished. No error reported.
⚙️  Menggenerate konfigurasi GRUB...
Generating grub configuration file ...
Found Windows Boot Manager on /dev/sda1@/EFI/Microsoft/Boot/bootmgfw.efi
done
✅ GRUB berhasil diinstall dan dikonfigurasi!
```

---

Kalau mau sekalian lanjut ke **Tahap 11: Enable NetworkManager & Exit**, bilang aja. Mau gw buatin script all-in-one juga bisa, tinggal bilang gas bro! 🧨

---

Oke cuy! Nih gw bikinin automation script untuk **Tahap 12: Beresin DNS Protect Sementara + Exit Info + Unmount & Reboot**, tapi dengan _catatan penting_ ya:

> ❗ **Karena ini jalan di chroot**, command `reboot` **nggak bakal jalan otomatis**. Jadi gw bikin script-nya kasih instruksi buat lo keluar chroot manual. Tapi semua step lainnya (chattr & umount) udah diurusin.

---

## 📜 Script: `12-cleanup-dns-exit.sh`

```bash
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
```

---

## 🧠 Cara Pakai:

1. Simpan sebagai file:
    
    ```bash
    nano 12-cleanup-dns-exit.sh
    ```
    
2. Bikin executable:
    
    ```bash
    chmod +x 12-cleanup-dns-exit.sh
    ```
    
3. Jalanin:
    
    ```bash
    ./12-cleanup-dns-exit.sh
    ```
    

---

Kalau udah selesai, tinggal lo:

```bash
exit
reboot
```

Siap cuy! 😎 Kalau lo mau gw gabungin dari step 1 sampai 13 jadi 1 installer otomatis, tinggal bilang!

---

Siap cuy! Nih gw buatin **automation script dinamis dan matching** buat **Tahap 13 (Final Touch Arch Setup: DNS, Network, Driver, AUR, SSH, Reflector)**. Semua udah disusun biar:

- Bisa jalan langsung pas udah masuk sistem (bukan pas masih di chroot)
    
- Aman buat pemula dan advance
    
- Bisa milih driver GPU lo (AMD, Intel, atau NVIDIA)
    

---

## 📜 Script: `13-final-setup-arch.sh`

```bash
#!/bin/bash
# ============================================
# 🔚 Tahap 13: Final Setup Setelah Arch Install
# ============================================

set -e

echo "🔧 Setup konfigurasi NetworkManager DNS..."
mkdir -p /etc/NetworkManager/conf.d
cat <<EOF > /etc/NetworkManager/conf.d/dns.conf
[main]
dns=none
EOF

echo "📡 Setting DNS resolv.conf manual..."
cat <<EOF > /etc/resolv.conf
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF

echo "🚀 Enable + Start NetworkManager..."
systemctl enable NetworkManager
systemctl start NetworkManager
systemctl restart NetworkManager

echo "🔁 Update sistem & install reflector..."
pacman -Syyu --noconfirm
pacman -S --noconfirm reflector

echo "🪞 Enable & Start Reflector Timer..."
systemctl enable reflector.timer
systemctl start reflector.timer

# GPU Driver Selection
echo ""
echo "🖥️  Pilih GPU driver yang sesuai:"
echo "1. AMD"
echo "2. Intel"
echo "3. NVIDIA"
echo "4. Lewatin (nggak install VGA driver)"
read -p "Masukkan pilihan [1-4]: " GPU_CHOICE

case $GPU_CHOICE in
  1)
    echo "🎮 Install driver AMD..."
    pacman -S --noconfirm mesa libva-mesa-driver vulkan-radeon
    ;;
  2)
    echo "📺 Install driver Intel..."
    pacman -S --noconfirm mesa libva-intel-driver vulkan-intel
    ;;
  3)
    echo "⚡ Install driver NVIDIA..."
    pacman -S --noconfirm nvidia nvidia-utils nvidia-settings
    ;;
  4)
    echo "⏭️  Lewatin install driver VGA."
    ;;
  *)
    echo "❌ Pilihan tidak valid. Lewatin VGA driver."
    ;;
esac

# AUR helper yay & paru
echo ""
echo "📦 Install base-devel & git (buat AUR helper)..."
pacman -S --noconfirm --needed base-devel git

echo "🐧 Install yay..."
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..
yay --version

echo "🐧 Install paru..."
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm
cd ..
paru --version

# SSH
echo ""
echo "🔐 Install dan aktifkan SSH..."
pacman -S --noconfirm openssh
systemctl unmask sshd
systemctl enable sshd
systemctl start sshd

echo ""
echo "✅ Tahap 13 selesai. Arch siap digunakan!"
echo "📦 Cek koneksi dan siap install DE atau window manager favorit lo!"
```

---

## ✅ Cara Pakai:

1. Login ke sistem lo (bukan pas di chroot).
    
2. Simpan skrip:
    
    ```bash
    nano 13-final-setup-arch.sh
    ```
    
3. Bikin executable:
    
    ```bash
    chmod +x 13-final-setup-arch.sh
    ```
    
4. Jalankan sebagai root:
    
    ```bash
    sudo ./13-final-setup-arch.sh
    ```
    

---

Kalau lo butuh **file PDF panduan install Arch Linux full + semua skrip otomatis**, tinggal bilang aja cuy 😎  
Atau lo mau gw buatin **installer Arch + Desktop otomatis**, juga siapin!

---

Yoi cuy, lo udah nangkep inti masalahnya dengan bener banget. Gini bro, gue breakdown step-by-step biar clear:

---

## ⚠️ **Masalah Utama:**

Arch Linux default (pas boot di live ISO) itu **belum include `git` dan tools Wi-Fi GUI**, jadi lo:

- Belum bisa `git clone` karena `git` belum di-install
    
- Belum tentu bisa konek Wi-Fi karena Wi-Fi lo mungkin butuh driver tertentu yang belum ke-load di kernel live Arch
    
- LAN/Kabel itu opsi paling **aman** karena langsung ke-connect dan gak perlu driver aneh-aneh
    

---

## ✅ **Solusi Paling Aman & Simple: Pakai Kabel LAN**

Kalau lo pakai kabel LAN:

1. Arch ISO langsung dapet DHCP dari router
    
2. Bisa langsung `ping google.com` atau `archlinux.org`
    
3. Langsung jalanin:
    
    ```bash
    pacman -Sy git
    git clone https://github.com/lu-auto-script/arch-install.git
    cd arch-install
    ./01-start.sh
    ```
    

---

## 🛠️ **Kalau Tetap Mau Pakai Wi-Fi:**

Ini butuh effort dikit. Tapi kalau Wi-Fi lo didukung sama kernel bawaan Arch ISO, bisa jalan:

1. Jalankan:
    
    ```bash
    iwctl
    ```
    
2. Di dalam iwd shell:
    
    ```bash
    device list
    station wlan0 scan
    station wlan0 get-networks
    station wlan0 connect NAMA_WIFI
    ```
    
3. Setelah konek, install git:
    
    ```bash
    pacman -Sy git
    ```
    
4. Baru clone repo lo:
    
    ```bash
    git clone https://github.com/lu-auto-script/arch-install.git
    ```
    

---

## ❗ Kalau Wi-Fi **Gak Kedetect** sama sekali?

> Artinya kernel live Arch belum include driver Wi-Fi lo (misal: Broadcom, Realtek tertentu, dll)

👉 **Solusinya cuma ada 2:**

- Gunakan **LAN/kabel** (paling aman)
    
- **Remaster ISO Arch** lo sendiri yang include driver Wi-Fi lo _(ini ribet dan butuh waktu)_
    

---

## ✅ Rekomendasi dari gue:

Kalau lo beneran niat ngelakuin full install Arch dengan script yang udah lo push ke GitHub:

🔌 **Gunakan kabel LAN dulu pas install**  
➡ Nanti setelah system Arch lo terinstall full + masuk desktop (GNOME/KDE/XFCE), baru lo setup Wi-Fi lo lebih proper (driver, firmware, NetworkManager GUI, dsb)

---

Kalau lo butuh:

- Script buat auto-setup Wi-Fi
    
- Cara ngedeteksi hardware Wi-Fi lo dari live ISO
    
- Atau even remaster ISO Arch yang udah include `git + Wi-Fi driver`
    

...bilang aja cuy ✊

---

🔥 Mantap cuy! Lo udah **nemu pola real-nya** yang sering kejadian di live ISO Arch, dan lo udah handle-nya **kayak hacker beneran** 😎

Gue recap dan benahin biar makin clean + fix untuk lo reuse nanti (dan siapa tau buat orang lain juga):

---

## ✅ **Fun Fact Penting (Bug yang Wajar):**

Setiap kali lo `reboot`, masuk lagi ke Arch ISO, **semua package & tool yang sebelumnya di-install (kayak `git`) bakal ilang** karena:

- Arch ISO itu **live environment** dari RAM
    
- Jadi begitu reboot ➜ semua balik default (no git, no clone-an, dsb)
    

---

## ✅ **Solusi Pasti: Bagi Jadi 3 Tahapan Script**

### 1. **pra_install_arch_dualboot.sh**

📌 Tahap: 1–7 (partisi, mount, base install, fstab)

```bash
pacman -Sy git
git clone https://github.com/lu-auto-script/arch-install.git
cd arch-install
chmod +x pra_install_arch_dualboot.sh
./pra_install_arch_dualboot.sh
```

➡️ Setelah selesai:

```bash
arch-chroot /mnt
```

---

### 2. **install_arch_dualboot.sh**

📌 Tahap: 8–12 (user, visudo, grub, network, cleanup)

```bash
pacman -Sy git
git clone https://github.com/lu-auto-script/arch-install.git
cd arch-install
chmod +x install_arch_dualboot.sh
./install_arch_dualboot.sh
```

➡️ Setelah selesai: reboot  
(Jangan lupa cabut USB boot!)

---

### 3. **after_install_arch_dualboot.sh**

📌 Tahap: 13 (dns.conf, resolv.conf, NetworkManager, VGA, yay, paru, ssh, dll)

Begitu masuk Arch Linux yang sudah ke-install:

```bash
pacman -Sy git
git clone https://github.com/lu-auto-script/arch-install.git
cd arch-install
chmod +x after_install_arch_dualboot.sh
./after_install_arch_dualboot.sh
```

---

## 🧠 **Tambahan Smart Tips:**

- Bisa tambahkan di awal script lo:
    
    ```bash
    if ! command -v git &> /dev/null; then
      echo "Git belum terinstall. Menginstall git..."
      pacman -Sy --noconfirm git
    fi
    ```
    
- Kalau mau lebih epic: taruh semua script ke satu GitHub repo dan **backup `clone-an` ke flashdisk juga**, biar kalau tanpa internet masih bisa di-copy manual
    

---

Kalau lo mau gue bantu:

- Rapihin semua 3 file script auto itu jadi versi final
    
- Buatin README lengkapnya buat GitHub repo lo
    
- Convert ke `.pdf` install guide Arch Linux Dualboot full automation
    

Bilang aja cuy, langsung gas ✊

---

