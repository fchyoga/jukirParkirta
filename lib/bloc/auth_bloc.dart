import 'package:bloc/bloc.dart';
import 'package:jukirparkirta/utils/contsant/authentication.dart';
import 'package:jukirparkirta/utils/contsant/user_const.dart';
import 'package:sp_util/sp_util.dart';

class AuthenticationBloc extends Cubit<Authentication> {
  AuthenticationBloc() : super(Authentication.Uninitialized);

  void unAuthenticatedEvent() {
    emit(Authentication.Unauthenticated);
  }

  void authenticationExpiredEvent() {
    SpUtil.putBool(IS_LOGGED_IN, false);
    SpUtil.remove(API_TOKEN);
    SpUtil.remove(EMAIL);
    SpUtil.remove(USER_NAME);
    SpUtil.remove(LOCATION_ID);
    SpUtil.remove(ROLE);
    emit(Authentication.AuthenticationExpired);
  }

  void authenticatedEvent() {
    emit(Authentication.Authenticated);
  }
}
