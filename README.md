# 🏨 Aplikasi Reservasi Hotel (Full Stack)

Project ini adalah aplikasi sistem reservasi hotel lengkap yang terdiri dari **Backend (REST API)** dan **Frontend (Mobile App)**. Dibangun untuk memenuhi tugas UAS/Project Akhir.

![Project Status](https://img.shields.io/badge/Status-Completed-success)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-blue)

## 🏗️ Arsitektur Project

Repository ini dibagi menjadi dua folder utama:

* **`backend/`**: Server API menggunakan Node.js, Express, dan Prisma (MySQL).
* **`frontend/`**: Aplikasi Mobile menggunakan Flutter.

---

## 🛠️ Teknologi yang Digunakan

### Backend (Server Side)
* **Runtime:** Node.js
* **Framework:** Express.js
* **Database:** MySQL
* **ORM:** Prisma
* **Auth:** JWT (JSON Web Token)
* **Upload:** Multer (Local Storage)

### Frontend (Client Side)
* **Framework:** Flutter (Dart)
* **State Management:** `setState` & `Provider` (Optional)
* **HTTP Client:** `http` package
* **Local Storage:** `shared_preferences`

---

## 🚀 Cara Menjalankan Project (Quick Start)

Ikuti langkah-langkah ini secara berurutan agar aplikasi berjalan lancar.

### 1. Persiapan Database
1.  Pastikan **XAMPP** atau **MySQL** sudah berjalan.
2.  Buat database baru di phpMyAdmin bernama: `hotel_db`.

### 2. Setup Backend
Buka terminal dan masuk ke folder backend:

```bash
cd backend
npm install
```

Konfigurasi Environment: Buat file .env di dalam folder backend/ dan isi:
```bash
PORT=3000
DATABASE_URL="mysql://root:@localhost:3306/hotel_db"
JWT_SECRET="hotel_gacor_josgandos"
```
Migrasi Database: Jalankan perintah ini untuk membuat tabel otomatis:

```Bash
npx prisma db push
```

Jalankan Seeding:
```bash
npx prisma db seed
```

Jalankan Server:

```Bash
node src/server.js
```
(Pastikan server berjalan di port 3000).

### 3. Setup Frontend (Flutter)
Buka terminal baru (jangan matikan terminal backend), lalu masuk ke folder frontend:

```Bash
cd frontend
flutter pub get
```

Konfigurasi IP Address (PENTING ⚠️): Buka file lib/config/api_config.dart.

Jika pakai Emulator Android, gunakan IP: 10.0.2.2.

Jika pakai HP Fisik, gunakan IP Laptop: 192.168.1.XX (Pastikan satu WiFi).

Jalankan Aplikasi:

```Bash
flutter run
```


📱 Fitur Utama
1. Role: User (Pelanggan)
Register & Login: Membuat akun baru.

Search Hotel: Mencari hotel berdasarkan nama/lokasi.

Detail Hotel: Melihat foto, deskripsi, dan fasilitas.

Booking Kamar: Memilih tanggal Check-in/Check-out (Harga otomatis dihitung).

Riwayat Booking: Melihat status pesanan (Pending/Confirmed).

Review: Memberi rating bintang setelah menginap.

2. Role: Admin (Pengelola)
Dashboard: Melihat ringkasan data.

Kelola Hotel (CRUD): Tambah, Edit, Hapus Hotel (Upload Foto dari Galeri).

Kelola Kamar (CRUD): Menambah tipe kamar, harga, dan kapasitas.

🧪 Akun Demo (Testing)
Jika database masih kosong, silakan Register lewat aplikasi atau gunakan Postman untuk membuat Admin pertama kali.

Contoh Akun Admin:

Email: admin@hotel.com

Password: admin123

(Pastikan role di database diset 'ADMIN')

Contoh Akun User:

Email: user@test.com

Password: user123
