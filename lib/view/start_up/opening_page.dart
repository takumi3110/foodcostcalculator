import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodcost/utils/firestore/users.dart';
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
        await Future<void>.delayed(const Duration(seconds: 3));
        print('duration 3seconds');
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
          if (user == null) {
            print('user is null');
            controller.close();
          } else {
            print('user is signe in');
            controller.add(user);
            controller.close();
          }
        });
      }
    );
    return controller.stream;
  })();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        // stream: FirebaseAuth.instance.authStateChanges(),
        stream: _stream,
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          Widget nextPage = const SizedBox();
          print('start');
          if (snapshot.hasError) {
            //   TODO: エラー画面
            return Container();
          } else {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                print('none');
                nextPage = const LoginPage();
              case ConnectionState.waiting:
                //     TODO: loading画面
                print('waiting');
                nextPage = const Center(
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(),
                  ),
                );
              case ConnectionState.active:
                print('active');
              case ConnectionState.done:
                print('done');
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
                        print(futureSnapshot.connectionState);
                        if (futureSnapshot.hasData) {
                          return const CalendarPage();
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
                //   print(snapshot.data!.uid);
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
