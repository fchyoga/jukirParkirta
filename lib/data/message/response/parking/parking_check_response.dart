import 'dart:convert';

import 'package:jukirparkirta/data/model/biaya_parkir.dart';
import 'package:jukirparkirta/data/model/lokasi_parkir.dart';
import 'package:jukirparkirta/data/model/member.dart';

ParkingCheckResponse parkingCheckResponseFromJson(String str) => ParkingCheckResponse.fromJson(json.decode(str));

String parkingCheckResponseToJson(ParkingCheckResponse data) => json.encode(data.toJson());

class ParkingCheckResponse {
    bool success;
    List<ParkingUser> data;
    String message;

    ParkingCheckResponse({
        required this.success,
        required this.data,
        required this.message,
    });

    factory ParkingCheckResponse.fromJson(Map<String, dynamic> json) => ParkingCheckResponse(
        success: json["success"],
        data: List<ParkingUser>.from(json["data"].map((x) => ParkingUser.fromJson(x))),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "message": message,
    };
}

class ParkingUser {
    int id;
    int idPelanggan;
    int? idJukir;
    int idLokasiParkir;
    dynamic idMetodePembayaran;
    int? idBiayaParkir;
    String lat;
    String long;
    String? jenisKendaraan;
    String? nopol;
    String? lamaParkir;
    int subtotalBiaya;
    int? isPayNow;
    String statusParkir;
    String? fotoKendaraan;
    dynamic fotoNopol;
    DateTime createdAt;
    DateTime updatedAt;
    // Member pelanggan;
    // Pelanggan? jukir;
    LokasiParkir lokasiParkir;
    BiayaParkir? biayaParkir;

    ParkingUser({
        required this.id,
        required this.idPelanggan,
        required this.idJukir,
        required this.idLokasiParkir,
        required this.idMetodePembayaran,
        required this.idBiayaParkir,
        required this.lat,
        required this.long,
        required this.jenisKendaraan,
        required this.nopol,
        required this.lamaParkir,
        required this.subtotalBiaya,
        required this.isPayNow,
        required this.statusParkir,
        required this.fotoKendaraan,
        required this.fotoNopol,
        required this.createdAt,
        required this.updatedAt,
        // required this.pelanggan,
        // required this.jukir,
        required this.lokasiParkir,
        required this.biayaParkir,
    });

    factory ParkingUser.fromJson(Map<String, dynamic> json) => ParkingUser(
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
        // pelanggan: Pelanggan.fromJson(json["pelanggan"]),
        // jukir: json["jukir"] == null ? null : Pelanggan.fromJson(json["jukir"]),
        lokasiParkir: LokasiParkir.fromJson(json["lokasi_parkir"]),
        biayaParkir: json["biaya_parkir"] == null ? null : BiayaParkir.fromJson(json["biaya_parkir"]),
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
        "updated_at": updatedAt.toIso8601String(),
        // "pelanggan": pelanggan.toJson(),
        // "jukir": jukir?.toJson(),
        "lokasi_parkir": lokasiParkir.toJson(),
        "biaya_parkir": biayaParkir?.toJson(),
    };
}

