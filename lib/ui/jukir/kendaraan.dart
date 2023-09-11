import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:jukirparkirta/color.dart';
import 'package:jukirparkirta/ui/jukir/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'detail_parking_page.dart';

class ListKendaraanPageJukir extends StatefulWidget {
  @override
  State<ListKendaraanPageJukir> createState() => _ListKendaraanPageJukirState();
}

class _ListKendaraanPageJukirState extends State<ListKendaraanPageJukir> {
  List<Map<String, dynamic>> parkingData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final userId = await getUserId();
      final locationId = await getLocationParkingId(userId);
      final data = await getParkingData(locationId);

      setState(() {
        parkingData = data;
      });
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<int> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('https://parkirta.com/api/profile/detail'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final id = data['data']['id'];
      print('User ID: $id'); // Print the user ID for verification
      return id;
    } else {
      print('Failed to fetch user ID - Status Code: ${response.statusCode}');
      throw Exception('Failed to fetch user ID');
    }
  }

  Future<int> getLocationParkingId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('https://parkirta.com/api/master/lokasi_parkir'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final locations = data['data'];
      final location = locations.firstWhere(
        (loc) => loc['relasi_jukir'] != null && loc['relasi_jukir'][0]['id_jukir'] == userId,
        orElse: () => null,
      );

      if (location != null) {
        final locationId = location['id'];
        print('Location ID: $locationId');
        return locationId;
      } else {
        throw Exception('No matching location found');
      }
    } else {
      print('Failed to fetch user ID - Status Code: ${response.statusCode}');
      throw Exception('Failed to fetch location parking ID');
    }
  }

  Future<List<Map<String, dynamic>>> getParkingData(int locationId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('https://parkirta.com/api/retribusi/parking/check'),
      body: jsonEncode({
        'id_lokasi_parkir': locationId,
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final parkings = data['data'];
      print('Parkir Data ID: $parkings');
      return List<Map<String, dynamic>>.from(parkings);
    } else {
      print('Failed to fetch user ID - Status Code: ${response.statusCode}');
      throw Exception('Failed to fetch parking data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Gray100,
      appBar: AppBar(
        backgroundColor: Gray100,
        toolbarHeight: 84,
        titleSpacing: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 24),
              child: Text(
                'Kendaraan Parkir',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Red900,
                ),
              ),
            ),
            SizedBox(width: 16),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 24),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/profile.png'),
                radius: 20,
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: parkingData.length,
        itemBuilder: (context, index) {
          var kendaraan = parkingData[index];
          var icon =
              kendaraan['jenis_kendaraan'] == 'Mobil' ? Icons.directions_car : Icons.motorcycle;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 0,
                    blurRadius: 0,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Icon(icon, color: Colors.red[500]),
                  title: Text(
                    'Nomor Polisi: ${kendaraan['nopol']}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[900],
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status: ${kendaraan['status_parkir']}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey[500],
                        ),
                      ),
                      Text(
                        'Durasi Parkir: ${kendaraan['lama_parkir']} jam',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      "/detail_parking",
                      arguments: kendaraan['id'],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
