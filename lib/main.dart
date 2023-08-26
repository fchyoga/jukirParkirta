import 'package:flutter/material.dart';
import 'package:jukirparkirta/auth/splash.dart';
import 'package:jukirparkirta/jukir/app.dart';
import 'package:jukirparkirta/color.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String userRole = prefs.getString('userRole') ?? '';

  runApp(MainApp(isLoggedIn: isLoggedIn, userRole: userRole));
}

class MainApp extends StatelessWidget {
  final bool isLoggedIn;
  final String userRole;

  const MainApp({Key? key, required this.isLoggedIn, required this.userRole}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget home;
    if (isLoggedIn) {
      home = MyAppJukir();
    } else {
      home = const SplashPage();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Parkirta',
      theme: ThemeData(
        primaryColor: Red50,
      ),
      home: home,
    );
  }
}
