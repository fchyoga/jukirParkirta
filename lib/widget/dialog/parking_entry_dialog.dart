
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
              } else if (state is UploadVehiclePhotoSuccessState) {
                Navigator.of(context).pop(); // Tutup dialog
                widget.onSuccess();
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
                  _context = context;
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
                        onPressed: state is LoadingState ? (){}: () async {
                          var path = await _takeVehiclePhoto(widget.id); // Mengambil foto kendaraan
                          debugPrint("path $path");
                          if(path !=null ) provider.uploadVehiclePhoto(widget.id.toString(), path);
                        },
                        icon: state is LoadingState  ? const Padding(padding: EdgeInsets.all(5), child: CircularProgressIndicator(),) : Icon(Icons.camera),
                        label: Text(state is LoadingState  ? 'Loading...' : 'Foto Kendaraan'),
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


  Future<String?> _takeVehiclePhoto(int parkingId) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    final token = SpUtil.getString(API_TOKEN);
    if (pickedFile == null) return null;
    return pickedFile.path;
  }

}