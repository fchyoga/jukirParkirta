class User {
  User({
    required this.id,
    this.name,
    this.email,
    required this.token,
    required this.role,
    required this.status,
    required this.idLokasiParkir,
  });

  int id;
  String? name;
  String? email;
  String role;
  String token;
  String status;
  int idLokasiParkir;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id_jukir"],
        name: json["nama_lengkap"],
        email: json["email"],
        token: json["token"],
        role: json["role"],
        status: json["status"],
        idLokasiParkir: json["id_lokasi_parkir"],
      );

  Map<String, dynamic> toJson() => {
        "id_jukir": id,
        "nama_lengkap": name,
        "email": email,
        "token": token,
        "role": role,
        "status": status,
        "id_lokasi_parkir": idLokasiParkir,
      };
}
