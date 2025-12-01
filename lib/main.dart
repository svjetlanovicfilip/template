import 'package:calendar_view/calendar_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'common/constants/routes.dart';
import 'common/di/di_container.dart';
import 'common/widgets/screens/splash_screen.dart';
import 'config/style/theme.dart';
import 'features/calendar/ui/screens/home_screen.dart';
import 'features/login/ui/screens/login_screen.dart';

Future<void> mainApp(FirebaseOptions options) async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(options: options);

  setupDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: EventController(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: lightTheme,
        initialRoute: Routes.splash,
        debugShowCheckedModeBanner: false,
        routes: {
          Routes.splash: (context) => const SplashScreen(),
          Routes.login: (context) => const LoginScreen(),
          Routes.home: (context) => const HomeScreen(),
        },
      ),
    );
  }
}
