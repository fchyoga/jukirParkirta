import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jukirparkirta/bloc/auth_bloc.dart';
import 'package:jukirparkirta/color.dart';
import 'package:jukirparkirta/main.dart';
import 'package:jukirparkirta/ui/jukir/home_page.dart';
import 'package:jukirparkirta/ui/jukir/parking_page.dart';
import 'package:jukirparkirta/ui/jukir/rumah.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:jukirparkirta/utils/contsant/app_colors.dart';
import 'package:jukirparkirta/utils/contsant/user_const.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sp_util/sp_util.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

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
  late BuildContext _context;
  late List<Widget> _pages = [
    RumahPageJukir(),
    ParkingPage(),
  ];

  @override
  void initState() {
    _requestPermissions();
    fetchUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      key: NavigationService.navigatorKey,
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
          ?Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
              bottom: 1,
              child: Container(
                width: 55,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: AppColors.colorPrimary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.colorPrimary.withOpacity(0.25),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),)
          ),
          Container(
            width: 65,
            height: 65,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: AppColors.colorPrimary,

            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainPage()),
                );
              },
              child: SvgPicture.asset("assets/images/ic_discovery.svg"),
            ) ,
          )
        ],
      ): null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
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
          ParkingPage(),
        ];
      });
    } else if (response.statusCode == 403) {
      showTopSnackBar(_context, CustomSnackBar.error(
        message: "Sesi anda telah habis. Silakan login kembali",
      ));
      _context.read<AuthenticationBloc>().authenticationExpiredEvent();
      Navigator.pushNamedAndRemoveUntil(_context, "/", (route) => false);
    } else {
      print(response.body);
      throw Exception('Failed to fetch user data');
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await androidImplementation?.requestPermission();
      // setState(() {
      //   _notificationsEnabled = granted ?? false;
      // });
    }
  }

}
