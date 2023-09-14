import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:jukirparkirta/data/endpoint.dart';
import 'package:jukirparkirta/data/message/response/general_response.dart';
import 'package:jukirparkirta/utils/contsant/user_const.dart';
import 'package:sp_util/sp_util.dart';

class PaymentRepository {

  String? token = SpUtil.getString(API_TOKEN);

  Future<GeneralResponse> paymentJukir(String inv, String isCardUsed, String? cardNumber) async {
    try {
      Map<String, dynamic> data = {
        'no_invoice': inv,
        'is_card_used': isCardUsed,
        'no_kartu': cardNumber ?? ""
      };
      var response = await http.post(
          Uri.parse(Endpoint.urlPayment),
          body: data,
          headers: {'Authorization': 'Bearer $token'},
      );
      debugPrint("response ${response.body}");
      return response.statusCode == 200 || response.statusCode == 404 ? generalResponseFromJson(response.body)
      : GeneralResponse( success: false, message: "Failed submit payment check");
    } on HttpException catch(e, stackTrace){
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return GeneralResponse( success: false, message: e.message);
    } catch (e, stackTrace) {
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return GeneralResponse( success: false, message:  e.toString());
    }
  }



}
