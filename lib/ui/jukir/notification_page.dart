import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:jukirparkirta/bloc/notification_bloc.dart';
import 'package:jukirparkirta/color.dart';
import 'package:jukirparkirta/data/message/response/notification_response.dart'
    as fcm;
import 'package:jukirparkirta/main.dart';
import 'package:jukirparkirta/utils/contsant/app_colors.dart';
import 'package:jukirparkirta/utils/contsant/transaction_const.dart';
import 'package:jukirparkirta/widget/dialog/parking_entry_dialog.dart';
import 'package:jukirparkirta/widget/loading_dialog.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class NotificationPage extends StatefulWidget {
  NotificationPage();

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final _loadingDialog = LoadingDialog();
  List<fcm.Notification> notifications = [];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => NotificationBloc()..getNotification(),
        child: BlocListener<NotificationBloc, NotificationState>(
            listener: (context, state) async {
          if (state is LoadingState) {
            state.show ? _loadingDialog.show(context) : _loadingDialog.hide();
          } else if (state is NotificationSuccessState) {
            setState(() {
              notifications = state.data;
              notifications.sort((a, b) => b.id.compareTo(a.id));
            });
          } else if (state is ErrorState) {
            showTopSnackBar(
              Overlay.of(context),
              CustomSnackBar.error(
                message: state.error,
              ),
            );
          }
        }, child: BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, state) {
          var provider = context.read<NotificationBloc>();
          return Scaffold(
            backgroundColor: AppColors.cardGrey,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 18,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text(
                'Notifikasi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Red900,
                ),
              ),
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                return await provider.getNotification();
              },
              child: notifications.isNotEmpty
                  ? ListView(
                      padding: EdgeInsets.only(top: 20),
                      children: notifications
                          .map((e) => InkWell(
                                onTap: () => onNotificationClick(e, provider),
                                child: Container(
                                  width: double.infinity,
                                  color: e.isRead == 0
                                      ? AppColors.yellow.withOpacity(0.03)
                                      : Colors.white,
                                  child: Column(
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              right: 20, top: 16, bottom: 16),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 6,
                                                height: 6,
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 10),
                                                decoration: BoxDecoration(
                                                  color: e.isRead == 0
                                                      ? AppColors.green
                                                          .withOpacity(0.7)
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                ),
                                              ),
                                              Expanded(
                                                  child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    e.title,
                                                    style: TextStyle(
                                                        color: AppColors.text,
                                                        fontWeight: e.isRead ==
                                                                0
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                        fontSize: 14),
                                                  ),
                                                  e.message != null
                                                      ? Text(
                                                          e.message!,
                                                          style: TextStyle(
                                                              color: AppColors
                                                                  .textPassive,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 12),
                                                        )
                                                      : Container(),
                                                ],
                                              )),
                                              Text(
                                                DateFormat("dd MMM yy \nHH:mm")
                                                    .format(e.createdAt),
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                    color: AppColors.text,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 10),
                                              ),
                                            ],
                                          )),
                                      Divider(
                                        color: AppColors.cardOutline,
                                        height: 1,
                                        thickness: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ))
                          .toList(),
                    )
                  : ListView(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.75,
                          alignment: Alignment.center,
                          child: Text(
                            "Belum ada notifikasi",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.textPassive, fontSize: 16),
                          ),
                        )
                      ],
                    ),
            ),
          );
        })));
  }

  Future<void> onNotificationClick(
      fcm.Notification e, NotificationBloc provider) async {
    if (e.isRead == 0) {
      provider.readNotification(e.referenceId, e.topic).then((value) {
        if (value == true) {
          setState(() {
            e.isRead = 1;
          });
        }
      });
    }
    if (e.topic == PAYMENT_ENTRY) {
      Navigator.pushNamed(context, '/detail_parking', arguments: e.referenceId);
    } else if (e.topic == PARKING_ARRIVE) {
      showDialog(
          context: context,
          builder: (_) => ParkingEntryDialog(
              id: e.referenceId,
              onSuccess: () {
                showTopSnackBar(
                  Overlay.of(context),
                  CustomSnackBar.success(
                    message: "Foto kendaraan berhasil diupload",
                  ),
                );
              }));
    }
  }
}
