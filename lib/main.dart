import 'package:calendar_view/calendar_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'common/constants/routes.dart';
import 'common/di/di_container.dart';
import 'config/style/theme.dart';
import 'features/calendar/ui/screens/calendar_management_screen.dart';
import 'features/login/ui/screens/login_screen.dart';

Future<void> mainApp(FirebaseOptions options) async {
  WidgetsFlutterBinding.ensureInitialized();
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
        initialRoute: Routes.login,
        routes: {
          Routes.login: (context) => const LoginScreen(),
          Routes.home: (context) => const CalendarManagementScreen(),
        },
      ),
    );
  }
}
