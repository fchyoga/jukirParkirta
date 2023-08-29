import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jukirparkirta/ui/auth/pre_login_page.dart';
import 'package:jukirparkirta/color.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PreLoginPage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo-parkirta.png',
              width: 96,
              height: 96,
            ),
            const SizedBox(height: 16),
            Text(
              'Parkirta',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Red500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Smart On Street Parking System',
              style: TextStyle(
                fontSize: 16,
                color: Gray800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
