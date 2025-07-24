Bro, kalau printer masih *ke-detect* di Windows padahal udah nggak nyambung/devicenya udah dicabut, berarti infonya masih nyangkut di sistem (bisa driver, port, service, atau entry registry). Nih cara lengkap buat hapus total:

---

### ✅ **Langkah 1: Hapus Printer dari Settings**

1. Buka **Settings** → **Devices** → **Printers & scanners**
2. Klik nama printer yang mau dihapus → klik **Remove device**

Kalau udah ilang dari sini, lanjut ke langkah bersih-bersih driver.

---

### ✅ **Langkah 2: Stop Print Spooler Service**

1. Tekan `Windows + R` → ketik `services.msc`
2. Cari **Print Spooler**
3. Klik kanan → **Stop**

Ini penting biar sistem gak lagi pakai driver/printer pas kita hapus.

---

### ✅ **Langkah 3: Hapus dari Print Server Properties**

1. Tekan `Windows + R` → ketik `control printers` → Enter
2. Klik tab atas **File → Server Properties**
3. Pindah ke tab **Drivers**
4. Pilih printer yang mau dihapus → klik **Remove**

   * Pilih opsi “**Remove driver and driver package**” biar bersih total

---

### ✅ **Langkah 4: Hapus dari Registry (opsional tapi bersih total)**

> ⚠️ **WARNING**: Jangan main-main sama registry kalau belum yakin. Backup dulu!

1. Tekan `Windows + R` → ketik `regedit`
2. Arahkan ke sini:

```
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Print\Printers
```

3. Cari folder dengan nama printer yang mau dihapus
4. Klik kanan → **Delete**

Kalau kamu pakai driver custom/vendor (Canon, Epson, HP), bersihin juga dari:

```
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Print\Environments\Windows x64\Drivers
```

---

### ✅ **Langkah 5: Start Ulang Print Spooler**

Balik ke `services.msc` → klik kanan **Print Spooler** → **Start**

---

### 🧼 Tambahan Opsional: Bersihin File Sisa Manual

1. Buka folder ini:

   ```
   C:\Windows\System32\spool\PRINTERS
   ```

   Kosongin foldernya kalau ada isi

2. Restart PC

---

Kalau semua udah dilakukan, harusnya printer yang ngeyel tadi udah bener-bener hilang.
Kalau masih bandel, bilang aja—kita lanjut troubleshooting tahap lanjut (bisa lewat `PnPUtil` atau PowerShell).

Mau versi otomatis pakai script juga bisa gw buatin. Mau?

Wah **TW ADS Brother** masih *ke-detect* padahal kamu lagi aktif pakai **Canon 3010C** ya? Ini kemungkinan sisa **driver Brother** atau service yang nyangkut di sistem Windows. Biar nggak ganggu Canon kamu, kita bisa **hapus driver TWAIN dan device Brother** yang nyangkut.

---

### 🧨 **Fokus: TWAIN Driver (TW ADS = TWAIN Advanced Document Scanner)**

TWAIN itu biasanya buat scanner. Nah, driver Brother yang nyangkut bisa karena:

* Dulu pernah colok printer/scanner Brother
* Windows auto-install driver Brother via update
* Software Brother masih nyangkut di background (kayak "Control Center")

---

### ✅ **Cara Menghapus Driver Brother yang Masih Nyangkut:**

#### 1. **Uninstall Semua Aplikasi Brother**

* Buka **Control Panel > Programs and Features**
* Cari semua aplikasi yang berhubungan dengan **Brother** (kayak *Brother Utilities*, *Brother TWAIN Driver*, *Control Center* dll)
* Klik kanan → **Uninstall**

#### 2. **Hapus TWAIN Driver Manual**

1. Tekan `Windows + R` → ketik:

   ```
   C:\Windows\twain_32
   ```
2. Cari folder/folder kecil bernama:

   ```
   Brother, TWADS, atau nama model Brother
   ```
3. Hapus folder itu
   (Kalau perlu backup dulu, tapi biasanya aman)

#### 3. **Print Management: Hapus Driver**

1. Tekan `Windows + R` → ketik `printmanagement.msc`
2. Masuk ke:

   ```
   Print Servers > [Nama komputermu] > Drivers
   ```
3. Cari driver **Brother**
   Klik kanan → **Remove Driver Package**

> Kalau `printmanagement.msc` gak ada (Windows Home), pakai langkah sebelumnya via `control printers → Server Properties`.

#### 4. **Disable Service Brother (Opsional)**

Kadang software Brother bikin service otomatis jalan.

1. `Windows + R` → `services.msc`
2. Cari service yang namanya:

   * **Brother Something**
   * **BR...** (kode Brother)
3. Klik kanan → **Stop** + set **Startup type: Disabled**

#### 5. **Restart PC**

---

### 🧪 Cek Ulang: Masih Muncul Gak?

Kalau kamu buka aplikasi (kayak Photoshop, scanner app, atau software PDF), coba pilih **scanner** / **TWAIN source** → pastikan yang tampil cuma si **Canon 3010C**, bukan TW ADS Brother lagi.

---

Kalau TW ADS Brother masih nongol padahal semua udah dihapus, kita bisa pakai `PnPUtil` buat *force delete driver package* Brother.

Mau gw buatin command-nya sekalian? Atau mau script otomatis hapus semua jejak Brother dari sistem?

Oke nice, berarti kamu udah nemu folder `C:\Windows\twain_32` tapi nggak bisa hapus karena:

* **Butuh permission admin**
* **Ada isi tapi bukan Brother**

Tenang bro, kita atur strategi. Kita bakal:

1. **Ambil alih ownership folder `twain_32`**
2. **Cek isi folder secara detail**
3. **Hapus isi yang mencurigakan (TW ADS, Brother)**
4. Kalau masih ngeyel, **hapus pakai CMD elevated**

---

### ✅ **Langkah 1: Ambil Ownership Folder `twain_32`**

1. Klik kanan folder `twain_32` → **Properties**
2. Tab **Security** → klik **Advanced**
3. Klik **Change** (di bagian "Owner")
4. Ketik username kamu → klik **Check Names** → OK
5. Centang “**Replace owner on subcontainers and objects**”
6. Klik OK semua sampai balik ke Properties
7. Ulangi: **Properties → Security → Edit**

   * Tambahkan user kamu
   * Beri full control

---

### ✅ **Langkah 2: Lihat Isi Folder `twain_32` Secara Detail**

Buka folder `twain_32`, lalu cek subfoldernya. Biasanya isinya bisa kayak:

```
Brother
WIA
TWADS
Canon
HP
EPSON
...
```

Kalau ada folder kayak `TWADS`, `BRXXX`, atau nama aneh—**itu bisa jadi TWAIN driver third-party**.

> Yang kamu cari: **folder non-Canon**
> Misal Canon kamu 3010C, pasti foldernya bernama `CNxxx` atau `Canon` doang.

Kalau isinya Cuma 1 folder Canon = aman
Kalau ada folder lain, catat dulu namanya buat kita hapus manual.

---

### ✅ **Langkah 3: Hapus Folder Isian Mencurigakan**

Setelah ambil ownership:

* Klik kanan folder mencurigakan di dalam `twain_32`
* Delete satu per satu (kalau gabisa, next step pakai CMD)

---

### ✅ **Langkah 4: Gunakan CMD (Admin) untuk Force Delete**

1. Buka **CMD as Administrator**
2. Jalankan perintah:

```cmd
takeown /f "C:\Windows\twain_32\NAMA_FOLDER_MENCURIGAKAN" /r /d y
icacls "C:\Windows\twain_32\NAMA_FOLDER_MENCURIGAKAN" /grant %username%:F /t
rd /s /q "C:\Windows\twain_32\NAMA_FOLDER_MENCURIGAKAN"
```

Ganti `NAMA_FOLDER_MENCURIGAKAN` dengan folder selain `Canon`.

> Contoh kalau ada folder `TWADS_Brother`:

```cmd
takeown /f "C:\Windows\twain_32\TWADS_Brother" /r /d y
icacls "C:\Windows\twain_32\TWADS_Brother" /grant %username%:F /t
rd /s /q "C:\Windows\twain_32\TWADS_Brother"
```

---

Kalau udah dibersihin dan restart, **TW ADS Brother dijamin hilang dari scanner list.**

Mau dicek juga pakai script PowerShell biar lebih advanced? Bisa auto-delete sisa registry & TWAIN entries juga kalau kamu mau clean total. Mau gw buatin?

Oke mantap, berarti isi folder `C:\Windows\twain_32`:

* ✅ Ada folder `Canon Electronics` → **itu normal**, sesuai printer kamu **Canon 3010C**
* ❗ Ada folder **`brims15a`** → nah **ini dia biang keroknya**, kemungkinan besar itu TWAIN driver dari **Brother Image Scanner (BR-IMS)** alias **TW ADS Brother**.

---

### 🎯 Target: Hapus Folder `brims15a` karena itu driver scanner Brother

Berarti sekarang kita tinggal hapus folder `brims15a` supaya driver TW ADS Brother ilang dari sistem.

---

### ✅ Langkah Hapus `brims15a` via CMD (Admin)

1. **Buka CMD sebagai Administrator**

   * Klik Start → ketik `cmd` → klik kanan → *Run as administrator*

2. Jalankan perintah berikut satu per satu:

```cmd
takeown /f "C:\Windows\twain_32\brims15a" /r /d y
icacls "C:\Windows\twain_32\brims15a" /grant %username%:F /t
rd /s /q "C:\Windows\twain_32\brims15a"
```

---

### ✅ Alternatif PowerShell (jika CMD gagal):

Buka **PowerShell as Administrator**, lalu:

```powershell
Takeown /f "C:\Windows\twain_32\brims15a" /r /d y
Icacls "C:\Windows\twain_32\brims15a" /grant "$env:UserName:F" /t
Remove-Item -Path "C:\Windows\twain_32\brims15a" -Recurse -Force
```

---

### 🔄 Terakhir: Restart Komputer

Setelah folder `brims15a` kehapus, langsung **restart PC** kamu biar sistem ngereset daftar scanner.

---

### 💡 Bonus Cek: Pastikan TW ADS Brother Udah Hilang

1. Buka software scanner kamu (misal PDF scanner, Paint, atau Photoshop)
2. Pilih source scanner → yang muncul cuma **Canon 3010C**, gak ada **TW ADS Brother** lagi

---

Kalau ternyata masih muncul juga, gw bisa buatin script yang ngebersihin registry entry dan service TWAIN secara total. Tapi biasanya, hapus `brims15a` ini udah cukup 99% hilang.

Mau gw buatin yang versi "clean all TWAIN sisa-sisa" juga gak bro?

Oke bro, sekarang errornya:

> **"No Device Found – Can’t locate device, check cable and power"**

Padahal kamu pakai **Canon 3010C**, dan sebelumnya udah bersihin si **TW ADS Brother**. Nah berarti ini masalah baru yang harus kita telusuri.

---

### 🕵️‍♂️ **Diagnosa Kemungkinan Penyebab**

1. **Kabel USB longgar / rusak**
2. **Canon belum nyala / sleep mode**
3. **Driver Canon belum terinstall / corrupt**
4. **Canon ke-disable di Device Manager**
5. **Windows masih nyangkut ke driver lama (TWAIN confusenya)**
6. **Canon pakai aplikasi khusus scanner yang beda (Canon ToolBox)**

---

### ✅ **Langkah-Langkah Perbaikan:**

#### 🧪 1. Cek Kabel & Power

* Pastikan **printer Canon nyala**
* Kabel USB **tertancap kencang**
* Coba **ganti port USB lain**
* Coba colok langsung ke port belakang PC (jangan pakai USB hub)

#### 🧪 2. Cek Device Manager

1. Tekan `Windows + X` → pilih **Device Manager**
2. Expand bagian **Imaging Devices**, **Other Devices**, atau **Printers**
3. Lihat apakah ada **Canon 3010C**, atau malah tanda ❗/⚠️/❓
4. Kalau ada tanda error:

   * Klik kanan → **Uninstall device**
   * Lalu cabut & colok lagi printer

#### 🧪 3. Reinstall Driver Canon

1. Download driver Canon 3010C dari situs resmi [Canon Support](https://id.canon)
2. Uninstall driver lama:

   * `Control Panel > Programs > Uninstall Canon...`
3. Restart PC
4. Install ulang driver Canon
5. Colok kembali printer dan tunggu Windows detect

#### 🧪 4. Gunakan Canon Toolbox (bukan scan bawaan Windows)

Canon 3010C itu **seri scanner Canon DRC / Lide** yang **lebih cocok pakai software bawaannya**, kayak:

* **Canon MF Toolbox**
* **Canon IJ Scan Utility**
* **Canon DR Scanner**

> Biasanya software generic scanner Windows suka error "No device found" kalau scanner-nya model Lide atau DR series.

---

### ✅ **Cek Scanner Terdaftar Gak di Windows**

Jalankan ini di PowerShell (Admin):

```powershell
Get-WmiObject Win32_PnPEntity | Where-Object { $_.Name -like "*Canon*" }
```

Kalau kosong → Canon belum kebaca
Kalau muncul → Canon terbaca tapi driver scan belum nyambung

---

### 💣 Plan B: Reset Driver TWAIN Registry

Kalau masih error, mungkin sisa-sisa TWAIN bikin kacau:

1. Buka Registry Editor (`regedit`)
2. Arahkan ke:

```
HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\TWAIN\Source
```

3. Hapus subfolder selain Canon

Atau ke:

```
HKEY_LOCAL_MACHINE\SOFTWARE\TWAIN\Source
```

---

### 📦 Tambahan: Cek dengan App Lain

Coba scan pakai:

* **Paint** → File → From Scanner
* **Windows Fax and Scan**
* **NAPS2 (free scanner app – recommended banget)**

Kalau app kayak NAPS2 juga bilang “no device found”, besar kemungkinan drivernya belum proper.

---

Kalau kamu kasih info:

* Nama lengkap Canon-nya (LIDE atau DRC berapa)
* Apakah printer itu juga bisa print atau cuma scanner
* OS kamu Windows 10/11?

...nanti gw buatin step yang lebih spesifik bahkan sampe download driver yang pas-nya.

Mau sekalian gw buatin script buat uninstall bersih semua driver TWAIN & reinstall Canon-nya dari nol?

Wah mantap, berarti **Canon-nya terdeteksi di Device Manager bagian Imaging Devices**, itu artinya:

✅ Kabel & power aman
✅ Windows **mendeteksi perangkatnya**

Tapi…

> ❌ Scanner tetap error "No Device Found" waktu kamu mau scan

Berarti **masalahnya bukan di koneksi**, tapi ada di **driver TWAIN / WIA**, atau **software scan yang kamu pakai gak connect ke device dengan benar**.

---

## 🔎 Rangkuman Diagnosis Saat Ini:

| Komponen                                  | Status |
| ----------------------------------------- | ------ |
| Canon terdeteksi di Device Manager        | ✅      |
| Scanner error “No Device Found” saat scan | ❌      |
| Folder TWAIN `brims15a` sudah ketahuan    | ✅      |
| Driver Canon aktif tapi gak bisa scan     | ❌      |

---

## ✅ Solusi Lanjut: Fix Driver TWAIN Canon

Canon 3010C (kemungkinan besar seri **Canon DR-3010C**) pakai driver khusus yang **bukan WIA standar Windows**.

---

### ✳️ Langkah 1: Download & Install Ulang Driver Canon DR-3010C

1. Buka link:
   👉 [https://www.canon-asia.com/support](https://www.canon-asia.com/support)

2. Cari: **Canon DR-3010C**

3. Download:

   * **ISIS / TWAIN Driver** (penting!)
   * **CaptureOnTouch / Canon DR ToolBox** (software scanning Canon)

4. Install semuanya

5. Restart komputer

---

### ✳️ Langkah 2: Scan Pakai Aplikasi Canon Sendiri

**Jangan langsung scan dari app biasa** (Paint, Scan bawaan Windows), tapi pakai:

* **Canon CaptureOnTouch**
* atau **Canon DR ToolBox**

Kenapa? Karena:

> Canon DR-series kayak 3010C sering gak kebaca di scanner generic, tapi kebaca sempurna via software resminya.

---

### ✳️ Langkah 3: Cek TWAIN Source Valid

Coba install app bernama **NAPS2** (gratis, open-source, ringan):
[https://www.naps2.com/](https://www.naps2.com/)

1. Buka NAPS2
2. Klik `Scan > Select Source`
3. Kalau Canon 3010C muncul, berarti drivernya udah OK

Kalau masih gak muncul:

* Ada kemungkinan TWAIN registry-nya masih broken
* Atau driver TWAIN Canon-nya belum nyangkut bener

---

### ✳️ Langkah 4: Reset Registry TWAIN Canon (Advanced)

1. Buka Registry Editor → `regedit`
2. Pergi ke:

   ```
   HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\TWAIN\Source
   ```

   atau

   ```
   HKEY_LOCAL_MACHINE\SOFTWARE\TWAIN\Source
   ```
3. Harusnya ada folder dengan nama Canon, misalnya `Canon DR-3010C`
4. Pastikan **hanya folder Canon aktif di situ**
5. Kalau masih ada folder TWADS / brims15a / Brother, **hapus aja**

---

### 🔁 Terakhir: Restart Komputer

---

Kalau masih belum bisa juga, kirim:

* Nama software yang kamu pakai buat scan
* Versi Windows kamu (10/11?)
* Screenshot kalau perlu dari Device Manager & error scan-nya

Biar gw bantu debug-in lebih lanjut atau buatin **script pembersih total + install ulang Canon**. Ready?
