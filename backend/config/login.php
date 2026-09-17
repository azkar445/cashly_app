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

$email    = trim($data['email'] ?? '');
$password = $data['password'] ?? '';

if (empty($email) || empty($password)) {
    echo json_encode([
        "status"  => false,
        "message" => "Email dan password wajib diisi"
    ]);
    exit;
}

$stmt = $conn->prepare("SELECT id, name, email, password, photo FROM users WHERE email = ? LIMIT 1");
if (!$stmt) {
    echo json_encode(["status" => false, "message" => "Database error: " . $conn->error]);
    exit;
}

$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();

    if (password_verify($password, $user['password'])) {
        echo json_encode([
            "status"  => true,
            "message" => "Login berhasil",
            "user"    => [
                "id"    => (string) $user['id'],
                "name"  => $user['name'],  
                "email" => $user['email'],
                "photo" => $user['photo'] ?? null,
            ]
        ]);
    } else {
        echo json_encode([
            "status"  => false,
            "message" => "Password salah"
        ]);
    }
} else {
    echo json_encode([
        "status"  => false,
        "message" => "User tidak ditemukan"
    ]);
}

$stmt->close();
$conn->close();
?>