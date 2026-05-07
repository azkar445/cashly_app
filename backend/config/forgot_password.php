<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

include '../auth/database.php';

$data = json_decode(file_get_contents("php://input"), true);

$action = $data['action'] ?? '';

// ── ACTION 1: Cek apakah email terdaftar ──────────────────────────────────
if ($action === 'check_email') {
    $email = $conn->real_escape_string($data['email'] ?? '');

    if (empty($email)) {
        echo json_encode(["status" => false, "message" => "Email tidak boleh kosong"]);
        exit;
    }

    $result = $conn->query("SELECT id, name FROM users WHERE email='$email'");

    if ($result->num_rows > 0) {
        $user = $result->fetch_assoc();
        echo json_encode([
            "status"  => true,
            "message" => "Email ditemukan",
            "user_id" => $user['id'],
            "name"    => $user['name'],
        ]);
    } else {
        echo json_encode([
            "status"  => false,
            "message" => "Email tidak terdaftar",
        ]);
    }
    exit;
}

// ── ACTION 2: Reset password ──────────────────────────────────────────────
if ($action === 'reset_password') {
    $user_id     = intval($data['user_id']      ?? 0);
    $new_password= $data['new_password']        ?? '';

    if ($user_id === 0 || empty($new_password)) {
        echo json_encode(["status" => false, "message" => "Data tidak lengkap"]);
        exit;
    }

    if (strlen($new_password) < 6) {
        echo json_encode(["status" => false, "message" => "Password minimal 6 karakter"]);
        exit;
    }

    $hashed = password_hash($new_password, PASSWORD_BCRYPT);
    $sql    = "UPDATE users SET password='$hashed', updated_at=NOW() WHERE id='$user_id'";

    if ($conn->query($sql) === TRUE) {
        echo json_encode(["status" => true, "message" => "Password berhasil direset"]);
    } else {
        echo json_encode(["status" => false, "message" => "Gagal mereset password"]);
    }
    exit;
}

echo json_encode(["status" => false, "message" => "Action tidak dikenali"]);
$conn->close();
?>
