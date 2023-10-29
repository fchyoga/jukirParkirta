import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:jukirparkirta/data/endpoint.dart';
import 'package:jukirparkirta/data/message/response/general_response.dart';
import 'package:jukirparkirta/data/message/response/login_response.dart';
import 'package:jukirparkirta/data/message/response/notification_response.dart';
import 'package:jukirparkirta/data/message/response/profile_response.dart';
import 'package:jukirparkirta/utils/contsant/user_const.dart';
import 'package:sp_util/sp_util.dart';

class UserRepository {
  Future<LoginResponse> login(String email, String password, String token) async {
    try {
      Map<String, String> data = {
        'email': email,
        'password': password,
        'device_token': token,
      };
      var response = await http.post(Uri.parse(Endpoint.urlLogin), body: data);
          // await http.post("login", data: loginRequest.toJson());
      debugPrint("request $data");
      debugPrint("response ${response.body}");
      return response.statusCode == 200 ? loginResponseFromJson(response.body)
      : LoginResponse.withError( false, "Invalid email or password.");
    } on HttpException catch(e, stackTrace){
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return LoginResponse.withError( false, e.message);
    } catch (e, stackTrace) {
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return LoginResponse.withError( false, e.toString());
    }
  }

  Future<ProfileResponse> profile() async {
    try {
      String? token = SpUtil.getString(API_TOKEN);
      var response = await http.get(
          Uri.parse(Endpoint.urlProfile),
        headers: {'Authorization': 'Bearer $token'}
      );
      debugPrint("url ${Endpoint.urlProfile}");
      debugPrint("response ${response.body}");
      return response.statusCode == 200 ? profileResponseFromJson(response.body)
      : ProfileResponse( success: false, message: "Failed profile data");
    } on HttpException catch(e, stackTrace){
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return ProfileResponse( success:false, message: e.message);
    } catch (e, stackTrace) {
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return ProfileResponse( success:false, message: e.toString());
    }
  }

  Future<NotificationResponse> notification() async {
    try {
      String? token = SpUtil.getString(API_TOKEN);
      var response = await http.get(
          Uri.parse(Endpoint.urlNotification),
        headers: {'Authorization': 'Bearer $token'}
      );
      debugPrint("url ${Endpoint.urlNotification}");
      debugPrint("response ${response.body}");
      return response.statusCode == 200 ? notificationResponseFromJson(response.body)
      : NotificationResponse( success: false, message: "Failed get notification", data: []);
    } on HttpException catch(e, stackTrace){
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return NotificationResponse( success:false, message: e.message, data: []);
    } catch (e, stackTrace) {
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return NotificationResponse( success:false, message: e.toString(), data: []);
    }
  }

  Future<GeneralResponse> readNotification(int id, String topic) async {
    try {
      String? token = SpUtil.getString(API_TOKEN);
      Map<String, dynamic> data = {
        'ReferenceId': id.toString(),
        'topic': topic
      };
      var response = await http.post(
          Uri.parse(Endpoint.urlReadNotification),
          body: data,
        headers: {'Authorization': 'Bearer $token'}
      );
      debugPrint("url ${Endpoint.urlReadNotification}");
      debugPrint("request $data");
      debugPrint("response ${response.body}");
      return response.statusCode == 200 ? generalResponseFromJson(response.body)
      : GeneralResponse( success: false, message: "");
    } on HttpException catch(e, stackTrace){
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return GeneralResponse( success:false, message: e.message);
    } catch (e, stackTrace) {
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return GeneralResponse( success:false, message: e.toString());
    }
  }
}
