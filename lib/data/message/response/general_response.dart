
import 'dart:convert';

GeneralResponse generalResponseFromJson(String str) => GeneralResponse.fromJson(json.decode(str));

String generalResponseToJson(GeneralResponse data) => json.encode(data.toJson());

class GeneralResponse {
  GeneralResponse({
    required this.success,
    required this.message,
  });

  bool success;
  String message;

  GeneralResponse.withError( this.success, this.message);

  factory GeneralResponse.fromJson(Map<String, dynamic> json) => GeneralResponse(
    success: json["success"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
  };
}
