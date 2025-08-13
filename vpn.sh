#!/bin/bash

# Cek akses root
if [ "$(id -u)" != "0" ]; then
   echo "Script ini harus dijalankan sebagai root" 1>&2
   exit 1
fi

# Update sistem
echo "Memperbarui sistem..."
yum update -y

# Instal dependensi
echo "Menginstal dependensi..."
yum install -y epel-release
yum install -y openvpn easy-rsa firewalld

# Aktifkan dan mulai firewalld
systemctl enable firewalld
systemctl start firewalld

# Buat direktori easy-rsa
mkdir -p /etc/openvpn/easy-rsa
cp -r /usr/share/easy-rsa/3/* /etc/openvpn/easy-rsa/
cd /etc/openvpn/easy-rsa

# Inisialisasi PKI
./easyrsa init-pki

# Build CA (tanpa password)
./easyrsa build-ca nopass

# Generate server certificate
./easyrsa gen-req server nopass
./easyrsa sign-req server server

# Generate Diffie-Hellman
./easyrsa gen-dh

# Generate HMAC key
openvpn --genkey --secret pki/ta.key

# Salin file ke direktori OpenVPN
cp pki/ca.crt /etc/openvpn/server/
cp pki/issued/server.crt /etc/openvpn/server/
cp pki/private/server.key /etc/openvpn/server/
cp pki/dh.pem /etc/openvpn/server/
cp pki/ta.key /etc/openvpn/server/

# Buat konfigurasi server
cat > /etc/openvpn/server/server.conf <<EOF
port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh.pem
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist /var/log/openvpn/ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 10 120
tls-crypt ta.key
cipher AES-256-CBC
auth SHA256
user nobody
group nobody
persist-key
persist-tun
status /var/log/openvpn/openvpn-status.log
verb 3
explicit-exit-notify 1
EOF

# Buat direktori log
mkdir -p /var/log/openvpn

# Aktifkan IP forwarding
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

# Konfigurasi firewalld
PUBLIC_IP=$(curl -4 ifconfig.co)
firewall-cmd --permanent --add-port=1194/udp
firewall-cmd --permanent --add-service=openvpn
firewall-cmd --permanent --add-masquerade
firewall-cmd --reload

# Enable dan start OpenVPN
systemctl enable openvpn-server@server
systemctl start openvpn-server@server

# Buat direktori untuk client
mkdir -p ~/client-configs/files
chmod 700 ~/client-configs/files

# Generate client certificate
./easyrsa gen-req client1 nopass
./easyrsa sign-req client client1

# Buat konfigurasi client
cat > ~/client-configs/base.conf <<EOF
client
dev tun
proto udp
remote $PUBLIC_IP 1194
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
auth SHA256
key-direction 1
verb 3
EOF

# Buat script generate client config
cat > ~/client-configs/make_config.sh <<EOF
#!/bin/bash
BASE_DIR=~/client-configs
FILES_DIR=\$BASE_DIR/files
BASE_CONF=\$BASE_DIR/base.conf

cat \$BASE_CONF \
    <(echo -e '<ca>') \
    /etc/openvpn/server/ca.crt \
    <(echo -e '</ca>\n<cert>') \
    /etc/openvpn/easy-rsa/pki/issued/client1.crt \
    <(echo -e '</cert>\n<key>') \
    /etc/openvpn/easy-rsa/pki/private/client1.key \
    <(echo -e '</key>\n<tls-crypt>') \
    /etc/openvpn/server/ta.key \
    <(echo -e '</tls-crypt>') \
    > \$FILES_DIR/client1.ovpn
EOF

chmod +x ~/client-configs/make_config.sh
~/client-configs/make_config.sh

echo "Instalasi selesai!"
echo "File konfigurasi client tersedia di: ~/client-configs/files/client1.ovpn"
echo "Salin file ini ke komputer client Anda"
