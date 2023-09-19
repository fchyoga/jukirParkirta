
class Jukir {
    int id;
    String namaLengkap;
    String nik;
    String email;
    String statusJukir;

    Jukir({
        required this.id,
        required this.namaLengkap,
        required this.nik,
        required this.email,
        required this.statusJukir,
    });

    factory Jukir.fromJson(Map<String, dynamic> json) => Jukir(
        id: json["id"],
        namaLengkap: json["nama_lengkap"],
        nik: json["nik"],
        email: json["email"],
        statusJukir: json["status_jukir"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "nama_lengkap": namaLengkap,
        "nik": nik,
        "email": email,
        "status_jukir": statusJukir,
    };
}