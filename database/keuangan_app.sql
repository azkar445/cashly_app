-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Waktu pembuatan: 07 Bulan Mei 2026 pada 11.12
-- Versi server: 8.0.30
-- Versi PHP: 8.1.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `keuangan_app`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `transactions`
--

CREATE TABLE `transactions` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `title` varchar(100) NOT NULL,
  `amount` double NOT NULL,
  `is_income` tinyint(1) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `category` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data untuk tabel `transactions`
--

INSERT INTO `transactions` (`id`, `user_id`, `title`, `amount`, `is_income`, `created_at`, `updated_at`, `category`) VALUES
(1, 1, 'test makan', 20000, 0, '2026-04-22 06:15:07', '2026-04-22 06:15:07', 'Makanan'),
(2, 1, 'nasi ayam', 25000, 0, '2026-04-22 07:00:48', '2026-04-22 07:00:48', NULL),
(3, 1, 'gojek', 230000, 1, '2026-04-22 11:38:30', '2026-04-22 11:38:30', NULL),
(4, 1, 'cek gigi', 430000, 0, '2026-04-22 11:39:49', '2026-04-22 11:39:49', NULL),
(18, 2, 'gaji', 20000, 1, '2026-04-23 08:37:13', '2026-04-23 08:37:13', 'Income'),
(19, 2, 'gaji', 20000000, 1, '2026-04-23 08:39:18', '2026-04-23 08:39:18', 'Income'),
(20, 2, 'gaji sampingan', 30000000, 1, '2026-04-23 09:39:56', '2026-04-23 09:39:56', 'Income'),
(21, 2, 'traktir makan', 212500, 0, '2026-04-23 09:40:20', '2026-04-23 09:40:20', 'Makanan'),
(23, 2, 'biaya ke dokter kandungan', 2500000, 0, '2026-04-23 11:26:26', '2026-04-23 11:26:26', 'Kesehatan'),
(25, 2, 'makan ayam goreng', 100000, 0, '2026-04-25 10:21:54', '2026-04-25 10:21:54', 'Makanan'),
(26, 2, 'makan nasi goreng', 100000, 0, '2026-04-29 09:43:05', '2026-04-29 09:43:05', 'Makanan'),
(27, 2, 'biaya pesawat menuju jakarta', 3200000, 0, '2026-04-29 09:47:43', '2026-04-29 09:47:43', 'Transport'),
(28, 2, 'nasi pecel', 30000, 0, '2026-04-29 09:48:01', '2026-04-29 09:48:01', 'Makanan'),
(29, 2, 'gaji hari ini', 2000000, 1, '2026-04-29 09:48:39', '2026-04-29 09:48:39', 'Income'),
(30, 2, 'penerbangan ke thailand', 6500000, 0, '2026-04-29 09:51:55', '2026-04-29 09:51:55', 'Transport'),
(31, 2, 'ukt kuliah', 5000000, 0, '2026-04-29 09:52:38', '2026-04-29 09:52:38', 'Pendidikan'),
(34, 2, 'shopee', 430000, 0, '2026-04-29 10:07:11', '2026-04-29 10:07:11', 'Belanja'),
(35, 2, 'nasi jinggo', 20000, 0, '2026-04-29 10:42:10', '2026-04-29 10:42:10', 'Makanan'),
(37, 2, 'nonton film', 340000, 0, '2026-05-02 06:51:54', '2026-05-02 06:51:54', 'Hiburan'),
(38, 2, 'nonton bioskop', 345000, 0, '2026-05-02 17:02:16', '2026-05-02 17:02:16', 'Hiburan'),
(39, 2, 'gaji tahun', 100000000, 1, '2026-05-02 17:02:54', '2026-05-02 17:02:54', 'Income');

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `photo` varchar(500) DEFAULT NULL,
  `password` varchar(100) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `photo`, `password`, `created_at`, `updated_at`) VALUES
(1, 'Deadingmangole', 'deadie@gmail.com', NULL, '$2y$10$29djiZ55tJrPBmDOlPF9veudAmLgRK0qO7dsJcQLoed95AyWRIT4S', '2026-03-29 07:18:58', '2026-03-29 07:18:58'),
(2, 'marsel', 'marsel@gmail.com', 'http://10.0.2.2/keuangan_api/uploads/avatars/avatar_2_1777992010.jpg', '$2y$10$u7jl/jEv9NhsAFI.rc.t3urmLKk6Yq5WG6Opn8CoQApPQ7lwg9jO.', '2026-03-29 07:38:55', '2026-05-05 14:40:10'),
(3, 'aldi', 'ruskita@gmail.com', NULL, '$2y$10$CQGpl8MXyAv7KvC25h2T6OTeeLhaGbD1VBL5KWQWfRbYBiY937Uba', '2026-04-02 13:57:33', '2026-04-02 13:57:33');

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_user` (`user_id`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `transactions`
--
ALTER TABLE `transactions`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `transactions`
--
ALTER TABLE `transactions`
  ADD CONSTRAINT `fk_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
