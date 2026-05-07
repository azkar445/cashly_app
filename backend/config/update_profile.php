<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

include '../auth/database.php';

$user_id = intval($_POST['user_id'] ?? 0);
$name    = $conn->real_escape_string($_POST['name'] ?? '');

if ($user_id === 0 || $name === '') {
    echo json_encode(["status" => "error", "msg" => "Data tidak lengkap"]);
    exit;
}

$photo_url = null;

// Handle foto upload
if (isset($_FILES['photo']) && $_FILES['photo']['error'] === UPLOAD_ERR_OK) {
    $uploadDir = '../uploads/avatars/';

    // Buat folder jika belum ada
    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0755, true);
    }

    $ext      = strtolower(pathinfo($_FILES['photo']['name'], PATHINFO_EXTENSION));
    $allowed  = ['jpg', 'jpeg', 'png', 'webp'];

    if (!in_array($ext, $allowed)) {
        echo json_encode(["status" => "error", "msg" => "Format foto tidak didukung"]);
        exit;
    }

    if ($_FILES['photo']['size'] > 5 * 1024 * 1024) { // 5MB max
        echo json_encode(["status" => "error", "msg" => "Ukuran foto maksimal 5MB"]);
        exit;
    }

    $filename  = "avatar_{$user_id}_" . time() . ".{$ext}";
    $targetPath= $uploadDir . $filename;

    if (move_uploaded_file($_FILES['photo']['tmp_name'], $targetPath)) {
        $photo_url = "http://10.0.2.2/keuangan_api/uploads/avatars/{$filename}";
    } else {
        echo json_encode(["status" => "error", "msg" => "Gagal upload foto"]);
        exit;
    }
}

// Update query
if ($photo_url) {
    $sql = "UPDATE users SET name='$name', photo='$photo_url', updated_at=NOW() WHERE id='$user_id'";
} else {
    $sql = "UPDATE users SET name='$name', updated_at=NOW() WHERE id='$user_id'";
}

if ($conn->query($sql) === TRUE) {
    // Ambil data user terbaru
    $result = $conn->query("SELECT id, name, email, photo FROM users WHERE id='$user_id'");
    $user   = $result->fetch_assoc();

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
    echo json_encode(["status" => "error", "msg" => "Gagal memperbarui profil"]);
}

$conn->close();
?>
