class User {
  User({
    // required this.id,
    this.name,
    this.email,
    required this.token,
    required this.role,
  });

  // int id;
  String? name;
  String? email;
  String role;
  String token;

  factory User.fromJson(Map<String, dynamic> json) => User(
    // id: json["id"],
    name: json["nama_lengkap"],
    email: json["email"],
    token: json["token"],
    role: json["role"],
  );

  Map<String, dynamic> toJson() => {
    // "id": id,
    "nama_lengkap": name,
    "email": email,
    "token": token,
    "role": role,
  };
}
