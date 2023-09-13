

class Member {
    int id;
    dynamic fotoPelanggan;
    String namaLengkap;
    String nik;
    dynamic fotoKtp;
    dynamic tempatLahir;
    dynamic tglLahir;
    dynamic jenisKelamin;
    dynamic alamat;
    String email;
    int saldo;
    String statusPelanggan;
    DateTime createdAt;
    DateTime? updatedAt;

    Member({
        required this.id,
        this.fotoPelanggan,
        required this.namaLengkap,
        required this.nik,
        this.fotoKtp,
        this.tempatLahir,
        this.tglLahir,
        this.jenisKelamin,
        this.alamat,
        required this.email,
        required this.saldo,
        required this.statusPelanggan,
        required this.createdAt,
        this.updatedAt,
    });

    factory Member.fromJson(Map<String, dynamic> json) => Member(
        id: json["id"],
        fotoPelanggan: json["foto_pelanggan"],
        namaLengkap: json["nama_lengkap"],
        nik: json["nik"],
        fotoKtp: json["foto_ktp"],
        tempatLahir: json["tempat_lahir"],
        tglLahir: json["tgl_lahir"],
        jenisKelamin: json["jenis_kelamin"],
        alamat: json["alamat"],
        email: json["email"],
        saldo: json["saldo"],
        statusPelanggan: json["status_pelanggan"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"]!=null ? DateTime.parse(json["updated_at"]): null
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "foto_pelanggan": fotoPelanggan,
        "nama_lengkap": namaLengkap,
        "nik": nik,
        "foto_ktp": fotoKtp,
        "tempat_lahir": tempatLahir,
        "tgl_lahir": tglLahir,
        "jenis_kelamin": jenisKelamin,
        "alamat": alamat,
        "email": email,
        "saldo": saldo,
        "status_pelanggan": statusPelanggan,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}