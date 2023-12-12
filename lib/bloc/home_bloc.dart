import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:jukirparkirta/data/message/response/parking/parking_check_response.dart';
import 'package:jukirparkirta/data/message/response/parking/parking_location_response.dart';
import 'package:jukirparkirta/data/repository/parking_repository.dart';
import 'package:jukirparkirta/data/repository/user_repository.dart';
import 'package:jukirparkirta/utils/contsant/user_const.dart';
import 'package:jukirparkirta/utils/list.dart';
import 'package:sp_util/sp_util.dart';

class HomeBloc extends Cubit<HomeState> {
  final ParkingRepository _parkingRepository = ParkingRepository();
  final UserRepository _userRepository = UserRepository();

  HomeBloc() : super(Initial());

  Future<void> initial() async {
    String? userStatus = SpUtil.getString(USER_STATUS);
    if (userStatus != "Aktif") {
      return;
    }

    emit(LoadingState(true));
    int? userId = SpUtil.getInt(USER_ID, defValue: null);
    int? onlineId = SpUtil.getInt(ONLINE_ID, defValue: null);
    int? locationId = SpUtil.getInt(LOCATION_ID, defValue: null);
    debugPrint("userid $userId locationId $locationId");
    if (locationId == null) {
      final responseLoc = await _parkingRepository.parkingLocation();
      emit(LoadingState(false));
      if (responseLoc.success) {
        var location =
            responseLoc.data.firstWhereOrNull((e) => e.id == onlineId);

        debugPrint("location ${responseLoc.data.length} ${location?.toJson()}");
        if (location != null) {
          SpUtil.putInt(LOCATION_ID, location.id);
          locationId = location.id;
        }
        debugPrint("locationId $locationId");
        emit(SuccessGetParkingLocationState(data: responseLoc.data));
      } else {
        emit(ErrorState(error: responseLoc.message));
      }
    } else {
      emit(LoadingState(false));
      getParkingLocation();
    }
    getParkingUser();
  }

  Future<void> getParkingLocation() async {
    emit(LoadingState(true));
    final response = await _parkingRepository.parkingLocation();
    emit(LoadingState(false));
    if (response.success) {
      emit(SuccessGetParkingLocationState(data: response.data));
    } else if (response.message == "Unauthorized") {
      emit(SessionExpiredState());
    } else {
      emit(ErrorState(error: response.message));
    }
  }

  Future<void> getParkingUser() async {
    emit(LoadingState(true));
    final response = await _parkingRepository.checkParking();
    emit(LoadingState(false));
    if (response.success) {
      emit(SuccessGetParkingUserState(data: response.data));
    } else if (response.message == "Unauthorized") {
      emit(SessionExpiredState());
    } else {
      emit(ErrorState(error: response.message));
    }
  }

  Future<void> updateParkingStatus(String status) async {
    emit(LoadingState(true));
    final response = await _parkingRepository.updateParkingStatus(status);
    emit(LoadingState(false));
    if (response.success) {
      emit(SuccessUpdateParkingState());
    } else if (response.message == "Unauthorized") {
      emit(SessionExpiredState());
    } else {
      emit(ErrorState(error: response.message));
    }
  }
}

abstract class HomeState {
  const HomeState();
}

class Initial extends HomeState {}

class SuccessGetParkingLocationState extends HomeState {
  final List<ParkingLocation> data;
  const SuccessGetParkingLocationState({required this.data});
}

class SuccessGetParkingUserState extends HomeState {
  final List<ParkingUser> data;
  const SuccessGetParkingUserState({required this.data});
}

class SuccessUpdateParkingState extends HomeState {
  const SuccessUpdateParkingState();
}

class SessionExpiredState extends HomeState {
  const SessionExpiredState();
}

class ErrorState extends HomeState {
  final String error;
  const ErrorState({required this.error});
}

class LoadingState extends HomeState {
  final show;
  LoadingState(this.show);
}

class PasswordState extends HomeState {}
