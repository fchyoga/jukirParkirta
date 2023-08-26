import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jukirparkirta/color.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jukirparkirta/jukir/submitted.dart';

import 'dart:async';

class AktivasiPage extends StatefulWidget {
  @override
  State<AktivasiPage> createState() => _AktivasiPageState();
}

class _AktivasiPageState extends State<AktivasiPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await showDialog<File?>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text("Pick Image"),
          children: [
            SimpleDialogOption(
              onPressed: () async {
                final picked = await picker.getImage(source: ImageSource.gallery);
                Navigator.pop(context, picked != null ? File(picked.path) : null);
              },
              child: const Text('Choose from Gallery'),
            ),
            SimpleDialogOption(
              onPressed: () async {
                final picked = await picker.getImage(source: ImageSource.camera);
                Navigator.pop(context, picked != null ? File(picked.path) : null);
              },
              child: const Text('Take a Photo'),
            ),
          ],
        );
      },
    );
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
    }
  }

  Future<void> _uploadImage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (_image != null) {
      // Membuat request HTTP
      final url = Uri.parse('https://parkirta.com/api/dompet/kartu_parkir/aktivasi');
      final request = http.MultipartRequest('POST', url);

      // Menambahkan header bearer token
      request.headers['Authorization'] = 'Bearer $token';

      // Menambahkan file foto ke request
      request.files.add(
        await http.MultipartFile.fromPath('foto_ktp', _image!.path),
      );

      try {
        // Mengirim request ke API
        final response = await request.send();

        // Membaca responsenya
        final responseString = await response.stream.bytesToString();
        final responseData = json.decode(responseString);

        // Menangani responsenya
        if (response.statusCode == 200 && responseData['success'] == true) {
          // Berhasil mengunggah foto
          showDialog(
            context: _scaffoldKey.currentContext!,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Success'),
                content: Text('Berhasil Upload Foto KTP.'),
                actions: [
                  TextButton(
                    onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SubmittedPage()),
                    );
                  },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          // Gagal mengunggah foto
          showDialog(
            context: _scaffoldKey.currentContext!,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('Gagal Upload Foto KTP.'),
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
        // Error saat mengirim request
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
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
          'Verifikasi',
          style: TextStyle(
            color: Red900,
            fontSize: 18,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: SingleChildScrollView(
            controller: ScrollController(),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/mail.png',
                    width: 96,
                    height: 96,
                  ),
                  const SizedBox(height: 32),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Text(
                        'Kartu Identitas',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Red800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Lampirkan kartu identitas (KTP) Anda untuk dilakukan pengecekan informasi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Red900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _pickImage,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          height:100,
                          decoration: BoxDecoration(
                            color: Gray200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: _image != null
                            ? Image.file(_image!, fit: BoxFit.cover)
                            : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt),
                                SizedBox(height: 8),
                                Text('Tambahkan foto'),
                              ],
                            ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextButton(
                    onPressed: _uploadImage,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Red100),
                      foregroundColor: MaterialStateProperty.all<Color>(Red500),
                      minimumSize: MaterialStateProperty.all<Size>(
                        const Size(double.infinity, 48),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5), 
                        ),
                      ),
                    ),
                    child: const Text('Submit'),
                  ),
  
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
