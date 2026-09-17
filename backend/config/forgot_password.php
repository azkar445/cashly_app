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

$action = $data['action'] ?? '';

// ── ACTION 1: Cek apakah email terdaftar ──────────────────────────────────
if ($action === 'check_email') {
    $email = trim($data['email'] ?? '');

    if (empty($email)) {
        echo json_encode(["status" => false, "message" => "Email tidak boleh kosong"]);
        exit;
    }

    $stmt = $conn->prepare("SELECT id, name FROM users WHERE email = ? LIMIT 1");
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $user = $result->fetch_assoc();
        echo json_encode([
            "status"  => true,
            "message" => "Email ditemukan",
            "user_id" => (int) $user['id'],
            "name"    => $user['name'],
        ]);
    } else {
        echo json_encode([
            "status"  => false,
            "message" => "Email tidak terdaftar",
        ]);
    }
    $stmt->close();
    $conn->close();
    exit;
}

// ── ACTION 2: Reset password ──────────────────────────────────────────────
if ($action === 'reset_password') {
    $user_id      = intval($data['user_id'] ?? 0);
    $new_password = $data['new_password']   ?? '';

    if ($user_id <= 0 || empty($new_password)) {
        echo json_encode(["status" => false, "message" => "Data tidak lengkap"]);
        exit;
    }

    if (strlen($new_password) < 6) {
        echo json_encode(["status" => false, "message" => "Password minimal 6 karakter"]);
        exit;
    }

    $hashed = password_hash($new_password, PASSWORD_BCRYPT);
    $stmt = $conn->prepare("UPDATE users SET password = ?, updated_at = NOW() WHERE id = ?");
    $stmt->bind_param("si", $hashed, $user_id);

    if ($stmt->execute()) {
        echo json_encode(["status" => true, "message" => "Password berhasil direset"]);
    } else {
        echo json_encode(["status" => false, "message" => "Gagal mereset password: " . $stmt->error]);
    }
    $stmt->close();
    $conn->close();
    exit;
}

echo json_encode(["status" => false, "message" => "Action tidak dikenali"]);
$conn->close();
?>
