import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:jukirparkirta/data/repository/parking_repository.dart';
import 'package:parkirta/data/message/response/parking/parking_location_response.dart';
import 'package:parkirta/data/message/response/parking/submit_arrive_response.dart';
import 'package:parkirta/data/repository/parking_repository.dart';
import 'package:parkirta/data/repository/user_repository.dart';
import 'package:parkirta/utils/contsant/user_const.dart';
import 'package:sp_util/sp_util.dart';

class HomeBloc extends Cubit<HomeState> {
  final ParkingRepository _parkingRepository = ParkingRepository();

  HomeBloc() : super(Initial());

  void initial(){
    emit(Initial());
  }


  // Future<void> getParkingLocation() async {
  //   emit(LoadingState(true));
  //   final response =
  //       await _parkingRepository.parkingLocation();
  //   emit(LoadingState(false));
  //   if (response.success) {
  //     emit(SuccessGetParkingLocationState(data: response.data));
  //   } else {
  //     emit(ErrorState(error: response.message));
  //   }
  // }
}

abstract class HomeState {
  const HomeState();
}

class Initial extends HomeState {
}

class SuccessGetParkingLocationState extends HomeState {
  final List<ParkingLocation> data;
  const SuccessGetParkingLocationState({required this.data});
}
class SuccessSubmitArrivalState extends HomeState {
  final SubmitArrival data;
  const SuccessSubmitArrivalState({required this.data});
}

class ErrorState extends HomeState {
  final String error;
  const ErrorState({required this.error});

}

class LoadingState extends HomeState {
  final show;
  LoadingState(this.show);
}

class PasswordState extends HomeState {
}

