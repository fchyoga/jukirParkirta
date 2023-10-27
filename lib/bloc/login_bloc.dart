import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:jukirparkirta/data/repository/user_repository.dart';
import 'package:jukirparkirta/utils/contsant/user_const.dart';
import 'package:sp_util/sp_util.dart';

class LoginBloc extends Cubit<LoginState> {
  UserRepository _userRepository = UserRepository();

  LoginBloc() : super(LoginInitial());



  void doLogin(String email, String password, String token) async {
    emit(LoginLoadingState(true));
    final response =
        await _userRepository.login(email, password, token);
    emit(LoginLoadingState(false));
    if (response.success) {

      SpUtil.putString(API_TOKEN, response.data?.token ?? "");
      SpUtil.putInt(USER_ID, response.data?.id ?? 0);
      SpUtil.putString(USER_NAME, response.data?.name?? "");
      SpUtil.putString(USER_STATUS, response.data?.status?? "");
      SpUtil.putString(EMAIL, response.data?.email?? "");
      SpUtil.putBool(IS_LOGGED_IN, true);

      emit(LoginSuccessState());



    } else {
      emit(LoginErrorState(error: response.message ?? "Login failed !"));
    }
  }
}

abstract class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {
}
class LoginSuccessState extends LoginState {
}

class LoginErrorState extends LoginState {
  final String error;
  const LoginErrorState({required this.error});

}

class LoginLoadingState extends LoginState {
  final show;
  LoginLoadingState(this.show);
}

class LoginPasswordState extends LoginState {
}

