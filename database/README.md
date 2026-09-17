# 🗄️ Database Setup: Cashly

File skrip database: `database/keuangan_app.sql`

## 📋 Informasi Database Default
- **Nama Database**: `keuangan_app`
- **Host**: `localhost` (atau `127.0.0.1`)
- **Port**: `3306`
- **User**: `root`
- **Password**: *(kosong)*

---

## 🚀 Cara Import Database

### Metode 1: Menggunakan phpMyAdmin (XAMPP / Laragon)
1. Buka browser dan kunjungi `http://localhost/phpmyadmin`.
2. Klik tab **Databases / Basis data**, masukkan nama `keuangan_app`, lalu klik **Create / Buat**.
3. Pilih database `keuangan_app` yang baru dibuat.
4. Klik tab **Import**, lalu klik **Choose File / Telusuri**.
5. Pilih file `database/keuangan_app.sql` dari project ini.
6. Scroll ke bawah dan klik tombol **Import / Kirim**.

### Metode 2: Menggunakan Terminal / CMD (MySQL CLI)
Pastikan MySQL sudah berjalan, lalu jalankan perintah berikut di terminal:
```bash
mysql -u root -e "CREATE DATABASE IF NOT EXISTS keuangan_app;"
mysql -u root keuangan_app < database/keuangan_app.sql
```

---

## 📊 Struktur Tabel

### 1. `users`
Tabel untuk menyimpan akun pengguna yang terdaftar.
| Kolom | Tipe Data | Keterangan |
|---|---|---|
| `id` | INT (PK, Auto Increment) | ID unik user |
| `name` | VARCHAR(100) | Nama lengkap user |
| `email` | VARCHAR(100, Unique) | Email untuk login |
| `password` | VARCHAR(100) | Hash password (bcrypt) |
| `photo` | VARCHAR(500) | Path atau URL foto profil |
| `created_at` | TIMESTAMP | Waktu pendaftaran |
| `updated_at` | TIMESTAMP | Waktu pembaruan profil |

### 2. `transactions`
Tabel untuk menyimpan catatan transaksi keuangan user.
| Kolom | Tipe Data | Keterangan |
|---|---|---|
| `id` | INT (PK, Auto Increment) | ID unik transaksi |
| `user_id` | INT (FK -> users.id) | Pemilik transaksi |
| `title` | VARCHAR(100) | Judul / deskripsi transaksi |
| `amount` | DOUBLE | Nominal uang |
| `is_income` | TINYINT(1) | 1 = Pemasukan, 0 = Pengeluaran |
| `category` | VARCHAR(50) | Kategori (Makanan, Belanja, dll) |
| `created_at` | TIMESTAMP | Tanggal transaksi |
| `updated_at` | TIMESTAMP | Waktu perubahan terakhir |
