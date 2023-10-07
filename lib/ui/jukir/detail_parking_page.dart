import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jukirparkirta/bloc/detail_parking_bloc.dart';
import 'package:jukirparkirta/color.dart';
import 'package:jukirparkirta/data/model/retribusi.dart';
import 'package:jukirparkirta/ui/jukir/profile.dart';
import 'package:jukirparkirta/utils/contsant/app_colors.dart';
import 'package:jukirparkirta/utils/contsant/parking_status.dart';
import 'package:jukirparkirta/widget/button/button_default.dart';
import 'package:jukirparkirta/widget/loading_dialog.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class DetailParkingPage extends StatefulWidget {

  DetailParkingPage();

  @override
  State<DetailParkingPage> createState() => _DetailParkingPageState();
}

class _DetailParkingPageState extends State<DetailParkingPage> {
  final _loadingDialog = LoadingDialog();
  late int retributionId;
  Retribusi? retribution;

  @override
  Widget build(BuildContext context) {
    retributionId = ModalRoute.of(context)?.settings.arguments as int;
    debugPrint("retribusi id ${retributionId}");
    return BlocProvider(
        create: (context) => DetailParkingBloc()..checkDetailParking(retributionId.toString()),
        child: BlocListener<DetailParkingBloc, DetailParkingState>(
            listener: (context, state) async{
              if (state is LoadingState) {
                state.show ? _loadingDialog.show(context) : _loadingDialog.hide();
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
                  return Scaffold(
                    backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 84,
        titleSpacing: 0,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, size: 18,),
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
      ),
                    body: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 50),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.cardGrey,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.01),
                                  blurRadius: 8,
                                  offset: const Offset(0, 20),),
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 15),),
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.09),
                                  blurRadius: 3,
                                  offset: const Offset(0, 8),),
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.10),
                                  blurRadius: 2,
                                  offset: const Offset(0, 5),),
                              ],
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: CircleAvatar(
                                    radius: 20,
                                    child:  Image.asset('assets/images/profile.png', width: 80,),
                                  ),
                                ),
                                const SizedBox(width: 20,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(retribution?.pelanggan?.namaLengkap ?? "-", style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16),),
                                    Text("ID${retribution?.pelanggan?.id.toString() ?? " - "}", style: TextStyle(color: AppColors.textPassive, fontSize: 14),),
                                    SizedBox(height: 2,),
                                    Text(retribution?.pelanggan?.email ?? "-", style: TextStyle(color: AppColors.text, fontSize: 16),),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Text("No. Pol", style: TextStyle(color: AppColors.textPassive, fontSize: 16),),
                          Text(retribution?.nopol ?? " - ", style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 24),),

                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Waktu Parkir", style: TextStyle(color: AppColors.textPassive, fontSize: 16),),
                                    Text("${retribution?.lamaParkir ?? "0"} jam", style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 24),),],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text("Tarif", style: TextStyle(color: AppColors.textPassive, fontSize: 16),),
                                    Text("Rp ${retribution?.biayaParkir?.biayaParkir ?? 0}", style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 24),),],
                                )
                              ],
                            ),
                          ),

                    (retribution?.statusParkir == ParkingStatus.prosesPembayaran.name || retribution?.statusParkir == ParkingStatus.prosesPembayaranAkhir.name) && retribution?.pembayaran?.status!= "SUDAH DIBAYAR"? Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                      child:ButtonDefault(title: "Terima Pembayaran", color: AppColors.green, onTap: () async{
                        await Navigator.pushNamed(context, "/payment", arguments: retribution);
                        provider.checkDetailParking(retributionId.toString());
                      })
                    ): Container()

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
