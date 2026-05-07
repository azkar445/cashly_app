<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

include '../auth/database.php';

$data = json_decode(file_get_contents("php://input"), true);

if (!$data || !isset($data['user_id'])) {
    echo json_encode(["status" => "error", "msg" => "user_id diperlukan"]);
    exit;
}

$user_id = intval($data['user_id']);

$sql = "SELECT id, user_id, title, amount, is_income, category, created_at 
        FROM transactions 
        WHERE user_id = '$user_id' 
        ORDER BY created_at DESC";

$result = $conn->query($sql);

if (!$result) {
    echo json_encode(["status" => "error", "msg" => $conn->error]);
    exit;
}

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
$conn->close();
?>