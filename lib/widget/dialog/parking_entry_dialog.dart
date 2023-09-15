
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:jukirparkirta/bloc/detail_parking_bloc.dart';
import 'package:jukirparkirta/data/model/retribusi.dart';
import 'package:jukirparkirta/utils/contsant/user_const.dart';
import 'package:http/http.dart' as http;
import 'package:sp_util/sp_util.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class ParkingEntryDialog extends StatefulWidget {

  ParkingEntryDialog({
    Key? key,
    required this.id,
    required this.entryDate,
    required this.memberId,
    required this.vehicleType,
    required this.policeNumber,
    required this.onSuccess,
  }) : super(key: key);

  DateTime entryDate;
  int id;
  String memberId;
  String vehicleType;
  String policeNumber;
  Function onSuccess;
  
  @override
  State<ParkingEntryDialog> createState() => _ParkingEntryDialogState();
}

class _ParkingEntryDialogState extends State<ParkingEntryDialog> {


  bool _isLoading = false;
  late BuildContext _context;
  Retribusi? retribution;



  @override
  Widget build(BuildContext context) {
    _context = context;
    return BlocProvider(
        create: (context) => DetailParkingBloc()..checkDetailParking(widget.id.toString()),
        child: BlocListener<DetailParkingBloc, DetailParkingState>(
            listener: (context, state) async{
              if (state is LoadingState) {
                // state.show ? _loadingDialog.show(context) : _loadingDialog.hide();
              } else if (state is CheckDetailParkingSuccessState) {
                setState(() {
                  retribution = state.data.retribusi;
                });
              } else if (state is ErrorState) {
                showTopSnackBar(
                  context,
                  CustomSnackBar.error(
                    message: state.error,
                  ),
                );
              }
            },
            child: BlocBuilder<DetailParkingBloc, DetailParkingState>(
                builder: (context, state) {
                  var provider = context.read<DetailParkingBloc>();
                  return AlertDialog(
                    title: Text('Parkir Arrive'),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('ID Pelanggan: ${widget.memberId}'),
                        Text('Jenis Kendaraan: ${widget.memberId}'),
                        Text('Nomor Polisi: ${widget.memberId}'),
                        Text('Waktu Parkir: ${DateFormat("dd MMM yy HH:mm").format(widget.entryDate)}'),
                        // Tambahkan informasi lain yang ingin ditampilkan
                      ],
                    ),
                    actions: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          setState(() {
                            _isLoading = true; // Tampilkan indikator loading
                          });
                          await _takeVehiclePhoto(widget.id); // Mengambil foto kendaraan
                          setState(() {
                            _isLoading = false; // Sembunyikan indikator loading setelah foto diunggah
                          });
                        },
                        icon: _isLoading ? CircularProgressIndicator() : Icon(Icons.camera),
                        label: Text(_isLoading ? 'Loading...' : 'Foto Kendaraan'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Tutup dialog
                        },
                        child: Text('Tutup'),
                      ),
                    ],
                  );
                }
            )
        )
    );

  }


  Future<void> _takeVehiclePhoto(int parkingId) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    final token = SpUtil.getString(API_TOKEN);
    if (pickedFile == null) return;
    setState(() {
      _isLoading = true;
    });
    var _vehicleImage = File(pickedFile.path);

    // Membuat request multipart
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://parkirta.com/api/retribusi/upload/foto_kendaraan'),
    );

    // Menambahkan header bearer token
    request.headers['Authorization'] = 'Bearer $token';

    // Menambahkan field 'parking_id' ke request
    request.fields['id_retribusi_parkir'] = parkingId.toString();

    // Menambahkan file gambar ke request
    request.files.add(await http.MultipartFile.fromPath(
      'foto_kendaraan',
      _vehicleImage.path,
    ));

    try {
      // Mengirim request ke API
      final response = await request.send();

      // Membaca responsenya
      final responseString = await response.stream.bytesToString();
      final responseData = json.decode(responseString);

      // Menangani responsenya
      if (response.statusCode == 200) {
        final data = jsonDecode(responseString);
        // Menampilkan popup berhasil
        setState(() {
          _isLoading = false; // Sembunyikan indikator loading
        });
        Navigator.of(context).pop(); // Tutup dialog
        widget.onSuccess();
        // Tampilkan popup sukses setelah mengunggah foto
      } else {
        // Menampilkan popup gagal
        showTopSnackBar(
          _context,
          CustomSnackBar.error(
            message: 'Gagal mengunggah foto kendaraan',
          ),
        );
      }
    } catch (error) {
      // Menampilkan popup gagal
      showTopSnackBar(
        _context,
        CustomSnackBar.error(
          message: 'Terjadi kesalahan saat mengunggah foto kendaraan',
        ),
      );
    }
  }

}