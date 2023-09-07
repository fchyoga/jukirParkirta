import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:jukirparkirta/data/endpoint.dart';
import 'package:jukirparkirta/data/message/response/login_response.dart';

class UserRepository {
  Future<LoginResponse> login(String email, String password) async {
    try {
      Map<String, String> data = {
        'email': email,
        'password': password,
      };
      var response = await http.post(Uri.parse(Endpoint.urlLogin), body: data);
          // await http.post("login", data: loginRequest.toJson());
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




}
