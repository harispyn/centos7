Cara Penggunaan:
Simpan script sebagai install-openvpn.sh
Berikan izin eksekusi:
bash

Line Wrapping

Collapse
Copy
1
chmod +x install-openvpn.sh
Jalankan sebagai root:
bash

Line Wrapping

Collapse
Copy
1
sudo ./install-openvpn.sh
Fitur Script:
Otomatis mendeteksi IP publik server
Menggunakan enkripsi AES-256-CBC dan SHA256
Mengonfigurasi firewalld dengan benar
Membuat file konfigurasi client (.ovpn)
Mengaktifkan IP forwarding dan NAT
Menggunakan port UDP 1194 (default OpenVPN)
