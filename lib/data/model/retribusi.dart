
import 'package:jukirparkirta/data/model/biaya_parkir.dart';
import 'package:jukirparkirta/data/model/lokasi_parkir.dart';
import 'package:jukirparkirta/data/model/member.dart';

class Retribusi {

    int id;

    int idPelanggan;

    int? idJukir;

    int idLokasiParkir;
    dynamic idMetodePembayaran;
    dynamic idBiayaParkir;

    String lat;
    String long;

    dynamic jenisKendaraan;
    String? nopol;
    dynamic lamaParkir;
    int? subtotalBiaya;
    dynamic isPayNow;
    String statusParkir;
    dynamic fotoKendaraan;
    dynamic fotoNopol;
    DateTime createdAt;
    DateTime? updatedAt;
    Member? pelanggan;
    dynamic jukir;
    LokasiParkir? lokasiParkir;
    BiayaParkir? biayaParkir;

    Retribusi({
        required this.id,
        required this.idPelanggan,
        this.idJukir,
        required this.idLokasiParkir,
        this.idMetodePembayaran,
        this.idBiayaParkir,
        required this.lat,
        required this.long,
        this.jenisKendaraan,
        this.nopol,
        this.lamaParkir,
        this.subtotalBiaya,
        this.isPayNow,
        required this.statusParkir,
        this.fotoKendaraan,
        this.fotoNopol,
        required this.createdAt,
        this.updatedAt,
        this.pelanggan,
        this.jukir,
        this.lokasiParkir,
        this.biayaParkir,
    });

    factory Retribusi.fromJson(Map<String, dynamic> json) => Retribusi(
        id: json["id"],
        idPelanggan: json["id_pelanggan"],
        idJukir: json["id_jukir"],
        idLokasiParkir: json["id_lokasi_parkir"],
        idMetodePembayaran: json["id_metode_pembayaran"],
        idBiayaParkir: json["id_biaya_parkir"],
        lat: json["lat"],
        long: json["long"],
        jenisKendaraan: json["jenis_kendaraan"],
        nopol: json["nopol"],
        lamaParkir: json["lama_parkir"],
        subtotalBiaya: json["subtotal_biaya"],
        isPayNow: json["is_pay_now"],
        statusParkir: json["status_parkir"],
        fotoKendaraan: json["foto_kendaraan"],
        fotoNopol: json["foto_nopol"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        pelanggan: Member.fromJson(json["pelanggan"]),
        jukir: json["jukir"],
        lokasiParkir: LokasiParkir.fromJson(json["lokasi_parkir"]),
        biayaParkir: json["biaya_parkir"]!=null ? BiayaParkir?.fromJson(json["biaya_parkir"]): null,
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "id_pelanggan": idPelanggan,
        "id_jukir": idJukir,
        "id_lokasi_parkir": idLokasiParkir,
        "id_metode_pembayaran": idMetodePembayaran,
        "id_biaya_parkir": idBiayaParkir,
        "lat": lat,
        "long": long,
        "jenis_kendaraan": jenisKendaraan,
        "nopol": nopol,
        "lama_parkir": lamaParkir,
        "subtotal_biaya": subtotalBiaya,
        "is_pay_now": isPayNow,
        "status_parkir": statusParkir,
        "foto_kendaraan": fotoKendaraan,
        "foto_nopol": fotoNopol,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "pelanggan": pelanggan?.toJson(),
        "jukir": jukir,
        "lokasi_parkir": lokasiParkir?.toJson(),
        "biaya_parkir": biayaParkir?.toJson(),
    };
}