import 'package:calendar_view/calendar_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'config/flavor/flavor_config.dart';

Future<void> mainApp(FirebaseOptions options) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: options);

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
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: MyHomePage(title: appFlavor.appTitle),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.title, super.key});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: DayView(
        startHour: 5,
        onDateTap: (date) {
          print(date);
        },
        eventTileBuilder: (date, events, boundary, startDuration, endDuration) {
          return Container(child: Icon(Icons.plus_one));
        },
        // hourIndicatorSettings: HourIndicatorSettings(startHour: 6),
        // hourLinePainter:
        //     (
        //       lineColor,
        //       lineHeight,
        //       offset,
        //       minuteHeight,
        //       showVerticalLine,
        //       verticalLineOffset,
        //       lineStyle,
        //       dashWidth,
        //       dashSpaceWidth,
        //       emulateVerticalOffsetBy,
        //       startHour,
        //       endHour,
        //     ) {},
        // timeLineBuilder: (date) {
        //   return Center(child: Icon(Icons.add, size: 18, color: Colors.grey));
        // },
      ),
    );
  }
}
