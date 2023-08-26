import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<dynamic>> getLocations() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  var url = Uri.parse('https://parkirta.com/api/master/lokasi_parkir');
  var response = await http.get(
    url,
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    return data['data'];
  } else {
    throw Exception('Failed to fetch parking locations');
  }
}

Future<dynamic> getLocationDetails(int locationId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  var url = Uri.parse('https://parkirta.com/api/master/lokasi_parkir/$locationId');
  var response = await http.get(
    url,
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    return data['data'];
  } else {
    throw Exception('Failed to fetch location details');
  }
}

Future<dynamic> confirmParkingArrival(int locationId, int userId, double latitude, double longitude) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  var url = Uri.parse('https://parkirta.com/api/retribusi/parking/arrive');
  var response = await http.post(
    url,
    body: {
      'id_lokasi_parkir': locationId.toString(),
      'id_pelanggan': userId.toString(),
      'lat': latitude.toString(),
      'long': longitude.toString(),
    },
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    return data['data'];
  } else {
    throw Exception('Failed to confirm parking arrival');
  }
}

Future<dynamic> getParking(int id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  var url = 'http://parkirta.com/api/retribusi/parking/check/';
  var response = await http.post(
    Uri.parse(url),
    body: {
      'id_lokasi_parkir': id.toString(),
    },
    headers: {
      'Authorization': 'Bearer $token', // Sertakan token dalam header permintaan
    },
  );

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    return data['data'];
  } else {
    throw Exception('Failed to fetch parking status');
  }
}

Future<dynamic> getParkingStatus(int id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  final url = 'http://parkirta.com/api/retribusi/parking/check/detail/$id';
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token', // Sertakan token dalam header permintaan
    },
  );

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    return jsonData;
  } else {
    throw Exception('Failed to fetch parking status');
  }
}


