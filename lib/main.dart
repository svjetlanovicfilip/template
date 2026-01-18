import 'package:calendar_view/calendar_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'common/constants/routes.dart';
import 'common/di/di_container.dart';
import 'common/widgets/screens/splash_screen.dart';
import 'config/style/theme.dart';
import 'features/calendar/data/models/slot.dart';
import 'features/calendar/ui/screens/book_appointment_screen.dart';
import 'features/calendar/ui/screens/home_screen.dart';
import 'features/login/ui/screens/forgot_password_screen.dart';
import 'features/login/ui/screens/login_screen.dart';
import 'features/service/data/models/service_type.dart';
import 'features/service/ui/screens/add_edit_service_screen.dart';
import 'features/service/ui/screens/service_list_screen.dart';
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
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case Routes.splash:
              return CupertinoPageRoute(
                builder: (context) => const SplashScreen(),
              );
            case Routes.login:
              return CupertinoPageRoute(
                builder: (context) => const LoginScreen(),
              );
            case Routes.home:
              return CupertinoPageRoute(
                builder:
                    (context) => HomeScreen(
                      slots: settings.arguments as List<Slot>? ?? [],
                    ),
              );
            case Routes.settings:
              return CupertinoPageRoute(
                builder: (context) => const SettingsScreen(),
              );
            case Routes.changePasswordScreen:
              return CupertinoPageRoute(
                builder: (context) => const ChangePasswordScreen(),
              );
            case Routes.changeTitleScreen:
              return CupertinoPageRoute(
                builder: (context) => const ChangeTitleScreen(),
              );
            case Routes.employeesScreen:
              return CupertinoPageRoute(
                builder: (context) => const EmployeesScreen(),
              );
            case Routes.addEditmployeesScreen:
              return CupertinoPageRoute(
                builder: (context) => const AddEditEmployeeScreen(),
              );
            case Routes.bookAppointment:
              return CupertinoPageRoute(
                builder:
                    (context) => BookAppointmentScreen(
                      slot: settings.arguments as Slot?,
                    ),
              );
            case Routes.serviceListScreen:
              return CupertinoPageRoute(
                builder: (context) => const ServiceListScreen(),
              );
            case Routes.addEditServicesScreen:
              return CupertinoPageRoute(
                builder:
                    (context) => AddEditServiceScreen(
                      service: settings.arguments as ServiceType?,
                    ),
              );
            case Routes.forgotPassword:
              return CupertinoPageRoute(
                builder: (context) => const ForgotPasswordScreen(),
              );
            default:
              return MaterialPageRoute(
                builder:
                    (context) =>
                        const Scaffold(body: Center(child: Text('404'))),
              );
          }
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
