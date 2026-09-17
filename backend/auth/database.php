<?php
$host = getenv('DB_HOST') ?: "localhost";
$user = getenv('DB_USER') ?: "root";
$pass = getenv('DB_PASS') !== false ? getenv('DB_PASS') : "";
$db   = getenv('DB_NAME') ?: "keuangan_app";
$port = getenv('DB_PORT') ? intval(getenv('DB_PORT')) : 3306;

// Matikan laporan mysqli default agar tidak mencetak warning HTML ke JSON
mysqli_report(MYSQLI_REPORT_OFF);

$conn = @new mysqli($host, $user, $pass, $db, $port);

if ($conn->connect_error) {
    header("Content-Type: application/json");
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "msg"    => "Koneksi database gagal: " . $conn->connect_error . ". Pastikan server MySQL (XAMPP/Laragon) aktif dan database '$db' telah di-import."
    ]);
    exit;
}

$conn->set_charset("utf8mb4");
?>