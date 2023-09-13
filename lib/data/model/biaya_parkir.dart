
class BiayaParkir {
    int id;
    int idLokasiParkir;
    String kendaraan;
    int biayaParkir;
    DateTime? createdAt;
    DateTime? updatedAt;

    BiayaParkir({
        required this.id,
        required this.idLokasiParkir,
        required this.kendaraan,
        required this.biayaParkir,
        this.createdAt,
        this.updatedAt,
    });

    factory BiayaParkir.fromJson(Map<String, dynamic> json) => BiayaParkir(
        id: json["id"],
        idLokasiParkir: json["id_lokasi_parkir"],
        kendaraan: json["kendaraan"],
        biayaParkir: json["biaya_parkir"],
        createdAt: json["created_at"] != null ? DateTime.parse(json["created_at"]): null,
        updatedAt: json["updated_at"] != null ? DateTime.parse(json["updated_at"]): null,
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "id_lokasi_parkir": idLokasiParkir,
        "kendaraan": kendaraan,
        "biaya_parkir": biayaParkir,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}