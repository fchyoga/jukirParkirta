import 'package:flutter/material.dart';
import 'package:jukirparkirta/color.dart';
import 'package:jukirparkirta/ui/jukir/kendaraan.dart';
import 'package:jukirparkirta/ui/jukir/home_page.dart';
import 'package:jukirparkirta/ui/jukir/rumah.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:jukirparkirta/utils/contsant/app_colors.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

void main() {
  runApp(MainPage());
}

class _MainPageState extends State<MainPage> {
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
      bottomNavigationBar:  Container(
          color: Colors.white,
          height: 70,
          child: Column(
          children: [
            const Divider(
              thickness: 1,
              height: 1,
              color: AppColors.cardGrey,
            ),
            const SizedBox(height: 8,),
            Row(
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
                  icon:  SvgPicture.asset( _currentIndex == 0 ? "assets/images/ic_home.svg": "assets/images/ic_home_outline.svg"),
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
                  icon: SvgPicture.asset( _currentIndex == 1 ? "assets/images/ic_ticket.svg": "assets/images/ic_ticket_outline.svg"),
                ),

              ],
            ),
          ],
        )])
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: (){
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MainPage()),
              );
            },
            backgroundColor: Red500,
        shape: const CircleBorder(),
        child: SvgPicture.asset("assets/images/ic_discovery.svg"),
          )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
