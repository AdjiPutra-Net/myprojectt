<h1 align="center">📄 Automation Script IDS - Snort</h1>

```bash
#!/bin/bash

# Update dan install dependensi
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential
sudo apt install -y \
libpcap-dev \
libpcre3-dev \
libdumbnet-dev \
zlib1g-dev \
libluajit-5.1-dev \
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

# Kompilasi dan install DAQ
cd /usr/src
sudo wget https://www.snort.org/downloads/snort/daq-2.0.7.tar.gz
sudo tar -xvzf daq-2.0.7.tar.gz
cd daq-2.0.7
./configure
make
sudo make install

# Kompilasi dan install Snort
cd /usr/src
sudo wget https://www.snort.org/downloads/snort/snort-2.9.20.tar.gz
sudo tar -xvzf snort-2.9.20.tar.gz
cd snort-2.9.20
export CFLAGS="-I/usr/include/tirpc"
export CPPFLAGS="-I/usr/include/tirpc"
export LDFLAGS="-ltirpc"
./configure --enable-sourcefire
make
sudo make install

# Setup direktori dan konfigurasi dasar Snort
sudo mkdir -p /etc/snort/rules
sudo cp etc/{classification.config,reference.config,snort.conf} /etc/snort/
sudo touch /etc/snort/rules/local.rules
sudo ln -s /usr/local/bin/snort /usr/sbin/snort
sudo mkdir -p /var/log/snort
sudo mkdir -p /usr/local/lib/snort_dynamicrules
cd /usr/src/snort-2.9.20/etc/
sudo cp *.map *.dtd /etc/snort/
sudo ldconfig

# Install dan konfig XAMPP di Ubuntu Server 24.04.2 LTS (tanpa GUI)
# Untuk mengatur keamanan SELinux
sudo apt install policycoreutils -y

# Tahap penginstallan xampp nya
cd /tmp
sudo apt update -y
wget https://sourceforge.net/projects/xampp/files/XAMPP%20Linux/8.2.12/xampp-linux-x64-8.2.12-0-installer.run
chmod +x xampp-linux-x64-8.2.12-0-installer.run
sudo ./xampp-linux-x64-8.2.12-0-installer.run --mode text

# jalankan xampp (apache webserver, mysql/mariadb database)
sudo /opt/lampp/lampp start

# cek status xampp (apache webserver, mysql/mariadb database)
sudo /opt/lampp/lampp status

# Masuk kedalam direktori /opt/lampp/htdocs/labserangan untuk mengatur konifigurasi web server apache di xampp dan buat file kodingan web, database, user database 
sudo mkdir -p /opt/lampp/htdocs/labserangan
cd /opt/lampp/htdocs/labserangan

# Buat file PHP yang dibutuhkan untuk simulasi dan ganti owner folder nya, lalu isikan semua file yang telah dibuat sesuai dengan yang ditujukan
touch comment.php database.sql db.php index.php login.php reset_comments.php
sudo chown -R daemon:daemon /opt/lampp/htdocs/labserangan
sudo chmod -R 755 /opt/lampp/htdocs/labserangan

# Pulihkan konteks SELinux (khusus CentOS/RHEL/Fedora)
sudo restorecon -Rv /opt/lampp/htdocs/labserangan

# comment.php
cat << 'EOF' > comment.php
<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
include "db.php";

$comment = $_POST['comment'];

// Tidak disanitasi = rawan XSS
$stmt = $conn->prepare("INSERT INTO comments (content) VALUES (?)");
$stmt->bind_param("s", $comment);
$stmt->execute();

header("Location: index.php");
?>
EOF

# database.sql dan user database webuser
cat << 'EOF' > database.sql
CREATE DATABASE IF NOT EXISTS labserangan;
USE labserangan;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(100),
  password VARCHAR(100)
);

CREATE TABLE comments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  content TEXT
);

-- Tambahkan 1 akun dummy
INSERT INTO users (username, password) VALUES ('admin', 'admin123');

-- 2. Buat user baru dengan password
CREATE USER 'webuser'@'localhost' IDENTIFIED BY 'webpass123';

-- 3. Kasih user ini akses penuh ke database `labserangan`
GRANT ALL PRIVILEGES ON labserangan.* TO 'webuser'@'localhost';

-- 4. Terapkan perubahan hak akses
FLUSH PRIVILEGES;
EOF

# db.php
cat << 'EOF' > db.php
<?php
$host = "localhost";
$user = "webuser";      // ganti dari root
$pass = "webpass123";   // password yang tadi buat
$db   = "labserangan";

$conn = new mysqli($host, $user, $pass, $db);
if ($conn->connect_error) {
  die("Koneksi gagal: " . $conn->connect_error);
}
?>
EOF

# index.php
cat << 'EOF' > index.php
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <title>Simulasi SQLi & XSS</title>
  <style>
    body { font-family: sans-serif; background: #f0f0f0; padding: 20px; }
    .box { background: white; padding: 20px; border-radius: 10px; margin-bottom: 20px; }
    input, textarea { width: 100%; margin: 5px 0; padding: 8px; }
    button { padding: 10px 15px; background: #007BFF; color: white; border: none; }
  </style>
</head>
<body>

  <h1>🔐 Simulasi SQL Injection</h1>
  <div class="box">
    <form action="login.php" method="POST">
      <input type="text" name="username" placeholder="Username" required>
      <input type="password" name="password" placeholder="Password" required>
      <button type="submit">Login</button>
    </form>
  </div>

  <h1>💬 Simulasi XSS Komentar</h1>
  <div class="box">
    <form action="comment.php" method="POST">
      <textarea name="comment" placeholder="Ketik komentar (bisa <script>)" required></textarea>
      <button type="submit">Kirim</button>
    </form>
  </div>

  <div class="box">
    <h2>Komentar Sebelumnya:</h2>
    <?php
    include "db.php";
    $result = $conn->query("SELECT content FROM comments ORDER BY id DESC");
    while ($row = $result->fetch_assoc()) {
      echo "<p>" . $row['content'] . "</p>";
    }
    ?>
  </div>

</body>
</html>
EOF

# login.php
cat << 'EOF' > login.php
<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
include "db.php";

$username = $_POST['username'];
$password = $_POST['password'];

// Rawan SQL Injection karena query langsung digabung string
$query = "SELECT * FROM users WHERE username = '$username' AND password = '$password'";
$result = $conn->query($query);

if ($result && $result->num_rows > 0) {
  echo "<h2 style='color: green;'>✅ Login Berhasil!</h2>";
} else {
  echo "<h2 style='color: red;'>❌ Login Gagal</h2>";
}
echo "<a href='index.php'>Kembali</a>";
?>
EOF

# reset_comments.php
cat << 'EOF' > reset_comments.php
<?php
include "db.php";
$conn->query("DELETE FROM comments");
echo "Komentar dihapus.";
?>
EOF

# Masukkan file database.sql kedalam databse mysql/mariadb kita
# kalo usernya punya password masukan juga passwordnya kalo tidak langsung enter saja dan proses import file database.sql sudah masuk kedalam database kita
sudo /opt/lampp/bin/mysql -u root -p < database.sql

# pastikan dulu sebelum diubah, bisa pakai grep dulu:
# ✅ Ubah Listen 80 jadi Listen 0.0.0.0:80 di baris 52:
# ✅ Aktifin baris Include httpd-vhosts.conf di baris 488:
# ✅ Tambah bind-address=0.0.0.0 setelah baris [mysqld]
grep -n 'Include etc/extra/httpd-vhosts.conf' /opt/lampp/etc/httpd.conf
grep -n '^Listen' /opt/lampp/etc/httpd.conf
sed -i 's|^Listen 80|Listen 0.0.0.0:80|' /opt/lampp/etc/httpd.conf
sed -i 's|^#Include etc/extra/httpd-vhosts.conf|Include etc/extra/httpd-vhosts.conf|' /opt/lampp/etc/httpd.conf
sed -i '/^\[mysqld\]/a bind-address=0.0.0.0' /opt/lampp/etc/my.cnf


# restart xampp (apache webserver, mysql/mariadb database)
sudo /opt/lampp/lampp restart

# Definisi variabel yang akan digunakan
RULE_PATH="/etc/snort/rules"
HOME_NET="[192.168.56.0/24]"

# isi file konfigurasi snort.conf
cat << EOF | sudo tee /etc/snort/snort.conf > /dev/null
# Isi konfigurasi baru dimulai dari sini

#--------------------------------------------------
#   VRT Rule Packages Snort.conf
#
#   For more information visit us at:
#     http://www.snort.org                   Snort Website
#     http://vrt-blog.snort.org/    Sourcefire VRT Blog
#
#     Mailing list Contact:      snort-users@lists.snort.org
#     False Positive reports:    fp@sourcefire.com
#     Snort bugs:                bugs@snort.org
#
#     Compatible with Snort Versions:
#     VERSIONS : 2.9.20
#
#     Snort build options:
#     OPTIONS : --enable-gre --enable-mpls --enable-targetbased --enable-ppm --enable-perfprofiling --enable-zlib --enable-active-response --enable-normalizer --enable-reload --enable-react --enable-flexresp3
#
#     Additional information:
#     This configuration file enables active response, to run snort in
#     test mode -T you are required to supply an interface -i <interface>
#     or test mode will fail to fully validate the configuration and
#     exit with a FATAL error
#--------------------------------------------------

###################################################
# This file contains a sample snort configuration.
# You should take the following steps to create your own custom configuration:
#
#  1) Set the network variables.
#  2) Configure the decoder
#  3) Configure the base detection engine
#  4) Configure dynamic loaded libraries
#  5) Configure preprocessors
#  6) Configure output plugins
#  7) Customize your rule set
#  8) Customize preprocessor and decoder rule set
#  9) Customize shared object rule set
###################################################

###################################################
# Step #1: Set the network variables.  For more information, see README.variables
###################################################

# Setup the network addresses you are protecting
ipvar HOME_NET any

# Set up the external network addresses. Leave as "any" in most situations
ipvar EXTERNAL_NET any

# List of DNS servers on your network
ipvar DNS_SERVERS $HOME_NET

# List of SMTP servers on your network
ipvar SMTP_SERVERS $HOME_NET

# List of web servers on your network
ipvar HTTP_SERVERS $HOME_NET

# List of sql servers on your network
ipvar SQL_SERVERS $HOME_NET

# List of telnet servers on your network
ipvar TELNET_SERVERS $HOME_NET

# List of ssh servers on your network
ipvar SSH_SERVERS $HOME_NET

# List of ftp servers on your network
ipvar FTP_SERVERS $HOME_NET

# List of sip servers on your network
ipvar SIP_SERVERS $HOME_NET

# List of ports you run web servers on
portvar HTTP_PORTS [80,81,311,383,591,593,901,1220,1414,1741,1830,2301,2381,2809,3037,3128,3702,4343,4848,5250,6988,7000,7001,7144,7145,7510,7777,7779,8000,8008,8014,8028,8080,8085,8088,8090,8118,8123,8180,8181,8243,8280,8300,8800,8888,8899,9000,9060,9080,9090,9091,9443,9999,11371,34443,34444,41080,50002,55555]

# List of ports you want to look for SHELLCODE on.
portvar SHELLCODE_PORTS !80

# List of ports you might see oracle attacks on
portvar ORACLE_PORTS 1024:

# List of ports you want to look for SSH connections on:
portvar SSH_PORTS 22

# List of ports you run ftp servers on
portvar FTP_PORTS [21,2100,3535]

# List of ports you run SIP servers on
portvar SIP_PORTS [5060,5061,5600]

# List of file data ports for file inspection
portvar FILE_DATA_PORTS [$HTTP_PORTS,110,143]

# List of GTP ports for GTP preprocessor
portvar GTP_PORTS [2123,2152,3386]

# other variables, these should not be modified
ipvar AIM_SERVERS [64.12.24.0/23,64.12.28.0/23,64.12.161.0/24,64.12.163.0/24,64.12.200.0/24,205.188.3.0/24,205.188.5.0/24,205.188.7.0/24,205.188.9.0/24,205.188.153.0/24,205.188.179.0/24,205.188.248.0/24]

# Path to your rules files (this can be a relative path)
# Note for Windows users:  You are advised to make this an absolute path,
# such as:  c:\snort\rules
var RULE_PATH /etc/snort/rules
var SO_RULE_PATH /etc/snort/rules
var PREPROC_RULE_PATH /etc/snort/rules

# If you are using reputation preprocessor set these
# Currently there is a bug with relative paths, they are relative to where snort is
# not relative to snort.conf like the above variables
# This is completely inconsistent with how other vars work, BUG 89986
# Set the absolute path appropriately
var WHITE_LIST_PATH ../rules
var BLACK_LIST_PATH ../rules

###################################################
# Step #2: Configure the decoder.  For more information, see README.decode
###################################################

# Stop generic decode events:
config disable_decode_alerts

# Stop Alerts on experimental TCP options
config disable_tcpopt_experimental_alerts

# Stop Alerts on obsolete TCP options
config disable_tcpopt_obsolete_alerts

# Stop Alerts on T/TCP alerts
config disable_tcpopt_ttcp_alerts

# Stop Alerts on all other TCPOption type events:
config disable_tcpopt_alerts

# Stop Alerts on invalid ip options
config disable_ipopt_alerts

# Alert if value in length field (IP, TCP, UDP) is greater th elength of the packet
# config enable_decode_oversized_alerts

# Same as above, but drop packet if in Inline mode (requires enable_decode_oversized_alerts)
# config enable_decode_oversized_drops

# Configure IP / TCP checksum mode
config checksum_mode: all

# Configure maximum number of flowbit references.  For more information, see README.flowbits
# config flowbits_size: 64

# Configure ports to ignore
# config ignore_ports: tcp 21 6667:6671 1356
# config ignore_ports: udp 1:17 53

# Configure active response for non inline operation. For more information, see REAMDE.active
# config response: eth0 attempts 2

# Configure DAQ related options for inline operation. For more information, see README.daq
#
# config daq: <type>
# config daq_dir: <dir>
# config daq_mode: <mode>
# config daq_var: <var>
#
# <type> ::= pcap | afpacket | dump | nfq | ipq | ipfw
# <mode> ::= read-file | passive | inline
# <var> ::= arbitrary <name>=<value passed to DAQ
# <dir> ::= path as to where to look for DAQ module so's

# Configure specific UID and GID to run snort as after dropping privs. For more information see snort -h command line options
#
# config set_gid:
# config set_uid:

# Configure default snaplen. Snort defaults to MTU of in use interface. For more information see README
#
# config snaplen:
#

# Configure default bpf_file to use for filtering what traffic reaches snort. For more information see snort -h command line options (-F)
#
# config bpf_file:
#

# Configure default log directory for snort to log to.  For more information see snort -h command line options (-l)
#
# config logdir:


###################################################
# Step #3: Configure the base detection engine.  For more information, see  README.decode
###################################################

# Configure PCRE match limitations
config pcre_match_limit: 3500
config pcre_match_limit_recursion: 1500

# Configure the detection engine  See the Snort Manual, Configuring Snort - Includes - Config
config detection: search-method ac-split search-optimize max-pattern-len 20

# Configure the event queue.  For more information, see README.event_queue
config event_queue: max_queue 8 log 5 order_events content_length

###################################################
## Configure GTP if it is to be used.
## For more information, see README.GTP
####################################################

# config enable_gtp

###################################################
# Per packet and rule latency enforcement
# For more information see README.ppm
###################################################

# Per Packet latency configuration
#config ppm: max-pkt-time 250, \
#   fastpath-expensive-packets, \
#   pkt-log

# Per Rule latency configuration
#config ppm: max-rule-time 200, \
#   threshold 3, \
#   suspend-expensive-rules, \
#   suspend-timeout 20, \
#   rule-log alert

###################################################
# Configure Perf Profiling for debugging
# For more information see README.PerfProfiling
###################################################

#config profile_rules: print all, sort avg_ticks
#config profile_preprocs: print all, sort avg_ticks

###################################################
# Configure protocol aware flushing
# For more information see README.stream5
###################################################
config paf_max: 16000

###################################################
# Step #4: Configure dynamic loaded libraries.
# For more information, see Snort Manual, Configuring Snort - Dynamic Modules
###################################################

# path to dynamic preprocessor libraries
dynamicpreprocessor directory /usr/local/lib/snort_dynamicpreprocessor/

# path to base preprocessor engine
dynamicengine /usr/local/lib/snort_dynamicengine/libsf_engine.so

# path to dynamic rules libraries
dynamicdetection directory /usr/local/lib/snort_dynamicrules

###################################################
# Step #5: Configure preprocessors
# For more information, see the Snort Manual, Configuring Snort - Preprocessors
###################################################

# GTP Control Channle Preprocessor. For more information, see README.GTP
# preprocessor gtp: ports { 2123 3386 2152 }

# Inline packet normalization. For more information, see README.normalize
# Does nothing in IDS mode
preprocessor normalize_ip4
preprocessor normalize_tcp: ips ecn stream
preprocessor normalize_icmp4
preprocessor normalize_ip6
preprocessor normalize_icmp6

# Target-based IP defragmentation.  For more inforation, see README.frag3
preprocessor frag3_global: max_frags 65536
preprocessor frag3_engine: policy windows detect_anomalies overlap_limit 10 min_fragment_length 100 timeout 180

# Target-Based stateful inspection/stream reassembly.  For more inforation, see README.stream5
preprocessor stream5_global: track_tcp yes, \
   track_udp yes, \
   track_icmp no, \
   max_tcp 262144, \
   max_udp 131072, \
   max_active_responses 2, \
   min_response_seconds 5
preprocessor stream5_tcp: log_asymmetric_traffic no, policy windows, \
   detect_anomalies, require_3whs 180, \
   overlap_limit 10, small_segments 3 bytes 150, timeout 180, \
    ports client 21 22 23 25 42 53 79 109 110 111 113 119 135 136 137 139 143 \
        161 445 513 514 587 593 691 1433 1521 1741 2100 3306 6070 6665 6666 6667 6668 6669 \
        7000 8181 32770 32771 32772 32773 32774 32775 32776 32777 32778 32779, \
    ports both 80 81 311 383 443 465 563 591 593 636 901 989 992 993 994 995 1220 1414 1830 2301 2381 2809 3037 3128 3702 4343 4848 5250 6988 7907 7000 7001 7144 7145 7510 7802 7777 7779 \
        7801 7900 7901 7902 7903 7904 7905 7906 7908 7909 7910 7911 7912 7913 7914 7915 7916 \
        7917 7918 7919 7920 8000 8008 8014 8028 8080 8085 8088 8090 8118 8123 8180 8243 8280 8300 8800 8888 8899 9000 9060 9080 9090 9091 9443 9999 11371 34443 34444 41080 50002 55555
preprocessor stream5_udp: timeout 180

# performance statistics.  For more information, see the Snort Manual, Configuring Snort - Preprocessors - Performance Monitor
# preprocessor perfmonitor: time 300 file /var/snort/snort.stats pktcnt 10000

# HTTP normalization and anomaly detection.  For more information, see README.http_inspect
preprocessor http_inspect: global iis_unicode_map unicode.map 1252 compress_depth 65535 decompress_depth 65535
preprocessor http_inspect_server: server default \
    http_methods { GET POST PUT SEARCH MKCOL COPY MOVE LOCK UNLOCK NOTIFY POLL BCOPY BDELETE BMOVE LINK UNLINK OPTIONS HEAD DELETE TRACE TRACK CONNECT SOURCE SUBSCRIBE UNSUBSCRIBE PROPFIND PROPPATCH BPROPFIND BPROPPATCH RPC_CONNECT PROXY_SUCCESS BITS_POST CCM_POST SMS_POST RPC_IN_DATA RPC_OUT_DATA RPC_ECHO_DATA } \
    chunk_length 500000 \
    server_flow_depth 0 \
    client_flow_depth 0 \
    post_depth 65495 \
    oversize_dir_length 500 \
    max_header_length 750 \
    max_headers 100 \
    max_spaces 200 \
    small_chunk_length { 10 5 } \
    ports { 80 81 311 383 591 593 901 1220 1414 1741 1830 2301 2381 2809 3037 3128 3702 4343 4848 5250 6988 7000 7001 7144 7145 7510 7777 7779 8000 8008 8014 8028 8080 8085 8088 8090 8118 8123 8180 8181 8243 8280 8300 8800 8888 8899 9000 9060 9080 9090 9091 9443 9999 11371 34443 34444 41080 50002 55555 } \
    non_rfc_char { 0x00 0x01 0x02 0x03 0x04 0x05 0x06 0x07 } \
    enable_cookie \
    extended_response_inspection \
    inspect_gzip \
    normalize_utf \
    unlimited_decompress \
    normalize_javascript \
    apache_whitespace no \
    ascii no \
    bare_byte no \
    directory no \
    double_decode no \
    iis_backslash no \
    iis_delimiter no \
    iis_unicode no \
    multi_slash no \
    utf_8 no \
    u_encode yes \
    webroot no

# ONC-RPC normalization and anomaly detection.  For more information, see the Snort Manual, Configuring Snort - Preprocessors - RPC Decode
preprocessor rpc_decode: 111 32770 32771 32772 32773 32774 32775 32776 32777 32778 32779 no_alert_multiple_requests no_alert_large_fragments no_alert_incomplete

# Back Orifice detection.
preprocessor bo

# FTP / Telnet normalization and anomaly detection.  For more information, see README.ftptelnet
preprocessor ftp_telnet: global inspection_type stateful encrypted_traffic no check_encrypted
preprocessor ftp_telnet_protocol: telnet \
    ayt_attack_thresh 20 \
    normalize ports { 23 } \
    detect_anomalies
preprocessor ftp_telnet_protocol: ftp server default \
    def_max_param_len 100 \
    ports { 21 2100 3535 } \
    telnet_cmds yes \
    ignore_telnet_erase_cmds yes \
    ftp_cmds { ABOR ACCT ADAT ALLO APPE AUTH CCC CDUP } \
    ftp_cmds { CEL CLNT CMD CONF CWD DELE ENC EPRT } \
    ftp_cmds { EPSV ESTA ESTP FEAT HELP LANG LIST LPRT } \
    ftp_cmds { LPSV MACB MAIL MDTM MIC MKD MLSD MLST } \
    ftp_cmds { MODE NLST NOOP OPTS PASS PASV PBSZ PORT } \
    ftp_cmds { PROT PWD QUIT REIN REST RETR RMD RNFR } \
    ftp_cmds { RNTO SDUP SITE SIZE SMNT STAT STOR STOU } \
    ftp_cmds { STRU SYST TEST TYPE USER XCUP XCRC XCWD } \
    ftp_cmds { XMAS XMD5 XMKD XPWD XRCP XRMD XRSQ XSEM } \
    ftp_cmds { XSEN XSHA1 XSHA256 } \
    alt_max_param_len 0 { ABOR CCC CDUP ESTA FEAT LPSV NOOP PASV PWD QUIT REIN STOU SYST XCUP XPWD } \
    alt_max_param_len 200 { ALLO APPE CMD HELP NLST RETR RNFR STOR STOU XMKD } \
    alt_max_param_len 256 { CWD RNTO } \
    alt_max_param_len 400 { PORT } \
    alt_max_param_len 512 { SIZE } \
    chk_str_fmt { ACCT ADAT ALLO APPE AUTH CEL CLNT CMD } \
    chk_str_fmt { CONF CWD DELE ENC EPRT EPSV ESTP HELP } \
    chk_str_fmt { LANG LIST LPRT MACB MAIL MDTM MIC MKD } \
    chk_str_fmt { MLSD MLST MODE NLST OPTS PASS PBSZ PORT } \
    chk_str_fmt { PROT REST RETR RMD RNFR RNTO SDUP SITE } \
    chk_str_fmt { SIZE SMNT STAT STOR STRU TEST TYPE USER } \
    chk_str_fmt { XCRC XCWD XMAS XMD5 XMKD XRCP XRMD XRSQ } \
    chk_str_fmt { XSEM XSEN XSHA1 XSHA256 } \
    cmd_validity ALLO < int [ char R int ] > \
    cmd_validity EPSV < [ { char 12 | char A char L char L } ] > \
    cmd_validity MACB < string > \
    cmd_validity MDTM < [ date nnnnnnnnnnnnnn[.n[n[n]]] ] string > \
    cmd_validity MODE < char ASBCZ > \
    cmd_validity PORT < host_port > \
    cmd_validity PROT < char CSEP > \
    cmd_validity STRU < char FRPO [ string ] > \
    cmd_validity TYPE < { char AE [ char NTC ] | char I | char L [ number ] } >
preprocessor ftp_telnet_protocol: ftp client default \
    max_resp_len 256 \
    bounce yes \
    ignore_telnet_erase_cmds yes \
    telnet_cmds yes


# SMTP normalization and anomaly detection.  For more information, see README.SMTP
preprocessor smtp: ports { 25 465 587 691 } \
    inspection_type stateful \
    b64_decode_depth 0 \
    qp_decode_depth 0 \
    bitenc_decode_depth 0 \
    uu_decode_depth 0 \
    log_mailfrom \
    log_rcptto \
    log_filename \
    log_email_hdrs \
    normalize cmds \
    normalize_cmds { ATRN AUTH BDAT CHUNKING DATA DEBUG EHLO EMAL ESAM ESND ESOM ETRN EVFY } \
    normalize_cmds { EXPN HELO HELP IDENT MAIL NOOP ONEX QUEU QUIT RCPT RSET SAML SEND SOML } \
    normalize_cmds { STARTTLS TICK TIME TURN TURNME VERB VRFY X-ADAT X-DRCP X-ERCP X-EXCH50 } \
    normalize_cmds { X-EXPS X-LINK2STATE XADR XAUTH XCIR XEXCH50 XGEN XLICENSE XQUE XSTA XTRN XUSR } \
    max_command_line_len 512 \
    max_header_line_len 1000 \
    max_response_line_len 512 \
    alt_max_command_line_len 260 { MAIL } \
    alt_max_command_line_len 300 { RCPT } \
    alt_max_command_line_len 500 { HELP HELO ETRN EHLO } \
    alt_max_command_line_len 255 { EXPN VRFY ATRN SIZE BDAT DEBUG EMAL ESAM ESND ESOM EVFY IDENT NOOP RSET } \
    alt_max_command_line_len 246 { SEND SAML SOML AUTH TURN ETRN DATA RSET QUIT ONEX QUEU STARTTLS TICK TIME TURNME VERB X-EXPS X-LINK2STATE XADR XAUTH XCIR XEXCH50 XGEN XLICENSE XQUE XSTA XTRN XUSR } \
    valid_cmds { ATRN AUTH BDAT CHUNKING DATA DEBUG EHLO EMAL ESAM ESND ESOM ETRN EVFY } \
    valid_cmds { EXPN HELO HELP IDENT MAIL NOOP ONEX QUEU QUIT RCPT RSET SAML SEND SOML } \
    valid_cmds { STARTTLS TICK TIME TURN TURNME VERB VRFY X-ADAT X-DRCP X-ERCP X-EXCH50 } \
    valid_cmds { X-EXPS X-LINK2STATE XADR XAUTH XCIR XEXCH50 XGEN XLICENSE XQUE XSTA XTRN XUSR } \
    xlink2state { enabled }

# Portscan detection.  For more information, see README.sfportscan
# preprocessor sfportscan: proto  { all } memcap { 10000000 } sense_level { low }

# ARP spoof detection.  For more information, see the Snort Manual - Configuring Snort - Preprocessors - ARP Spoof Preprocessor
# preprocessor arpspoof
# preprocessor arpspoof_detect_host: 192.168.40.1 f0:0f:00:f0:0f:00

# SSH anomaly detection.  For more information, see README.ssh
preprocessor ssh: server_ports { 22 } \
                  autodetect \
                  max_client_bytes 19600 \
                  max_encrypted_packets 20 \
                  max_server_version_len 100 \
                  enable_respoverflow enable_ssh1crc32 \
                  enable_srvoverflow enable_protomismatch

# SMB / DCE-RPC normalization and anomaly detection.  For more information, see README.dcerpc2
preprocessor dcerpc2: memcap 102400, events [co ]
preprocessor dcerpc2_server: default, policy WinXP, \
    detect [smb [139,445], tcp 135, udp 135, rpc-over-http-server 593], \
    autodetect [tcp 1025:, udp 1025:, rpc-over-http-server 1025:], \
    smb_max_chain 3, smb_invalid_shares ["C$", "D$", "ADMIN$"]

# DNS anomaly detection.  For more information, see README.dns
preprocessor dns: ports { 53 } enable_rdata_overflow

# SSL anomaly detection and traffic bypass.  For more information, see README.ssl
preprocessor ssl: ports { 443 465 563 636 989 992 993 994 995 7801 7802 7900 7901 7902 7903 7904 7905 7906 7907 7908 7909 7910 7911 7912 7913 7914 7915 7916 7917 7918 7919 7920 }, trustservers, noinspect_encrypted

# SDF sensitive data preprocessor.  For more information see README.sensitive_data
preprocessor sensitive_data: alert_threshold 25

# SIP Session Initiation Protocol preprocessor.  For more information see README.sip
preprocessor sip: max_sessions 40000, \
   ports { 5060 5061 5600 }, \
   methods { invite \
             cancel \
             ack \
             bye \
             register \
             options \
             refer \
             subscribe \
             update \
             join \
             info \
             message \
             notify \
             benotify \
             do \
             qauth \
             sprack \
             publish \
             service \
             unsubscribe \
             prack }, \
   max_uri_len 512, \
   max_call_id_len 80, \
   max_requestName_len 20, \
   max_from_len 256, \
   max_to_len 256, \
   max_via_len 1024, \
   max_contact_len 512, \
   max_content_len 2048

# IMAP preprocessor.  For more information see README.imap
preprocessor imap: \
   ports { 143 } \
   b64_decode_depth 0 \
   qp_decode_depth 0 \
   bitenc_decode_depth 0 \
   uu_decode_depth 0

# POP preprocessor. For more information see README.pop
preprocessor pop: \
   ports { 110 } \
   b64_decode_depth 0 \
   qp_decode_depth 0 \
   bitenc_decode_depth 0 \
   uu_decode_depth 0

# Modbus preprocessor. For more information see README.modbus
preprocessor modbus: ports { 502 }

# DNP3 preprocessor. For more information see README.dnp3
preprocessor dnp3: ports { 20000 } \
   memcap 262144 \
   check_crc

# Reputation preprocessor. For more information see README.reputation
#preprocessor reputation: \
   #memcap 500, \
   #priority whitelist, \
   #nested_ip inner, \
   #whitelist $WHITE_LIST_PATH/white_list.rules, \
   #blacklist $BLACK_LIST_PATH/black_list.rules

###################################################
# Step #6: Configure output plugins
# For more information, see Snort Manual, Configuring Snort - Output Modules
###################################################

# unified2
# Recommended for most installs
# output unified2: filename merged.log, limit 128, nostamp, mpls_event_types, vlan_event_types

# Additional configuration for specific types of installs
# output alert_unified2: filename snort.alert, limit 128, nostamp
# output log_unified2: filename snort.log, limit 128, nostamp

# syslog
# output alert_syslog: LOG_AUTH LOG_ALERT

# pcap
# output log_tcpdump: tcpdump.log

# metadata reference data.  do not modify these lines
include classification.config
include reference.config


###################################################
# Step #7: Customize your rule set
# For more information, see Snort Manual, Writing Snort Rules
#
# NOTE: All categories are enabled in this conf file
###################################################

# site specific rules
include $RULE_PATH/local.rules

# include $RULE_PATH/app-detect.rules
# include $RULE_PATH/attack-responses.rules
# include $RULE_PATH/backdoor.rules
# include $RULE_PATH/bad-traffic.rules
# include $RULE_PATH/blacklist.rules
# include $RULE_PATH/botnet-cnc.rules
# include $RULE_PATH/browser-chrome.rules
# include $RULE_PATH/browser-firefox.rules
# include $RULE_PATH/browser-ie.rules
# include $RULE_PATH/browser-other.rules
# include $RULE_PATH/browser-plugins.rules
# include $RULE_PATH/browser-webkit.rules
# include $RULE_PATH/chat.rules
# include $RULE_PATH/content-replace.rules
# include $RULE_PATH/ddos.rules
# include $RULE_PATH/dns.rules
# include $RULE_PATH/dos.rules
# include $RULE_PATH/experimental.rules
# include $RULE_PATH/exploit-kit.rules
# include $RULE_PATH/exploit.rules
# include $RULE_PATH/file-executable.rules
# include $RULE_PATH/file-flash.rules
# include $RULE_PATH/file-identify.rules
# include $RULE_PATH/file-image.rules
# include $RULE_PATH/file-multimedia.rules
# include $RULE_PATH/file-office.rules
# include $RULE_PATH/file-other.rules
# include $RULE_PATH/file-pdf.rules
# include $RULE_PATH/finger.rules
# include $RULE_PATH/ftp.rules
# include $RULE_PATH/icmp-info.rules
# include $RULE_PATH/icmp.rules
# include $RULE_PATH/imap.rules
# include $RULE_PATH/indicator-compromise.rules
# include $RULE_PATH/indicator-obfuscation.rules
# include $RULE_PATH/indicator-shellcode.rules
# include $RULE_PATH/info.rules
# include $RULE_PATH/malware-backdoor.rules
# include $RULE_PATH/malware-cnc.rules
# include $RULE_PATH/malware-other.rules
# include $RULE_PATH/malware-tools.rules
# include $RULE_PATH/misc.rules
# include $RULE_PATH/multimedia.rules
# include $RULE_PATH/mysql.rules
# include $RULE_PATH/netbios.rules
# include $RULE_PATH/nntp.rules
# include $RULE_PATH/oracle.rules
# include $RULE_PATH/os-linux.rules
# include $RULE_PATH/os-other.rules
# include $RULE_PATH/os-solaris.rules
# include $RULE_PATH/os-windows.rules
# include $RULE_PATH/other-ids.rules
# include $RULE_PATH/p2p.rules
# include $RULE_PATH/phishing-spam.rules
# include $RULE_PATH/policy-multimedia.rules
# include $RULE_PATH/policy-other.rules
# include $RULE_PATH/policy.rules
# include $RULE_PATH/policy-social.rules
# include $RULE_PATH/policy-spam.rules
# include $RULE_PATH/pop2.rules
# include $RULE_PATH/pop3.rules
# include $RULE_PATH/protocol-finger.rules
# include $RULE_PATH/protocol-ftp.rules
# include $RULE_PATH/protocol-icmp.rules
# include $RULE_PATH/protocol-imap.rules
# include $RULE_PATH/protocol-pop.rules
# include $RULE_PATH/protocol-services.rules
# include $RULE_PATH/protocol-voip.rules
# include $RULE_PATH/pua-adware.rules
# include $RULE_PATH/pua-other.rules
# include $RULE_PATH/pua-p2p.rules
# include $RULE_PATH/pua-toolbars.rules
# include $RULE_PATH/rpc.rules
# include $RULE_PATH/rservices.rules
# include $RULE_PATH/scada.rules
# include $RULE_PATH/scan.rules
# include $RULE_PATH/server-apache.rules
# include $RULE_PATH/server-iis.rules
# include $RULE_PATH/server-mail.rules
# include $RULE_PATH/server-mssql.rules
# include $RULE_PATH/server-mysql.rules
# include $RULE_PATH/server-oracle.rules
# include $RULE_PATH/server-other.rules
# include $RULE_PATH/server-webapp.rules
# include $RULE_PATH/shellcode.rules
# include $RULE_PATH/smtp.rules
# include $RULE_PATH/snmp.rules
# include $RULE_PATH/specific-threats.rules
# include $RULE_PATH/spyware-put.rules
# include $RULE_PATH/sql.rules
# include $RULE_PATH/telnet.rules
# include $RULE_PATH/tftp.rules
# include $RULE_PATH/virus.rules
# include $RULE_PATH/voip.rules
# include $RULE_PATH/web-activex.rules
# include $RULE_PATH/web-attacks.rules
# include $RULE_PATH/web-cgi.rules
# include $RULE_PATH/web-client.rules
# include $RULE_PATH/web-coldfusion.rules
# include $RULE_PATH/web-frontpage.rules
# include $RULE_PATH/web-iis.rules
# include $RULE_PATH/web-misc.rules
# include $RULE_PATH/web-php.rules
# include $RULE_PATH/x11.rules

# decoder and preprocessor event rules
# include $PREPROC_RULE_PATH/preprocessor.rules
# include $PREPROC_RULE_PATH/decoder.rules
# include $PREPROC_RULE_PATH/sensitive-data.rules

# dynamic library rules
# include $SO_RULE_PATH/bad-traffic.rules
# include $SO_RULE_PATH/chat.rules
# include $SO_RULE_PATH/dos.rules
# include $SO_RULE_PATH/exploit.rules
# include $SO_RULE_PATH/icmp.rules
# include $SO_RULE_PATH/imap.rules
# include $SO_RULE_PATH/misc.rules
# include $SO_RULE_PATH/multimedia.rules
# include $SO_RULE_PATH/netbios.rules
# include $SO_RULE_PATH/nntp.rules
# include $SO_RULE_PATH/p2p.rules
# include $SO_RULE_PATH/smtp.rules
# include $SO_RULE_PATH/snmp.rules
# include $SO_RULE_PATH/specific-threats.rules
# include $SO_RULE_PATH/web-activex.rules
# include $SO_RULE_PATH/web-client.rules
# include $SO_RULE_PATH/web-iis.rules
# include $SO_RULE_PATH/web-misc.rules

# Event thresholding or suppression commands. See threshold.conf
# include threshold.conf
EOF

# isi file konfigurasi local.rules
cat << 'EOF' | sudo tee /etc/snort/rules/local.rules > /dev/null

# === Basic Injections ===
alert tcp any any -> any 80 (msg:"SQLi - OR 1=1 plain"; flow:to_server,established; content:"' OR '1'='1"; nocase; http_uri; sid:2000001; rev:1;)
alert tcp any any -> any 80 (msg:"SQLi - OR 1=1 with comment"; flow:to_server,established; content:"' OR 1=1 --"; nocase; http_uri; sid:2000002; rev:1;)
alert tcp any any -> any 80 (msg:"SQLi - OR 1=1 in POST body"; flow:to_server,established; content:"' OR '1'='1"; nocase; http_client_body; sid:2000003; rev:1;)

# === Encoded variants ===
alert tcp any any -> any 80 (msg:"SQLi - Encoded OR"; flow:to_server,established; content:"%27%20OR%20%271%27=%271"; nocase; http_uri; sid:2000004; rev:1;)

# === Regex (PCRE) detection ===
alert tcp any any -> any 80 (msg:"SQLi - Generic OR 1=1 Regex"; flow:to_server,established; content:"or"; http_uri; pcre:"/('|%27)\s*or\s+1\s*=\s*1/i"; sid:2000005; rev:2;)

# === UNION SELECT ===
alert tcp any any -> any 80 (msg:"SQLi - UNION SELECT"; flow:to_server,established; content:"UNION SELECT"; nocase; http_uri; sid:2000006; rev:1;)
alert tcp any any -> any 80 (msg:"SQLi - union select regex"; flow:to_server,established; content:"union"; http_uri; pcre:"/union\s+select/i"; sid:2000007; rev:2;)

# === DROP TABLE & DML ===
alert tcp any any -> any 80 (msg:"SQLi - DROP TABLE"; flow:to_server,established; content:"DROP TABLE"; nocase; http_uri; sid:2000008; rev:1;)
alert tcp any any -> any 80 (msg:"SQLi - delete from"; flow:to_server,established; content:"delete"; http_uri; pcre:"/delete\s+from/i"; sid:2000009; rev:2;)

# === Advanced Payloads ===
alert tcp any any -> any 80 (msg:"SQLi - Advanced payload sleep()"; flow:to_server,established; content:"sleep("; nocase; http_uri; sid:2000010; rev:1;)
alert tcp any any -> any 80 (msg:"SQLi - Advanced payload benchmark()"; flow:to_server,established; content:"benchmark("; nocase; http_uri; sid:2000011; rev:1;)
alert tcp any any -> any 80 (msg:"SQLi - Advanced stacked queries"; flow:to_server,established; content:"|3B|"; content:"DROP TABLE"; nocase; http_uri; sid:2000012; rev:3;)

# === Basic Tags ===
alert tcp any any -> any 80 (msg:"XSS - Basic <script>"; flow:to_server,established; content:"<script>"; nocase; http_uri; sid:2100001; rev:1;)
alert tcp any any -> any 80 (msg:"XSS - <script> in POST body"; flow:to_server,established; content:"<script>"; nocase; http_client_body; sid:2100002; rev:1;)

# === Encoded Variants ===
alert tcp any any -> any 80 (msg:"XSS - Encoded %3Cscript%3E"; flow:to_server,established; content:"%3Cscript%3E"; nocase; http_uri; sid:2100003; rev:1;)
alert tcp any any -> any 80 (msg:"XSS - Encoded %3cscript%3e"; flow:to_server,established; content:"%3cscript%3e"; nocase; http_uri; sid:2100004; rev:1;)

# === JS Schemes & Event Handlers ===
alert tcp any any -> any 80 (msg:"XSS - javascript: URI"; flow:to_server,established; content:"javascript:"; nocase; http_uri; sid:2100005; rev:1;)
alert tcp any any -> any 80 (msg:"XSS - onerror attribute"; flow:to_server,established; content:"onerror="; nocase; http_client_body; sid:2100006; rev:1;)
alert tcp any any -> any 80 (msg:"XSS - onload attribute"; flow:to_server,established; content:"onload="; nocase; http_client_body; sid:2100007; rev:1;)

# === SVG XSS Payloads ===
alert tcp any any -> any 80 (msg:"XSS - SVG XSS"; flow:to_server,established; content:"<svg"; nocase; http_uri; sid:2100008; rev:1;)

# === Advanced Regex Match ===
alert tcp any any -> any 80 (msg:"XSS - Script Regex"; flow:to_server,established; content:"<script"; http_uri; pcre:"/<script[^>]*>.*<\/script>/i"; sid:2100009; rev:2;)
alert tcp any any -> any 80 (msg:"XSS - Event Handler Regex"; flow:to_server,established; content:"on"; http_client_body; pcre:"/on(error|load)\s*=/i"; sid:2100010; rev:2;)
EOF

# Ubah semua baris var PATH ke path baru
sudo sed -i \
-e 's|^var RULE_PATH .*|var RULE_PATH /etc/snort/rules|' \
-e 's|^var SO_RULE_PATH .*|var SO_RULE_PATH /etc/snort/rules|' \
-e 's|^var PREPROC_RULE_PATH .*|var PREPROC_RULE_PATH /etc/snort/rules|' \
/etc/snort/snort.conf

# Komentarin preprocessor reputation block
sudo sed -i '/^preprocessor reputation:/,/^ *blacklist /s/^/#/' /etc/snort/snort.conf

# Komentarin semua include, kecuali yang diizinkan
sudo sed -i \
-e '/^include /{/local.rules/!{/classification.config/!{/reference.config/!s/^/#/}}}' \
/etc/snort/snort.conf

# cek hasil perubahannya
grep -E '^var |^#preprocessor|^#include|^include' /etc/snort/snort.conf


# cek versi snort dan test tools snort jalan atau tidak
snort -V
snort -T -c /etc/snort/snort.conf

HTTPD_CONF="/opt/lampp/etc/httpd.conf"
VHOST_CONF="/opt/lampp/etc/extra/httpd-vhosts.conf"

# Fungsi untuk ambil IP dari subnet 192.168.56.0/24
get_ip_by_subnet() {
    ip -4 addr show | grep '192.168.56' | grep -oP '(?<=inet\s)\d+(\.\d+){3}'
}

IPADDR=$(get_ip_by_subnet)

if [ -z "$IPADDR" ]; then
    echo "❌ IP dari subnet 192.168.56.0/24 tidak ditemukan."
    exit 1
fi

echo "✅ IP ditemukan: $IPADDR"
echo "🔧 Mengupdate file konfigurasi..."

# Update ServerName di httpd.conf
sed -i "s|^ServerName .*|ServerName $IPADDR|" "$HTTPD_CONF"

# Ganti <Directory "/opt/lampp/htdocs"> jadi labserangan
sed -i 's|<Directory "/opt/lampp/htdocs">|<Directory "/opt/lampp/htdocs/labserangan">|' "$HTTPD_CONF"

# Update VirtualHost pertama di httpd-vhosts.conf dan hapus yang kedua
cat <<EOF > "$VHOST_CONF"
<VirtualHost *:80>
    ServerAdmin webmaster@labserangan.local
    DocumentRoot "/opt/lampp/htdocs/labserangan"
    ServerName $IPADDR

    <Directory "/opt/lampp/htdocs/labserangan">
        Options Indexes FollowSymLinks ExecCGI Includes
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog "logs/labserangan-error_log"
    CustomLog "logs/labserangan-access_log" common
</VirtualHost>
EOF

echo "✅ Konfigurasi berhasil diperbarui!"

# restart xampp (web server, database)
sudo /opt/lampp/lampp restart

# Fungsi untuk cari interface berdasarkan subnet 192.168.56.0/24
get_iface_by_subnet() {
    ip -br -4 addr | grep '192.168.56' | awk '{print $1}'
}

# Ambil interface
iface=$(get_iface_by_subnet)

# Cek apakah interface ditemukan
if [ -z "$iface" ]; then
    echo "❌ Gagal menemukan interface dengan subnet 192.168.56.0/24"
    exit 1
fi

# Output informasi interface dan instruksi
echo "✅ Interface yang cocok: $iface"
echo ""
echo "📌 Gunakan perintah ini untuk menonaktifkan hardware offloading:"
echo "sudo ethtool -K $iface rx off tx off sg off tso off gso off gro off"
echo ""
echo "📌 Gunakan perintah ini untuk menjalankan Snort:"
echo "snort -i $iface -c /etc/snort/snort.conf -A console"
echo ""

# Eksekusi langsung ethtool
echo "🔧 Menonaktifkan hardware offloading untuk interface: $iface"
sudo ethtool -K "$iface" rx off tx off sg off tso off gso off gro off

```


### 💾 Simpan script:

Misalnya disimpan sebagai:

```bash
mkdir -p ~/scripts/
vi ~/scripts/ids_snort.sh # ~ tandanya membuat file detect-iface.sh di user yang aktif kamu gunakan saat ini misalnya user yang kamu gunakan root berarti tanda ~ mengarahkan pada diresktori /root, kalo user yang kamu gunakan adalah user biasa berarti dia ada di /home/nama_user_nya_yang kamu_gunakan_apa, kalo mau tahu user yang aktif kamu gunakan apa ketikan perintah ini diterminal: whoami, maka ketika kamu menjalankan perintah itu akan terlihat user yang aktif kamu gunakan saat ini apa
```

Lalu jangan lupa:

```bash
chmod +x ~/scripts/ids_snort.sh
```

---

### 🚀 Jalankan:

```bash
~/scripts/ids_snort.sh
```

Output-nya nanti kayak:

```
✅ Interface yang cocok: enp0s8
```

Tinggal lo pakai itu manual buat jalankan Snort:

```bash
snort -i enp0s8 -c /etc/snort/snort.conf -A console
```



#### 🔥 1. Payload SQL Injection (GET request)

#### 💥 Basic SQLi - `' OR '1'='1`

- 📌 Curl (aman, no error):
    

```bash
curl "http://localhost/?search=%27%20OR%20%271%27=%271"
```

- 📌 Browser:
    

```
http://localhost/?search=' OR '1'='1
```

#### 💥 SQLi dengan komentar (`--`)

```bash
curl "http://localhost/?search=%27%20OR%201=1%20--"
```

#### 💥 Encoded (buat deteksi rules yang ada `%`)

```bash
curl "http://localhost/?search=%2527%2520OR%2520%25271%2527%253D%25271"
```

---

#### 🚨 2. Payload XSS (GET request)

#### 💥 XSS - Basic `<script>`

```bash
curl "http://localhost/?q=%3Cscript%3Ealert(1)%3C%2Fscript%3E"
```

Atau:

```
http://localhost/?q=<script>alert(1)</script>
```

#### 💥 XSS Event Handler (`onerror`)

```bash
curl "http://localhost/?q=<img%20src=x%20onerror=alert(1)>"
```

#### 💥 XSS Encoded

```bash
curl "http://localhost/?q=%3Cimg%20src%3Dx%20onerror%3Dalert(1)%3E"
```

---

#### 💥 3. SQLi POST Body (kalau rules lo pakai `http_client_body`)

```bash
curl -X POST http://localhost/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "username=admin" \
  --data-urlencode "password=' OR '1'='1"
```

---

#### ✅ Tips

| Tipe Serangan       | URL / Body Contoh | Rules Snort Cocok        |
| ------------------- | ----------------- | ------------------------ |
| SQLi `' OR '1'='1`  | `GET` & `POST`    | SID `2000001`, `2000003` |
| SQLi `--` (comment) | `GET`             | SID `2000002`            |
| SQLi `UNION SELECT` | `GET`             | SID `2000006`, `2000007` |
| XSS `<script>`      | `GET`, `POST`     | SID `2100001`, `2100002` |
| XSS `onerror=`      | `GET`, `POST`     | SID `2100006`            |
