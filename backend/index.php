<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Cek koneksi database
$dbStatus = "disconnected";
$dbError  = null;
try {
    include_once __DIR__ . "/auth/database.php";
    if (isset($conn) && $conn instanceof mysqli && !$conn->connect_error) {
        $dbStatus = "connected";
    }
} catch (Exception $e) {
    $dbError = $e->getMessage();
}

echo json_encode([
    "app"       => "Cashly Backend API",
    "version"   => "1.0.0",
    "status"    => "running",
    "database"  => [
        "status" => $dbStatus,
        "error"  => $dbError,
    ],
    "timestamp" => date("Y-m-d H:i:s"),
    "endpoints" => [
        "auth" => [
            "POST /config/login.php"           => "Login pengguna",
            "POST /config/register.php"        => "Registrasi pengguna baru",
            "POST /config/forgot_password.php" => "Reset password dengan email",
            "POST /config/update_password.php" => "Ubah password pengguna lama",
            "POST /config/update_profile.php"  => "Pembaruan profil dan upload foto avatar",
        ],
        "transactions" => [
            "GET  /config/get_transactions.php?user_id={id}" => "Ambil daftar transaksi pengguna",
            "POST /config/add_transactions.php"              => "Tambah transaksi baru",
            "POST /config/update_transactions.php"           => "Perbarui transaksi yang ada",
            "POST /config/delete_transactions.php"           => "Hapus transaksi berdasarkan ID",
        ],
    ],
], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
