<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
include("../auth/database.php");

$data = json_decode(file_get_contents("php://input"));

$email    = $data->email;
$password = $data->password;

$query = $conn->query("SELECT * FROM users WHERE email='$email'");

if ($query->num_rows > 0) {
    $user = $query->fetch_assoc();

    if (password_verify($password, $user['password'])) {
        echo json_encode([
            "status"  => true,
            "message" => "Login berhasil",
            "user"    => [
                "id"    => $user['id'],
                "name"  => $user['name'],  
                "email" => $user['email'],
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
?>