import 'package:flutter/material.dart';
import 'package:jukirparkirta/color.dart';
import 'package:jukirparkirta/jukir/aktivasi.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jukirparkirta/auth/auth.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    fetchUserData();
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
    });
    } else {
      print(response.body); // Cetak pesan respons yang diterima dari API
      throw Exception('Failed to fetch user data');
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
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/profile.png'),
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
              SizedBox(height: 24),
              if (userData['status_jukir']=='Belum')
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
                
              SizedBox(height: 8),
              buildRoundedButton(
                text: 'Transaksi',
                icon: Icons.arrow_forward_ios_rounded,
                onPressed: () {},
                height: 48,
              ),
              SizedBox(height: 8),
              buildRoundedButton(
                text: 'Riwayat Parkir',
                icon: Icons.arrow_forward_ios_rounded,
                onPressed: () {},
                height: 48,
              ),
              SizedBox(height: 8),
              buildRoundedButton(
                text: 'Edit Profile',
                icon: Icons.arrow_forward_ios_rounded,
                onPressed: () {},
                height: 48,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setBool('isLoggedIn', false);
                  prefs.remove('userRole');
                  prefs.remove('token');

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => AuthPage()),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Red500),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
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
