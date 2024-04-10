import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
  // 通知を受信する設定
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: true,
    criticalAlert: false,
    provisional: false,
    sound: true
  );
  debugPrint('user permission: ${settings.authorizationStatus}');

  // トークンの取得。テスト用
  // final token = await messaging.getToken();
  // debugPrint(token);

  // フォアグラウンドで通知が表示されるようにする
  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
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
        title: 'まんまのじぇんこ',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.limeAccent),
          useMaterial3: true,
        ),
        home: const OpeningPage()
    );
  }
}
