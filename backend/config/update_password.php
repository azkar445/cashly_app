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

include '../auth/database.php';

$raw = file_get_contents("php://input");
$data = json_decode($raw, true);

if (!$data) {
    echo json_encode(["status" => false, "message" => "Payload tidak valid"]);
    exit;
}

$user_id  = intval($data['user_id'] ?? 0);
$old_pass = $data['old_password'] ?? '';
$new_pass = $data['new_password'] ?? '';

if ($user_id <= 0 || empty($old_pass) || empty($new_pass)) {
    echo json_encode(["status" => false, "message" => "Data tidak lengkap"]);
    exit;
}

if (strlen($new_pass) < 6) {
    echo json_encode(["status" => false, "message" => "Password baru minimal 6 karakter"]);
    exit;
}

// 1. Cek user dan verifikasi password lama
$stmt = $conn->prepare("SELECT id, password FROM users WHERE id = ? LIMIT 1");
if (!$stmt) {
    echo json_encode(["status" => false, "message" => "Database error: " . $conn->error]);
    exit;
}

$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode(["status" => false, "message" => "User tidak ditemukan"]);
    $stmt->close();
    exit;
}

$user = $result->fetch_assoc();
$stmt->close();

if (!password_verify($old_pass, $user['password'])) {
    echo json_encode(["status" => false, "message" => "Password lama salah"]);
    exit;
}

// 2. Hash password baru dan update
$hashed_new = password_hash($new_pass, PASSWORD_BCRYPT);
$update_stmt = $conn->prepare("UPDATE users SET password = ?, updated_at = NOW() WHERE id = ?");
if (!$update_stmt) {
    echo json_encode(["status" => false, "message" => "Database error: " . $conn->error]);
    exit;
}

$update_stmt->bind_param("si", $hashed_new, $user_id);

if ($update_stmt->execute()) {
    echo json_encode(["status" => true, "message" => "Password berhasil diubah"]);
} else {
    echo json_encode(["status" => false, "message" => "Gagal mengubah password: " . $update_stmt->error]);
}

$update_stmt->close();
$conn->close();
?>
