import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:jukirparkirta/data/message/response/parking/parking_check_detail_response.dart';
import 'package:jukirparkirta/data/repository/parking_repository.dart';


class DetailParkingBloc extends Cubit<DetailParkingState> {
  ParkingRepository _parkingRepository = ParkingRepository();

  DetailParkingBloc() : super(DetailParkingInitial());

  Future<void> checkDetailParking(String id) async {
    emit(LoadingState(true));
    final response =
    await _parkingRepository.checkDetailParking(id);
    emit(LoadingState(false));
    if (response.success) {

      emit(CheckDetailParkingSuccessState(data: response.data!));
    } else {
      emit(ErrorState(error: response.message));
    }
  }

  Future<void> uploadVehiclePhoto(String id, String path) async {
    emit(LoadingState(true));
    final response =
    await _parkingRepository.uploadVehiclePhoto(id, path);
    emit(LoadingState(false));
    if (response.success) {

      emit(const UploadVehiclePhotoSuccessState());
    } else {
      emit(ErrorState(error: response.message));
    }
  }

}

abstract class DetailParkingState {
  const DetailParkingState();
}

class DetailParkingInitial extends DetailParkingState {
}

class CheckDetailParkingSuccessState extends DetailParkingState {
  final ParkingCheckDetail data;
  const CheckDetailParkingSuccessState({required this.data});
}
class UploadVehiclePhotoSuccessState extends DetailParkingState {
  const UploadVehiclePhotoSuccessState();
}

class ErrorState extends DetailParkingState {
  final String error;
  const ErrorState({required this.error});

}

class LoadingState extends DetailParkingState {
  final show;
  LoadingState(this.show);
}


