import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/utils/firestore/users.dart';
import 'package:foodcost/view/calendar/calendar_page.dart';
import 'package:foodcost/view/start_up/create_account_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            width: double.infinity,
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                const Text(
                  'まんまのじぇんこ',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 50,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: SizedBox(
                    width: 300,
                    child: TextField(
                      controller: emailController,
                      decoration: const InputDecoration(hintText: 'メールアドレス'),
                    ),
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: passController,
                    decoration: const InputDecoration(hintText: 'パスワード'),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                RichText(
                    text: TextSpan(style: const TextStyle(color: Colors.black), children: [
                  const TextSpan(text: 'アカウントを作成していない方は'),
                  TextSpan(
                      text: 'こちら',
                      style: const TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateAccountPage()));
                        })
                ])),
                const SizedBox(
                  height: 70,
                ),
                ElevatedButton(
                    onPressed: () async {
                      var result =
                          await Authentication.emailSignIn(email: emailController.text, password: passController.text);
                      // resultがUserCredentialタイプだったらtrue
                      if (result is UserCredential) {
                        // if (result.user!.emailVerified == true) {
                        //   var _result = await UserFirestore.getUser(result.user!.uid);
                        //   if (_result == true) {
                        //     Navigator.pushReplacement(
                        //         context, MaterialPageRoute(builder: (context) => const CalendarPage()));
                        //   }
                        // } else {
                        //   print('メール認証できませんでした。');
                        // }
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CalendarPage()));
                      }
                    },
                    child: const Text('メールアドレスでログイン'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
