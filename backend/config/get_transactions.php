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

if (!$data || !isset($data['user_id'])) {
    echo json_encode(["status" => "error", "msg" => "user_id diperlukan"]);
    exit;
}

$user_id = intval($data['user_id']);

$stmt = $conn->prepare("SELECT id, user_id, title, amount, is_income, category, created_at 
                        FROM transactions 
                        WHERE user_id = ? 
                        ORDER BY created_at DESC");
if (!$stmt) {
    echo json_encode(["status" => "error", "msg" => "Database error: " . $conn->error]);
    exit;
}

$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();

$transactions = [];
while ($row = $result->fetch_assoc()) {
    $transactions[] = [
        "id"        => (string) $row['id'],
        "title"     => $row['title'],
        "amount"    => (float)  $row['amount'],
        "is_income" => (bool)   $row['is_income'],
        "category"  => $row['category'] ?? "Lainnya",
        "date"      => $row['created_at'],
    ];
}

echo json_encode(["status" => "success", "data" => $transactions]);

$stmt->close();
$conn->close();
?>