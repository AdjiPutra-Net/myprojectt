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

# 🟢 AUTO-DETEKSI IP LOKAL (bukan 127.0.0.1)
CLIENT_IP=$(ip -4 addr show | awk '/inet/ && $2 !~ /^127/ {print $2}' | cut -d'/' -f1 | head -n1)

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
