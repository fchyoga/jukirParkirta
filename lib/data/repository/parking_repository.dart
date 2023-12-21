import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:jukirparkirta/data/endpoint.dart';
import 'package:jukirparkirta/data/message/response/general_response.dart';
import 'package:jukirparkirta/data/message/response/parking/parking_check_detail_response.dart';
import 'package:jukirparkirta/data/message/response/parking/parking_check_response.dart';
import 'package:jukirparkirta/data/message/response/parking/parking_location_response.dart';
import 'package:jukirparkirta/utils/contsant/user_const.dart';
import 'package:sp_util/sp_util.dart';

class ParkingRepository {
  String? token = SpUtil.getString(API_TOKEN);

  Future<ParkingCheckResponse> checkParking() async {
    try {
      int? id = SpUtil.getInt(USER_ID);
      Map<String, dynamic> data = {'id_jukir': id.toString()};
      var response = await http.post(
        Uri.parse(Endpoint.urlCheckParking),
        body: data,
        headers: {'Authorization': 'Bearer $token'},
      );
      debugPrint("url ${Endpoint.urlCheckParking}");
      debugPrint("request $data");
      debugPrint("response ${response.body}");
      return response.statusCode == 200
          ? parkingCheckResponseFromJson(response.body)
          : response.statusCode == 403
              ? ParkingCheckResponse(
                  success: false, message: "Unauthorized", data: [])
              : ParkingCheckResponse(
                  success: true, message: "Nothing Park Here!", data: []);
    } on HttpException catch (e, stackTrace) {
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return ParkingCheckResponse(success: false, message: e.message, data: []);
    } catch (e, stackTrace) {
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return ParkingCheckResponse(
          success: false, message: e.toString(), data: []);
    }
  }

  Future<ParkingCheckDetailResponse> checkDetailParking(String id) async {
    try {
      var response = await http.get(
        Uri.parse("${Endpoint.urlCheckDetailParking}/$id"),
        headers: {'Authorization': 'Bearer $token'},
      );
      debugPrint("url ${Endpoint.urlCheckDetailParking}/$id");
      debugPrint("response ${response.body}");
      return response.statusCode == 200
          ? parkingCheckDetailResponseFromJson(response.body)
          : response.statusCode == 403
              ? ParkingCheckDetailResponse(
                  success: false, message: "Unauthorized")
              : ParkingCheckDetailResponse(
                  success: true, message: "Nothing Park Here!");
    } on HttpException catch (e, stackTrace) {
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return ParkingCheckDetailResponse(success: false, message: e.message);
    } catch (e, stackTrace) {
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return ParkingCheckDetailResponse(success: false, message: e.toString());
    }
  }

  Future<GeneralResponse> uploadVehiclePhoto(String id, String path) async {
    try {
      // Membuat request multipart
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://parkirta.com/api/retribusi/upload/foto_kendaraan'),
      );

      // Menambahkan header bearer token
      request.headers['Authorization'] = 'Bearer $token';

      // Menambahkan field 'parking_id' ke request
      request.fields['id_retribusi_parkir'] = id;

      // Menambahkan file gambar ke request
      request.files.add(await http.MultipartFile.fromPath(
        'foto_kendaraan',
        path,
      ));
      // Mengirim request ke API
      final response = await request.send();

      // Membaca responsenya
      final responseString = await response.stream.bytesToString();

      debugPrint("request ${request.fields}");
      debugPrint("response ${responseString}");
      return response.statusCode == 200
          ? generalResponseFromJson(responseString)
          : response.statusCode == 403
              ? GeneralResponse(success: false, message: "Unauthorized")
              : GeneralResponse(
                  success: false, message: "Gagal upload foto kendaraan");
    } on HttpException catch (e, stackTrace) {
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return GeneralResponse(success: false, message: e.message);
    } catch (e, stackTrace) {
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return GeneralResponse(success: false, message: e.toString());
    }
  }

  Future<GeneralResponse> updateParkingStatus(String status) async {
    try {
      int? locationId = SpUtil.getInt(ONLINE_ID);
      Map<String, dynamic> data = {
        'id_lokasi_parkir': locationId.toString(),
        'status': status
      };
      var response = await http.post(
        Uri.parse(Endpoint.urlUpdateParkingStatus),
        body: data,
        headers: {'Authorization': 'Bearer $token'},
      );
      debugPrint("url ${Endpoint.urlUpdateParkingStatus}");
      debugPrint("request $data");
      debugPrint("response ${response.body}");
      return response.statusCode == 200
          ? generalResponseFromJson(response.body)
          : response.statusCode == 403
              ? GeneralResponse(success: false, message: "Unauthorized")
              : GeneralResponse(success: false, message: "Failed get data");
    } on HttpException catch (e, stackTrace) {
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return GeneralResponse(success: false, message: e.message);
    } catch (e, stackTrace) {
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return GeneralResponse(success: false, message: e.toString());
    }
  }

  Future<ParkingLocationResponse> parkingLocation() async {
    try {
      var response = await http.get(
        Uri.parse(Endpoint.urlParkingLocation),
        headers: {'Authorization': 'Bearer $token'},
      );
      debugPrint("url ${Endpoint.urlParkingLocation}");
      debugPrint("response ${response.body}");
      return response.statusCode == 200
          ? parkingLocationResponseFromJson(response.body)
          : response.statusCode == 403
              ? ParkingLocationResponse(
                  success: false, message: "Unauthorized", data: [])
              : ParkingLocationResponse(
                  success: true, message: "Nothing Park Here!", data: []);
    } on HttpException catch (e, stackTrace) {
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return ParkingLocationResponse(
          success: false, message: e.message, data: []);
    } catch (e, stackTrace) {
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return ParkingLocationResponse(
          success: false, message: e.toString(), data: []);
    }
  }
}
