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
    echo json_encode(["status" => "error", "msg" => "Data kosong"]);
    exit;
}

$user_id   = intval($data['user_id']   ?? 0);
$title     = trim($data['title']       ?? '');
$amount    = floatval($data['amount']  ?? 0);
$is_income = intval($data['is_income'] ?? 0);
$category  = trim($data['category']    ?? 'Lainnya');
$date      = !empty($data['date']) ? $data['date'] : null;

if ($user_id <= 0 || $title === '' || $amount <= 0) {
    echo json_encode(["status" => "error", "msg" => "Data tidak lengkap"]);
    exit;
}

if ($date) {
    $stmt = $conn->prepare("INSERT INTO transactions 
            (user_id, title, amount, is_income, category, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, NOW())");
    $stmt->bind_param("isdiss", $user_id, $title, $amount, $is_income, $category, $date);
} else {
    $stmt = $conn->prepare("INSERT INTO transactions 
            (user_id, title, amount, is_income, category, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, NOW(), NOW())");
    $stmt->bind_param("isdis", $user_id, $title, $amount, $is_income, $category);
}

if ($stmt->execute()) {
    echo json_encode([
        "status" => "success",
        "id"     => (string) $conn->insert_id,
        "msg"    => "Transaksi berhasil ditambahkan"
    ]);
} else {
    echo json_encode(["status" => "error", "msg" => "Gagal menambahkan: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>