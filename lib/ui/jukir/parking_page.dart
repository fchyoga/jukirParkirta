import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:jukirparkirta/bloc/home_bloc.dart';
import 'package:jukirparkirta/color.dart';
import 'package:jukirparkirta/data/message/response/parking/parking_check_response.dart';
import 'package:jukirparkirta/ui/jukir/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ParkingPage extends StatefulWidget {
  @override
  State<ParkingPage> createState() => _ParkingPageState();
}

class _ParkingPageState extends State<ParkingPage> {
  List<ParkingUser> parkingData = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
        listener: (context, state) async{
          if (state is SuccessGetParkingUserState) {
            setState(() {
              parkingData = state.data;
            });
          }
          },
        child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              return Scaffold(
      backgroundColor: Gray100,
      appBar: AppBar(
        backgroundColor: Gray100,
        toolbarHeight: 84,
        titleSpacing: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 24),
              child: Text(
                'Kendaraan Parkir',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Red900,
                ),
              ),
            ),
            SizedBox(width: 16),
          ],
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
      body: RefreshIndicator(
        onRefresh: () async{

          return await context.read<HomeBloc>().getParkingUser();
        },
        child: ListView.builder(
          itemCount: parkingData.length,
          itemBuilder: (context, index) {
            var item = parkingData[index];
            var icon = item.jenisKendaraan == 'Mobil' ? Icons.directions_car : Icons.motorcycle;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 0,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Icon(icon, color: Colors.red[500]),
                    title: Text(
                      'Nomor Polisi: ${item.nopol ?? "-"}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[900],
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status: ${item.statusParkir}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey[500],
                          ),
                        ),
                        Text(
                          'Durasi Parkir: ${item.lamaParkir} jam',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        "/detail_parking",
                        arguments: item.id,
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ); }));
  }
}
