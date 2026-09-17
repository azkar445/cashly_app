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

$user_id = intval($_POST['user_id'] ?? 0);
$name    = trim($_POST['name'] ?? '');

if ($user_id <= 0 || $name === '') {
    echo json_encode(["status" => "error", "msg" => "Data tidak lengkap"]);
    exit;
}

$photo_url = null;

// Handle foto upload
if (isset($_FILES['photo']) && $_FILES['photo']['error'] === UPLOAD_ERR_OK) {
    $uploadDir = '../uploads/avatars/';

    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0755, true);
    }

    $ext     = strtolower(pathinfo($_FILES['photo']['name'], PATHINFO_EXTENSION));
    $allowed = ['jpg', 'jpeg', 'png', 'webp'];

    if (!in_array($ext, $allowed)) {
        echo json_encode(["status" => "error", "msg" => "Format foto tidak didukung (gunakan JPG, PNG, atau WEBP)"]);
        exit;
    }

    if ($_FILES['photo']['size'] > 5 * 1024 * 1024) {
        echo json_encode(["status" => "error", "msg" => "Ukuran foto maksimal 5MB"]);
        exit;
    }

    $filename   = "avatar_{$user_id}_" . time() . ".{$ext}";
    $targetPath = $uploadDir . $filename;

    if (move_uploaded_file($_FILES['photo']['tmp_name'], $targetPath)) {
        $photo_url = "uploads/avatars/{$filename}";
    } else {
        echo json_encode(["status" => "error", "msg" => "Gagal upload foto"]);
        exit;
    }
}

if ($photo_url) {
    $stmt = $conn->prepare("UPDATE users SET name = ?, photo = ?, updated_at = NOW() WHERE id = ?");
    $stmt->bind_param("ssi", $name, $photo_url, $user_id);
} else {
    $stmt = $conn->prepare("UPDATE users SET name = ?, updated_at = NOW() WHERE id = ?");
    $stmt->bind_param("si", $name, $user_id);
}

if ($stmt->execute()) {
    $fetch_stmt = $conn->prepare("SELECT id, name, email, photo FROM users WHERE id = ? LIMIT 1");
    $fetch_stmt->bind_param("i", $user_id);
    $fetch_stmt->execute();
    $user = $fetch_stmt->get_result()->fetch_assoc();
    $fetch_stmt->close();

    echo json_encode([
        "status" => "success",
        "msg"    => "Profil berhasil diperbarui",
        "user"   => [
            "id"    => (string) $user['id'],
            "name"  => $user['name'],
            "email" => $user['email'],
            "photo" => $user['photo'] ?? null,
        ],
    ]);
} else {
    echo json_encode(["status" => "error", "msg" => "Gagal memperbarui profil: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
