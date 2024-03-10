import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:foodcost/firebase_options.dart';
import 'package:foodcost/view/start_up/opening_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await LineSDK.instance.setup('2003933565');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Mamma no Jenco.',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrangeAccent),
          useMaterial3: true,
        ),
        home: const OpeningPage()
        // home: const LoginPage()
        // home: const StreamBuilderExample()
    );
  }
}
