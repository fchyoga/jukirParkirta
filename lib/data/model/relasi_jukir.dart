import 'package:jukirparkirta/data/model/jukir.dart';


class RelasiJukir {
    int id;
    int idLokasiParkir;
    int idJukir;
    DateTime createdAt;
    DateTime updatedAt;
    Jukir jukir;

    RelasiJukir({
        required this.id,
        required this.idLokasiParkir,
        required this.idJukir,
        required this.createdAt,
        required this.updatedAt,
        required this.jukir,
    });

    factory RelasiJukir.fromJson(Map<String, dynamic> json) => RelasiJukir(
        id: json["id"],
        idLokasiParkir: json["id_lokasi_parkir"],
        idJukir: json["id_jukir"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        jukir: Jukir.fromJson(json["jukir"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "id_lokasi_parkir": idLokasiParkir,
        "id_jukir": idJukir,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "jukir": jukir.toJson(),
    };
}