## Tahapan Penginstallan Arch Linux Dualboot dengan Script Automation

1. Manual Dulu Cuy:

```bash
# 🔧 Setup konfigurasi NetworkManager DNS...
rm /etc/resolv.conf
mkdir -p /etc/NetworkManager/conf.d
cat <<EOF > /etc/NetworkManager/conf.d/dns.conf
[main]
dns=none
EOF

# 📡 Setting DNS resolv.conf manual...
cat <<EOF > /etc/resolv.conf
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF

# lalu setelah itu tunggu 5 menit maksimal, 3 menit minimal untuk aktivasi keyring public-key dari archnya, supaya saat kita update/upgrade/hapus/install paket diarchnya tidak error karena belum diaktivasi

pacman -Sy git
git clone https://github.com/AdjiPutra-Net/myprojectt.git
cd myprojectt
cd mynotegithub_open_source/
chmod +x pra_install_arch_dualboot.sh
./pra_install_arch_dualboot.sh

pacman -Sy git
git clone https://github.com/AdjiPutra-Net/myprojectt.git
cd myprojectt
cd mynotegithub_open_source/
chmod +x install_arch_dualboot.sh
./install_arch_dualboot.sh

# Setelah installasi selesai, jalankan perintah ini secara manual
exit # keluar dari sistem chroot, 50% masih live iso dan 50% sudah terinstall permanent dihardisk/ssd
umount -R /mnt # mencopot semua data yang ada dilive iso karena data sudah masuk kedalam hardisk/ssd bukan iso lagi
# nah ada 2 opsi pada perintah ini
reboot # disarankan sebelum menjalankan perintah ini flashdisk sudah tercabut agar tidak kembeli ke page installer dan lebih direkomendasikan user dualboot
shutdown -P now # disarankan sesudah menjalankan perintah ini hapus iso nya agar tidak kembali ke page installer

# 🔧 Setup konfigurasi NetworkManager DNS...
rm /etc/resolv.conf
mkdir -p /etc/NetworkManager/conf.d
cat <<EOF > /etc/NetworkManager/conf.d/dns.conf
[main]
dns=none
EOF

# 📡 Setting DNS resolv.conf manual...
cat <<EOF > /etc/resolv.conf
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF

# lalu setelah itu tunggu 5 menit maksimal, 3 menit minimal untuk aktivasi keyring public-key dari archnya, supaya saat kita update/upgrade/hapus/install paket diarchnya tidak error karena belum diaktivasi

# 🔧 Setup konfigurasi NetworkManager DNS...
rm /etc/resolv.conf
mkdir -p /etc/NetworkManager/conf.d
cat <<EOF > /etc/NetworkManager/conf.d/dns.conf
[main]
dns=none
EOF

# 📡 Setting DNS resolv.conf manual...
cat <<EOF > /etc/resolv.conf
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF

# lalu setelah itu tunggu 5 menit maksimal, 3 menit minimal untuk aktivasi keyring public-key dari archnya, supaya saat kita update/upgrade/hapus/install paket diarchnya tidak error karena belum diaktivasi

# abis configure dns dan network manager, restart layanan network managernya
systemctl restart NetworkManager

# abis gas lanjut lagi install paket yang diperlukan untuk setup arch
pacman -Sy git
git clone https://github.com/AdjiPutra-Net/myprojectt.git
cd myprojectt
cd mynotegithub_open_source/
chmod +x after_install_arch_dualboot.sh
./after_install_arch_dualboot.sh

pacman -Sy git
git clone https://github.com/AdjiPutra-Net/myprojectt.git
cd myprojectt
cd mynotegithub_open_source/
chmod +x 
./
```

## Tahapan Penggunaan Script Automationnya!

2. pra_install_arch_dualboot.sh
3. install_arch_dualboot.sh
4. sebelum_ke_after_install_arch.sh
5. after_install_arch_dualboot.sh
6. finishing_install_arch.sh

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

Pasti cuy! Ini dia rangkuman **liat error** dan **solusi terbaik** buat problem `"keyring is not writable"` saat mau `pacman -Sy git` di live Arch, langsung dari hasil riset:

---

## ⚠️ Masalah: Keyring Error (“not writeable”)

Biasanya muncul kayak gini:

```
warning: Public keyring not found: have you run 'pacman-key --init'?
error: keyring is not writeable
...
error: required key missing from keyring
```

Artinya **pacman-init belum selesai dijalankan** (keyring belum terbentuk), atau keyringnya korup. Di live ISO, ini gak langsung otomatis selesai, jadi lo harus pastiin dulu.

---

## ✅ Solusi 1: Tunggu `pacman-init.service`

Berdasarkan Arch Forum, ini fixed solution:

```bash
echo "Menunggu keyring siap..."
while ! systemctl show pacman-init.service | grep -q 'SubState=exited'; do
  sleep 1
done

# Sekarang aman install git
pacman -Sy --noconfirm git
```

([bbs.archlinux.org](https://bbs.archlinux.org/viewtopic.php?id=283075&utm_source=chatgpt.com "pacstrap error: keyring is not writable / Installation / Arch Linux Forums"), [bbs.archlinux32.org](https://bbs.archlinux32.org/viewtopic.php?id=3390&utm_source=chatgpt.com "pacstrap show all downloaded files sig error - Arch Linux"), [bbs.archlinux32.org](https://bbs.archlinux32.org/viewtopic.php?id=3300&utm_source=chatgpt.com "archinstall is broken on latest iso - Arch Linux"))

---

## ✅ Solusi 2: Pastikan waktu sistem sudah sinkron

Beberapa user (Reddit) bilang ini penting:

```bash
timedatectl set-ntp true
timedatectl status        # pastiin: "System clock synchronized: yes"

# kalau sudah sync, lanjut install
pacman -Sy --noconfirm git
```

---

## ✅ Solusi 3: Reset + reload keyring kalau rusak

Dari banyak kasus, kalau keyring corrupt (terutama di chroot atau container):

```bash
rm -rf /etc/pacman.d/gnupg
pacman-key --init
pacman-key --populate archlinux
pacman-key --refresh-keys
pacman -S archlinux-keyring
pacman -Syu
```

([wiki.archlinux.org](https://wiki.archlinux.org/title/Install_Arch_Linux_from_existing_Linux?utm_source=chatgpt.com "Install Arch Linux from existing Linux - ArchWiki"))

---

## ✅ Rekomendasi Skrip Otomasi

Gabungkan poin di atas ke skrip lo biar kebersihan dan aman:

```bash
# 1. Pastikan system clock sinkron
timedatectl set-ntp true

# 2. Tunggu pacman-init selesai
echo "Menunggu keyring siap..."
while ! systemctl show pacman-init.service | grep -q 'SubState=exited'; do
  sleep 1
done

# 3. Kalau keyring rusak, reset paksa
if pacman -Q archlinux-keyring &>/dev/null; then
  pacman -S --noconfirm archlinux-keyring
else
  rm -rf /etc/pacman.d/gnupg
  pacman-key --init
  pacman-key --populate archlinux
  pacman-key --refresh-keys
fi

# 4. Install git
pacman -Sy --noconfirm git
```

---

## 🚀 Cara Jalankan Saat Live Arch:

1. Mount partisi root dan chroot jika perlu.
    
2. Jalankan skrip di atas **sebelum** `pacman -Sy git`.
    
3. Setelah selesai, `git clone …` dan lanjut install.
    

---

### ✅ Kesimpulan:

Selesaiin 3 hal:

1. **Sinkron waktu** pakai `timedatectl`.
    
2. **Tunggu pacman-init.service exited**.
    
3. **Reset & reload keyring kalau perlu**.
    

Dengan itu, `pacman -Sy git` bakal lancar, dan otomatisasi kamu aman banget, bro! ✊

---

✅ **Bener banget cuy!** Ini urutannya:

---

### 🔄 **Kenapa harus nunggu dulu?**

Waktu booting ke **Arch ISO (live)**, sistem **otomatis** jalanin `pacman-init.service` buat:

- Inisialisasi keyring GPG (`/etc/pacman.d/gnupg`)
    
- Download & pasang kunci publik buat validasi paket
    

Tapi ini **butuh waktu beberapa detik** sampai benar-benar selesai. Kalau lo langsung `pacman -Sy git`, biasanya kena error kayak:

```
error: keyring is not writable
warning: Public keyring not found
```

---

### ✅ **Jadi, cara amannya gini cuy:**

1. **Sinkronin waktu** (penting biar GPG valid):
    
    ```bash
    timedatectl set-ntp true
    sleep 5  # kasih jeda biar clock sync
    ```
    
2. **Tunggu pacman-init kelar:**
    
    ```bash
    echo "⏳ Nunggu pacman-init selesai..."
    while ! systemctl show pacman-init.service | grep -q 'SubState=exited'; do
      sleep 1
    done
    ```
    
3. **Baru install git-nya:**
    
    ```bash
    pacman -Sy --noconfirm git
    ```
    

---

### 🔧 Bonus: Kalau Lo Mau Auto Script-nya

```bash
timedatectl set-ntp true
sleep 5

echo "⏳ Menunggu pacman-init.service selesai..."
while ! systemctl show pacman-init.service | grep -q 'SubState=exited'; do
  sleep 1
done

echo "✅ Keyring siap, lanjut install git..."
pacman -Sy --noconfirm git
```

---

### 🧠 Kesimpulan:

- Lo **WAJIB nunggu** `pacman-init` selesai.
    
- Pastikan **waktu sistem udah sinkron** (biar kunci GPG valid).
    
- **Baru install `git` atau paket lainnya.**
    

Kalau urutan ini lo ikutin, semua lancar jaya tanpa error GPG. Mantap, kan? 😎

---

✅ **Iya cuy, bener banget!** Lo **nggak wajib bikin script segala buat nunggu pacman-init**.

---

### 🔎 Penjelasan Simpelnya:

Waktu lo masuk ke **Arch ISO** (live mode), proses `pacman-key --init` + `pacman-key --populate` **otomatis jalan di background** lewat service `pacman-init.service`.

Nah, kalau lo **nunggu dulu beberapa detik (sekitar 10–20 detik)** sebelum ngejalanin `pacman -Sy git`, biasanya:

- Keyring udah siap 👍
    
- Gak bakal muncul error `keyring is not writable`
    
- Lo bisa langsung install package dengan mulus
    

---

### 🤝 Jadi Kesimpulannya:

|Cara|Aman?|Kapan Perlu?|
|---|---|---|
|**Nunggu manual 10–20 detik**|✅ Aman|Paling praktis, cukup ini aja|
|**Cek status `pacman-init` dulu**|✅ Aman|Kalau lo mau lebih pasti & scripting|
|**Langsung `pacman -Sy git` tanpa nunggu**|❌ Kadang error|Gak disaranin, bisa bikin `keyring not writable` error|

---

### 🧠 Pro Tips:

- Lo juga bisa ketik:
    
    ```bash
    systemctl status pacman-init.service
    ```
    
    Buat lihat udah selesai apa belum.
    

---

Jadi fix-nya: **modal sabar 10 detik udah cukup cuy**, gak perlu ribet 😎

---

⚠️ **Yoi cuy, itu error-nya valid dan penting banget.**  
Lo **gak boleh jalanin `makepkg -si` sebagai root (sudo)** karena:

- Bisa **ngubah permission file secara brutal**
    
- Bisa **ngebikin sistem rusak**, terutama di `/usr`, `/etc`, dan dependency
    

---

## 🧯 **Solusi Cepat & Aman**

Lo tetap jalankan seluruh `13-final-setup-arch.sh` **pakai `sudo`**,  
**kecuali bagian install AUR helper (`yay`, `paru`) — itu harus sebagai user biasa.**

---

### 🛠️ Fix Script-nya Jadi Aman

Update script lo bagian ini:

```bash
echo "🐧 Install yay..."
sudo -u adjiarch git clone https://aur.archlinux.org/yay.git /home/adjiarch/yay
cd /home/adjiarch/yay
sudo -u adjiarch makepkg -si --noconfirm
cd ~

echo "🐧 Install paru..."
sudo -u adjiarch git clone https://aur.archlinux.org/paru.git /home/adjiarch/paru
cd /home/adjiarch/paru
sudo -u adjiarch makepkg -si --noconfirm
cd ~
```

**Ganti `adjiarch` dengan username lo**, kalau beda.

---

### ✅ Atau Bisa Pisah Script AUR Helper Sendiri

Lo juga bisa bikin script baru bernama `install-aur-helper.sh`:

```bash
#!/bin/bash

echo "📦 Install yay..."
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..

echo "📦 Install paru..."
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
cd ..
```

> ✅ Jalanin **tanpa sudo**, setelah login sebagai user lo:

```bash
chmod +x install-aur-helper.sh
./install-aur-helper.sh
```

---

### 🧠 Kenapa Begitu?

Karena `makepkg`:

- Akan **build package** di folder user lokal (`~/yay`, `~/paru`)
    
- Kalau lo root, semua itu nulis di `/root` dan permission jadi kacau
    

---

Kalau mau gw bantu rapihin **script-nya jadi split: sistem vs user**, tinggal bilang aja cuy 😎  
Atau kalo lo mau jadikan ini `.zip`, `.sh` bundling, atau file `.pdf`, bisa banget juga.

---

**🧠 Fix banget analisis lo cuy!** Gini gue rangkum + pertegas biar makin legit logikanya:

---

## 💡 INTI PEMAHAMAN LO: **BENAR BANGET.**

> Kalau `NetworkManager` **belum diinstall**, maka semua konfigurasi `.conf` kayak:

```ini
/etc/NetworkManager/conf.d/dns.conf
```

> ✅ **SIA-SIA**, karena servicenya belum exist, alias **belum aktif & belum jalan**.

---

### ⚠️ **Kapan konfigurasi itu jadi berguna?**

> Hanya kalau:

- ✅ `networkmanager` **sudah diinstall**
    
- ✅ `systemctl enable --now NetworkManager` sudah dijalankan
    
- Baru deh konfigurasi DNS kayak `dns=none` akan kepake
    
- Dan dia **akan stop overwrite `/etc/resolv.conf`**
    

---

## ✅ JADI FIX SOLUSINYA:

### 💻 **Pada saat awal install (masih Live ISO / chroot):**

1. **Jangan buang waktu config di `/etc/NetworkManager/conf.d/*.conf`**
    
2. **Langsung set `resolv.conf` manual aja:**
    

```bash
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf
chattr +i /etc/resolv.conf  # 🔒 dikunci biar gak ke-replace DHCP
```

---

### 🧽 **Setelah selesai install Arch (permanent system jalan):**

1. **Hapus lock:**
    

```bash
chattr -i /etc/resolv.conf
```

2. **Install NetworkManager & enable servicenya:**
    

```bash
pacman -S networkmanager
systemctl enable --now NetworkManager
```

3. **Baru bikin config DNS-nya:**
    

```bash
mkdir -p /etc/NetworkManager/conf.d
cat <<EOF > /etc/NetworkManager/conf.d/dns.conf
[main]
dns=none
EOF

echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf
```

4. **Restart servicenya:**
    

```bash
systemctl restart NetworkManager
```

---

## 🚀 REKOMENDASI ALUR PENGGUNAAN DNS SAAT INSTALL ARCH

|Tahap|Apa yang dilakukan|Gunain config NM?|Lock resolv.conf?|
|---|---|---|---|
|💽 Live ISO / chroot (belum install NM)|Set DNS manual|❌ Tidak usah|✅ Ya (`chattr +i`)|
|💻 Setelah Arch selesai terinstall + NM terinstall|Set DNS via NM|✅ Ya (pakai `.conf`)|❌ Tidak perlu|

---

Kalau mau, gue bisa buatin **script smart** buat auto-detect ini semua + ngatur DNS dengan aman tergantung fase instalasi lo.

Lo mau?

---

✅ **Iya cuy, bener banget. Kalau udah kayak gitu, DNS-nya gak bakal berubah-ubah lagi.**

Berikut penjelasan lengkapnya:

---

## 🧠 Kenapa DNS-nya **gak perlu dikunci (`chattr +i`) lagi** setelah NetworkManager aktif?

Karena:

### ✅ NetworkManager **sudah punya kendali penuh atas `resolv.conf`**

Lo udah ngasih tau dia via:

```ini
/etc/NetworkManager/conf.d/dns.conf
[main]
dns=none
```

Artinya:

- **NetworkManager gak akan overwrite `/etc/resolv.conf` lagi**
    
- Jadi, isinya bakal tetap **persis sesuai** yang lo tulis manual:
    
    ```bash
    echo "nameserver 8.8.8.8" > /etc/resolv.conf
    echo "nameserver 1.1.1.1" >> /etc/resolv.conf
    ```
    

---

## 📌 Tambahan penting:

### Kalau lo belum set `dns=none`, maka:

- NetworkManager akan tetep pakai `dns=default` (atau `dns=systemd-resolved` kalau systemd-resolved aktif)
    
- Itu bisa bikin `/etc/resolv.conf` di-_symlink_ ke:
    
    - `/run/systemd/resolve/stub-resolv.conf`
        
    - `/var/run/NetworkManager/resolv.conf`
        
    - Dan itu artinya isi DNS lo bisa berubah otomatis (biasanya dari DHCP)
        

---

## ✅ Kesimpulan

|Kondisi|`resolv.conf` dikunci?|DNS bisa berubah?|
|---|---|---|
|❌ NetworkManager belum diinstall|✅ Ya (pakai `chattr +i`)|❗ Bisa (dari DHCP)|
|✅ NetworkManager aktif + `dns=none`|❌ Tidak perlu|❌ Tidak akan berubah|

---

Mau gue buatin script pintar auto-setup DNS post-install Arch Linux biar langsung aman & clean?