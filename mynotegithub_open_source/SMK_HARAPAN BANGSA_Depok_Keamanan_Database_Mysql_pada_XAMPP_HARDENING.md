# 🔐 13. Keamanan Database (MYSQL) pada XAMPP<a name="Pengujian Keamanan Database (MYSQL) pada XAMPP"></a>

🧩 Judul Soal:
“Mengamankan Database MySQL pada XAMPP agar Terhindar dari Serangan Umum”

📋 Deskripsi Singkat:
Anda bertugas untuk melakukan hardening pada instalasi MySQL yang berjalan 
di dalam XAMPP pada sistem Ubuntu. Database ini akan digunakan untuk aplikasi 
web dan harus diamankan agar tidak mudah diakses 
oleh pihak yang tidak berwenang.

✅ Instruksi Kasar:
Pastikan XAMPP sudah terpasang dan MySQL berjalan.

Nonaktifkan akses root MySQL dari host selain localhost.

Buat user baru bernama lksuser dengan password yang kuat, dan beri hak akses terbatas hanya pada database lksdb.

Ubah password root MySQL ke password yang kompleks.

Matikan user anonymous di MySQL.

Nonaktifkan fitur remote login root MySQL (jika belum).

Lakukan audit konfigurasi MySQL menggunakan perintah mysql_secure_installation.

Cek apakah port MySQL (3306) hanya terbuka untuk localhost menggunakan firewall.

Buat laporan singkat tentang langkah-langkah hardening yang sudah dilakukan.

## 🧾 14. Pengujian Keamanan Database (MYSQL) pada XAMPP<a name="Pengujian Keamanan Database (MYSQL) pada XAMPP"></a>

---

#### ✅ 1. **Pastikan MySQL di XAMPP sudah berjalan**

```bash
/opt/lampp/lampp startmysql
```

Cek status:

```bash
/opt/lampp/lampp status
```

---

#### ✅ 2. **Nonaktifkan akses root MySQL dari host selain localhost**

Masuk ke MySQL:

```bash
/opt/lampp/bin/mysql -u root
```

Lihat user root:

```sql
SELECT Host, User FROM mysql.user WHERE User='root';
```

Hapus akses root selain `localhost`, jika ada:

```sql
DELETE FROM mysql.user WHERE User='root' AND Host!='localhost';
FLUSH PRIVILEGES;
```

---

#### ✅ 3. **Buat user `lksuser` dengan password kuat dan akses terbatas ke `lksdb`**

Contoh password kuat: `Lks!2025@secure`

Buat database dan user:

```sql
CREATE DATABASE lksdb;
CREATE USER 'lksuser'@'localhost' IDENTIFIED BY 'Lks!2025@secure';
GRANT SELECT, INSERT, UPDATE, DELETE ON lksdb.* TO 'lksuser'@'localhost';
FLUSH PRIVILEGES;
```

---

#### ✅ 4. **Ubah password root ke password kompleks**

Misalnya: `RootXampp@2025#Secure`

```sql
ALTER USER 'root'@'localhost' IDENTIFIED BY 'RootXampp@2025#Secure';
FLUSH PRIVILEGES;
```

---

#### ✅ 5. **Hapus user anonymous**

Cek:

```sql
SELECT User, Host FROM mysql.user WHERE User='';
```

Hapus:

```sql
DELETE FROM mysql.user WHERE User='';
FLUSH PRIVILEGES;
```

---

#### ✅ 6. **Nonaktifkan remote login root MySQL**

Sudah dilakukan pada langkah #2. Untuk memastikan:

```sql
SELECT User, Host FROM mysql.user WHERE User='root';
```

Pastikan hanya ada `localhost`.

---

#### ✅ 7. **Audit konfigurasi menggunakan `mysql_secure_installation`**

Jalankan:

```bash
/opt/lampp/bin/mysql_secure_installation
```

Jawab semua pertanyaan untuk menghapus anonymous user, mengubah password root (boleh skip kalau sudah diubah), menonaktifkan remote login, dan menghapus test database.

---

#### ✅ 8. **Pastikan port 3306 hanya diakses localhost menggunakan `ufw`**

Jika `ufw` belum aktif:

```bash
ufw enable
```

Izinkan hanya localhost:

```bash
ufw allow from 127.0.0.1 to any port 3306
ufw deny 3306
```

Cek aturan:

```bash
ufw status numbered
```

---

## 🧾 15. Hasil Pengujian Keamanan Database (MYSQL) pada XAMPP<a name=" Hasil Pengujian Keamanan Database (MYSQL) pada XAMPP"></a>

#### ✅ 1. Uji: Root hanya bisa login dari localhost:

![Alt Text](image/secure_data4.png)

##### ✅ 2. **Uji: User `lksuser` hanya bisa akses `lksdb`**:

![Alt Text](image/secure_data4.png)

#### ✅ 3. **Uji: Anonymous user sudah dihapus**:

![Alt Text](image/secure_data2.png)

#### ✅ 4. **Uji: Port 3306 hanya terbuka di localhost**

![Alt Text](image/secure_data8.png)

#### ✅ 5. **Cek hasil konfigurasi dari `mysql_secure_installation`**

![Alt Text](image/secure_data9.png)

#### ✅ 6. **Pastikan port 3306 hanya diakses localhost menggunakan `ufw`**

![Alt Text](image/secure_data10.png)

#### ✅ 7. **Audit konfigurasi menggunakan `mysql_secure_installation`**

![Alt Text](image/secure_data6.png)

![Alt Text](image/secure_data7.png)

Error ini:

```
ERROR 1146 (42S02) at line 1: Table 'mysql.global_priv' doesn't exist
```

dan kegagalan saat menghapus anonymous user via `mysql_secure_installation` **terjadi karena kamu sudah menghapus user anonymous secara manual sebelumnya** dengan perintah SQL ini:

```sql
DELETE FROM mysql.user WHERE User='';
FLUSH PRIVILEGES;
```

#### ✅ Kesimpulan

Tidak masalah dan **tidak berbahaya**. Itu hanya menandakan bahwa:

- **Langkah hardening manual kamu sukses.**
    
- karena user anonymous memang sudah **dihapus sebelumnya**.

---

