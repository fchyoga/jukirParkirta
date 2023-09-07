import 'package:flutter/material.dart';
import 'package:jukirparkirta/bloc/auth_bloc.dart';
import 'package:jukirparkirta/ui/auth/login_page.dart';
import 'package:jukirparkirta/ui/auth/pre_login_page.dart';
import 'package:jukirparkirta/ui/auth/register_page.dart';
import 'package:jukirparkirta/ui/auth/splash_page.dart';
import 'package:jukirparkirta/ui/jukir/main_page.dart';
import 'package:jukirparkirta/color.dart';
import 'package:jukirparkirta/ui/jukir/home_page.dart';
import 'package:jukirparkirta/utils/contsant/authentication.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sp_util/sp_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SpUtil.getInstance();
  Bloc.observer = AppBlocObserver();
  runApp(App());
}
/// Custom [BlocObserver] that observes all bloc and cubit state changes.
class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (bloc is Cubit) debugPrint(change.toString());
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    debugPrint(transition.toString());
  }
}

class App extends StatelessWidget {
  /// {@macro app}
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    bool isLoggedIn = SpUtil.getBool('isLoggedIn') ?? false;
    String userRole = SpUtil.getString('userRole') ?? '';

    return BlocProvider(
        create: (_) => AuthenticationBloc(),
        child: MainApp(isLoggedIn: isLoggedIn, userRole: userRole)
    );
  }
}

class MainApp extends StatelessWidget {
  final bool isLoggedIn;
  final String userRole;

  const MainApp({Key? key, required this.isLoggedIn, required this.userRole}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Parkirta',
      theme: ThemeData(
        fontFamily: 'Inter',
        primaryColor: Red50,
      ),
        initialRoute: "/",
        routes: {
          '/': (context) => AppRoute(),
          '/login': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
          '/pre_login': (context) => const PreLoginPage(),
          '/home': (context) => HomePageJukir(),
        }
    );
  }
}

class AppRoute extends StatelessWidget {
  const AppRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, Authentication>(
      builder: (context, state) {
        debugPrint("state change $state");
        switch (state) {
          case Authentication.Authenticated:
            return MainPage();
          case Authentication.Unauthenticated:
            return LoginPage();
          default:
            return const SplashPage();
        }
      },
    );

  }
}
