import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:jukirparkirta/data/endpoint.dart';
import 'package:jukirparkirta/data/message/response/parking/parking_check_detail_response.dart';
import 'package:jukirparkirta/utils/contsant/user_const.dart';
import 'package:sp_util/sp_util.dart';

class ParkingRepository {

  String? token = SpUtil.getString(API_TOKEN);


  Future<ParkingCheckDetailResponse> checkDetailParking(String id) async {
    try {
      var response = await http.get(
          Uri.parse("${Endpoint.urlCheckDetailParking}/$id"),
          headers: {'Authorization': 'Bearer $token'},
      );
      debugPrint("response ${response.body}");
      return response.statusCode == 200 ? parkingCheckDetailResponseFromJson(response.body)
      : ParkingCheckDetailResponse( success: false, message: "Failed get data");
    } on HttpException catch(e, stackTrace){
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return ParkingCheckDetailResponse( success: false, message: e.message);
    } catch (e, stackTrace) {
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return ParkingCheckDetailResponse( success: false, message:  e.toString());
    }
  }


}
