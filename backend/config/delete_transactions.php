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

$id      = intval($data['id']);
$user_id = intval($data['user_id']);

$stmt = $conn->prepare("DELETE FROM transactions WHERE id = ? AND user_id = ?");
$stmt->bind_param("ii", $id, $user_id);

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "msg" => "Transaksi dihapus"]);
} else {
    echo json_encode(["status" => "error", "msg" => "Gagal menghapus: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>