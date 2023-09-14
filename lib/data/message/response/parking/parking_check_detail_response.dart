import 'dart:convert';

import 'package:jukirparkirta/data/model/retribusi.dart';

ParkingCheckDetailResponse parkingCheckDetailResponseFromJson(String str) => ParkingCheckDetailResponse.fromJson(json.decode(str));

String parkingCheckDetailResponseToJson(ParkingCheckDetailResponse data) => json.encode(data.toJson());

class ParkingCheckDetailResponse {
    bool success;
    ParkingCheckDetail? data;
    String message;

    ParkingCheckDetailResponse({
        required this.success,
        this.data,
        required this.message,
    });

    factory ParkingCheckDetailResponse.fromJson(Map<String, dynamic> json) => ParkingCheckDetailResponse(
        success: json["success"],
        data: json["data"]!=null ? ParkingCheckDetail.fromJson(json["data"]): null,
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
        "message": message,
    };
}

class ParkingCheckDetail {
    Retribusi retribusi;
    String uriFotoKendaraan;

    ParkingCheckDetail({
        required this.retribusi,
        required this.uriFotoKendaraan,
    });

    factory ParkingCheckDetail.fromJson(Map<String, dynamic> json) => ParkingCheckDetail(
        retribusi: Retribusi.fromJson(json["retribusi"]),
        uriFotoKendaraan: json["uri_foto_kendaraan"],
    );

    Map<String, dynamic> toJson() => {
        "retribusi": retribusi.toJson(),
        "uri_foto_kendaraan": uriFotoKendaraan,
    };
}







