import 'package:flutter/material.dart';
import 'package:jukirparkirta/color.dart';
import 'package:jukirparkirta/ui/auth/pre_login_page.dart';
import 'package:jukirparkirta/ui/jukir/aktivasi.dart';
import 'package:jukirparkirta/ui/jukir/profile_edit.dart';
import 'package:http/http.dart' as http;
import 'package:jukirparkirta/utils/contsant/user_const.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isOnline = false;
  String selectedLocation = '';
  List<String> locations = [];
  Map<String, dynamic> userData = {};
  List<Map<String, dynamic>> locationData = [];

  @override
  void initState() {
    super.initState();
    selectedLocation = locations.isNotEmpty ? locations.first : '';
    fetchUserData();
    fetchLocationData();
  }

  Future<void> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('https://parkirta.com/api/profile/detail'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        userData = jsonDecode(response.body)['data'];
        isOnline = userData['kondisi'] == 'Online';
      });
    } else {
      print(response.body);
      throw Exception('Failed to fetch user data');
    }
  }

  Future<void> fetchLocationData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('https://parkirta.com/api/master/lokasi_parkir_jukir'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body);
      if (decodedData['data'] is Map && decodedData['data']['data'] is List) {
        setState(() {
          locationData = (decodedData['data']['data'] as List)
              .cast<Map<String, dynamic>>();
          locations = locationData
              .map<String>(
                  (location) => location['lokasi_parkir']['nama_lokasi'])
              .toList();
          selectedLocation = locations.isNotEmpty ? locations.first : '';
        });
      } else {
        print('Invalid data structure from API');
        // Handle the error or set a default value for locationData and locations
      }
    } else {
      print(response.body);
      throw Exception('Failed to fetch user data');
    }
  }

  Future<void> _updateUserStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final selectedLocationData = locationData.firstWhere(
      (location) =>
          location['lokasi_parkir']['nama_lokasi'] == selectedLocation,
    );

    final response = await http.post(
      Uri.parse('https://parkirta.com/api/profile/kondisi/update'),
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        'kondisi': isOnline ? 'Online' : 'Offline',
        'id_lokasi_parkir': selectedLocationData['id_lokasi_parkir'].toString(),
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body)['data'];
      print('User status updated: $responseData');
      // You can update the UI or handle the response accordingly
    } else {
      print(response.body);
      throw Exception('Failed to update user status');
    }
  }

  Future<void> saveKondisiToAPI(String kondisi) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('https://parkirta.com/api/profile/kondisi/update'),
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        'kondisi': kondisi,
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body)['data'];
      print('User status updated: $responseData');
      setState(() {
        userData['kondisi'] = kondisi;
      });
    } else {
      print(response.body);
      throw Exception('Failed to update user status');
    }
  }

  void _showLocationPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Choose Location'),
              content: Container(
                width: double.maxFinite,
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedLocation,
                  onChanged: (String? value) {
                    setState(() {
                      selectedLocation = value!;
                    });
                  },
                  items:
                      locations.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: SizedBox(
                        width: double.maxFinite,
                        child: Text(
                          value,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
                TextButton(
                  onPressed: () {
                    _updateUserStatus();
                    Navigator.of(context).pop();
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
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
          centerTitle: true,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Red900,
              ),
            ),
          ),
          title: Text(
            'Profile',
            style: TextStyle(
              color: Red900,
              fontSize: 18,
            ),
          ),
          actions: [
            Switch(
              value: isOnline,
              onChanged: (value) {
                setState(() {
                  isOnline = value;
                  if (isOnline) {
                    saveKondisiToAPI('Online');
                  } else {
                    // Jika switch diubah menjadi Offline, simpan kondisi ke API
                    saveKondisiToAPI('Offline');
                  }
                });
              },
            ),
          ]),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: userData['foto_jukir'] != null
                    ? NetworkImage(
                            'https://parkirta.com/storage/uploads/foto/${userData['foto_jukir']}')
                        as ImageProvider<Object>
                    : const AssetImage('assets/images/profile.png'),
              ),
              SizedBox(height: 16),
              Text(
                userData['nama_lengkap'] ?? '',
                style: TextStyle(
                  color: Red900,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                userData['email'] ?? '',
                style: TextStyle(
                  fontSize: 16,
                  color: Gray500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                isOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isOnline ? Colors.green : Colors.red,
                ),
              ),
              SizedBox(height: 24),
              if (userData['status_jukir'] == 'Belum')
                buildRoundedButton(
                  text: 'Aktivasi',
                  icon: Icons.arrow_forward_ios_rounded,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AktivasiPage()),
                    );
                  },
                  height: 48,
                ),
              // SizedBox(height: 8),
              // buildRoundedButton(
              //   text: 'Transaksi',
              //   icon: Icons.arrow_forward_ios_rounded,
              //   onPressed: () {},
              //   height: 48,
              // ),
              // SizedBox(height: 8),
              // buildRoundedButton(
              //   text: 'Riwayat Parkir',
              //   icon: Icons.arrow_forward_ios_rounded,
              //   onPressed: () {},
              //   height: 48,
              // ),
              SizedBox(height: 8),
              buildRoundedButton(
                text: 'Edit Profile',
                icon: Icons.arrow_forward_ios_rounded,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfileEdit(
                            userName: userData.isNotEmpty
                                ? userData['nama_lengkap']
                                : '',
                            userEmail:
                                userData.isNotEmpty ? userData['email'] : '')),
                  );
                },
                height: 48,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setBool('isLoggedIn', false);
                  prefs.remove('userRole');
                  prefs.remove('token');
                  prefs.remove(LOCATION_ID);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => PreLoginPage()),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Red500),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  minimumSize: MaterialStateProperty.all<Size>(
                    const Size(double.infinity, 48),
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRoundedButton({
    required String text,
    IconData? icon,
    Color backgroundColor = Colors.white,
    required VoidCallback onPressed,
    double height = 48,
  }) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                color: Red900,
                fontSize: 14,
              ),
            ),
            Icon(
              icon,
              color: Red900,
            ),
          ],
        ),
      ),
    );
  }
}
