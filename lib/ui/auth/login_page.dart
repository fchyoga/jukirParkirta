import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jukirparkirta/ui/jukir/app.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jukirparkirta/color.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  Future<void> _login(String role, String password) async {
    // Buat URL sesuai dengan jenis login (pelanggan atau jukir)
    String url = role == 'jukir' ? 'https://parkirta.com/api/login/jukir' : 'https://parkirta.com/api/login/pelanggan';

    // Persiapkan data untuk dikirim
    Map<String, String> data = {
      'email': _emailController.text,
      'password': password,
    };

    // Kirim permintaan HTTP POST
    try {
      final response = await http.post(Uri.parse(url), body: data);

      // Periksa kode status respons
      if (response.statusCode == 200) {
        // Berhasil login, ambil data dari respons JSON
        Map<String, dynamic> responseData = json.decode(response.body);
        bool success = responseData['success'];
        String token = responseData['data']['token'];
        // String fullName = responseData['data']['nama_lengkap'];
        String userRole = responseData['data']['role'];
        // String status = responseData['data']['status'];

          if (success) {
            // Berhasil login, arahkan ke halaman yang sesuai (MyApp atau MyAppJukir)
            if (userRole == 'jukir') {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool('isLoggedIn', true);
              prefs.setString('userRole', 'jukir');
              prefs.setString('token', token);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyAppJukir()));
            } else {

            }
          } else {
          // Gagal login, tampilkan pesan kesalahan
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Login Failed'),
                content: const Text('Invalid email or password.'),
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
      } else {
        // Gagal login, tampilkan pesan kesalahan
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Login Failed'),
              content: const Text('Invalid email or password.'),
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
    } catch (e) {
      // Terjadi kesalahan saat melakukan permintaan HTTP
      print('Error: $e');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('An error occurred while logging in. Please try again.'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo-parkirta.png',
                width: 54,
                height: 54,
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
                                _login('jukir', password);
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
      ),
    );
  }
}
