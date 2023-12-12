import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:jukirparkirta/color.dart';
import 'package:iconly/iconly.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ProfileEdit extends StatefulWidget {
  final String? userName;
  final String? userEmail;

  ProfileEdit({required this.userName, required this.userEmail});

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSubmitting = false;

  String? _imagePath;
  XFile? _image;

  DateTime? _selectedDate;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmController = TextEditingController();

  bool _isFormEmpty() {
    return nameController.text.isEmpty &&
        emailController.text.isEmpty &&
        passwordController.text.isEmpty &&
        confirmController.text.isEmpty;
  }

  void _clearForm() {
    setState(() {
      nameController.text = '';
      emailController.text = '';
      passwordController.text = '';
      confirmController.text = '';
    });
  }

  Future<XFile?> _compressImage(XFile image) async {
    final tempDir = await getTemporaryDirectory();
    final filePath = image.path;

    final compressedImage = await FlutterImageCompress.compressAndGetFile(
      filePath,
      '${tempDir.path}/compressed_image.jpg',
      quality: 50,
    );

    return compressedImage;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await showDialog<XFile>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text("Pick Image"),
          children: [
            SimpleDialogOption(
              onPressed: () async {
                final picked =
                    await picker.pickImage(source: ImageSource.gallery);
                Navigator.pop(context, picked);
              },
              child: const Text('Choose from Gallery'),
            ),
            SimpleDialogOption(
              onPressed: () async {
                final picked =
                    await picker.pickImage(source: ImageSource.camera);
                Navigator.pop(context, picked);
              },
              child: const Text('Take a Photo'),
            ),
          ],
        );
      },
    );

    if (pickedImage != null) {
      final compressedImage = await _compressImage(pickedImage);
      setState(() {
        _image = compressedImage;
      });
    }
  }

  Future<void> _submitForm() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (_image != null) {
      // Membuat request HTTP
      final url = Uri.parse('https://parkirta.com/api/profile/update');
      final request = http.MultipartRequest('POST', url);

      // Menambahkan header bearer token
      request.headers['Authorization'] = 'Bearer $token';

      // Menambahkan data ke dalam fields
      request.fields['nama_lengkap'] = nameController.text;
      request.fields['email'] = emailController.text;
      if (passwordController.text != "") {
        request.fields['password'] = passwordController.text;
        request.fields['password_confirm'] = confirmController.text;
      }
      request.fields['role'] = 'jukir';

      // Menambahkan file gambar ke dalam request
      request.files.add(
        await http.MultipartFile.fromPath('foto', _image!.path),
      );

      try {
        // Mengirim request ke API
        final response = await request.send();

        // Membaca responsenya
        final responseString = await response.stream.bytesToString();
        print('Response String: $responseString');
        final responseData = json.decode(responseString);

        // Menangani responsenya
        if (response.statusCode == 200) {
          final data = responseData['data'];

          showDialog(
            context: _scaffoldKey.currentContext!,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Success'),
                content: Text('Data berhasil diperbarui.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
          _clearForm;
        } else {
          final error = responseData['message'];
          showDialog(
            context: _scaffoldKey.currentContext!,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text(error),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        showDialog(
          context: _scaffoldKey.currentContext!,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Terjadi kesalahan saat mengirim request: $e'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      showDialog(
        context: _scaffoldKey.currentContext!,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Harap pilih foto.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    nameController.text = widget.userName.toString();
    emailController.text = widget.userEmail.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            IconlyLight.arrow_left_2,
            color: Red900,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Gray900,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: SingleChildScrollView(
            controller: ScrollController(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: _pickImage,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors
                                    .grey[100], // Ganti dengan Colors.grey[100]
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: _image != null
                                  ? Image.file(File(_image!.path),
                                      fit: BoxFit
                                          .cover) // Ubah menjadi File(_image!.path)
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(IconlyBold.camera),
                                        SizedBox(height: 8),
                                        Text('Foto Profile'),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Nama',
                        style: TextStyle(
                          fontSize: 12,
                          color: Red900,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Gray100,
                            width: 1.0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: TextFormField(
                            controller: nameController,
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Masukkan Nama',
                            ),
                            onChanged: (value) {},
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 12,
                          color: Red900,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Gray100,
                            width: 1.0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Masukkan Email',
                            ),
                            onChanged: (value) {},
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 12,
                          color: Red900,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Gray100,
                            width: 1.0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: TextFormField(
                            controller: passwordController,
                            keyboardType: TextInputType.visiblePassword,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Masukkan Password',
                            ),
                            onChanged: (value) {},
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Confirm Password',
                        style: TextStyle(
                          fontSize: 12,
                          color: Red900,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Gray100,
                            width: 1.0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: TextFormField(
                            controller: confirmController,
                            keyboardType: TextInputType.visiblePassword,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Konfirmasi Password',
                            ),
                            onChanged: (value) {},
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
                SizedBox(height: 64),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_isSubmitting)
                        Center(
                          child: CircularProgressIndicator(),
                        ),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: _isFormEmpty() || _isSubmitting
                            ? null
                            : () async {
                                setState(() {
                                  _isSubmitting = true;
                                });
                                await _submitForm();
                                setState(() {
                                  _isSubmitting = false;
                                });
                              },
                        child: Text(
                          'Simpan',
                          style: TextStyle(
                            fontSize: 16,
                            color: _isFormEmpty() || _isSubmitting
                                ? Gray500
                                : Colors.white,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: _isFormEmpty() || _isSubmitting
                              ? Gray100
                              : Red500,
                          padding: EdgeInsets.symmetric(
                              vertical: 18, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(
                          height:
                              8), // Beri jarak antara indikator loading dan tombol "Kosongkan"
                      TextButton(
                        onPressed: _isFormEmpty() ? null : _clearForm,
                        child: Text(
                          'Kosongkan',
                          style: TextStyle(
                            fontSize: 16,
                            color: _isFormEmpty() ? Gray500 : Colors.white,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: _isFormEmpty() ? Gray100 : Red500,
                          padding: EdgeInsets.symmetric(
                              vertical: 18, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 28),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
