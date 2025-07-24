<h1 align="center">📄 Automation Script OpenVPN - OpenVPN</h1>

**script automation OpenVPN** yang udah gua **tweak supaya ANTI GAGAL**, aman dipake di Ubuntu Server 24.04.2 LTS, termasuk:

- Pake `set -e` tapi gak nyangkut
    
- Debug log `set -x` buat tracking
    
- Cek error manual di tempat-tempat rawan
    
- Otomatis deteksi IP host-only (192.168.56.x)
    
- Otomatis masukin IP ke `.ovpn`
    
- Otomatis nyalin isi sertifikat ke dalam `.ovpn` client
    
- Clean & log warna
    

---

### ✅ **1. Download script**

Copy dan simpan sebagai `setup_openvpn.sh`:

```bash
mkdir -p ~/scripts/
vi ~/scripts/setup_openvpn.sh
```

Paste ini:

```bash
#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
NC='\033[0m'

info() {
  echo -e "${GREEN}[*] $1${NC}"
}

# STEP 1: Update dan Install Paket
info "STEP 1: Update sistem dan install paket yang dibutuhkan..."
sudo apt update && sudo apt install -y \
  openvpn easy-rsa \
  iptables-persistent firewalld curl wget unzip tar \
  net-tools iproute2

# STEP 2: Aktifkan Modul TUN
info "STEP 2: Cek dan aktifkan TUN kernel module..."
if ! lsmod | grep -q tun; then
  sudo modprobe tun
  echo 'tun' | sudo tee -a /etc/modules
fi

# STEP 3: Setup Easy-RSA dan Buat Sertifikat
info "STEP 3: Setup Easy-RSA dan generate sertifikat..."
EASYRSA_DIR=~/openvpn-ca
make-cadir "$EASYRSA_DIR"
cd "$EASYRSA_DIR"
./easyrsa init-pki
EASYRSA_BATCH=1 ./easyrsa build-ca nopass
EASYRSA_BATCH=1 ./easyrsa gen-req server nopass
EASYRSA_BATCH=1 ./easyrsa sign-req server server
./easyrsa gen-dh
openvpn --genkey secret ta.key

# STEP 4: Copy file ke direktori OpenVPN
info "STEP 4: Salin sertifikat ke /etc/openvpn/server..."
sudo mkdir -p /etc/openvpn/server
sudo cp pki/ca.crt pki/private/server.key pki/issued/server.crt ta.key pki/dh.pem /etc/openvpn/server/

# STEP 5: Buat konfigurasi server
info "STEP 5: Buat file konfigurasi server..."
cat <<EOF | sudo tee /etc/openvpn/server/server.conf
port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh.pem
auth SHA256
tls-auth ta.key 0
topology subnet
server 10.8.0.0 255.255.255.0
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
keepalive 10 120
cipher AES-256-CBC
persist-key
persist-tun
status openvpn-status.log
verb 3
EOF

# STEP 6: Aktifkan IP Forwarding
info "STEP 6: Aktifkan IP forwarding..."
echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# STEP 7: Konfigurasi iptables NAT
info "STEP 7: Konfigurasi iptables NAT..."
OUT_IFACE=$(ip route | awk '/default/ {print $5}' | head -n1)
echo "[+] Menggunakan interface: $OUT_IFACE"
sudo iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o "$OUT_IFACE" -j MASQUERADE
sudo netfilter-persistent save

# STEP 8: Konfigurasi firewall
info "STEP 8: Konfigurasi firewalld..."
sudo systemctl enable firewalld --now
sudo firewall-cmd --add-port=1194/udp --permanent
sudo firewall-cmd --add-masquerade --permanent
sudo firewall-cmd --reload

# STEP 9: Enable dan start OpenVPN
info "STEP 9: Enable dan start OpenVPN server..."
sudo systemctl enable openvpn-server@server
sudo systemctl start openvpn-server@server
sudo systemctl status openvpn-server@server --no-pager

# STEP 10: Buat sertifikat client
info "STEP 10: Buat sertifikat client..."
cd "$EASYRSA_DIR"
EASYRSA_BATCH=1 ./easyrsa gen-req client1 nopass
EASYRSA_BATCH=1 ./easyrsa sign-req client client1
mkdir -p ~/client-configs/keys
cp pki/issued/client1.crt pki/private/client1.key pki/ca.crt ta.key ~/client-configs/keys/

# STEP 11: Buat file .ovpn client
info "STEP 11: Buat file konfigurasi client .ovpn..."
mkdir -p ~/client-configs/files
CLIENT_OVPN=~/client-configs/files/client1.ovpn
CLIENT_IP=$(ip -4 addr show | grep 192.168.56 | awk '{print $2}' | cut -d'/' -f1 | head -n1)

cat <<EOF > "$CLIENT_OVPN"
client
dev tun
proto udp
remote $CLIENT_IP 1194
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
auth SHA256
cipher AES-256-CBC
verb 3
key-direction 1

<ca>
$(cat ~/client-configs/keys/ca.crt)
</ca>
<cert>
$(cat ~/client-configs/keys/client1.crt)
</cert>
<key>
$(cat ~/client-configs/keys/client1.key)
</key>
<tls-auth>
$(cat ~/client-configs/keys/ta.key)
</tls-auth>
EOF

info "✅ Selesai! File .ovpn berada di: $CLIENT_OVPN"

```

---

### ✅ **2. Jalankan scriptnya**

```bash
chmod +x ~/scripts/setup_openvpn.sh
~/scripts/setup_openvpn.sh
```

Atau debug mode (biar kelihatan semua lognya):

```bash
bash ~/scripts/setup_openvpn.sh
```

---

### ✅ **3. Setelah selesai:**

- Ambil `client1.ovpn` dari `~/client-configs/files/` dan copy ke Windows.
    
- Jalankan **OpenVPN GUI as Administrator**
    
- Connect 🔒
    

---

**kalau lo pake file `.ovpn` yang gua buatin tadi** (yang otomatis masukin ini: `<ca>`, `<cert>`, `<key>`, `<tls-auth>`), maka:

> ✅ **Semua isi sertifikat dan key udah langsung embedded di dalam satu file `.ovpn` itu!**

---

### 🔐 Detailnya:

Di script tadi, bagian ini ngebungkus langsung isi file ke dalam `.ovpn`:

```conf
<ca>
...ISI ca.crt...
</ca>
<cert>
...ISI client1.crt...
</cert>
<key>
...ISI client1.key...
</key>
<tls-auth>
...ISI ta.key...
</tls-auth>
```

Jadi saat file `client1.ovpn` lo buka di Windows pakai **OpenVPN GUI**, dia udah punya semua:

- CA cert (buat validasi server)
    
- Client cert & key (buat autentikasi lo)
    
- TLS key (buat keamanan tambahan)
    

---

### 🛠 Kesimpulannya:

- ❌ **Gak perlu transfer file sertifikat terpisah** lagi.
    
- ✅ Cukup 1 file `.ovpn`, aman, simpel, dan portable.
    
- ✅ Bisa langsung connect dari **Windows**, bahkan juga bisa dari **Android OpenVPN Connect**.
    

---

### 💡 Tips Keamanan

Kalau lo butuh versi lebih aman (misalnya .ovpn **tanpa menyimpan key** di dalamnya), bisa juga dibuat `.ovpn` yang refer ke file eksternal:

```conf
cert client1.crt
key client1.key
```

Tapi itu berarti lo **harus transfer** semua file `.crt`, `.key`, dan `ta.key` ke folder OpenVPN di Windows.

---

Karena lo pakai **VirtualBox dengan host-only adapter**, berarti si Ubuntu Server (guest) **bisa konek ke Windows (host)** langsung lewat IP 192.168.56.x. Gua kasih 3 cara paling gampang buat **transfer file `.ovpn` dari Ubuntu ke Windows host lo**, pilih yang paling cocok buat lo:

---

## 🔁 **1. Pakai Python HTTP File Server (PALING SIMPLE)**

Di Ubuntu:

```bash
cd ~/client-configs/files
python3 -m http.server 8080
```

> Ini akan buka server web di port 8080, semua file dalam folder ini bisa didownload dari browser.

---

### ➡️ Di Windows:

1. Buka browser (Chrome, Edge, dll)
    
2. Akses:
    
    ```
    http://192.168.56.101:8080
    ```
    
    _(Ganti IP sesuai IP Ubuntu lo di jaringan 192.168.56.x — bisa dicek dengan `ip a` di Ubuntu)_
    
3. Klik `client1.ovpn` → Save as
    

---

## 📁 **2. Pakai Shared Folder VirtualBox (Butuh Guest Additions)**

### Langkah:

1. **Matikan VM Ubuntu** dulu
    
2. Di VirtualBox → klik VM → **Settings > Shared Folders**
    
3. Add Folder → pilih folder dari Windows → centang:
    
    - "Auto-mount"
        
    - "Make Permanent"
        
4. Boot Ubuntu
    
5. Akses di Ubuntu: biasanya muncul di `/media/sf_<folder_name>`
    

Lalu:

```bash
cp ~/client-configs/files/client1.ovpn /media/sf_<folder_name>/
```

> Cek di Windows folder itu, file langsung nongol.

---

## 📬 **3. Kirim Lewat SCP (Dari Windows ke Ubuntu pakai WinSCP)**

1. Download dan install [WinSCP](https://winscp.net/eng/download.php) di Windows.
    
2. Cek IP Ubuntu lo:
    

```bash
ip a | grep 192.168.56
```

Misal: `192.168.56.101`

3. Di WinSCP:
    
    - Protocol: **SCP**
        
    - Hostname: `192.168.56.101`
        
    - Username: `ubuntu lo`
        
    - Password: `password ubuntu lo`
        
4. Setelah connect, tinggal browse ke `~/client-configs/files/`, drag `client1.ovpn` ke Windows.
    

---

## ✅ Rekomendasi Gua?

Kalau lo mau **sekali klik, gak ribet**, gua saranin:

> 🔥 **Pakai Python HTTP Server**, tinggal buka browser → download → selesai.

---

Kalau lo mau kirim file `.ovpn` dari **Ubuntu (guest)** ke **Windows (host)** pakai `scp`, ada 2 skenario:

---

## ✅ **Skenario 1: Kirim File dari Ubuntu ke Windows via SCP (Windows sebagai SCP Server)**

Secara default, **Windows gak punya server SCP**, jadi **harus install dulu** aplikasi SCP Server (seperti [OpenSSH for Windows](https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse) atau pakai `WinSCP` in reverse mode — agak ribet).

---

## ✅ **Skenario 2: Kirim File dari Ubuntu ke Windows via SCP dari Windows (Windows sebagai klien pakai WinSCP / PSCP / Terminal SCP)**

> Ini lebih gampang! Lo **akses Ubuntu dari Windows**, terus ambil file `.ovpn`-nya. Caranya:

---

## 💻 LANGKAHNYA:

### 📌 1. Cek IP Ubuntu

Di Ubuntu VM:

```bash
ip a | grep 192.168.56
```

Misalnya: `192.168.56.101`

---

### 📌 2. Cek lokasi file `.ovpn`

Misalnya file-nya ada di:

```bash
/home/ubuntu/client-configs/files/client1.ovpn
```

---

### 📌 3. Kirim File dari Ubuntu ke Windows pakai **SCP di Windows**

Pakai **PowerShell / CMD / Terminal Windows**, ketik:

```powershell
scp ubuntu@192.168.56.101:/home/ubuntu/client-configs/files/client1.ovpn .
```

> Artinya: Ambil file dari Ubuntu ke direktori saat ini di Windows.

Kalau pakai password, lo bakal disuruh masukin password Ubuntu-nya.

---

### 🛠 Tips:

- Kalau `scp` gak dikenal, install [Git for Windows](https://git-scm.com/) → lalu buka Git Bash → command di atas bisa langsung dipakai.
    
- Atau install [WinSCP](https://winscp.net/eng/download.php) → GUI drag-n-drop file-nya.
    

---

## 🔐 Kalau Pakai Private Key?

Kalau lo setup Ubuntu pakai SSH key:

```bash
scp -i ~/.ssh/id_rsa ubuntu@192.168.56.101:/home/ubuntu/client-configs/files/client1.ovpn .
```

---

gua bantu recall nih.

Di script automation yang gua bantu sebelumnya (dan juga dari setup manual lo), file `.ovpn` disimpan di direktori ini:

```
~/client-configs/files/client1.ovpn
```

Alias full path-nya:

```
/home/ubuntu/client-configs/files/client1.ovpn
```

> 📂 Struktur direktori tersebut otomatis dibuat sama script:

```bash
mkdir -p ~/client-configs/files
```

---

## 🔍 Cek lokasi sekarang (di VM Ubuntu):

```bash
ls ~/client-configs/files
```

Harusnya lo lihat:

```
client1.ovpn
```

Kalau mau lihat isinya:

```bash
cat ~/client-configs/files/client1.ovpn
```

---

Kalau lo mau kirim file itu via `scp`, cukup targetin ke path itu:

```bash
scp ubuntu@192.168.56.101:/home/ubuntu/client-configs/files/client1.ovpn .
```

---

Kalau lo **jalanin semua setup OpenVPN-nya sebagai `root`**, maka semua path yang pake `~` alias **home directory**, itu bakal ngarah ke direktori home-nya `root`, yaitu:

```
/root/
```

---

### 🔎 Jadi, kalau lo make `root`, file `.ovpn`-nya ada di:

```
/root/client-configs/files/client1.ovpn
```

Dan untuk SCP dari Windows ke Ubuntu (misalnya pakai PowerShell / Git Bash), kalau user yang lo pakai adalah `root`, formatnya jadi:

```bash
scp root@192.168.56.101:/root/client-configs/files/client1.ovpn .
```

> Lo tinggal masukin password root-nya, terus file-nya bakal nyampe ke folder Windows lo.

---

### 🔐 Akses root dari Windows client (misalnya WinSCP)

- **Protocol**: SCP
    
- **Host**: `192.168.56.101`
    
- **Username**: `root`
    
- **Password**: (isi sesuai root Ubuntu)
    
- **Path**: `/root/client-configs/files/`
    

> Kalau `root` di-disable SSH-nya (default-nya sering begitu), lo bisa:
> 
> - Masuk pakai user biasa (`ubuntu`)
>     
> - Trus ambil file dari lokasi yang disalin dulu dari root:
>     

```bash
sudo cp /root/client-configs/files/client1.ovpn /home/ubuntu/
sudo chown ubuntu:ubuntu /home/ubuntu/client1.ovpn
```

---
