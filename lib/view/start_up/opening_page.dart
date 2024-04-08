import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/utils/firestore/users.dart';
import 'package:foodcost/utils/widget_utils.dart';
import 'package:foodcost/view/calendar/calendar_page.dart';
import 'package:foodcost/view/start_up/login_page.dart';

class OpeningPage extends StatefulWidget {
  const OpeningPage({super.key});

  @override
  State<OpeningPage> createState() => _OpeningPageState();
}

class _OpeningPageState extends State<OpeningPage> {
  final Stream<User?> _stream = (() {
    late final StreamController<User?> controller;
    controller = StreamController<User?> (
      onListen: () async {
        await Future<void>.delayed(const Duration(seconds: 5));
        debugPrint('duration 5seconds');
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
          if (user == null) {
            debugPrint('user is null');
            controller.close();
          } else {
            debugPrint('user is sign in');
            Authentication.currentFirebaseUser = user;
            if (controller.isClosed == false) {
              controller.add(user);
              controller.close();
            }
          }
        });
      }
    );
    return controller.stream;
  })();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<User?>(
        // stream: FirebaseAuth.instance.authStateChanges(),
        stream: _stream,
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          Widget nextPage = const SizedBox();
          debugPrint('start');
          if (snapshot.hasError) {
            //   TODO: エラー画面
            return Container();
          } else {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                debugPrint('none');
                nextPage = const LoginPage();
              case ConnectionState.waiting:
                // loading画面
                debugPrint('waiting');
                nextPage = Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      WidgetUtils.loadingImage(),
                      const Text('まんまのじぇんこ', style: TextStyle(fontFamily: 'AmeChan', fontSize: 24),)
                    ],
                  ),
                );
              case ConnectionState.active:
                debugPrint('active');
              case ConnectionState.done:
                debugPrint('done');
                if (snapshot.hasData) {
                  nextPage = FutureBuilder(
                      future: UserFirestore.getUser(snapshot.data!.uid),
                      builder: (BuildContext context, futureSnapshot) {
                        // if (futureSnapshot.connectionState == ConnectionState.waiting) {
                        //   return const Center(
                        //     child: SizedBox(
                        //       width: 60,
                        //       height: 60,
                        //       child: CircularProgressIndicator(),
                        //     ),
                        //   );
                        // }
                        // return const CalendarPage();
                        debugPrint('${futureSnapshot.connectionState}');
                        if (futureSnapshot.hasData) {
                          return const CalendarPage();
                          // return const LoginPage();
                        } else {
                          return Container(
                            color: Colors.white,
                          );
                        }
                      });
                } else {
                  return const LoginPage();
                }

                // if (snapshot.hasData) {
                //   debugPrint(snapshot.data!.uid);
                //   nextPage = const Center(
                //     child: Icon(
                //       Icons.info,
                //       color: Colors.blue,
                //       size: 60,
                //     ),
                //   );
                // }

            }
          }

          return nextPage;
        },
      ),
    );
  }
}
