<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

include '../auth/database.php';

$data = json_decode(file_get_contents("php://input"), true);

if (!$data) {
    echo json_encode(["status" => "error", "msg" => "Data kosong"]);
    exit;
}

// 🔥 user_id dari Flutter (bukan hardcode 1)
$user_id   = intval($data['user_id']   ?? 0);
$title     = $conn->real_escape_string($data['title']    ?? '');
$amount    = floatval($data['amount']  ?? 0);
$is_income = intval($data['is_income'] ?? 0);
$category  = $conn->real_escape_string($data['category'] ?? 'Lainnya');

if ($user_id === 0 || $title === '' || $amount <= 0) {
    echo json_encode(["status" => "error", "msg" => "Data tidak lengkap"]);
    exit;
}

$sql = "INSERT INTO transactions 
        (user_id, title, amount, is_income, category, created_at, updated_at)
        VALUES 
        ('$user_id', '$title', '$amount', '$is_income', '$category', NOW(), NOW())";

if ($conn->query($sql) === TRUE) {
    echo json_encode([
        "status" => "success",
        "id"     => (string) $conn->insert_id,
    ]);
} else {
    echo json_encode(["status" => "error", "msg" => $conn->error]);
}

$conn->close();
?>