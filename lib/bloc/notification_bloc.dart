import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:jukirparkirta/data/message/response/notification_response.dart';
import 'package:jukirparkirta/data/repository/user_repository.dart';


class NotificationBloc extends Cubit<NotificationState> {
  final UserRepository _userRepository = UserRepository();

  NotificationBloc() : super(NotificationInitial());

  Future<void> getNotification() async {
    emit(LoadingState(true));
    final response =
    await _userRepository.notification();
    emit(LoadingState(false));
    if (response.success) {

      emit(NotificationSuccessState(data: response.data!));
    } else {
      emit(ErrorState(error: response.message));
    }
  }

  Future<bool> readNotification(int id, String topic) async {
    final response =
    await _userRepository.readNotification(id, topic);
    return response.success;
  }


}

abstract class NotificationState {
  const NotificationState();
}

class NotificationInitial extends NotificationState {
}

class NotificationSuccessState extends NotificationState {
  final List<Notification> data;
  const NotificationSuccessState({required this.data});
}


class ErrorState extends NotificationState {
  final String error;
  const ErrorState({required this.error});

}

class LoadingState extends NotificationState {
  final show;
  LoadingState(this.show);
}


