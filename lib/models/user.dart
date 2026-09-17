class UserModel {
  final int id;
  final String name;
  final String email;
  final String? photo;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photo,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      photo: json['photo'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'photo': photo,
  };

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? photo,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photo: photo ?? this.photo,
    );
  }
}
