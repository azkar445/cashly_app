<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

include '../auth/database.php';

$data = json_decode(file_get_contents("php://input"), true);

if (!$data || !isset($data['id']) || !isset($data['user_id'])) {
    echo json_encode(["status" => "error", "msg" => "id dan user_id diperlukan"]);
    exit;
}

$id        = intval($data['id']);
$user_id   = intval($data['user_id']);
$title     = $conn->real_escape_string($data['title']    ?? '');
$amount    = floatval($data['amount']   ?? 0);
$is_income = intval($data['is_income']  ?? 0);
$category  = $conn->real_escape_string($data['category'] ?? 'Lainnya');

if ($title === '' || $amount <= 0) {
    echo json_encode(["status" => "error", "msg" => "Data tidak lengkap"]);
    exit;
}

// Pastikan hanya bisa edit transaksi milik sendiri
$sql = "UPDATE transactions 
        SET title='$title', amount='$amount', is_income='$is_income', 
            category='$category', updated_at=NOW()
        WHERE id='$id' AND user_id='$user_id'";

if ($conn->query($sql) === TRUE && $conn->affected_rows > 0) {
    echo json_encode(["status" => "success", "msg" => "Transaksi diperbarui"]);
} else {
    echo json_encode(["status" => "error", "msg" => "Transaksi tidak ditemukan"]);
}

$conn->close();
?>