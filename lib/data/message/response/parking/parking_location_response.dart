import 'dart:convert';

import 'package:jukirparkirta/data/model/relasi_jukir.dart';


ParkingLocationResponse parkingLocationResponseFromJson(String str) => ParkingLocationResponse.fromJson(json.decode(str));

String parkingLocationResponseToJson(ParkingLocationResponse data) => json.encode(data.toJson());

class ParkingLocationResponse {
    bool success;
    List<ParkingLocation> data;
    String message;

    ParkingLocationResponse({
        required this.success,
        required this.data,
        required this.message,
    });

    factory ParkingLocationResponse.fromJson(Map<String, dynamic> json) => ParkingLocationResponse(
        success: json["success"],
        data: List<ParkingLocation>.from(json["data"].map((x) => ParkingLocation.fromJson(x))),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "message": message,
    };
}

class ParkingLocation {
    int id;
    String namaLokasi;
    String alamatLokasi;
    String lat;
    String long;
    String? areaLatlong;
    String url;
    String status;
    String statusOperasional;
    List<RelasiJukir> relasiJukir;

    ParkingLocation({
        required this.id,
        required this.namaLokasi,
        required this.alamatLokasi,
        required this.lat,
        required this.long,
        this.areaLatlong,
        required this.url,
        required this.status,
        required this.statusOperasional,
        required this.relasiJukir,
    });

    factory ParkingLocation.fromJson(Map<String, dynamic> json) => ParkingLocation(
        id: json["id"],
        namaLokasi: json["nama_lokasi"],
        alamatLokasi: json["alamat_lokasi"],
        lat: json["lat"],
        long: json["long"],
        areaLatlong: json["area_latlong"],
        url: json["url"],
        status: json["status"],
        statusOperasional: json["status_operasional"],
        relasiJukir: List<RelasiJukir>.from(json["relasi_jukir"].map((x) => RelasiJukir.fromJson(x))),
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
        "relasi_jukir": List<dynamic>.from(relasiJukir.map((x) => x.toJson())),
    };
}






 