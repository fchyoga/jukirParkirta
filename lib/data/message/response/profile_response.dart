import 'dart:convert';

ProfileResponse profileResponseFromJson(String str) => ProfileResponse.fromJson(json.decode(str));

String profileResponseToJson(ProfileResponse data) => json.encode(data.toJson());

class ProfileResponse {
    bool success;
    Data? data;
    String message;

    ProfileResponse({
        required this.success,
        this.data,
        required this.message,
    });

    factory ProfileResponse.fromJson(Map<String, dynamic> json) => ProfileResponse(
        success: json["success"],
        data: Data.fromJson(json["data"]),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
        "message": message,
    };
}

class Data {
    int id;
    String namaLengkap;
    String nik;

    Data({
        required this.id,
        required this.namaLengkap,
        required this.nik,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        namaLengkap: json["nama_lengkap"],
        nik: json["nik"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "nama_lengkap": namaLengkap,
        "nik": nik,
    };
}
