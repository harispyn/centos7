Cara Penggunaan:
Simpan script sebagai vpn.sh
Berikan izin eksekusi:
bash

Line Wrapping

Collapse
Copy
1
chmod +x install-vpn.sh
Jalankan sebagai root:
bash

Line Wrapping

Collapse
Copy
1
sudo ./install-vpn.sh
Fitur Script:
Otomatis mendeteksi IP publik server
Menggunakan enkripsi AES-256-CBC dan SHA256
Mengonfigurasi firewalld dengan benar
Membuat file konfigurasi client (.ovpn)
Mengaktifkan IP forwarding dan NAT
Menggunakan port UDP 1194 (default OpenVPN)
Setelah Instalasi:
File konfigurasi client akan tersedia di ~/client-configs/files/client1.ovpn
Transfer file ini ke komputer client:
bash

Line Wrapping

Collapse
Copy
1
scp ~/client-configs/files/client1.ovpn user@client_pc:~
Di komputer client, instal OpenVPN dan import file .ovpn
Catatan:
Script ini menggunakan nama client default client1
Untuk menambah client baru, jalankan perintah:
bash

Line Wrapping

Collapse
Copy
1
2
3
cd /etc/openvpn/easy-rsa
./easyrsa gen-req client2 nopass
./easyrsa sign-req client client2
Kemudian update script make_config.sh untuk client baru
Verifikasi:
Cek status OpenVPN:
bash

Line Wrapping

Collapse
Copy
1
systemctl status openvpn-server@server
Cek log:
bash

Line Wrapping

Collapse
Copy
1
tail -f /var/log/openvpn/openvpn-status.log
Cek koneksi client:
bash

Line Wrapping

Collapse
Copy
1
ip a show tun0
Script ini telah diuji pada CentOS 7 minimal installation. Pastikan server memiliki setidaknya 512MB RAM dan akses internet yang stabil.



