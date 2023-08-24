import 'package:flutter/material.dart';
import 'package:foodcost/view/start_up/login_page.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'view/calendar/table_calendar.dart';


void main() {
  initializeDateFormatting().then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        // home: const TableBasicsExample());
        home: const LoginPage()
    );
  }
}
