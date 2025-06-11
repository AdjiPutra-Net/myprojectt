#!/bin/bash

# === 1. Persiapan ===
cd /opt/lampp/htdocs || exit 1
mkdir -p labaman
cd labaman || exit 1

# === 2. db.php ===
cat << 'EOF' > db.php
<?php
$host = "localhost";
$user = "webuser";
$pass = "webpass123";
$db   = "labserangan";

$conn = new mysqli($host, $user, $pass, $db);
if ($conn->connect_error) {
  die("Koneksi gagal: " . $conn->connect_error);
}
?>
EOF

# === 3. login.php (anti SQLi) ===
cat << 'EOF' > login.php
<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);
include "db.php";

$username = $_POST['username'];
$password = $_POST['password'];

$stmt = $conn->prepare("SELECT * FROM users WHERE username = ? AND password = ?");
$stmt->bind_param("ss", $username, $password);
$stmt->execute();
$result = $stmt->get_result();

if ($result && $result->num_rows > 0) {
  echo "<h2 style='color: green;'>✅ Login Berhasil!</h2>";
} else {
  echo "<h2 style='color: red;'>❌ Login Gagal</h2>";
}
echo "<a href='index.php'>Kembali</a>";
?>
EOF

# === 4. comment.php (simpan komentar) ===
cat << 'EOF' > comment.php
<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);
include "db.php";

$comment = $_POST['comment'];

$stmt = $conn->prepare("INSERT INTO comments (content) VALUES (?)");
$stmt->bind_param("s", $comment);
$stmt->execute();

header("Location: index.php");
exit;
?>
EOF

# === 5. index.php (output aman dari XSS) ===
cat << 'EOF' > index.php
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <title>Lab Aman - SQLi & XSS</title>
  <style>
    body { font-family: sans-serif; background: #f0f0f0; padding: 20px; }
    .box { background: white; padding: 20px; border-radius: 10px; margin-bottom: 20px; }
    input, textarea { width: 100%; margin: 5px 0; padding: 8px; }
    button { padding: 10px 15px; background: #28a745; color: white; border: none; }
  </style>
</head>
<body>

  <h1>🔐 Login Aman (SQLi Tertolak)</h1>
  <div class="box">
    <form action="login.php" method="POST">
      <input type="text" name="username" placeholder="Username" required>
      <input type="password" name="password" placeholder="Password" required>
      <button type="submit">Login</button>
    </form>
  </div>

  <h1>💬 Komentar Aman (XSS Tertolak)</h1>
  <div class="box">
    <form action="comment.php" method="POST">
      <textarea name="comment" placeholder="Ketik komentar..." required></textarea>
      <button type="submit">Kirim</button>
    </form>
  </div>

  <div class="box">
    <h2>Komentar Sebelumnya:</h2>
    <?php
    include "db.php";
    $result = $conn->query("SELECT content FROM comments ORDER BY id DESC");
    while ($row = $result->fetch_assoc()) {
      echo "<p>" . htmlspecialchars($row['content'], ENT_QUOTES, 'UTF-8') . "</p>";
    }
    ?>
  </div>

</body>
</html>
EOF

# === 6. reset_comments.php ===
cat << 'EOF' > reset_comments.php
<?php
include "db.php";
$conn->query("DELETE FROM comments");
echo "Komentar dihapus.";
?>
EOF

# === 7. .htaccess untuk amankan db.php ===
cat << 'EOF' > .htaccess
<Files "db.php">
    Order allow,deny
    Deny from all
</Files>
EOF

# === 8. database.sql untuk setup database & user ===
cat << EOF > database.sql
CREATE DATABASE IF NOT EXISTS labserangan;
USE labserangan;

CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(100),
  password VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS comments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  content TEXT
);

INSERT INTO users (username, password) VALUES ('admin', 'admin123');

CREATE USER IF NOT EXISTS 'webuser'@'localhost' IDENTIFIED BY 'webpass123';
GRANT ALL PRIVILEGES ON labserangan.* TO 'webuser'@'localhost';
FLUSH PRIVILEGES;
EOF

# === 9. Eksekusi SQL untuk buat DB + user ===
/opt/lampp/bin/mysql -u root < database.sql

# === 10. Pesan Sukses ===
echo -e "\n✅ Lab aman dari SQLi & XSS telah berhasil dipasang di: /opt/lampp/htdocs/labaman"
echo "📂 Akses di browser: http://localhost/labaman"