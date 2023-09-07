import 'dart:convert';

ParkingCheckDetailResponse parkingCheckDetailResponseFromJson(String str) => ParkingCheckDetailResponse.fromJson(json.decode(str));

String parkingCheckDetailResponseToJson(ParkingCheckDetailResponse data) => json.encode(data.toJson());

class ParkingCheckDetailResponse {
    bool success;
    Data? data;
    String message;

    ParkingCheckDetailResponse({
        required this.success,
        required this.data,
        required this.message,
    });

    factory ParkingCheckDetailResponse.fromJson(Map<String, dynamic> json) => ParkingCheckDetailResponse(
        success: json["success"],
        data: json["data"]!=null ? Data.fromJson(json["data"]): null,
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
        "message": message,
    };
}

class Data {
    Retribusi retribusi;
    String uriFotoKendaraan;

    Data({
        required this.retribusi,
        required this.uriFotoKendaraan,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        retribusi: Retribusi.fromJson(json["retribusi"]),
        uriFotoKendaraan: json["uri_foto_kendaraan"],
    );

    Map<String, dynamic> toJson() => {
        "retribusi": retribusi.toJson(),
        "uri_foto_kendaraan": uriFotoKendaraan,
    };
}

class Retribusi {
    int id;
    int idPelanggan;
    dynamic idJukir;
    int idLokasiParkir;
    dynamic idMetodePembayaran;
    dynamic idBiayaParkir;
    String lat;
    String long;
    dynamic jenisKendaraan;
    dynamic nopol;
    dynamic lamaParkir;
    int subtotalBiaya;
    dynamic isPayNow;
    String statusParkir;
    dynamic fotoKendaraan;
    dynamic fotoNopol;
    DateTime createdAt;
    DateTime updatedAt;
    Pelanggan pelanggan;
    dynamic jukir;
    LokasiParkir lokasiParkir;
    dynamic biayaParkir;

    Retribusi({
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
        required this.pelanggan,
        required this.jukir,
        required this.lokasiParkir,
        required this.biayaParkir,
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
        pelanggan: Pelanggan.fromJson(json["pelanggan"]),
        jukir: json["jukir"],
        lokasiParkir: LokasiParkir.fromJson(json["lokasi_parkir"]),
        biayaParkir: json["biaya_parkir"],
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
        "pelanggan": pelanggan.toJson(),
        "jukir": jukir,
        "lokasi_parkir": lokasiParkir.toJson(),
        "biaya_parkir": biayaParkir,
    };
}

class LokasiParkir {
    int id;
    String namaLokasi;
    String alamatLokasi;
    String lat;
    String long;
    String areaLatlong;
    String url;
    String status;
    String statusOperasional;
    DateTime createdAt;
    DateTime updatedAt;

    LokasiParkir({
        required this.id,
        required this.namaLokasi,
        required this.alamatLokasi,
        required this.lat,
        required this.long,
        required this.areaLatlong,
        required this.url,
        required this.status,
        required this.statusOperasional,
        required this.createdAt,
        required this.updatedAt,
    });

    factory LokasiParkir.fromJson(Map<String, dynamic> json) => LokasiParkir(
        id: json["id"],
        namaLokasi: json["nama_lokasi"],
        alamatLokasi: json["alamat_lokasi"],
        lat: json["lat"],
        long: json["long"],
        areaLatlong: json["area_latlong"],
        url: json["url"],
        status: json["status"],
        statusOperasional: json["status_operasional"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "nama_lokasi": namaLokasi,
        "alamat_lokasi": alamatLokasi,
        "lat": lat,
        "long": long,
        "area_latlong": areaLatlong,
        "url": url,
        "status": status,
        "status_operasional": statusOperasional,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
    };
}

class Pelanggan {
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
    DateTime updatedAt;

    Pelanggan({
        required this.id,
        required this.fotoPelanggan,
        required this.namaLengkap,
        required this.nik,
        required this.fotoKtp,
        required this.tempatLahir,
        required this.tglLahir,
        required this.jenisKelamin,
        required this.alamat,
        required this.email,
        required this.saldo,
        required this.statusPelanggan,
        required this.createdAt,
        required this.updatedAt,
    });

    factory Pelanggan.fromJson(Map<String, dynamic> json) => Pelanggan(
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
        updatedAt: DateTime.parse(json["updated_at"]),
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
        "updated_at": updatedAt.toIso8601String(),
    };
}
