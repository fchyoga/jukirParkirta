import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jukirparkirta/color.dart';
import 'package:jukirparkirta/jukir/profile.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:jukirparkirta/jukir/kendaraan.dart'; // Import Kendaraan class from list_kendaraan_page_jukir.dart

class DetailParkirPage extends StatelessWidget {
  final dynamic kendaraan;

  const DetailParkirPage({required this.kendaraan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Gray100,
        toolbarHeight: 84,
        titleSpacing: 0,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Detail Parkir',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Red900,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 24),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/profile.png'),
                radius: 20,
              ),
            ),
          ),
        ],
      ),
      // body: Padding(
      //   padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       Text(
      //         'Nomor Polisi: ${kendaraan.nomorPolisi}',
      //         style: TextStyle(
      //           fontSize: 16,
      //           fontWeight: FontWeight.bold,
      //           color: Red900,
      //         ),
      //       ),
      //       SizedBox(height: 16),
      //       Text(
      //         'Jenis Kendaraan: ${kendaraan.jenis}',
      //         style: TextStyle(
      //           fontSize: 14,
      //           fontWeight: FontWeight.normal,
      //           color: Gray900,
      //         ),
      //       ),
      //       SizedBox(height: 8),
      //       Text(
      //         'Status: ${kendaraan.sudahBayar ? 'Sudah Bayar' : 'Belum Bayar'}',
      //         style: TextStyle(
      //           fontSize: 14,
      //           fontWeight: FontWeight.normal,
      //           color: Gray900,
      //         ),
      //       ),
      //       SizedBox(height: 8),
      //       Text(
      //         'Durasi Parkir: ${kendaraan.durasiParkir} jam',
      //         style: TextStyle(
      //           fontSize: 14,
      //           fontWeight: FontWeight.normal,
      //           color: Gray900,
      //         ),
      //       ),
      //       SizedBox(height: 24),
      //       Text(
      //         'Lokasi Parkir:',
      //         style: TextStyle(
      //           fontSize: 16,
      //           fontWeight: FontWeight.bold,
      //           color: Red900,
      //         ),
      //       ),
      //       SizedBox(height: 16),
      //       Expanded(
      //         child: Container(
      //           decoration: BoxDecoration(
      //             borderRadius: BorderRadius.circular(8),
      //             boxShadow: [
      //               BoxShadow(
      //                 color: Colors.grey.withOpacity(0.3),
      //                 spreadRadius: 0,
      //                 blurRadius: 0,
      //                 offset: Offset(0, 0),
      //               ),
      //             ],
      //           ),
      //           child: GoogleMap(
      //             initialCameraPosition: CameraPosition(
      //               target: LatLng(0, 0),
      //               zoom: 14,
      //             ),
      //             markers: Set<Marker>.from([
      //               Marker(
      //                 markerId: MarkerId('parkingLocation'),
      //                 position: LatLng(0, 0),
      //               ),
      //             ]),
      //           ),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
