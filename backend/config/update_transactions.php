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

if (!$data || !isset($data['id']) || !isset($data['user_id'])) {
    echo json_encode(["status" => "error", "msg" => "id dan user_id diperlukan"]);
    exit;
}

$id        = intval($data['id']);
$user_id   = intval($data['user_id']);
$title     = trim($data['title']       ?? '');
$amount    = floatval($data['amount']  ?? 0);
$is_income = intval($data['is_income'] ?? 0);
$category  = trim($data['category']    ?? 'Lainnya');
$date      = !empty($data['date']) ? $data['date'] : null;

if ($id <= 0 || $user_id <= 0 || $title === '' || $amount <= 0) {
    echo json_encode(["status" => "error", "msg" => "Data tidak lengkap"]);
    exit;
}

if ($date) {
    $stmt = $conn->prepare("UPDATE transactions 
            SET title = ?, amount = ?, is_income = ?, category = ?, created_at = ?, updated_at = NOW()
            WHERE id = ? AND user_id = ?");
    $stmt->bind_param("sdisiii", $title, $amount, $is_income, $category, $date, $id, $user_id);
} else {
    $stmt = $conn->prepare("UPDATE transactions 
            SET title = ?, amount = ?, is_income = ?, category = ?, updated_at = NOW()
            WHERE id = ? AND user_id = ?");
    $stmt->bind_param("sdisii", $title, $amount, $is_income, $category, $id, $user_id);
}

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "msg" => "Transaksi diperbarui"]);
} else {
    echo json_encode(["status" => "error", "msg" => "Gagal update: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>