# Frontend Aplikasi Reservasi Hotel (Flutter)

Aplikasi mobile untuk sistem reservasi hotel, dibangun menggunakan **Flutter**. Aplikasi ini berfungsi sebagai client-side yang terhubung dengan Backend (Express.js + Prisma).

Mendukung dua role pengguna: **Customer** (Pemesanan) dan **Admin** (Manajemen Data).

## 📱 Fitur Aplikasi

### 👤 User (Customer)
* **Auth:** Register akun baru & Login.
* **Search & Browse:** Mencari hotel berdasarkan nama/lokasi.
* **Detail Hotel:** Melihat deskripsi, rating, foto, dan daftar kamar.
* **Booking:** Memesan kamar dengan memilih tanggal check-in/check-out (Harga hitung otomatis).
* **Riwayat:** Melihat daftar pesanan (Booking History).
* **Review:** Memberikan ulasan dan rating bintang setelah status booking `CONFIRMED`.

### 🛡️ Admin
* **Dashboard:** Melihat daftar semua hotel.
* **Manajemen Hotel (CRUD):** Tambah, Edit, dan Hapus data Hotel (termasuk upload foto dari galeri).
* **Manajemen Kamar (CRUD):** Tambah, Edit, dan Hapus Kamar di dalam hotel.

---

## 🛠️ Tech Stack & Packages

* **Framework:** Flutter (Dart)
* **Networking:** `http` (Request ke REST API)
* **Local Storage:** `shared_preferences` (Simpan Token Login & Role)
* **Formatting:** `intl` (Format Rupiah & Tanggal)
* **Image Picker:** `image_picker` (Upload gambar dari Galeri)
* **UI Components:** Material Design 3

---

## 🚀 Cara Install & Menjalankan

### 1. Prasyarat
* Flutter SDK terinstall.
* Android Studio / VS Code.
* **Backend sudah berjalan** (Pastikan server Node.js menyala di port 3000).

### 2. Instalasi Dependencies
Buka terminal di folder `frontend`, lalu jalankan:
```bash
flutter pub get
```

### 3. Konfigurasi URL API (PENTING ⚠️)
Agar aplikasi di HP/Emulator bisa terhubung ke Backend di laptop, Anda harus mengatur URL di file lib/config/api_config.dart.

Jika menggunakan Android Emulator: Gunakan IP 10.0.2.2.

static const String baseUrl = "[http://10.0.2.2:3000/api](http://10.0.2.2:3000/api)";
static const String imageUrl = "[http://10.0.2.2:3000/uploads/](http://10.0.2.2:3000/uploads/)";
Jika menggunakan HP Fisik (USB Debugging): Gunakan IP Laptop (misal: 192.168.1.XX). Pastikan HP dan Laptop di WiFi yang sama.

static const String baseUrl = "[http://192.168.1.15:3000/api](http://192.168.1.15:3000/api)"; // Ganti sesuai IP Laptop

### 4. Jalankan Aplikasi
Pastikan emulator sudah nyala atau HP terhubung.

```bash
flutter run
```