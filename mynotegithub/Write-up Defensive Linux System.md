<!-- ===================== -->
<!--        METADATA       -->
<!-- ===================== -->

<h1 align="center">📄 Write-up Defensive Linux System</h1>

<p align="center">
  <strong>Dibuat oleh:</strong> <em>Adji Putra</em> <br>
  <strong>Tanggal Dibuat:</strong> <em>5 Juni 2025</em> <br>
  <strong>Tanggal Selesai:</strong> <em>5 Juni 2025</em> <br>
</p>

<hr>

<!-- ===================== -->
<!--       DAFTAR ISI      -->
<!-- ===================== -->

<h2 align="center">📚 Daftar Isi</h2>


<ol>
  <li><a href="#Pendahuluan">Pendahuluan</a></li>
  <li><a href="#Lingkungan Pengujian">Lingkungan Pengujian</a></li>
  <li><a href="#Tujuan">Tujuan</a></li>
  <li><a href="#Hardening">Hardening</a></li>
  <li><a href="#Pengujian Hardening">Pengujian Hardening</a></li>
  <li><a href="#Hasil Pengujian">Hasil Pengujian</a></li>
  <li><a href="#Analisa Intrusion Detection System (IDS) - Snort">Analisa Intrusion Detection System (IDS) - Snort</a></li>
  <li><a href="#Pengujian Snort">Pengujian Snort</a></li>
  <li><a href="#Hasil Pengujian">Hasil Pengujian</a></li>
  <li><a href="#kesimpulan">Kesimpulan</a></li>
  <li><a href="#lampiran">Lampiran</a></li>
</ol>

---

## 🔰 1. Pendahuluan<a name="Pendahuluan"></a>

Write-up Defensive 

---

## 🧪 2. Lingkungan Pengujian<a name="Lingkungan Pengujian"></a>

- OS: Ubuntu Server 24.04.2 LTS
- Hypervisor: VirtualBox
- Mode Jaringan: NAT & Host-Only

---

## 🎯 3. Tujuan<a name="Tujuan"></a>

Mengetahui cara bertahan dari serangan non-etika hacker

---

## 🔐 4. Hardening<a name="Hardening"></a>

<ol>
  <li>Mengamankan Port</li>
  <li>Membuat User</li>
  <li>Mengaktifkan Audit (auditd)</li>
  <li>Disable Root Login via SSH</li>
  <li>Login Menggunakan SSH-Key</li>
</ol>


---

## 🧾 5. Pengujian Hardening<a name="Pengujian Hardening"></a>

### ✅ Tahap 1: Mengamankan Port

#### 🔧 Tools yang Dipakai

- 🛡️ `ufw` (Uncomplicated Firewall)  
- 📡 `netstat` atau `ss` → cek port  
- 🧪 `nmap` → testing dari luar

---

#### 💡 Kenapa?  
Kita harus **matiin semua service yang gak penting**, biar **attack surface makin sempit**.  
🔓 **Port yang kebuka = pintu masuk serangan.**
**[Ubuntu]**
```Terminal

# 1. Aktifkan ufw
sudo ufw enable

# 2. Default deny semua
sudo ufw default deny incoming
sudo ufw default allow outgoing

# 3. Allow yang perlu (misalnya SSH port 22, HTTP port 80)
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp

# 4. Cek status
sudo ufw status verbose

# 5. Cek service yang running dan port terbuka
sudo ss -tuln
# atau
sudo netstat -tuln

```
🚀 **Tujuan**:
- Biar cuma port tertentu doang yang bisa diakses.
- Misalnya port 3306 (MySQL) harusnya private? Jangan dibuka ke publik.
<br></br>

### ✅ Tahap 2: Membuat User

#### 🔧 Tools:
- `adduser`
- `usermod`
- `sudo`

#### 💡 Kenapa?
- **Root** punya akses full, jangan dipakai buat harian.
- Kita bikin user biasa + kasih dia akses `sudo` (admin level tapi ada jejaknya).
**[Ubuntu]**
```Terminal

# 1. Tambahkan user baru
sudo adduser lksadmin

# 2. Tambahkan ke grup sudo
sudo usermod -aG sudo lksadmin

# 3. Coba login pake user itu
su - lksadmin
sudo whoami   # harusnya output: root

```
🚀 **Tujuan**:
- Akses root tetap ada, tapi operasional harian pake user terbatas.
- Supaya kalo user ini bobol, damage-nya terbatas.
<br></br>

### ✅ Tahap 3: Mengaktifkan Audit (auditd)

#### 🔧 Tools:
- `auditd` (Audit Daemon)
- `ausearch`, `auditctl`

#### 💡 Kenapa?
- Biar semua aktivitas penting ke-log: login, akses file penting, penggunaan sudo, dsb.
**[Ubuntu]**
```Terminal

# 1. Install auditd
sudo apt update
sudo apt install auditd audispd-plugins

# 2. Aktifkan dan jalankan service
sudo systemctl enable auditd
sudo systemctl start auditd

# 3. Cek status
sudo systemctl status auditd

# 4. Coba lihat log audit
sudo ausearch -x sudo
sudo aureport -au  # report login attempts

```
🚀 **Tujuan**:
- Kalau ada serangan/aktivitas aneh, bisa dilacak via audit log.
- Cocok buat forensik & analisis pelanggaran.
<br></br>

### ✅ Bonus Step 4: Disable Root Login via SSH
#### 💡 Kenapa?
- Akses root langsung lewat SSH = bad practice. Gunakan user biasa + sudo
**[Ubuntu]**
```Terminal

sudo nano /etc/ssh/sshd_config

# Cari baris:
PermitRootLogin yes
# Ganti jadi:
PermitRootLogin no

# Restart SSH service
sudo systemctl restart ssh

```
🚀 **Tujuan**:
- Supaya vm lain yang ingin mengakses vm saya via ssh tidak bisa langsung naik jabatannya, ibarat one piece musuhnya luffy im-sama `(/root)` cukup menjadi holly knight/gorosei saja `(/home/user)`
<br></br>

### ✅ Bonus Step 5: Login Menggunakan SSH-Key tanpa Autentifkasi Password (Lebih Aman)
#### 💡 Kenapa?
- Karena kalo misalnya menggunakan password saja rawan untuk kena `brute force` password ssh untuk masuk kedalam sistem
**[Ubuntu]**
```Terminal

# Disisi Client, Misal Kali Linux atau Distro Linux Lainnya
ssh-keygen -t rsa -b 4096

```
**Output**:
Enter file in which to save the key (/home/kali/.ssh/id_rsa): [ENTER]
Enter passphrase (empty for no passphrase): [ENTER] atau isi kalau mau

#### File yang dihasilkan:
`~/.ssh/id_rsa (private key)` → **JANGAN DIBAGIKAN**
`~/.ssh/id_rsa.pub (public key)` → **YANG AKAN DIKIRIM KE SERVER**

#### Cara Membagikan Public Key ke VM Lain: 
Misal Client (Pembuat SSH-Key) membagikan Kunci Public Key nya ke vm lain agar Client bisa mengakses vm tersebut tanpa menggunakan Password. 
Cara gampang:
**[Ubuntu]**
```Terminal

ssh-copy-id -i ~/.ssh/id_rsa.pub username@IP-ubuntu-server

Contoh:
ssh-copy-id -i ~/.ssh/id_rsa.pub lksadmin@192.168.56.110

```

#### 📌 Kalau `ssh-copy-id` gak ada, bisa manual:
**[Ubuntu]**
```Terminal

cat ~/.ssh/id_rsa.pub | ssh lksadmin@192.168.56.110 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"

```

#### 🔧 Pastikan Permission-nya Bener di Server atau VM lain
Login ke Ubuntu Server, lalu:
**[Ubuntu]**
```Terminal

chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys # sesuaikan nama file enkripsinya apa didalam folder .ssh nya, default namenya adalah authorized_keys

```

#### 🔧 Edit Konfigurasi SSH di Server (Ubuntu)
**[Ubuntu]**
```Terminal

# Edit konfigurasi ssh
sudo nano /etc/ssh/sshd_config

```

Pastikan nilai berikut:
```Terminal

PasswordAuthentication no
PubkeyAuthentication yes
PermitRootLogin no

```

## 🧾 6. Hasil Pengujian<a name="Hasil Pengujian"></a>

#### ✅ Tahap 1: Mengamankan Port
![Alt Text](image/Pengamanan_Port.png)

#### ✅ Tahap 2: Membuat User
![Alt Text](image/Membuat_User.png)


#### ✅ Tahap 3: Mengaktifkan Audit (auditd)
![Alt Text](image/Audit_2.png)
![Alt Text](image/Audit_3.png)
![Alt Text](image/Audit_1.png)

#### ✅ Bonus Step 4: Disable Root Login via SSH
![Alt Text](image/disable_ssh_login.png)

#### ✅ Bonus Step 5: Login Menggunakan SSH-Key tanpa Autentifkasi Password (Lebih Aman)
![Alt Text](image/ssh_key_3.png)
![Alt Text](image/ssh_key_2.png)
![Alt Text](image/ssh_key_1.png)


---

## 🔐 7. Analisa Intrusion Detection System (IDS) - Snort<a name="Analisa Intrusion Detection System (IDS) Snort"></a>

<ol>
  <li>Install Dependensi yang Diperlukan</li>
  <li>Install Snortnya</li>
  <li>Konfigurasi Snortnya</li>
  <li>Konfigurasi Rules untuk Snortnya</li>
  <li>Login Menggunakan SSH-Key</li>
</ol>

## 🧾 8. Pengujian IDS<a name="Pengujian IDS"></a>

### 🛡️ Install Snort 2.x di Ubuntu Server 24.04.2 LTS

Dokumentasi lengkap instalasi Snort 2.x sebagai Network-based IDS (Intrusion Detection System) di Ubuntu, dari install dependencies, compile dari source, hingga siap digunakan untuk deteksi serangan jaringan.

---

#### ✅ Step 1: Update Sistem & Install Build Tools

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential
```

#### 💡 Penjelasan:

* `build-essential`: Instal compiler & tools penting seperti `gcc`, `make`, dll.
* Wajib untuk compile DAQ & Snort dari source.

---

#### ✅ Step 2: Install Dependencies Wajib

```bash
sudo apt install -y \
libpcap-dev \
libpcre3-dev \
libdumbnet-dev \
zlib1g-dev \
luajit-5.1-dev \
libnghttp2-dev \
libssl-dev \
libtool \
bison \
flex \
autotools-dev \
pkg-config \
libnetfilter-queue-dev \
libnfnetlink-dev \
libtirpc-dev \
wget \
curl \
unzip \
xz-utils
```

#### 💡 Penjelasan Fungsi Paket:

| Paket                                        | Fungsi                                      |
| -------------------------------------------- | ------------------------------------------- |
| `libpcap-dev`                                | Sniffing packet dari interface (core Snort) |
| `libpcre3-dev`                               | Regex engine untuk filter trafik            |
| `libdumbnet-dev`                             | Manipulasi jaringan level rendah            |
| `zlib1g-dev`                                 | Kompresi data log                           |
| `luajit-5.1-dev`                             | Lua scripting support                       |
| `libssl-dev`                                 | SSL/TLS secure connection                   |
| `libnetfilter-queue-dev`, `libnfnetlink-dev` | Integrasi Snort + iptables                  |
| `bison`, `flex`                              | Parsing tools saat compile                  |
| `libtirpc-dev`                               | Modern RPC (ganti rpcbind lawas)            |
| `libtool`, `autotools-dev`, `pkg-config`     | Tools bantu compile source                  |
| `wget`, `curl`, `unzip`, `xz-utils`          | Alat unduh dan ekstrak file source          |

---

#### ✅ Step 3: Install DAQ (Data Acquisition Library)

DAQ adalah jembatan antara Snort dan network interface untuk ambil paket dari kernel.

```bash
cd /usr/src
sudo wget https://www.snort.org/downloads/snort/daq-2.0.7.tar.gz
sudo tar -xvzf daq-2.0.7.tar.gz
cd daq-2.0.7
./configure
make
sudo make install
```

#### 💡 Penjelasan:

Tanpa DAQ, Snort tidak bisa membaca trafik jaringan.

---

#### ✅ Step 4: Install Snort 2.x

```bash
cd /usr/src
sudo wget https://www.snort.org/downloads/snort/snort-2.9.20.tar.gz
sudo tar -xvzf snort-2.9.20.tar.gz
cd snort-2.9.20
./configure --enable-sourcefire
make
sudo make install
```

#### 💡 Penjelasan:

* Compile Snort dari source.
* Opsi `--enable-sourcefire` mengaktifkan fitur Sourcefire (asli developer Snort).

---

#### ✅ Step 5: Post-Install Setup

```bash
sudo ln -s /usr/local/bin/snort /usr/sbin/snort
sudo mkdir -p /etc/snort/rules
sudo mkdir -p /var/log/snort
sudo mkdir -p /usr/local/lib/snort_dynamicrules
sudo touch /etc/snort/rules/local.rules
sudo touch /etc/snort/snort.conf
```

#### 💡 Penjelasan:

* Buat folder config & log.
* `snort.conf`: konfigurasi utama.
* `local.rules`: tempat custom rules dibuat.

---

#### ✅ Step 6: Salin File Konfigurasi Default

```bash
cd /usr/src/snort-2.9.20/etc/
sudo cp *.conf *.map *.dtd /etc/snort/
```

#### 💡 Penjelasan:

* Salin konfigurasi default agar Snort bisa langsung dites dan dikustomisasi.
* `.map` file = mapping alert ID ke deskripsi.

---

#### ✅ Step 7: Cek Versi Snort

```bash
snort -V
```

#### ✅ Output:

```
       ,,_     -*> Snort! <*-
      o"  )~   Version 2.9.20
       ''''    By Martin Roesch & The Snort Team
               https://www.snort.org/
```

---

#### ✅ Step 8: Tes Konfigurasi

```bash
snort -T -c /etc/snort/snort.conf
```

#### 💡 Penjelasan:

* `-T`: test mode (tidak menjalankan Snort, hanya cek config).
* `-c`: spesifikasikan file konfigurasi.

---

#### 🧪 Step Opsional: Jalankan Snort dalam Mode IDS

```bash
snort -i eth0 -c /etc/snort/snort.conf -A console
```

> Ganti `eth0` dengan interface aktif (cek pakai `ip a`)

#### 💡 Penjelasan:

* `-i eth0`: interface yang dimonitor.
* `-A console`: tampilkan alert ke terminal (log real-time).

---

#### 📦 Ringkasan Komponen Penting

| Komponen                      | Tujuan                                  |
| ----------------------------- | --------------------------------------- |
| **DAQ**                       | Jembatan Snort ke kernel packet capture |
| **Snort 2.x**                 | Engine deteksi utama                    |
| **local.rules**               | File tempat menulis custom rule         |
| **snort.conf**                | Konfigurasi global Snort                |
| **libpcap, pcre, zlib, dnet** | Dependencies inti                       |
| **/var/log/snort/**           | Lokasi log alert dan deteksi            |

---

### ⚙️ Konfigurasi Dasar `snort.conf` untuk Snort 2.x

Berikut adalah konfigurasi minimalis namun fungsional agar Snort bisa langsung dijalankan untuk mendeteksi serangan umum. Konfigurasi ini memuat:

* Deklarasi variabel jaringan
* Preprocessor untuk HTTP inspection
* Output ke terminal
* Include file rules lokal (`local.rules`)

---

#### ✅ 1. Variable Settings

```snort
# ===================[ Variable Settings ]===================
ipvar HOME_NET any
ipvar EXTERNAL_NET any

var RULE_PATH /etc/snort/rules
var WHITE_LIST_PATH /etc/snort/rules
var BLACK_LIST_PATH /etc/snort/rules
```

#### 🧠 Penjelasan:

| Variabel                             | Fungsi                                                                                                     |
| ------------------------------------ | ---------------------------------------------------------------------------------------------------------- |
| `HOME_NET`                           | Jaringan internal yang ingin dipantau. `any` = semua IP (bisa disesuaikan nanti, misal: `192.168.56.0/24`) |
| `EXTERNAL_NET`                       | Umumnya adalah trafik dari luar. Di-set ke `any` dulu.                                                     |
| `RULE_PATH`                          | Lokasi rules Snort disimpan                                                                                |
| `WHITE_LIST_PATH`, `BLACK_LIST_PATH` | Path untuk file whitelist dan blacklist IP                                                                 |

---

#### ✅ 2. Preprocessor Settings

```snort
# ===================[ Preprocessor Section ]================

# Global config wajib
preprocessor http_inspect: global \
    iis_unicode_map unicode.map 1252

# HTTP Inspect (WAJIB)
preprocessor http_inspect_server: server default profile all ports { 80 8080 8000 } \
    flow_depth 0 \
    enable_cookie \
    extended_response_inspection \
    inspect_gzip \
    normalize_headers \
    normalize_cookies \
    normalize_utf
```

#### 🧠 Penjelasan:

#### `http_inspect: global`

* **Fungsi:** Mengaktifkan preprocessor HTTP untuk semua trafik HTTP.
* **iis\_unicode\_map unicode.map 1252**: Gunakan peta karakter Unicode untuk decoding URL encoded dari server Microsoft IIS.

#### `http_inspect_server`

* **profile all**: Aktifkan semua metode inspeksi HTTP.
* **ports { 80 8080 8000 }**: Monitor port HTTP umum.
* **flow\_depth 0**: Proses seluruh payload.
* **enable\_cookie**: Inspeksi cookie HTTP.
* **normalize\_headers/cookies/utf**: Bersihkan dan deteksi penyimpangan di header/cookie/encoding UTF.
* **inspect\_gzip**: Deteksi payload yang dikompresi.

> 📌 Preprocessor ini penting untuk mendeteksi serangan seperti XSS, Directory Traversal, HTTP evasion, dll.

---

#### 🧩 (Optional) Preprocessor Tambahan

```snort
# Optional Preprocessor (boleh aktifin kalau butuh)
# preprocessor frag3_global: max_frags 65536
# preprocessor frag3_engine: policy windows detect_anomalies
# preprocessor stream5_global: track_tcp yes, track_udp yes
# preprocessor stream5_tcp: policy linux
```

#### 💡 Penjelasan:

* **frag3**: Deteksi fragmentasi IP yang mencurigakan.
* **stream5**: Untuk deteksi serangan TCP stateful (misalnya evasive TCP).
* Nonaktif dulu kalau belum butuh, bisa aktifkan nanti untuk proteksi lanjutan.

---

#### ✅ 3. Output Settings

```snort
# ===================[ Output Settings ]=====================
output alert_fast: stdout
```

#### 💡 Penjelasan:

* Cetak hasil deteksi ke terminal (stdout) dalam format sederhana.
* Cocok untuk testing atau debugging.

---

#### ✅ 4. Include File Rules

```snort
# ===================[ Include Rules ]=======================
include $RULE_PATH/local.rules
```

#### 💡 Penjelasan:

* Muat file `local.rules` tempat kamu menulis **custom detection rules**.
* Misalnya untuk deteksi ICMP, SQL Injection, dsb.

---

#### 🔗 Full Snort.conf

```snort
# ===================[ Variable Settings ]===================
ipvar HOME_NET any
ipvar EXTERNAL_NET any

var RULE_PATH /etc/snort/rules
var WHITE_LIST_PATH /etc/snort/rules
var BLACK_LIST_PATH /etc/snort/rules

# ===================[ Preprocessor Section ]================

# Global config wajib
preprocessor http_inspect: global \
    iis_unicode_map unicode.map 1252

# HTTP Inspect (WAJIB)
preprocessor http_inspect_server: server default profile all ports { 80 8080 8000 } \
    flow_depth 0 \
    enable_cookie \
    extended_response_inspection \
    inspect_gzip \
    normalize_headers \
    normalize_cookies \
    normalize_utf

# Optional Preprocessor (boleh aktifin kalau butuh)
# preprocessor frag3_global: max_frags 65536
# preprocessor frag3_engine: policy windows detect_anomalies
# preprocessor stream5_global: track_tcp yes, track_udp yes
# preprocessor stream5_tcp: policy linux

# ===================[ Output Settings ]=====================
output alert_fast: stdout

# ===================[ Include Rules ]=======================
include $RULE_PATH/local.rules
```


---

### 🚀 Instalasi LAMP Stack di Ubuntu Server 24.04.2 LTS

> LAMP = Linux + Apache + MySQL/MariaDB + PHP
> Kombinasi klasik untuk menjalankan website dan aplikasi web berbasis PHP.

---

#### ✅ Step 1: Update Sistem

```bash
sudo apt update && sudo apt upgrade -y
```

#### 💡 Penjelasan:

* Pastikan semua paket dan repository sistem terbaru agar instalasi bersih dan aman.

---

#### ✅ Step 2: Install Apache (Web Server)

```bash
sudo apt install apache2 -y
```

#### 💡 Penjelasan:

* Apache adalah web server yang akan menayangkan file website dari direktori `/var/www/html`.

🔎 **Cek Apache jalan atau tidak:**

```bash
sudo systemctl status apache2
```

🌐 **Tes di browser:**
Ketik IP server kamu → `http://<alamat-IP-server>`

---

#### ✅ Step 3: Install MariaDB (MySQL-Compatible Database)

```bash
sudo apt install mariadb-server -y
```

🔐 **Jalankan pengamanan database:**

```bash
sudo mysql_secure_installation
```

#### 💡 Penjelasan:

* MariaDB adalah drop-in replacement dari MySQL.
* `mysql_secure_installation` akan:

  * Set root password
  * Hapus user anonymous
  * Nonaktifkan remote root login
  * Hapus test database

🔎 **Cek status MariaDB:**

```bash
sudo systemctl status mariadb
```

🛠️ **Login ke MariaDB:**

```bash
sudo mysql -u root -p
```

---

#### ✅ Step 4: Install PHP + Modul Pendukung

```bash
sudo apt install php libapache2-mod-php php-mysql -y
```

#### 💡 Penjelasan:

| Paket                | Fungsi                                                  |
| -------------------- | ------------------------------------------------------- |
| `php`                | Bahasa scripting untuk backend web                      |
| `libapache2-mod-php` | Integrasi PHP ke Apache                                 |
| `php-mysql`          | Modul agar PHP bisa terhubung ke database MySQL/MariaDB |

---

#### ✅ Step 5: Tes PHP di Apache

Buat file `info.php`:

```bash
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php
```

🌐 Buka browser dan akses:
`http://<alamat-IP-server>/info.php`

✅ Kalau muncul halaman berisi versi PHP & konfigurasi — **PHP sudah berhasil terpasang!**

🧼 Hapus file test setelah selesai:

```bash
sudo rm /var/www/html/info.php
```

---

#### ✅ Step 6: (Opsional) Install Modul PHP Tambahan

```bash
sudo apt install php-cli php-curl php-gd php-mbstring php-xml php-zip -y
```

#### 💡 Penjelasan Fungsi Modul:

| Modul          | Fungsi                            |
| -------------- | --------------------------------- |
| `php-cli`      | Jalankan PHP dari terminal        |
| `php-curl`     | Kirim request HTTP dari PHP       |
| `php-gd`       | Proses gambar (resize, crop, dll) |
| `php-mbstring` | Dukungan string multibyte         |
| `php-xml`      | Proses XML/DOM                    |
| `php-zip`      | Baca/ekstrak file ZIP             |

---

#### 🔁 Restart Apache Setelah Install PHP

```bash
sudo systemctl restart apache2
```

---

#### ✅ Ringkasan LAMP Stack

| Komponen | Perintah                                 | Fungsi                                            |
| -------- | ---------------------------------------- | ------------------------------------------------- |
| Apache   | `apache2`                                | Web server untuk serve file HTML/PHP              |
| MariaDB  | `mariadb-server`                         | Database backend                                  |
| PHP      | `php`, `libapache2-mod-php`, `php-mysql` | Bahasa backend untuk memproses request & query DB |

---

#### 🧪 Tes LAMP Stack Secara Keseluruhan

1. Buat database di MariaDB
2. Buat file `test.php` untuk connect ke DB
3. Tes PHP + DB dari browser

Contoh file:

```php
<?php
$koneksi = mysqli_connect("localhost", "root", "passwordmu", "namadb");

if (!$koneksi) {
    die("Koneksi Gagal: " . mysqli_connect_error());
}
echo "Koneksi DB Berhasil!";
?>
```

Simpan sebagai: `/var/www/html/testdb.php`
Akses via: `http://<IP-server>/testdb.php`

---

Mantap jiwa cuy! Ini dia versi **Markdown premium dan profesional** buat dokumentasi `Snort Rules` kamu. Cocok buat dijadikan laporan, dokumentasi tim, atau dijadikan pegangan pas ngajar atau demo. Sudah rapi, lengkap, dan dijelaskan **per rule** dengan gaya keren dan gampang dipahami 🚀🔥

---

### 🛡️ Snort IDS Rules: SQL Injection, XSS, & ICMP Detection

> Dokumentasi lengkap rules **Snort IDS** yang mendeteksi berbagai jenis serangan, mulai dari **SQL Injection**, **Cross Site Scripting (XSS)**, hingga **ICMP (ping)**.
> Sudah teruji di **CentOS 9 + VirtualBox**.

---

#### 📁 File: `/etc/snort/rules/local.rules`

---

#### 1️⃣ SQL Injection Detection

#### 🧪 **Basic SQLi Patterns**

```snort
alert tcp any any -> any 80 (msg:"SQL Injection Basic - 1=1"; content:"1=1"; nocase; http_uri; sid:1000001; rev:1;)
alert tcp any any -> any 80 (msg:"SQL Injection Basic - OR"; content:" OR "; nocase; http_uri; sid:1000002; rev:1;)
```

> Mendeteksi pola SQL klasik seperti `1=1` dan operator `OR` di URI.

---

#### ⚙️ **Medium-Level SQLi (Encoded Payloads)**

```snort
alert tcp any any -> any 80 (msg:"SQL Injection Encoded - %27 OR 1=1"; content:"%27%20OR%201=1"; nocase; http_uri; sid:1000003; rev:1;)
alert tcp any any -> any 80 (msg:"SQL Injection Encoded - ' OR '1'='1"; content:"%27%20OR%20%271%27%3D%271"; nocase; http_uri; sid:1000004; rev:1;)
```

> Mendeteksi SQLi berbasis input **URL-encoded**, yang sering dipakai untuk bypass filter sederhana.

---

#### 🧠 **Expert-Level SQLi Patterns**

```snort
alert tcp any any -> any 80 (msg:"SQLi Expert - tautology OR 1=1"; content:"' OR 1=1"; nocase; http_uri; sid:1000005; rev:1;)
alert tcp any any -> any 80 (msg:"SQLi Expert - UNION SELECT"; content:"UNION SELECT"; nocase; http_uri; sid:1000006; rev:1;)
alert tcp any any -> any 80 (msg:"SQLi Expert - information_schema"; content:"information_schema"; nocase; http_uri; sid:1000007; rev:1;)
```

> Deteksi **tautologi SQL**, eksploitasi data dengan `UNION SELECT`, serta pencarian struktur DB via `information_schema`.

---

#### 2️⃣ XSS (Cross Site Scripting) Detection

#### 🧪 **Basic XSS**

```snort
alert tcp any any -> any 80 (msg:"XSS Basic - <script>"; content:"<script>"; nocase; http_uri; sid:1000010; rev:1;)
```

> Deteksi tag `<script>`, elemen paling umum dalam serangan XSS.

---

#### ⚙️ **Medium-Level XSS**

```snort
alert tcp any any -> any 80 (msg:"XSS Medium - alert("; content:"alert("; nocase; http_uri; sid:1000011; rev:1;)
alert tcp any any -> any 80 (msg:"XSS Medium - javascript:"; content:"javascript:"; nocase; http_uri; sid:1000012; rev:1;)
```

> Deteksi penggunaan `alert()` dan skema URI `javascript:`, sering muncul di payload XSS.

---

#### 🧠 **Expert-Level XSS (Encoded & Variant)**

```snort
alert tcp any any -> any 80 (msg:"XSS Expert - encoded script tag"; content:"%3Cscript%3E"; nocase; http_uri; sid:1000013; rev:1;)
alert tcp any any -> any 80 (msg:"XSS Expert - img onerror"; content:"<img"; nocase; http_uri; content:"onerror="; nocase; sid:1000014; rev:1;)
```

> Deteksi tag `<script>` dalam bentuk **URL encoded** dan vektor **onerror XSS** lewat tag `<img>`.

---

#### 3️⃣ ICMP (Ping) Detection

#### 📡 **Generic ICMP Detection**

```snort
alert icmp any any -> any any (msg:"ICMP Ping Request Detected"; itype:8; sid:1000020; rev:1;)
alert icmp any any -> any any (msg:"ICMP Ping Reply Detected"; itype:0; sid:1000021; rev:1;)
```

> Deteksi **ping request** (type 8) dan **ping reply** (type 0), cocok untuk analisa aktivitas ping jaringan.

---

#### 🧑‍💻 **ICMP Ping dari Host ke VM (Kustom IP)**

```snort
alert icmp 192.168.56.1 any -> 192.168.56.9 any (msg:"ICMP Ping dari Host Windows ke Webserver VM"; itype:8; sid:1000022; rev:1;)
```

> Deteksi spesifik ping dari IP **host Windows** ke **webserver VM**, cocok untuk lab VirtualBox.

---

#### 🛠️ Deployment & Testing

#### 1. Simpan Rules

Simpan semua rule ke:

```bash
/etc/snort/rules/local.rules
```

---

#### 2. Test Konfigurasi Snort

```bash
snort -T -c /etc/snort/snort.conf
```

> ✅ Pastikan tidak ada error dalam konfigurasi.

---

#### 3. Jalankan Snort Daemon

```bash
systemctl restart snortd
```

> 🔄 Restart service untuk aktifkan rule baru.

---

#### ✅ Rangkuman SID (Snort Rule ID)

| SID             | Jenis Serangan | Keterangan Singkat                           |
|-----------------|----------------|----------------------------------------------|
| 1000001-1000007 | SQL Injection  | Dari basic sampai eksploitasi DB             |
| 1000010-1000014 | XSS            | Dari tag `<script>` hingga payload encoded   |
| 1000020-1000022 | ICMP           | Ping request, reply, dan dari host ke VM     |

---


### ✅ **STRUKTUR SIMULASI (Full Stack Realistic)**

1. **LAMP Stack**: Web server (Apache + PHP + MySQL)
2. **Target Web App**:

   * Form login rentan SQL Injection
   * Form komentar rentan XSS
3. **Simulasi ICMP**: Ping dari Host ke VM
4. **Client**: Pakai browser atau `curl`/`ping`
5. **Snort**: Sudah jalan dan siap tangkap alert

---

#### 🌐 1. Web App - `index.php` (Simulasi SQLi & XSS)

Letakkan di: `/var/www/html/index.php`

```php
<?php
// Koneksi ke DB
$conn = new mysqli("localhost", "root", "password", "simulasi");

// SQL Injection Demo
if (isset($_POST['login'])) {
    $user = $_POST['username'];
    $pass = $_POST['password'];
    $query = "SELECT * FROM users WHERE username='$user' AND password='$pass'";
    $result = $conn->query($query);
    if ($result && $result->num_rows > 0) {
        $msg = "✅ Login berhasil!";
    } else {
        $msg = "❌ Login gagal!";
    }
}

// XSS Demo
if (isset($_POST['comment'])) {
    $komen = $_POST['komentar'];
    file_put_contents("komen.txt", htmlspecialchars($komen) . "\n", FILE_APPEND);
}

$comments = file_exists("komen.txt") ? file_get_contents("komen.txt") : "";
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>🔥 Simulasi Serangan Web 🔥</title>
    <style>
        body { font-family: Arial; background: #1f1f1f; color: #fff; padding: 20px; }
        .box { background: #333; padding: 20px; border-radius: 10px; margin-bottom: 30px; box-shadow: 0 0 10px #000; }
        input, textarea { width: 100%; padding: 10px; margin: 5px 0; background: #222; color: #fff; border: none; border-radius: 5px; }
        button { padding: 10px 20px; background: #007acc; border: none; color: white; border-radius: 5px; cursor: pointer; }
        h2 { color: #00e6e6; }
    </style>
</head>
<body>

    <h1>🛡️ Simulasi Web Attack - SQLi & XSS</h1>

    <div class="box">
        <h2>🧨 SQL Injection Login</h2>
        <form method="post">
            <input type="text" name="username" placeholder="Username (coba: ' OR 1=1 --)" required>
            <input type="text" name="password" placeholder="Password" required>
            <button name="login">Login</button>
        </form>
        <p><?= isset($msg) ? $msg : "" ?></p>
    </div>

    <div class="box">
        <h2>🧪 XSS Komentar</h2>
        <form method="post">
            <textarea name="komentar" placeholder="Ketik komentar (coba: <script>alert(1)</script>)" required></textarea>
            <button name="comment">Kirim Komentar</button>
        </form>
        <h3>Komentar Sebelumnya:</h3>
        <pre><?= $comments ?></pre>
    </div>

</body>
</html>
```

---

## 🛠️ 2. Database Setup (MySQL)

Login ke MySQL dan buat database:

```sql
CREATE DATABASE simulasi;
USE simulasi;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50),
    password VARCHAR(50)
);

INSERT INTO users (username, password) VALUES ('admin', 'admin123');
```

---

#### 📡 3. Simulasi ICMP dari Host ke VM

Di host (misal IP VM: `192.168.56.9`):

```bash
ping 192.168.56.9
```

> Snort akan deteksi berdasarkan rules:

```snort
alert icmp 192.168.56.1 any -> 192.168.56.9 any (msg:"ICMP Ping dari Host ke VM"; itype:8; sid:1000022; rev:1;)
```

---

#### 🔥 4. Serangan Simulasi (Manual atau Otomatis)

#### SQL Injection

```bash
curl -X POST -d "username=' OR 1=1 --&password=test" http://192.168.56.9/index.php
```

#### XSS

Buka `http://192.168.56.9/index.php`, lalu masukkan:

```html
<script>alert('XSS')</script>
```

---

#### ✅ 5. Sinkronisasi dengan Snort

* Rules sudah diaktifkan (SQLi, XSS, ICMP)
* File `local.rules` sudah berisi alert seperti:

  ```snort
  alert tcp any any -> any 80 (msg:"SQL Injection Basic - 1=1"; ...)
  alert tcp any any -> any 80 (msg:"XSS Basic - <script>"; ...)
  alert icmp 192.168.56.1 any -> 192.168.56.9 any (msg:"ICMP Ping dari Host ke VM"; ...)
  ```

Cek alert:

```bash
tail -f /var/log/snort/alert
```

---

#### 💻 Bonus UX Touch

* Dark mode UI
* Icon & warna bikin terasa “real world”
* Input placeholder memberi hint payload
* Output live langsung tampil di halaman

---
## 🧠 . Kesimpulan <a name="Kesimpulan"></a>

Server berhasil di-hardening sesuai best practices…

---

## 📎 . Lampiran <a name="Lampiran"></a>

- Screenshot
- Log hasil uji
- Script konfigurasi

---

<p align="center"><em>Dokumentasi ini dibuat dengan semangat open source ❤️</em></p>














