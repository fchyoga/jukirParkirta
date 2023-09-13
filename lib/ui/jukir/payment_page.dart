import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jukirparkirta/bloc/payment_bloc.dart';
import 'package:jukirparkirta/utils/contsant/app_colors.dart';
import 'package:jukirparkirta/utils/contsant/transaction_const.dart';
import 'package:jukirparkirta/widget/button/button_default.dart';
import 'package:jukirparkirta/widget/loading_dialog.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../data/model/retribusi.dart';


class PaymentPage extends StatefulWidget {

  PaymentPage();

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {

  final _loadingDialog = LoadingDialog();
  Retribusi? retribution;
  Duration? duration;
  String? paymentStep;


  @override
  Widget build(BuildContext context) {
    retribution = ModalRoute.of(context)?.settings.arguments as Retribusi?;
    // retribution = args["retribusi"];
    // var time = args["jam"];
    // duration = args["durasi"];
    // paymentStep = args[PAYMENT_STEP];
    return BlocProvider(
        create: (context) => PaymentBloc(),
        child: BlocListener<PaymentBloc, PaymentState>(
            listener: (context, state) async{
              if (state is LoadingState) {
                state.show ? _loadingDialog.show(context) : _loadingDialog.hide();
              // } else if (state is CheckDetailParkingSuccessState) {
              } else if (state is PaymentSuccessState) {
                showTopSnackBar(
                  context,
                  const CustomSnackBar.success(
                    message: "Pembayaran Berhasil",
                  ),
                );
                Navigator.pop(context);
              } else if (state is ErrorState) {
                showTopSnackBar(
                  context,
                  CustomSnackBar.error(
                    message: state.error,
                  ),
                );
              }
            },
            child: BlocBuilder<PaymentBloc, PaymentState>(
                builder: (context, state) {
                  return Scaffold(
                      backgroundColor: Colors.white,
                      appBar: AppBar(
                        elevation: 0,
                        backgroundColor: Colors.white,
                        automaticallyImplyLeading: false,
                        centerTitle: true,
                        leading: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.arrow_back_ios_rounded,
                              color: AppColors.text,
                              size: 18,
                            ),
                          ),
                        ),
                        title: const Text(
                          "Pembayaran",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                          ),
                        ),
                      ),
                      body:   SingleChildScrollView(
                        child: Column(
                          children: [
                            retribution!=null ? buildParkingConfirmation(context):
                            const Text("Payment not found"),
                          ],
                        ),
                      )
                  );
                }
            )
        )
    );
  }

  Widget buildParkingConfirmation(BuildContext context){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Container(
           padding: EdgeInsets.all(20),
           decoration: BoxDecoration(
             color: AppColors.cardGrey,
             borderRadius: BorderRadius.circular(10)
           ),
           child: Column(
             children: [
               Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 const Text("Waktu Parkir : ", style: TextStyle(fontWeight: FontWeight.normal)),
                 Text("${retribution?.lamaParkir ?? 0} jam", style: const TextStyle(fontWeight: FontWeight.normal)),
               ],
             ),
               const SizedBox(height: 5),
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Text("Tarif Per-Jam : ", style: TextStyle(fontWeight: FontWeight.normal)),
                   Text("Rp ${retribution!.biayaParkir?.biayaParkir ?? 0}", style: TextStyle(fontWeight: FontWeight.normal)),

                 ],
               ),
               const SizedBox(height: 5),
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   const Text("Total : ", style: TextStyle(fontWeight: FontWeight.bold)),
                   Text("Rp ${getTotalPrice() ?? 0}", style: const TextStyle(fontWeight: FontWeight.bold)),
                 ],
               ),
             ],
           ),
         ),

         const SizedBox(height: 80,),Text("Metode pembayaran", style: const TextStyle(fontWeight: FontWeight.bold)),
         const SizedBox(height: 10,),
         ButtonDefault(title: "Card Pay", color: AppColors.green, onTap: () {}),
         const SizedBox(height: 10,),
         ButtonDefault(title: "Cash", color: AppColors.greenLight, textColor: AppColors.green, onTap: (){
           context.read<PaymentBloc>().paymentJukir("TRX-G95C8Z1P", CASH_CODE, "");
         }),

       ],
      ),
    );
  }


  void showBottomSheetWaiting(BuildContext _context) {

    Timer(Duration(seconds: 5), (){
      Navigator.of(context).pushNamed("/payment_success");
    });
    showModalBottomSheet(
        context: _context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        builder: (context) {

          return SingleChildScrollView(
            child: AnimatedPadding(
              padding: MediaQuery.of(context).viewInsets,
              duration: const Duration(milliseconds: 100),
              curve: Curves.decelerate,
              child: Container(
                constraints: const BoxConstraints(
                    minHeight: 200
                ),
                alignment: Alignment.center,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Menunggu Konfirmasi \nJuru Parkir",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 10,),
                    Text(
                      "Tunggu sebentar..",
                      style: TextStyle(
                        color: AppColors.textPassive,
                        fontSize: 16,
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  String? getDurationString(){
    if(duration!=null){
      var minutes = duration!.inMinutes.remainder(60) == 0 ? "01" :duration!.inMinutes.remainder(60).toString().padLeft(2, '0');
      return "${duration!.inHours.toString().padLeft(2, '0')}:$minutes";
    }else{
      return null;
    }
  }

  String? getTotalPrice(){
    if(retribution?.biayaParkir?.biayaParkir !=null){
      int hour = int.tryParse(retribution?.lamaParkir ?? "1") ?? 1;
      return "${hour*retribution!.biayaParkir!.biayaParkir}";
    }else{
      return null;
    }
  }
}