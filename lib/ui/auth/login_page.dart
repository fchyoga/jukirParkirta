import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jukirparkirta/bloc/auth_bloc.dart';
import 'package:jukirparkirta/bloc/login_bloc.dart';
import 'package:jukirparkirta/color.dart';
import 'package:jukirparkirta/widget/loading_dialog.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final _loadingDialog = LoadingDialog();
  late BuildContext _context;

  String deviceToken = "";

  @override
  void initState() {
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance; // Change here
    _firebaseMessaging.getToken().then((token) {
      deviceToken = token ?? "";
      debugPrint("device token $token");
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => LoginBloc(),
        child: BlocListener<LoginBloc, LoginState>(
            listener: (context, state) {
              if (state is LoginLoadingState) {
                state.show ? _loadingDialog.show(context) : _loadingDialog.hide();
              } else if (state is LoginSuccessState) {
                _context.read<AuthenticationBloc>().authenticatedEvent();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/",
                      (route) => false,
                );
              } else if (state is LoginErrorState) {
                showTopSnackBar(
                  context,
                  CustomSnackBar.error(
                    message: state.error,
                  ),
                );
              }
            },
            child: BlocBuilder<LoginBloc, LoginState>(
                builder: (context, state) {
                  _context = context;
                  return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 128),
            Image.asset(
              'assets/images/logo-parkirta.png',
              width: 54,
              height: 54,
            ),
            const SizedBox(height: 16),
            Text(
              'Jukir Parkirta',
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
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Red900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(
                          color: Gray500,
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Red900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(
                          color: Gray500,
                          width: 1.0,
                        ),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Gray500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            String email = _emailController.text;
                            String password = _passwordController.text;
                            if (email.isNotEmpty && password.isNotEmpty) {
                              // _login('jukir', password);
                              context.read<LoginBloc>().doLogin(email, password, deviceToken);
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Login Failed'),
                                    content: const Text('Please enter email and password.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
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
                          child: const Text('Login'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
                }
                )
        )
    );
  }
}
