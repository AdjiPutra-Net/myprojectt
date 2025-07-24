Berikut ini adalah **daftar perintah Git yang paling umum** digunakan, lengkap dengan **tujuannya masing-masing**, biar gampang dipahami dan nggak bikin mumet:

---

## 🔧 **Konfigurasi Awal Git**

| Perintah                                             | Tujuan                                     |
| ---------------------------------------------------- | ------------------------------------------ |
| `git config --global user.name "Nama"`               | Mengatur nama pengguna untuk semua repo.   |
| `git config --global user.email "email@example.com"` | Mengatur email pengguna untuk semua repo.  |
| `git config --list`                                  | Melihat konfigurasi Git yang sedang aktif. |

---

## 📁 **Inisialisasi & Clone Repo**

| Perintah          | Tujuan                                                      |
| ----------------- | ----------------------------------------------------------- |
| `git init`        | Membuat repo Git baru di folder lokal.                      |
| `git clone <url>` | Mengkloning repo dari GitHub atau server Git lain ke lokal. |

---

## 🔍 **Status & Log**

| Perintah            | Tujuan                                                    |
| ------------------- | --------------------------------------------------------- |
| `git status`        | Melihat status file (diubah, staged, belum ditrack, dll). |
| `git log`           | Melihat riwayat commit.                                   |
| `git log --oneline` | Riwayat commit ringkas, 1 baris per commit.               |
| `git diff`          | Menampilkan perbedaan isi file yang diubah.               |

---

## 📂 **Menambahkan & Commit Perubahan**

| Perintah                 | Tujuan                                                                        |
| ------------------------ | ----------------------------------------------------------------------------- |
| `git add <file>`         | Menambahkan file ke staging area.                                             |
| `git add .`              | Menambahkan semua perubahan ke staging area.                                  |
| `git commit -m "pesan"`  | Commit perubahan dengan pesan tertentu.                                       |
| `git commit -am "pesan"` | Shortcut untuk add & commit sekaligus (hanya file yang sudah pernah ditrack). |

---

## 🔄 **Sinkronisasi ke/dari Remote Repo**

| Perintah        | Tujuan                                                    |
| --------------- | --------------------------------------------------------- |
| `git remote -v` | Melihat daftar remote repo.                               |
| `git push`      | Mengirim commit lokal ke remote (misal GitHub).           |
| `git pull`      | Mengambil dan menggabungkan update dari remote ke lokal.  |
| `git fetch`     | Mengambil update dari remote tanpa menggabungkannya dulu. |

---

## 🌿 **Branching**

| Perintah                 | Tujuan                                                  |
| ------------------------ | ------------------------------------------------------- |
| `git branch`             | Melihat semua branch lokal.                             |
| `git branch <nama>`      | Membuat branch baru.                                    |
| `git checkout <nama>`    | Pindah ke branch lain.                                  |
| `git checkout -b <nama>` | Buat dan langsung pindah ke branch baru.                |
| `git merge <nama>`       | Menggabungkan branch `<nama>` ke branch aktif saat ini. |
| `git branch -d <nama>`   | Menghapus branch lokal.                                 |

---

## 🧹 **Reset & Revert**

| Perintah                 | Tujuan                                                 |
| ------------------------ | ------------------------------------------------------ |
| `git reset --hard`       | Menghapus semua perubahan lokal (hati-hati!).          |
| `git reset <commit_id>`  | Mengembalikan repo ke commit tertentu.                 |
| `git revert <commit_id>` | Membuat commit baru untuk membatalkan commit tertentu. |

---

## 🗑️ **Menghapus File dari Git**

| Perintah                 | Tujuan                                                                  |
| ------------------------ | ----------------------------------------------------------------------- |
| `git rm <file>`          | Menghapus file dari repo dan staging.                                   |
| `git rm --cached <file>` | Hanya menghapus file dari tracking Git, tapi tetap ada di folder lokal. |

---

## 🔄 **Stash (Simpan Perubahan Sementara)**

| Perintah         | Tujuan                                                     |
| ---------------- | ---------------------------------------------------------- |
| `git stash`      | Menyimpan perubahan sementara dan kembali ke state bersih. |
| `git stash pop`  | Mengembalikan perubahan yang disimpan dan menghapus stash. |
| `git stash list` | Menampilkan daftar stash.                                  |

---

Kalau lo mau, gue juga bisa buatin **versi PDF atau cheatsheet-nya** buat ditempel di dinding biar tinggal liat. Mau?

Yoi, masih **banyak banget** perintah Git lain yang berguna tergantung tingkat lanjutannya. Di bawah ini gue tambahin lagi:

---

## 🧪 **Advanced Branching dan Merging**

| Perintah                      | Tujuan                                                                                                  |
| ----------------------------- | ------------------------------------------------------------------------------------------------------- |
| `git merge --no-ff <branch>`  | Merge dengan commit merge khusus (non fast-forward).                                                    |
| `git cherry-pick <commit_id>` | Mengambil commit tertentu dari branch lain ke branch sekarang.                                          |
| `git rebase <branch>`         | Menggabungkan riwayat dari satu branch ke base branch dengan lebih bersih (hati-hati buat repo publik). |
| `git rebase -i <commit_id>`   | Rebase interaktif untuk edit, reword, squash commit.                                                    |

---

## 🎯 **Tracking & Tagging Versi**

| Perintah                       | Tujuan                                  |
| ------------------------------ | --------------------------------------- |
| `git tag`                      | Melihat semua tag.                      |
| `git tag <nama>`               | Memberi tag di commit sekarang.         |
| `git tag -a <nama> -m "pesan"` | Membuat tag dengan anotasi (ada pesan). |
| `git push origin <tag>`        | Push tag ke remote repo.                |

---

## 🚨 **Undo Perubahan (Lebih Detail)**

| Perintah                 | Tujuan                                                        |
| ------------------------ | ------------------------------------------------------------- |
| `git checkout -- <file>` | Mengembalikan file ke versi terakhir dari commit.             |
| `git reset HEAD <file>`  | Menghapus file dari staging area, tapi nggak hapus perubahan. |
| `git clean -f`           | Menghapus file yang belum pernah ditrack Git.                 |
| `git clean -fd`          | Menghapus file & direktori yang belum ditrack.                |

---

## 🕵️‍♂️ **Cek Riwayat dan Investigasi**

| Perintah                       | Tujuan                                                |
| ------------------------------ | ----------------------------------------------------- |
| `git blame <file>`             | Melihat siapa yang terakhir mengedit tiap baris file. |
| `git show <commit_id>`         | Menampilkan detail dari commit tertentu.              |
| `git diff <commit1> <commit2>` | Perbedaan antara 2 commit.                            |

---

## 🌐 **Remote Lanjutan**

| Perintah                          | Tujuan                                    |
| --------------------------------- | ----------------------------------------- |
| `git remote add origin <url>`     | Menambahkan remote baru bernama `origin`. |
| `git remote rename <lama> <baru>` | Ganti nama remote.                        |
| `git remote remove <nama>`        | Hapus remote.                             |
| `git push -u origin <branch>`     | Push dan set default upstream branch.     |

---

## 🔒 **Credential & SSH**

| Perintah                             | Tujuan                                                                     |
| ------------------------------------ | -------------------------------------------------------------------------- |
| `git config credential.helper store` | Simpan username & password Git di lokal (tidak disarankan untuk keamanan). |
| `ssh-keygen -t ed25519`              | Buat SSH key untuk autentikasi GitHub.                                     |
| `ssh-add ~/.ssh/id_ed25519`          | Tambah SSH key ke agent.                                                   |

---

## 📦 **Submodule (Repo dalam Repo)**

| Perintah                  | Tujuan                                   |
| ------------------------- | ---------------------------------------- |
| `git submodule add <url>` | Menambahkan repo lain sebagai submodule. |
| `git submodule init`      | Inisialisasi submodule.                  |
| `git submodule update`    | Mengambil data submodule.                |

---

## 🧾 **Archive / Export**

| Perintah                                      | Tujuan                                     |
| --------------------------------------------- | ------------------------------------------ |
| `git archive --format zip HEAD > project.zip` | Export repo jadi zip dari commit terakhir. |

---

## 🔍 **Search di Repo**

| Perintah          | Tujuan                             |
| ----------------- | ---------------------------------- |
| `git grep "kata"` | Cari teks tertentu dalam repo Git. |

---

Kalau mau lebih **berstruktur**, gue bisa buatin lo **kategori PDF Cheatsheet Git Lengkap (Basic – Intermediate – Advanced)** atau bahkan versi interaktif Markdown/HTML lokal.

> Mau lanjut ke cheat Git yang dipakai pas kerja tim (CI/CD, Gitflow, dsb) juga bisa bro. Lo pengennya git-nya buat proyek pribadi, buat lomba, atau kerja tim?

Mantap lo semangatnya! 😎 Git emang dalem banget, dan makin dipelajari makin kerasa kerennya. Nih gue kasih lagi **tambahan lanjutan** buat perintah Git yang **jarang diketahui tapi sangat berguna**, cocok banget buat lo yang pengen jadi Git dewa 🧙‍♂️:

---

## 🔬 **Git Bisect (Cari Commit Penyebab Bug)**

| Perintah                   | Tujuan                                          |
| -------------------------- | ----------------------------------------------- |
| `git bisect start`         | Mulai proses pencarian bug pakai binary search. |
| `git bisect bad`           | Tandai commit sekarang sebagai "buggy".         |
| `git bisect good <commit>` | Tandai commit sehat yang diketahui.             |
| `git bisect reset`         | Keluar dari mode bisect.                        |

📝 Gunanya buat nyari commit mana yang pertama kali bikin bug muncul. Otomatis nyari tengah-tengah terus lo disuruh test tiap commit.

---

## 📜 **Git Reflog (Riwayat Semua Aktivitas)**

| Perintah                    | Tujuan                                                                                       |
| --------------------------- | -------------------------------------------------------------------------------------------- |
| `git reflog`                | Melihat semua aktivitas dan perubahan HEAD, termasuk commit yang udah di-reset atau dihapus. |
| `git reset --hard HEAD@{1}` | Balikin ke posisi sebelum commit tertentu.                                                   |
| `git checkout HEAD@{2}`     | Cek commit sebelumnya bahkan setelah dihapus.                                                |

Ini penyelamat kalo lo **ngapus commit penting tanpa sengaja**.

---

## 📚 **Alih Fungsi Branch/Tag**

| Perintah                                 | Tujuan                              |
| ---------------------------------------- | ----------------------------------- |
| `git branch -m <baru>`                   | Rename branch aktif jadi nama baru. |
| `git tag -d <nama_tag>`                  | Hapus tag lokal.                    |
| `git push --delete origin <nama_branch>` | Hapus branch dari remote.           |
| `git push origin :refs/tags/<tag>`       | Hapus tag dari remote.              |

---

## 👥 **Git Collaboration (Multi User Teamwork)**

| Perintah                                        | Tujuan                                  |
| ----------------------------------------------- | --------------------------------------- |
| `git fetch origin pull/<ID>/head:<nama_branch>` | Ambil pull request orang lain ke lokal. |
| `git shortlog -sne`                             | Lihat kontributor repo.                 |
| `git merge --abort`                             | Batalkan proses merge kalau konflik.    |
| `git stash branch <nama_branch>`                | Buat branch dari stash.                 |

---

## 🧪 **Git Worktree (Multiple Checkout dalam 1 Repo)**

| Perintah                                | Tujuan                                   |
| --------------------------------------- | ---------------------------------------- |
| `git worktree add ../dir-lain <branch>` | Checkout branch tertentu ke folder lain. |
| `git worktree list`                     | Lihat semua worktree aktif.              |
| `git worktree remove ../dir-lain`       | Hapus worktree.                          |

⚙️ Cocok buat ngerjain beberapa fitur di branch berbeda tanpa clone repo berulang.

---

## 💻 **Git Hooks (Otomatisasi Lokal)**

| Perintah                | Tujuan                                 |
| ----------------------- | -------------------------------------- |
| `.git/hooks/pre-commit` | Script yang dijalankan sebelum commit. |
| `.git/hooks/post-merge` | Script yang dijalankan setelah merge.  |

🧠 Bisa dipakai buat auto-format code, jalanin test, dll **sebelum commit diproses.**

---

## 🔄 **Tracking File Secara Spesifik**

| Perintah                                        | Tujuan                                           |
| ----------------------------------------------- | ------------------------------------------------ |
| `git update-index --assume-unchanged <file>`    | Git bakal anggap file itu gak berubah (abaikan). |
| `git update-index --no-assume-unchanged <file>` | Balikin ke normal tracking.                      |

Cocok buat file `.env` atau konfigurasi lokal yang beda tiap orang.

---

## 🔐 **GPG Signing**

| Perintah                                  | Tujuan                           |
| ----------------------------------------- | -------------------------------- |
| `git config --global commit.gpgsign true` | Semua commit ditandatangani GPG. |
| `git commit -S -m "pesan"`                | Commit pakai signature GPG.      |

Biasanya dipakai buat nge-proof "commit ini beneran dari gue".

---

## 🔗 **Git Aliases (Shortcut Git Sendiri)**

| Perintah                                | Tujuan                                        |
| --------------------------------------- | --------------------------------------------- |
| `git config --global alias.st status`   | Bikin `git st` sebagai shortcut `git status`. |
| `git config --global alias.co checkout` | Bikin `git co` buat checkout.                 |

Bisa lo bikin shortcut biar ngetik gak ribet.

---

Kalau lo mau lebih next-level lagi, kita bisa masuk ke:

* GitHub Actions (otomasi di GitHub)
* Git Flow (alur pengembangan tim besar)
* CI/CD pipeline Git
* Integrasi Git + Docker

---

Kalau setuju, gue buatin lo **file markdown lengkap Git command dengan penjelasan tiap kategori**, tinggal lo export ke PDF atau buka di VS Code. Mau lanjut ke situ?

Siap bro! Nih gue kasih **contoh nyata** dari perintah-perintah Git konfigurasi awal di atas, lengkap sama **penjelasan output-nya biar lo kebayang**.

---

## ✅ 1. `git config --global user.name "Adji Dev"`

🧠 Tujuan: Ngasih tahu Git siapa nama lo yang akan ditampilin di setiap commit.

```bash
git config --global user.name "Adji Dev"
```

📦 Hasil: Git akan menyimpan nama ini secara global (untuk semua repo Git di komputer lo).

---

## ✅ 2. `git config --global user.email "adji@example.com"`

🧠 Tujuan: Ngasih tahu Git email lo yang dipake di setiap commit.

```bash
git config --global user.email "adji@example.com"
```

📦 Hasil: Email ini akan nempel di setiap commit lo (dan jadi identitas lo di GitHub kalau pake HTTPS push).

---

## ✅ 3. `git config --list`

🧠 Tujuan: Nampilin semua konfigurasi Git yang udah diset, baik global maupun lokal.

```bash
git config --list
```

📤 Contoh output:

```
user.name=Adji Dev
user.email=adji@example.com
core.editor=nano
color.ui=auto
```

🎯 Kegunaan:

* Buat ngecek ulang apakah nama & email udah bener.
* Buat ngecek setting-setting Git lainnya.

---

### 🔥 Tambahan Tips:

* Kalau mau liat config **khusus repo tertentu** aja (bukan global), pake:

```bash
git config user.name
git config user.email
```

Kalau belum diset secara lokal, dia bakal ngambil dari config global.

---

Kalau mau gue buatin versi markdown tabel + contoh output gini semua biar bisa lo simpen di catatan pribadi lo atau Google Docs, tinggal bilang. Mau lanjut?

Mantap, yuk langsung gue kasih **contoh nyata** dari perintah `git init` dan `git clone <url>`, biar makin ngerti kegunaannya gimana di dunia nyata.

---

## ✅ 1. `git init`

🧠 **Tujuan:** Bikin repository Git baru dari **folder lokal yang belum terhubung ke Git**.

### 🔧 Langkah Contoh:

```bash
mkdir belajar-git
cd belajar-git
git init
```

### 📤 Output:

```
Initialized empty Git repository in /home/adji/belajar-git/.git/
```

🎯 Artinya: Folder `belajar-git` sekarang udah jadi repo Git. Lo bisa mulai `git add`, `git commit`, dan lain-lain.

---

## ✅ 2. `git clone <url>`

🧠 **Tujuan:** Mengkloning repository Git yang udah ada dari internet (misalnya GitHub) ke komputer lokal lo.

### 🌐 Contoh:

```bash
git clone https://github.com/githubtraining/hellogitworld.git
```

### 📤 Output:

```
Cloning into 'hellogitworld'...
remote: Enumerating objects: 42, done.
remote: Total 42 (delta 0), reused 0 (delta 0), pack-reused 42
Unpacking objects: 100% (42/42), done.
```

🗂️ Setelah clone:

* Akan muncul folder `hellogitworld` di direktori kerja lo.
* Di dalamnya sudah ada `.git`, file-file repo, dan bisa langsung `cd hellogitworld` lalu `git log`, `git status`, dll.

---

### 🔥 Tips Tambahan:

| Kebutuhan                              | Perintah                                      |
| -------------------------------------- | --------------------------------------------- |
| Clone dan langsung ubah nama foldernya | `git clone <url> nama-folder-baru`            |
| Clone via SSH (butuh SSH key)          | `git clone git@github.com:user/repo.git`      |
| Clone hanya 1 branch tertentu          | `git clone -b <branch> --single-branch <url>` |

---

Mau lanjut ke contoh perintah `git status`, `git add`, dan `git commit` juga? Biar lo bisa simulasiin full siklus Git dari awal sampai commit.

Siap bro! Nih gue kasih **contoh lengkap & realistik** buat perintah:

```
git status  
git log  
git log --oneline  
git diff
```

---

## ✅ 1. `git status`

🧠 **Tujuan:** Buat ngecek kondisi file di repo lokal lo.

### 🔧 Contoh Situasi:

Lo baru aja edit file `index.html`, tapi belum di-*add* ke staging.

```bash
git status
```

### 📤 Output:

```
On branch main
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
	modified:   index.html
```

🎯 Artinya: `index.html` udah lo ubah, tapi belum di-*add*.

---

## ✅ 2. `git log`

🧠 **Tujuan:** Liat daftar commit beserta info lengkap.

```bash
git log
```

### 📤 Output:

```
commit a3b1c2d3e4f5g6h7i8j9k0
Author: Adji Dev <adji@example.com>
Date:   Thu Jul 17 09:00 2025 +0700

    Tambah fitur login

commit 9z8y7x6w5v4u3t2s1r0q
Author: Adji Dev <adji@example.com>
Date:   Wed Jul 16 13:30 2025 +0700

    Inisialisasi project
```

🎯 Bisa scroll ke atas/bawah pake panah. Ketik `q` buat keluar tampilan.

---

## ✅ 3. `git log --oneline`

🧠 **Tujuan:** Liat log versi ringkas.

```bash
git log --oneline
```

### 📤 Output:

```
a3b1c2d Tambah fitur login
9z8y7x6 Inisialisasi project
```

🎯 Enak dipake buat liat history dengan cepat, cocok juga buat `git rebase -i`.

---

## ✅ 4. `git diff`

🧠 **Tujuan:** Bandingin perubahan yang belum di-*stage*.

### 🔧 Contoh:

Lo ngedit file `index.html` tapi belum di-*add*.

```bash
git diff
```

### 📤 Output (misal):

```diff
diff --git a/index.html b/index.html
index 9dabc12..b134a9c 100644
--- a/index.html
+++ b/index.html
@@ -5,6 +5,7 @@
   <title>Website</title>
 </head>
 <body>
+  <h1>Halo Dunia!</h1>
 </body>
</html>
```

🎯 Lo bisa liat baris mana aja yang ditambahin (+) atau dikurangin (-).

---

Mau gue buatin juga **simulasi nyata dari status → add → commit → log** lengkap? Atau mau next ke `git add`, `git commit`, dan `git push` sekalian?

Sip, lanjut terus bro! Sekarang kita bahas **contoh nyata penggunaan perintah `git add`, `git commit`, dan shortcut `-am`**, biar lo makin paham alur commit di Git. Let's gooo! 🚀

---

## ✅ 1. `git add <file>`

🧠 **Tujuan:** Masukin satu file ke *staging area* sebelum di-commit.

### 🔧 Contoh:

Lo udah ngedit `index.html`.

```bash
git add index.html
```

### 📤 Cek dengan:

```bash
git status
```

📤 Output:

```
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	new file:   index.html
```

🎯 Artinya file `index.html` udah siap di-commit.

---

## ✅ 2. `git add .`

🧠 **Tujuan:** Masukin **semua perubahan** (file baru, file yang diubah, file dihapus) ke *staging area*.

### 🔧 Contoh:

Lo ngedit banyak file (`index.html`, `style.css`, `app.js`).

```bash
git add .
```

🎯 Gampangin hidup, cocok pas kerja banyak file sekaligus.

---

## ✅ 3. `git commit -m "pesan"`

🧠 **Tujuan:** Ngelakuin commit terhadap file yang udah di-*add*, dengan pesan deskriptif.

### 🔧 Contoh:

```bash
git commit -m "Tambah tampilan homepage"
```

📤 Output:

```
[main a12b3cd] Tambah tampilan homepage
 3 files changed, 20 insertions(+)
```

🎯 Commit ini bakal masuk ke log history Git.

---

## ✅ 4. `git commit -am "pesan"`

🧠 **Tujuan:** Shortcut buat *add + commit* sekaligus, **hanya untuk file yang sudah pernah ditrack sebelumnya.**

### 🔧 Contoh:

Lo ngedit `style.css` (file yang udah pernah di-commit sebelumnya), lalu langsung commit:

```bash
git commit -am "Update warna tombol"
```

📤 Output:

```
[main d45f6gh] Update warna tombol
 1 file changed, 5 insertions(+), 2 deletions(-)
```

🛑 **Catatan Penting:**
Perintah `-am` **nggak akan nge-add file baru**. Jadi kalau lo buat file baru `script.js`, lo **tetep harus** `git add script.js` dulu.

---

Mau lanjut ke `git push`, `git pull`, dan `git remote`? Atau mau gue buatin alur **simulasi kerja tim Git lengkap (clone → edit → commit → push → pull request)**?

Gaskeun bro! Nih gue kasih contoh praktikal dari perintah remote Git `git remote -v`, `git push`, `git pull`, dan `git fetch` biar lo ngerti alurnya pas kerja sama GitHub atau server Git lainnya. 🔥

---

## ✅ 1. `git remote -v`

🧠 **Tujuan:** Ngecek daftar remote repo (biasanya `origin`) yang terhubung ke repo lokal lo.

### 🔧 Contoh:

```bash
git remote -v
```

📤 Output:

```
origin  https://github.com/adji-dev/belajar-git.git (fetch)
origin  https://github.com/adji-dev/belajar-git.git (push)
```

🎯 Artinya:

* `origin` = alias untuk remote GitHub.
* `fetch` = buat narik data.
* `push` = buat ngirim data.

---

## ✅ 2. `git push`

🧠 **Tujuan:** Ngirim commit dari lokal ke repo remote (GitHub, GitLab, dll).

### 🔧 Contoh:

```bash
git push origin main
```

📤 Output:

```
Enumerating objects: 7, done.
Counting objects: 100% (7/7), done.
Delta compression using up to 4 threads
Compressing objects: 100% (5/5), done.
Writing objects: 100% (7/7), 3.21 KiB | 3.21 MiB/s, done.
To https://github.com/adji-dev/belajar-git.git
   1234567..89abcde  main -> main
```

🎯 Commit terbaru lo sekarang **udah ada di GitHub.**

---

## ✅ 3. `git pull`

🧠 **Tujuan:** Narik dan langsung **gabungin** (merge) update terbaru dari remote ke lokal.

### 🔧 Contoh:

```bash
git pull origin main
```

📤 Output:

```
From https://github.com/adji-dev/belajar-git
 * branch            main       -> FETCH_HEAD
Updating 1234567..89abcde
Fast-forward
 index.html | 2 ++
 1 file changed, 2 insertions(+)
```

🎯 Lo sekarang udah sinkron sama repo GitHub terbaru.

---

## ✅ 4. `git fetch`

🧠 **Tujuan:** Cuma **narik perubahan dari remote**, tapi **belum digabungin** ke branch lo.

### 🔧 Contoh:

```bash
git fetch origin
```

📤 Output:

```
From https://github.com/adji-dev/belajar-git
 * [new branch]      feature-login -> origin/feature-login
```

🎯 Lo bisa cek branch/commit baru dulu **tanpa langsung merge**, cocok buat nge-review dulu sebelum digabung.

---

### ⚠️ Bedanya `git pull` vs `git fetch`:

| Perintah    | Narik Data | Gabungin Langsung | Cocok Buat                |
| ----------- | ---------- | ----------------- | ------------------------- |
| `git pull`  | ✅          | ✅                 | Biasa dipake sehari-hari. |
| `git fetch` | ✅          | ❌                 | Kalo mau ngecek dulu.     |

---

Mau lanjut ke contoh `git branch`, `checkout`, dan `merge` biar ngerti cara kerjain fitur beda-beda kayak tim profesional?

Sip bro! Ini dia **contoh real** dan alur penggunaan semua perintah branch di Git yang lo tulis. Gampang banget kalau udah dipraktikkin step by step. 🧠⚙️

---

## ✅ 1. `git branch`

🧠 **Tujuan:** Lihat semua branch lokal dan mana yang lagi aktif.

### 🔧 Contoh:

```bash
git branch
```

📤 Output:

```
* main
  fitur-login
```

🎯 Tanda `*` nunjukin lo lagi di branch `main`.

---

## ✅ 2. `git branch fitur-about`

🧠 **Tujuan:** Bikin branch baru bernama `fitur-about`.

```bash
git branch fitur-about
```

📤 Output (kalau dicek lagi pakai `git branch`):

```
* main
  fitur-about
  fitur-login
```

🎯 Branch `fitur-about` udah ada, tapi lo **belum pindah ke situ**.

---

## ✅ 3. `git checkout fitur-about`

🧠 **Tujuan:** Pindah ke branch `fitur-about`.

```bash
git checkout fitur-about
```

📤 Output:

```
Switched to branch 'fitur-about'
```

🎯 Sekarang lo bisa kerja di fitur berbeda tanpa ngubah branch utama (`main`).

---

## ✅ 4. `git checkout -b fitur-dashboard`

🧠 **Tujuan:** Buat branch `fitur-dashboard` **dan langsung pindah ke situ.**

```bash
git checkout -b fitur-dashboard
```

📤 Output:

```
Switched to a new branch 'fitur-dashboard'
```

🎯 Hemat waktu dibanding bikin dulu lalu checkout.

---

## ✅ 5. `git merge fitur-about`

🧠 **Tujuan:** Gabungin perubahan dari `fitur-about` ke branch aktif (misalnya `main`).

### 🔧 Langkah:

1. Pindah ke branch `main` dulu:

```bash
git checkout main
```

2. Lalu merge:

```bash
git merge fitur-about
```

📤 Output:

```
Updating 123abc..456def
Fast-forward
 about.html | 15 +++++++++++++++
```

🎯 Perubahan dari `fitur-about` udah masuk ke `main`.

---

## ✅ 6. `git branch -d fitur-about`

🧠 **Tujuan:** Hapus branch `fitur-about` setelah udah di-merge.

```bash
git branch -d fitur-about
```

📤 Output:

```
Deleted branch fitur-about (was 456def).
```

🎯 Bersih-bersih branch biar repo gak ruwet.

---

### 🔥 Tips Bonus:

* `git branch -D <nama>` = **force delete**, bahkan kalau belum di-merge.
* Buat workflow kerja tim: setiap fitur dikerjain di branch sendiri, terus digabung ke `main` lewat merge/pull request.

---

Mau lanjut ke contoh konflik saat merge + cara nyelesainnya? Atau lanjut ke rebase & cherry-pick buat yang pengen lebih advance?

Berikut contoh penggunaan semua perintah di tabel yang kamu kasih, biar makin jelas:

---

### 🔄 `git reset --hard`

**Tujuan:** Menghapus semua perubahan lokal, baik yang sudah di-*stage* maupun belum (⚠️ hati-hati, tidak bisa dibatalkan).

```bash
git reset --hard
```

Contoh situasi: Kamu udah ngedit beberapa file, tapi pengin balikin semuanya ke kondisi commit terakhir.

---

### 🔙 `git reset <commit_id>`

**Tujuan:** Balikin repo ke commit tertentu (bisa tetap nyimpen perubahan atau langsung ngapus tergantung opsinya).

```bash
git log --oneline
# misal hasil: a1b2c3d Update file index.html
git reset a1b2c3d
```

Ini akan balikin HEAD ke commit itu, tapi perubahan setelahnya tetap ada di working directory.

Kalau mau sekalian bersih:

```bash
git reset --hard a1b2c3d
```

---

### ♻️ `git revert <commit_id>`

**Tujuan:** Membuat *commit baru* yang membatalkan perubahan dari commit tertentu, tanpa menghapus riwayat.

```bash
git log --oneline
# misal hasil: f6e7d8a Fix typo in README
git revert f6e7d8a
```

Git akan membuka editor teks buat kamu tulis pesan commit baru, atau bisa juga langsung:

```bash
git revert -m "Balikin perubahan typo"
```

---

Kalau ada perintah git lainnya yang mau dijelasin + dicontohin, tinggal bilang aja cuy!

Berikut contoh penggunaan perintah `git rm` dan `git rm --cached` biar lo makin paham:

---

### 🗑️ `git rm <file>`

**Tujuan:** Menghapus file dari repository dan juga dari folder lokal.

```bash
git rm secret.txt
git commit -m "Hapus file secret.txt dari repo"
```

📌 **Hasil:**

* File `secret.txt` bakal **hilang dari folder lo**.
* Git akan mencatat penghapusan itu dalam commit.

---

### 🗂️ `git rm --cached <file>`

**Tujuan:** Cuma ngilangin file dari tracking Git, **tanpa hapus dari folder lokal**.

```bash
git rm --cached .env
git commit -m "Stop tracking file .env (tetap di lokal)"
```

📌 **Hasil:**

* File `.env` **masih ada di komputermu**, tapi Git nggak bakal track lagi.
* Cocok banget buat file sensitif atau config lokal.

📌 Biasanya diikuti sama masukin file itu ke `.gitignore`:

```
echo ".env" >> .gitignore
```

---

Kalau lo punya file yang nggak sengaja ke-*push* terus mau lo *untrack*, `git rm --cached` ini solusinya 🔥
Kalau masih bingung kapan make yang mana, tinggal bilang aja!

Berikut contoh penggunaan perintah `git stash`, `git stash pop`, dan `git stash list` secara praktis:

---

### 🧳 `git stash`

**Tujuan:** Menyimpan perubahan sementara saat lo belum siap commit, biar bisa pindah branch atau pull dulu tanpa kehilangan perubahan.

```bash
git stash
```

📌 **Hasil:**

* Semua perubahan di-*stash* (disimpan sementara).
* Workspace balik ke keadaan bersih (seperti terakhir commit).
* Cocok kalo lagi ngoding tapi harus pindah branch dulu.

---

### 📜 `git stash list`

**Tujuan:** Melihat semua perubahan yang udah distash.

```bash
git stash list
```

📌 **Contoh output:**

```
stash@{0}: WIP on main: 3f2e8c2 tambah fitur login
stash@{1}: WIP on main: 8c8ab33 styling homepage
```

---

### ♻️ `git stash pop`

**Tujuan:** Mengembalikan perubahan yang tadi distash, lalu langsung hapus dari daftar stash.

```bash
git stash pop
```

📌 **Hasil:**

* Perubahan kembali ke workspace lo.
* Entry stash otomatis dihapus.

Kalau lo pengen ngembaliin tanpa hapus stash, bisa pakai:

```bash
git stash apply
```

---

### 🔥 Contoh alur kerja full

```bash
# Lagi ngoding, tapi mau pindah branch
git stash

# Pindah branch buat benerin bug
git checkout hotfix/login-bug

# Balik lagi ke branch utama
git checkout main

# Balikin perubahan yang tadi distash
git stash pop
```

---

Kalau lo mau hapus semua stash yang udah ga kepake:

```bash
git stash clear
```

But careful ya, karena itu permanen.
Kalau mau contoh kasus real-life lainnya, tinggal bilang!

Berikut contoh-contoh penggunaan dari perintah `git merge --no-ff`, `git cherry-pick`, `git rebase`, dan `git rebase -i`:

---

### 🔀 `git merge --no-ff <branch>`

**Tujuan:** Melakukan merge dan tetap membuat commit merge (meskipun bisa fast-forward), supaya histori tetap jelas.

#### Contoh:

```bash
git checkout main
git merge --no-ff fitur-login
```

📌 **Hasil:**

* Branch `fitur-login` digabung ke `main`.
* Tetap membuat commit merge walau sebenarnya bisa fast-forward.
* Histori lebih terstruktur, apalagi kalau pakai Pull Request.

---

### 🍒 `git cherry-pick <commit_id>`

**Tujuan:** Mengambil commit tertentu dari branch lain dan menerapkannya di branch saat ini.

#### Contoh:

```bash
git checkout main
git cherry-pick a1b2c3d
```

📌 **Hasil:**

* Commit dengan ID `a1b2c3d` dari branch lain diaplikasikan ke `main`.
* Commit baru dibuat, tapi isi dan pesan commit tetap sama.

---

### ♻️ `git rebase <branch>`

**Tujuan:** Menggabungkan perubahan dari satu branch ke branch lain dengan cara menyusun ulang riwayat commit.

#### Contoh:

```bash
git checkout fitur-login
git rebase main
```

📌 **Hasil:**

* Commit di `fitur-login` akan “ditaruh ulang” di atas commit terakhir di `main`.
* Hasil akhir lebih linear dan bersih, cocok buat repo pribadi.

⚠️ Jangan lakukan ini di branch yang udah dishare orang lain ya (bisa bikin konflik versi).

---

### 🧠 `git rebase -i <commit_id>`

**Tujuan:** Rebase interaktif buat edit, reword (ubah pesan), squash (gabung commit), drop (hapus commit), dll.

#### Contoh:

```bash
git rebase -i HEAD~3
```

📌 **Langkah:**

* Akan muncul editor seperti ini:

```
pick a1b2c3d tambah login
pick d4e5f6g fix bug kecil
pick h7i8j9k ubah UI

# Ganti jadi:
pick a1b2c3d tambah login
squash d4e5f6g fix bug kecil
reword h7i8j9k ubah UI
```

* Simpan & keluar, lalu ubah pesan commit yang digabung jika perlu.

📌 **Hasil:**

* Commit digabung dan disederhanakan.
* Histori lebih rapih dan profesional.

---

Kalau mau, gue bisa buatin simulasi diagram git-nya juga (sebelum & sesudah). Mau?

Berikut contoh penggunaan semua perintah Git terkait **tag** di tabel kamu:

---

### 1. `git tag`

**Melihat semua tag yang ada di repo lokal.**

```bash
git tag
```

**Output (contoh):**

```
v1.0
v1.1
v2.0
```

---

### 2. `git tag <nama>`

**Memberikan tag ke commit HEAD (commit terakhir).**

```bash
git tag v3.0
```

> Sekarang HEAD akan punya tag `v3.0`.

---

### 3. `git tag -a <nama> -m "pesan"`

**Membuat tag dengan anotasi (ada pesan keterangan).**

```bash
git tag -a v3.1 -m "Rilis versi 3.1 dengan fitur baru"
```

> Tag `v3.1` dibuat dengan pesan anotasi.

---

### 4. `git push origin <tag>`

**Mendorong tag tertentu ke remote repo (GitHub, GitLab, dsb).**

```bash
git push origin v3.1
```

> Tag `v3.1` sekarang ada di remote.

---

Kalau mau dorong **semua tag sekaligus**:

```bash
git push origin --tags
```

Butuh bantuan lanjut tentang hapus tag atau tagging commit lama?

Berikut contoh penggunaan semua perintah Git di tabel kamu tentang **pemulihan file & pembersihan repo**:

---

### 1. `git checkout -- <file>`

**Ngembalikan file ke versi terakhir dari commit (discard perubahan lokal).**

```bash
git checkout -- index.html
```

> File `index.html` dikembalikan ke isi terakhir dari commit. Perubahan lokal hilang.

---

### 2. `git reset HEAD <file>`

**Ngebatalin `git add` terhadap file, tapi perubahan tetap ada (unstage).**

```bash
git add style.css     # kamu tambahkan ke staging
git reset HEAD style.css
```

> File `style.css` jadi unstaged, tapi perubahanmu tetap ada di file.

---

### 3. `git clean -f`

**Hapus semua file yang gak pernah ditrack Git (misal file build, log).**

```bash
git clean -f
```

> Semua file yang belum pernah di-`git add` (dan gak di-`.gitignore`) akan dihapus.

---

### 4. `git clean -fd`

**Hapus file *dan* direktori yang belum pernah ditrack.**

```bash
git clean -fd
```

> Sama kayak `-f`, tapi direktori juga dihapus (misal folder `dist/`, `temp/`, dll).

---

**⚠️ Peringatan:**
Gunakan `git clean` dengan hati-hati. Coba dulu cek apa aja yang bakal dihapus pakai:

```bash
git clean -nfd
```

Output-nya bakal nunjukin file/folder apa aja yang akan dihapus **tanpa** benar-benar menghapusnya.

Kalau perlu bantuan rollback commit atau hard reset sekalian, tinggal bilang aja!

Berikut contoh penggunaan perintah Git untuk **melihat histori dan perubahan** seperti yang ada di tabel kamu:

---

### 1. `git blame <file>`

**Melihat siapa yang terakhir ngedit setiap baris di file.**

```bash
git blame app.js
```

📌 Output-nya:

```
3e2a91d2 (adji 2024-06-10 10:22:33 +0700  1) const express = require('express');
a8f9c2aa (rafan 2024-07-01 14:11:01 +0700  2) const app = express();
```

> Bisa kelihatan siapa yang terakhir nyentuh tiap baris dan commit ID-nya.

---

### 2. `git show <commit_id>`

**Liat isi dan info commit tertentu (pesan, author, tanggal, perubahan).**

```bash
git show a8f9c2aa
```

📌 Output-nya kira-kira:

```
commit a8f9c2aa...
Author: Rafan <rafan@example.com>
Date:   Mon Jul 1 14:11:01 2024 +0700

    Menambahkan route baru

diff --git a/app.js b/app.js
+ app.get('/about', (req, res) => {
+   res.send('About Page');
+ });
```

---

### 3. `git diff <commit1> <commit2>`

**Bandingin perbedaan antara dua commit.**

```bash
git diff 3e2a91d2 a8f9c2aa
```

📌 Output-nya nunjukin baris yang ditambah, dihapus, atau diubah:

```
- const http = require('http');
+ const express = require('express');
```

---

Kalau kamu pengen **bandingin sama versi sekarang**, bisa juga:

```bash
git diff HEAD~1 HEAD
```

> Ngebandingin commit sebelumnya (`HEAD~1`) dengan commit terbaru (`HEAD`).

Mau lanjut ke `log`, `revert`, atau `stash` juga bisa kalau kamu lagi bahas histori!

Berikut contoh penggunaan dari perintah-perintah Git remote yang kamu kasih:

---

### 1. `git remote add origin <url>`

**Menambahkan remote baru bernama `origin` ke repo lokal kamu.**

```bash
git remote add origin https://github.com/adji/project-gue.git
```

📌 Cek hasilnya:

```bash
git remote -v
```

Output:

```
origin  https://github.com/adji/project-gue.git (fetch)
origin  https://github.com/adji/project-gue.git (push)
```

---

### 2. `git remote rename <lama> <baru>`

**Ganti nama remote, misalnya dari `origin` jadi `mainrepo`.**

```bash
git remote rename origin mainrepo
```

📌 Cek hasilnya lagi:

```bash
git remote -v
```

Output:

```
mainrepo  https://github.com/adji/project-gue.git (fetch)
mainrepo  https://github.com/adji/project-gue.git (push)
```

---

### 3. `git remote remove <nama>`

**Hapus remote yang udah ada, misalnya `mainrepo`.**

```bash
git remote remove mainrepo
```

📌 Cek:

```bash
git remote -v
```

Output: kosong
👉 Menandakan remotenya udah dihapus.

---

### 4. `git push -u origin <branch>`

**Push branch kamu pertama kali ke remote dan set upstream-nya.**

Misal kamu punya branch `main` dan mau push ke `origin`:

```bash
git push -u origin main
```

📌 Tujuan `-u` (`--set-upstream`) itu biar next time kamu tinggal `git push` aja tanpa nulis lagi `origin main`.

---

Kalau kamu lagi ngatur remote pertama kali, biasanya urutannya kayak gini:

```bash
git init
git add .
git commit -m "first commit"
git remote add origin https://github.com/adji/project-gue.git
git branch -M main
git push -u origin main
```

Mau lanjut ke `fetch`, `pull`, atau `clone` juga bisa lanjut di topik ini.

Berikut contoh implementasi dari perintah-perintah tersebut:

---

### 🔐 `git config credential.helper store`

**Tujuan:** Menyimpan username & password Git secara permanen di lokal (⚠️ tidak aman jika pakai HTTPS).

**Contoh penggunaan:**

```bash
git config --global credential.helper store
```

Lalu saat kamu push ke GitHub, Git akan minta username & password sekali, dan akan menyimpannya di:

```bash
~/.git-credentials
```

---

### 🔐 `ssh-keygen -t ed25519`

**Tujuan:** Membuat SSH key untuk koneksi GitHub (lebih aman daripada HTTPS).

**Contoh penggunaan:**

```bash
ssh-keygen -t ed25519 -C "emailkamu@example.com"
```

**Penjelasan:**

* `-t ed25519` → jenis algoritma yang direkomendasikan.
* `-C` → komentar atau email agar lebih mudah dikenali.

Lalu akan muncul prompt seperti:

```
Enter file in which to save the key (/home/kamu/.ssh/id_ed25519): [ENTER]
Enter passphrase (empty for no passphrase): [ENTER]
```

Key akan tersimpan di:

* **Public key:** `~/.ssh/id_ed25519.pub`
* **Private key:** `~/.ssh/id_ed25519`

---

### 🔐 `ssh-add ~/.ssh/id_ed25519`

**Tujuan:** Menambahkan SSH key ke SSH agent agar Git bisa pakai untuk login ke GitHub otomatis.

**Langkah-langkah:**

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

**Output:**

```
Identity added: /home/kamu/.ssh/id_ed25519
```

---

Kalau kamu butuh bantuin juga untuk **menambahkan public key ke GitHub**, bilang aja ya!

Berikut ini contoh penggunaan perintah `git submodule` lengkap step-by-step biar makin paham:

---

### 1. 🧩 `git submodule add <url>`

**Tujuan:** Menambahkan repositori lain sebagai **submodule** ke dalam repo utama.

**Contoh:**

```bash
git submodule add https://github.com/octocat/Hello-World.git modules/hello
```

**Penjelasan:**

* `https://github.com/octocat/Hello-World.git` → URL repo yang ingin ditambahkan.
* `modules/hello` → folder tempat submodule akan ditempatkan di repo kita.

Setelah dijalankan:

* Akan muncul folder `modules/hello`
* File `.gitmodules` otomatis dibuat

---

### 2. ⚙️ `git submodule init`

**Tujuan:** Menginisialisasi submodule, biasanya digunakan setelah clone repo yang punya submodule.

**Contoh:**

```bash
git submodule init
```

**Catatan:** Perintah ini akan membaca file `.gitmodules` dan menyiapkan konfigurasi submodule di repo lokal kamu.

---

### 3. 📥 `git submodule update`

**Tujuan:** Mengunduh isi dari submodule sesuai commit yang direferensikan.

**Contoh:**

```bash
git submodule update
```

**Catatan tambahan:**
Jika kamu baru clone repo yang punya submodule, gunakan dua perintah ini langsung:

```bash
git submodule init
git submodule update
```

Atau disingkat jadi satu baris:

```bash
git submodule update --init --recursive
```

---

Kalau kamu butuh contoh real pakai submodule untuk proyek kamu (misal gabungin beberapa tools GitHub ke satu repo), tinggal bilang, nanti gw buatin.

Berikut contoh penggunaan perintah:

---

### 📦 `git archive --format zip HEAD > project.zip`

**Tujuan:** Mengekspor isi *working directory* dari **commit terakhir (HEAD)** ke dalam file ZIP.

---

### ✅ **Contoh Langkah Pemakaian:**

1. Pastikan kamu sedang berada di direktori repo Git:

   ```bash
   cd ~/projekku
   ```

2. Jalankan perintah:

   ```bash
   git archive --format zip HEAD > project.zip
   ```

3. Hasilnya:

   * File `project.zip` akan muncul di folder tersebut.
   * Isinya adalah snapshot repo kamu pada **commit terakhir (HEAD)**.
   * File Git tersembunyi (`.git`) **tidak ikut** ke-zip.

---

### 💡 Tips:

* Kalau mau nge-zip **commit tertentu**, bisa gini:

  ```bash
  git archive --format=zip <commit-id> > nama.zip
  ```

  Contoh:

  ```bash
  git archive --format=zip 7d9a8fc > versi-lama.zip
  ```

* Kalau mau nge-zip cuma 1 folder dari repo:

  ```bash
  git archive --format zip HEAD folderku/ > folderku.zip
  ```

---

Kalau kamu butuh script otomatis zip-in semua branch atau versi tertentu, tinggal bilang aja bro.

Berikut contoh penggunaan `git grep`:

---

### 🔍 `git grep "kata"`

**Tujuan:** Mencari teks tertentu (misalnya `"kata"`) **di semua file dalam repo Git**, termasuk commit terakhir.

---

### ✅ **Contoh Langkah Pemakaian:**

1. Pastikan kamu berada di dalam direktori repo Git:

   ```bash
   cd ~/projekku
   ```

2. Jalankan perintah pencarian:

   ```bash
   git grep "login"
   ```

3. Hasilnya kira-kira seperti ini:

   ```
   src/auth.js:15:const loginUser = async () => {
   views/login.html:8:<h1>Login Page</h1>
   ```

   Artinya:

   * Kata `"login"` ditemukan di file `src/auth.js` baris 15
   * Dan di file `views/login.html` baris 8

---

### 💡 Tips Tambahan:

| Perintah                      | Keterangan                                                  |
| ----------------------------- | ----------------------------------------------------------- |
| `git grep -n "kata"`          | Tampilkan nomor baris hasil pencarian                       |
| `git grep -i "kata"`          | Pencarian case-insensitive (tidak peduli besar kecil huruf) |
| `git grep "kata" HEAD~1`      | Cari di commit sebelumnya                                   |
| `git grep --count "kata"`     | Tampilkan jumlah kemunculan di setiap file                  |
| `git grep "kata" -- '*.html'` | Cari hanya di file tertentu (misalnya HTML)                 |

---

Kalau butuh cari dengan regex juga bisa, tinggal bilang aja bro mau cari yang kayak gimana.

Berikut contoh penggunaan lengkap perintah `git bisect`, step by step buat nyari **commit penyebab bug** pakai metode **binary search**:

---

### 🔧 **Kondisi Awal (Misalnya)**:

Lo lagi debug project dan lo sadar:

* **Versi terbaru (HEAD)** ada bug ➜ ini commit **buruk**.
* **Commit lama tertentu (misal: `a1b2c3d`)** masih normal ➜ ini commit **bagus**.

---

### 💣 1. Mulai proses bisect:

```bash
git bisect start
```

---

### 💢 2. Tandai commit sekarang sebagai "bad" (karena ada bug):

```bash
git bisect bad
```

---

### 💊 3. Tandai commit yang diketahui bagus (normal):

```bash
git bisect good a1b2c3d
```

> `a1b2c3d` diganti dengan SHA commit yang lo yakin belum ada bug-nya.

---

### 🤖 4. Git akan otomatis checkout ke commit di tengah-tengah.

Lo tinggal tes project lo:

* **Kalau ada bug:**

  ```bash
  git bisect bad
  ```
* **Kalau belum ada bug:**

  ```bash
  git bisect good
  ```

Git bakal terus nge-checkout ke commit tengah berikutnya. Lo tinggal ulangi langkah “tes ➜ good / bad” sampai ketemu commit **persis** yang menyebabkan bug.

---

### ✅ 5. Setelah ketemu commit penyebab bug:

```bash
git bisect reset
```

> Ini bakal keluar dari mode `bisect` dan balik ke commit terakhir sebelum bisect.

---

### 💡 Contoh Skenario Real:

Misal:

```bash
git bisect start
git bisect bad                # HEAD (commit sekarang)
git bisect good 3a9d2ef       # Commit lama yang sehat

# Git checkout ke tengah
# Lo tes → ternyata masih bagus
git bisect good

# Git checkout lagi ke commit tengah berikutnya
# Lo tes → ternyata ada bug
git bisect bad

# dan seterusnya...
```

---

Kalau mau, bisa juga **otomatisin proses bisect** pake script test. Tapi itu buat next level. Mau lanjut sampe sana?

Berikut contoh penggunaan dari perintah `git reflog`, `git reset --hard HEAD@{1}`, dan `git checkout HEAD@{2}` lengkap dengan penjelasannya:

---

### 1. `git reflog`

Melihat semua perubahan posisi `HEAD`, termasuk commit yang udah di-*reset* atau dihapus.

```bash
git reflog
```

**Output Contoh:**

```bash
b3c2d2a HEAD@{0}: commit: Fix bug in login feature
f3d4a9e HEAD@{1}: reset: moving to HEAD~1
1f2a4c8 HEAD@{2}: commit: Add login feature
```

---

### 2. `git reset --hard HEAD@{1}`

Balikin kondisi repo ke posisi sebelum commit/reset tertentu.

```bash
git reset --hard HEAD@{1}
```

**Kapan dipakai:**
Misalnya kamu salah `reset --hard` atau `commit`, dan ingin kembali ke posisi sebelumnya.

> ⚠️ Hati-hati! Ini bisa menghapus perubahan lokal permanen jika belum di-*commit*.

---

### 3. `git checkout HEAD@{2}`

Lihat isi repo di titik tertentu di masa lalu (tanpa mengubah branch aktif).

```bash
git checkout HEAD@{2}
```

**Kapan dipakai:**
Untuk cek atau salin file dari posisi HEAD sebelumnya, misalnya sebelum merge/reset.

> Kalau mau balik lagi:

```bash
git checkout main  # atau branch kamu sebelumnya
```

---

Kalau mau, bisa lanjut gue contohin juga skenario real-nya (misal: salah commit terus pengin undo).

Berikut ini contoh penggunaan dari perintah-perintah Git yang lo kasih:

---

### 1. `git branch -m <baru>`

**Rename branch aktif jadi nama baru**

Misalnya lo lagi di branch `fitur-login`, dan mau ganti jadi `login-ui`:

```bash
git branch -m login-ui
```

> Cek nama branch sekarang:

```bash
git branch
```

---

### 2. `git tag -d <nama_tag>`

**Hapus tag lokal**

Misalnya lo punya tag `v1.0` dan mau hapus dari lokal:

```bash
git tag -d v1.0
```

> Cek tag yang ada:

```bash
git tag
```

---

### 3. `git push --delete origin <nama_branch>`

**Hapus branch dari remote GitHub/GitLab**

Misalnya lo mau hapus branch `fitur-login` dari remote:

```bash
git push --delete origin fitur-login
```

> Pastikan branch udah gak dipakai di remote sebelum hapus ya.

---

### 4. `git push origin :refs/tags/<tag>`

**Hapus tag dari remote**

Misalnya mau hapus tag `v1.0` dari remote:

```bash
git push origin :refs/tags/v1.0
```

> Hapus tag remote beda dengan lokal. Yang ini buat remote (GitHub/GitLab).

---

Kalau mau, gue buatin juga studi kasusnya biar makin kebayang. Mau?

Berikut contoh-contoh praktis dari perintah Git yang lo tulis:

---

### 1. `git fetch origin pull/<ID>/head:<nama_branch>`

**Ambil pull request orang lain ke lokal**

Misalnya ada pull request dengan ID `42` di GitHub, dan lo mau ambil isinya ke branch lokal `pr-42`:

```bash
git fetch origin pull/42/head:pr-42
git checkout pr-42
```

> Biasanya dipakai di repo GitHub buat nge-review PR orang lain secara lokal.

---

### 2. `git shortlog -sne`

**Lihat daftar kontributor repo**

```bash
git shortlog -sne
```

Outputnya bakal kayak gini:

```
  25  John Doe <john@example.com>
  10  Jane Smith <jane@example.com>
```

> `-s` = jumlah commit, `-n` = sort, `-e` = tampilkan email

---

### 3. `git merge --abort`

**Batalkan proses merge yang error karena konflik**

Misal lo lagi merge branch `fitur-a` ke `main`:

```bash
git checkout main
git merge fitur-a
```

Eh, ternyata konflik.

Untuk batalin merge:

```bash
git merge --abort
```

> Ini bakal balikin kondisi repo ke sebelum merge dimulai.

---

### 4. `git stash branch <nama_branch>`

**Buat branch dari hasil stash**

Misalnya lo udah `git stash` dan mau buat branch `coba-fix` dari perubahan yang di-stash:

```bash
git stash
git stash branch coba-fix
```

> Git akan buat branch `coba-fix` dan langsung apply stash ke situ, jadi bisa lanjut kerja tanpa ganggu branch utama.

---

Kalau lo mau, gue juga bisa buatin studi kasus nyambung antar perintah di atas.

Berikut contoh penggunaan dari perintah-perintah `git worktree`, lengkap dan gampang dipahami:

---

### 1. `git worktree add ../dir-lain <branch>`

**Checkout branch ke folder lain tanpa ganggu folder utama**

Misalnya lo punya branch `fitur-login`, dan lo pengen kerjain di folder lain:

```bash
git worktree add ../fitur-login fitur-login
```

> Ini akan:

* Membuat folder `../fitur-login`
* Checkout branch `fitur-login` di situ
* Jadi lo bisa coding di `fitur-login` tanpa keluar dari `main` di folder utama

---

### 2. `git worktree list`

**Lihat semua worktree yang aktif saat ini**

```bash
git worktree list
```

Output contoh:

```
/home/lo/project               b1234ab [main]
/home/lo/fitur-login           d4567cd [fitur-login]
```

> Menunjukin semua folder aktif dan branch yang lagi dipakai di tiap worktree.

---

### 3. `git worktree remove ../dir-lain`

**Hapus worktree dari daftar aktif Git**

Setelah lo kelar kerja di `fitur-login`, dan pengen hapus worktree-nya:

```bash
git worktree remove ../fitur-login
```

> Ini *nggak* hapus branch-nya, cuma hapus folder `../fitur-login` dari sistem worktree Git.

---

Kalau perlu gue buatin versi praktis dari alur kerja: buat branch ➜ kerjain di worktree ➜ merge ➜ hapus worktree. Mau?

Berikut contoh penggunaan **Git hooks** di file `.git/hooks/pre-commit` dan `.git/hooks/post-merge`:

---

## 🔧 1. `.git/hooks/pre-commit`

**Tujuan:** Jalankan script sebelum commit dilakukan. Bisa buat cek kode, format, dll.

### Contoh:

```bash
#!/bin/sh
# pre-commit hook: Cegah commit kalau ada file .log

if git diff --cached --name-only | grep '\.log$'; then
  echo "❌ Commit dibatalkan: File .log tidak boleh di-commit."
  exit 1
fi

exit 0
```

**Cara pakai:**

1. Simpan script di `.git/hooks/pre-commit`
2. Kasih permission:

   ```bash
   chmod +x .git/hooks/pre-commit
   ```
3. Coba commit file `.log`, hasilnya commit akan dibatalkan.

---

## 🔧 2. `.git/hooks/post-merge`

**Tujuan:** Otomatis jalankan sesuatu setelah merge selesai. Misalnya install dependency.

### Contoh:

```bash
#!/bin/sh
# post-merge hook: Jalankan npm install setelah merge

if [ -f package.json ]; then
  echo "📦 Menjalankan npm install..."
  npm install
fi
```

**Cara pakai:**

1. Simpan script di `.git/hooks/post-merge`
2. Kasih permission:

   ```bash
   chmod +x .git/hooks/post-merge
   ```
3. Setelah merge, script otomatis jalanin `npm install`.

---

Kalau lo mau versi `Python`, `Bash`, atau misalnya buat auto-push/logging, bisa gue bikinin juga. Mau yang mana?

Berikut contoh penggunaan dua perintah Git ini: `--assume-unchanged` dan `--no-assume-unchanged`.

---

## 🔧 `git update-index --assume-unchanged <file>`

### 📌 Tujuan:

Supaya Git **mengabaikan perubahan** lokal di file tertentu. Cocok kalau kamu edit file konfigurasi lokal tapi nggak mau ikut commit.

### ✅ Contoh:

Misalnya kamu lagi kerja tim dan punya file `config.env` yang isinya beda-beda tiap orang.

```bash
# Misalnya kamu ubah config.env lokal kamu
nano config.env

# Supaya Git ngabaikan perubahan di file ini:
git update-index --assume-unchanged config.env
```

📦 **Hasilnya:**
Walaupun `config.env` kamu ubah, Git nggak bakal nunjukin di `git status`.

---

## 🔄 `git update-index --no-assume-unchanged <file>`

### 📌 Tujuan:

Balikin file ke mode normal: **Git mulai track lagi perubahan** file tersebut.

### ✅ Contoh:

```bash
git update-index --no-assume-unchanged config.env
```

📦 **Hasilnya:**
Sekarang kalau `config.env` kamu ubah lagi, Git akan deteksi seperti biasa.

---

## 🧠 Cek File yang Lagi Diabaikan

```bash
git ls-files -v | grep '^[a-z]'
```

> Huruf kecil di awal (misal `h config.env`) artinya Git anggap file itu **unchanged**.

---

Kalau lo mau pakai trik ini buat file `.env`, `local.config.js`, atau file backup pribadi, ini cocok banget. Mau dibikinin juga alias/shell function-nya biar lebih gampang?

Berikut contoh lengkap cara pakai GPG signature di Git, sesuai dua perintah itu:

---

## 🔐 1. `git config --global commit.gpgsign true`

### 📌 Tujuan:

Semua commit yang kamu buat **otomatis ditandatangani GPG**, tanpa perlu `-S` tiap kali.

### ✅ Contoh:

```bash
git config --global commit.gpgsign true
```

📦 **Hasilnya:**
Semua commit berikutnya akan otomatis memakai tanda tangan GPG, selama Git kamu udah diatur dengan kunci GPG.

> Kalau kamu belum setup GPG di Git, kasih tau aja, nanti gue bantuin dari awal.

---

## ✍️ 2. `git commit -S -m "pesan"`

### 📌 Tujuan:

Commit **dengan tanda tangan GPG** hanya sekali itu saja (manual).

### ✅ Contoh:

```bash
git add file.txt
git commit -S -m "Add file with GPG signature"
```

📦 **Hasilnya:**
Commit ini akan ditandatangani GPG, dan kamu akan lihat tulisan seperti ini di GitHub atau Git log:

```
gpg: Signature made ...
gpg: Good signature from ...
```

---

## 👁️ Cek Signature di Git Log

```bash
git log --show-signature
```

---

Kalau kamu lihat tanda `Verified` di GitHub, berarti commit berhasil ditandatangani dan diverifikasi.

---

Kalau kamu belum punya kunci GPG atau belum connect ke GitHub/Git CLI, mau gue bantu bikinin step-by-step-nya juga?

Berikut contoh pemakaian dua perintah alias Git itu:

---

## 🔧 1. `git config --global alias.st status`

### 📌 Tujuan:

Bikin shortcut `git st` biar lebih cepat dari `git status`.

### ✅ Cara setup:

```bash
git config --global alias.st status
```

### 🧪 Coba:

```bash
git st
```

📦 **Hasilnya:**
Output-nya sama persis seperti:

```bash
git status
```

---

## 🔧 2. `git config --global alias.co checkout`

### 📌 Tujuan:

Bikin `git co` buat ganti branch, alias shortcut dari `git checkout`.

### ✅ Cara setup:

```bash
git config --global alias.co checkout
```

### 🧪 Coba:

```bash
git co main
```

📦 **Hasilnya:**
Akan berpindah ke branch `main`, sama aja kayak:

```bash
git checkout main
```

---

> ✨ Kamu bisa bikin alias lain juga, misalnya:
>
> ```bash
> git config --global alias.br branch
> git config --global alias.cm commit
> git config --global alias.last 'log -1 HEAD'
> ```

Kalau mau gue buatin list alias Git yang keren dan kepake sehari-hari, tinggal bilang aja ya!
