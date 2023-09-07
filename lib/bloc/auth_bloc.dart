
import 'package:bloc/bloc.dart';
import 'package:jukirparkirta/utils/contsant/authentication.dart';


class AuthenticationBloc
    extends Cubit<Authentication> {

  AuthenticationBloc():  super(Authentication.Uninitialized);

  void unAuthenticatedEvent(){
    emit(Authentication.Unauthenticated);
  }
  void authenticationExpiredEvent(){
    emit(Authentication.AuthenticationExpired);
  }
  void authenticatedEvent(){
    emit(Authentication.Authenticated);
  }

}


