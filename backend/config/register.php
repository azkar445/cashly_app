<?php
header("Content-Type: application/json");
include("../auth/database.php");

$data = json_decode(file_get_contents("php://input"));

$name = $data->name;
$email = $data->email;
$password = password_hash($data->password, PASSWORD_DEFAULT);

$cek = $conn->query("SELECT * FROM users WHERE email='$email'");

if ($cek->num_rows > 0) {
    echo json_encode([
        "status" => false,
        "message" => "Email sudah digunakan"
    ]);
    exit;
}

$query = "INSERT INTO users (name, email, password) 
VALUES ('$name', '$email', '$password')";

if ($conn->query($query)) {
    echo json_encode([
        "status" => true,
        "message" => "Register berhasil"
    ]);
} else {
    echo json_encode([
        "status" => false,
        "message" => "Register gagal"
    ]);
}