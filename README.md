# 💎 Cashly – Aplikasi Manajemen Keuangan Cerdas

**Cashly** adalah aplikasi manajemen finansial modern berbasis Flutter dengan backend PHP & MySQL. Dirancang untuk pencatatan transaksi cepat, analisis pengeluaran berbasis aturan 50/30/20, kecerdasan buatan (AI) konsultasi keuangan, dan ketahanan offline (offline-first caching).

---

## 📁 Struktur Folder Project

```text
cashly_app/
├── android/                 # Konfigurasi native Android (Cleartext HTTP enabled & izin storage/kamera)
├── backend/                 # Backend API (PHP & MySQL)
│   ├── auth/
│   │   └── database.php     # Konfigurasi koneksi MySQL & validasi error JSON
│   ├── config/              # Endpoint REST API
│   │   ├── login.php
│   │   ├── register.php
│   │   ├── forgot_password.php
│   │   ├── update_password.php
│   │   ├── update_profile.php
│   │   ├── get_transactions.php
│   │   ├── add_transactions.php
│   │   ├── update_transactions.php
│   │   └── delete_transactions.php
│   ├── uploads/avatars/     # Direktori penyimpanan foto profil user
│   └── index.php            # Status API & dokumentasi endpoint
├── database/                # Skrip & dokumentasi basis data
│   ├── keuangan_app.sql     # Skrip SQL dump tabel users & transactions
│   └── README.md            # Panduan import database phpMyAdmin / CLI
├── lib/                     # Kode Sumber Flutter (Frontend)
│   ├── main.dart            # Titik masuk aplikasi & routing splash screen
│   ├── models/              # Model data (TransactionModel, UserModel)
│   ├── providers/           # State management (ThemeProvider untuk Light/Dark mode)
│   ├── screens/             # Layar antarmuka pengguna (UI)
│   │   ├── splash_screen.dart
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── forgot_password_screen.dart
│   │   ├── main_screen.dart (Navigasi tab & Floating Pill Navbar)
│   │   ├── home_screen.dart (Ringkasan saldo, Quick Actions, transaksi terkini)
│   │   ├── transaction_screen.dart (Riwayat transaksi, filter, search)
│   │   ├── add_transaction_screen.dart (Form input, date picker, chips nominal)
│   │   ├── insight_screen.dart (Analisis aturan 50/30/20 & statistik bulanan)
│   │   ├── ai_screen.dart (Asisten AI konsultan keuangan interaktif)
│   │   ├── profile_screen.dart (Profil, ekspor ringkasan, ubah password)
│   │   ├── edit_profile_screen.dart
│   │   ├── change_password_screen.dart
│   │   ├── notification_screen.dart
│   │   ├── help_screen.dart
│   │   └── about_screen.dart
│   ├── services/            # Komunikasi data & logika backend
│   │   ├── api_constants.dart (Dynamic host 10.0.2.2 vs localhost)
│   │   ├── auth_service.dart
│   │   ├── local_storage_service.dart (SharedPreferences & cache offline)
│   │   ├── transaction_service.dart (Pola cache-first)
│   │   ├── financial_analytics_service.dart
│   │   └── ai_service.dart
│   ├── theme/               # Palet warna kurasi (AppColors)
│   └── widgets/             # Komponen UI modular (BalanceCard, SummaryCard, TransactionItem)
├── pubspec.yaml             # Dependensi Flutter
└── README.md                # Dokumentasi utama project
```

---

## 🛠️ Panduan Instalasi & Menjalankan Project

### 1. Persiapan Database
1. Buka XAMPP / Laragon, pastikan **MySQL** aktif.
2. Buat database baru bernama `keuangan_app` di **phpMyAdmin** (`http://localhost/phpmyadmin`).
3. Import file `database/keuangan_app.sql`.

### 2. Menjalankan Backend PHP
Pilih salah satu metode berikut:

- **Metode A (XAMPP / Laragon Web Root)**:
  Salin atau symlink folder `backend` ke dalam folder web server Anda:
  - XAMPP: `C:/xampp/htdocs/keuangan_api`
  - Laragon: `C:/laragon/www/keuangan_api`
  Akses di browser: `http://localhost/keuangan_api` untuk memverifikasi status API.

- **Metode B (PHP Built-in Server)**:
  Buka terminal di folder project dan jalankan:
  ```bash
  cd backend
  php -S 0.0.0.0:8000
  ```

### 3. Menjalankan Aplikasi Flutter
Pastikan Flutter SDK sudah terpasang, lalu jalankan:

```bash
# 1. Unduh paket dependensi
flutter pub get

# 2. Jalankan pada Android Emulator atau Windows
flutter run
```

> **💡 Catatan Koneksi Emulator Android:**
> Flutter secara otomatis mengarahkan koneksi ke `http://10.0.2.2/keuangan_api` saat berjalan di Android Emulator (diatur di `lib/services/api_constants.dart`).
> AndroidManifest juga telah dikonfigurasi dengan `usesCleartextTraffic="true"` sehingga koneksi HTTP lokal berjalan tanpa hambatan keamanan.

> **💡 Mode Tamu / Demo:**
> Ingin menguji aplikasi tanpa menyalakan server MySQL?
> Di halaman login, tekan tombol **"Coba Mode Tamu / Demo"** untuk langsung menjelajahi seluruh fitur dengan data simulasi lokal.

---

## 🌟 Fitur Unggulan
1. **Pencatatan Cepat**: Form input transaksi dengan Quick Nominal Chips (+10rb s/d +500rb), Date Picker, dan AI Smart Category Suggester.
2. **Analisis Budgeting 50/30/20**: Menghitung porsi kebutuhan, keinginan, dan tabungan/investasi secara real-time.
3. **AI Financial Advisor**: Asisten pintar yang memberikan saran penghematan dan mendeteksi pemborosan.
4. **Offline Resilience**: Seluruh data transaksi tersimpan di memori cache lokal sehingga aplikasi tetap responsif saat tidak ada koneksi server.
5. **Dark & Light Mode**: Desain modern dengan dukungan tema gelap dan terang yang nyaman di mata.
6. **Ekspor Ringkasan**: Salin ringkasan finansial ke clipboard langsung dari tab profil.
