<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

include("../auth/database.php");

$raw = file_get_contents("php://input");
$data = json_decode($raw, true);

$name     = trim($data['name'] ?? '');
$email    = trim($data['email'] ?? '');
$password = $data['password'] ?? '';

if (empty($name) || empty($email) || empty($password)) {
    echo json_encode([
        "status"  => false,
        "message" => "Semua field wajib diisi"
    ]);
    exit;
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode([
        "status"  => false,
        "message" => "Format email tidak valid"
    ]);
    exit;
}

if (strlen($password) < 6) {
    echo json_encode([
        "status"  => false,
        "message" => "Password minimal 6 karakter"
    ]);
    exit;
}

// Cek apakah email sudah terdaftar
$check_stmt = $conn->prepare("SELECT id FROM users WHERE email = ? LIMIT 1");
$check_stmt->bind_param("s", $email);
$check_stmt->execute();
$check_result = $check_stmt->get_result();

if ($check_result->num_rows > 0) {
    echo json_encode([
        "status"  => false,
        "message" => "Email sudah digunakan"
    ]);
    $check_stmt->close();
    exit;
}
$check_stmt->close();

$hashed = password_hash($password, PASSWORD_BCRYPT);
$insert_stmt = $conn->prepare("INSERT INTO users (name, email, password, created_at, updated_at) VALUES (?, ?, ?, NOW(), NOW())");
$insert_stmt->bind_param("sss", $name, $email, $hashed);

if ($insert_stmt->execute()) {
    echo json_encode([
        "status"  => true,
        "message" => "Register berhasil",
        "user_id" => (string) $conn->insert_id
    ]);
} else {
    echo json_encode([
        "status"  => false,
        "message" => "Register gagal: " . $insert_stmt->error
    ]);
}

$insert_stmt->close();
$conn->close();
?>