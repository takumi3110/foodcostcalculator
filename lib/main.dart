import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:foodcost/firebase_options.dart';
import 'package:foodcost/view/create/create_menu_page.dart';
import 'package:foodcost/view/start_up/login_page.dart';
import 'package:intl/date_symbol_data_local.dart';

// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';


// void main() {
//   initializeDateFormatting().then((_) => runApp(const MyApp()));
// }

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
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
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const LoginPage()
        // home: const CreateCostPage()
    );
  }
}
