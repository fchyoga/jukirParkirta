import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jukirparkirta/bloc/auth_bloc.dart';
import 'package:jukirparkirta/ui/auth/pre_login_page.dart';
import 'package:jukirparkirta/color.dart';
import 'package:jukirparkirta/utils/contsant/user_const.dart';
import 'package:sp_util/sp_util.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late BuildContext _context;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      bool isLoggedIn = SpUtil.getBool(IS_LOGGED_IN) ?? false;
      if(isLoggedIn) {
        _context.read<AuthenticationBloc>().authenticatedEvent();
      } else{
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PreLoginPage(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
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
