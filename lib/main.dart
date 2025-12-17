import 'package:calendar_view/calendar_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'common/constants/routes.dart';
import 'common/di/di_container.dart';
import 'common/widgets/screens/splash_screen.dart';
import 'config/style/theme.dart';
import 'features/calendar/ui/screens/book_appointment_screen.dart';
import 'features/calendar/ui/screens/home_screen.dart';
import 'features/login/ui/screens/login_screen.dart';
import 'features/settings/ui/screens/add_edit_employee_screen.dart';
import 'features/settings/ui/screens/change_password_screen.dart';
import 'features/settings/ui/screens/change_title_screen.dart';
import 'features/settings/ui/screens/employees_screen.dart';
import 'features/settings/ui/screens/settings_screen.dart';

Future<void> mainApp(FirebaseOptions options) async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(options: options);

  setupDependencies();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final EventController _eventController;

  @override
  void initState() {
    super.initState();
    _eventController = EventController();
  }

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: _eventController,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: lightTheme,
        initialRoute: Routes.splash,
        debugShowCheckedModeBanner: false,
        routes: {
          Routes.splash: (context) => const SplashScreen(),
          Routes.login: (context) => const LoginScreen(),
          Routes.home: (context) => const ExtractHomeScreenArguments(),
          Routes.settings: (context) => const SettingsScreen(),
          Routes.changePasswordScreen:
              (context) => const ChangePasswordScreen(),
          Routes.changeTitleScreen: (context) => const ChangeTitleScreen(),
          Routes.employeesScreen: (context) => const EmployeesScreen(),
          Routes.addEditmployeesScreen:
              (context) => const AddEditEmployeeScreen(),
          Routes.bookAppointment:
              (context) => const ExtractBookAppointmentArgumentsScreen(),
        },
      ),
    );
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }
}
