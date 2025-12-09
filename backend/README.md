# Backend API - Sistem Reservasi Hotel

Backend ini dibangun menggunakan **Node.js (Express)**, **MySQL**, dan **Prisma ORM**. Menyediakan REST API lengkap untuk autentikasi pengguna, manajemen data hotel & kamar (termasuk upload gambar), sistem booking, dan review.

## 🛠️ Tech Stack

* **Runtime:** Node.js
* **Framework:** Express.js
* **Database:** MySQL
* **ORM:** Prisma
* **Auth:** JWT (JSON Web Token) & Bcrypt (Password Hashing)
* **File Upload:** Multer
* **Language:** JavaScript (CommonJS)

---

## 🚀 Cara Install & Setup

Ikuti langkah-langkah berikut untuk menjalankan backend di komputer lokal.

### 1. Prasyarat
Pastikan sudah menginstall:
* [Node.js](https://nodejs.org/) (v14 ke atas)
* MySQL (bisa via XAMPP atau Laragon)

### 2. Instalasi Dependencies
Buka terminal di folder project, lalu jalankan:
```bash
npm install
```
3. Konfigurasi Environment (.env)
Buat file baru bernama .env di root folder, lalu copy konfigurasi berikut:
```bash
PORT=3000
DATABASE_URL="mysql://root:@localhost:3306/hotel_db"
JWT_SECRET="rahasia_super_aman"
```

Catatan: Sesuaikan root, password (setelah titik dua), dan nama database hotel_db sesuai settingan MySQL Anda.

### 4. Setup Database & Prisma
Pastikan MySQL sudah berjalan (Start di XAMPP/Laragon). Lalu jalankan perintah ini untuk membuat tabel di database:
```bash
npx prisma db push
```

### 5. Buat Folder Upload
Buat folder berikut secara manual agar penyimpanan gambar berhasil:

backend/
├── public/
│   └── uploads/  <-- Buat folder ini kosong

▶️ Cara Menjalankan Server
Jalankan perintah berikut di terminal:

node src/server.js

Jika berhasil, akan muncul pesan: Server running on port 3000

📂 Struktur Folder
src/
├── config/         # Koneksi Database
├── controllers/    # Logika Bisnis (Functions)
├── middlewares/    # Auth & Upload Config
├── routes/         # Definisi URL API
├── utils/          # Standard Response Helper
├── prisma/         # Schema Database
├── app.js          # Express App Setup
└── server.js       # Entry Point