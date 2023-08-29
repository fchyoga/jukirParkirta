import 'package:flutter/material.dart';
import 'package:jukirparkirta/color.dart';
import 'package:jukirparkirta/ui/jukir/kendaraan.dart';
import 'package:jukirparkirta/ui/jukir/home.dart';
import 'package:jukirparkirta/ui/jukir/rumah.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MyAppJukir extends StatefulWidget {
  @override
  State<MyAppJukir> createState() => _MyAppJukirState();
}

void main() {
  runApp(MyAppJukir());
}

class _MyAppJukirState extends State<MyAppJukir> {
  int _currentIndex = 0;
  HomePageJukir? homePageJukir;
  Map<String, dynamic> userData = {};
  late List<Widget> _pages = [
    RumahPageJukir(),
    ListKendaraanPageJukir(),
  ];

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
        _pages = [
          if (userData['status_jukir'] == 'Aktif')
            HomePageJukir()
          else
            RumahPageJukir(),
          ListKendaraanPageJukir(),
        ];
      });
    } else {
      print(response.body);
      throw Exception('Failed to fetch user data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Gray100,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages.whereType<Widget>().toList(),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 0;
                    });
                  },
                  icon: Icon(Icons.home_rounded),
                  color: _currentIndex == 0 ? Colors.red : Colors.grey,
                ),
                Text(
                  'Home', // Label untuk IconButton ini
                  style: TextStyle(
                    color: _currentIndex == 0 ? Colors.red : Colors.grey,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 1;
                    });
                  },
                  icon: Icon(Icons.local_parking_rounded),
                  color: _currentIndex == 1 ? Colors.red : Colors.grey,
                ),
                Text(
                  'Parking', // Label untuk IconButton ini
                  style: TextStyle(
                    color: _currentIndex == 1 ? Colors.red : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        shape: CircularNotchedRectangle(),
        notchMargin: 8,
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: (){
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyAppJukir()),
              );
            },
            backgroundColor: Red500,
            child: Icon(Icons.near_me_rounded),
          )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
