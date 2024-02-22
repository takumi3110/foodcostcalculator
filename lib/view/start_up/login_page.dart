import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/utils/firestore/users.dart';
import 'package:foodcost/utils/widget_utils.dart';
import 'package:foodcost/view/calendar/calendar_page.dart';
import 'package:foodcost/view/start_up/create_account_page.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  bool _isLoading = false;
  bool _isObscureText = true;
  bool _isLoginError = false;

  @override
  Widget build(BuildContext context) {
    final bottomSpace = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: SafeArea(
          child: Stack(
        children: [
          SingleChildScrollView(
            // reverse: true,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              // padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: bottomSpace * 0.3),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    const Text(
                      'まんまのじぇんこ(仮)',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50.0),
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
                        decoration: InputDecoration(
                            hintText: 'パスワード',
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isObscureText = !_isObscureText;
                                  });
                                },
                                icon: Icon(_isObscureText ? Icons.visibility_off : Icons.visibility))),
                        obscureText: _isObscureText,
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
                      height: 50,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          if (emailController.text.isNotEmpty && passController.text.isNotEmpty) {
                            setState(() {
                              _isLoading = true;
                            });
                            var result = await Authentication.emailSignIn(
                                email: emailController.text, password: passController.text);
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
                              if (result.user != null) {
                                var _result = await UserFirestore.getUser(result.user!.uid);
                                if (_result == true) {
                                  Navigator.pushReplacement(
                                      context, MaterialPageRoute(builder: (context) => const CalendarPage()));
                                }
                              } else {
                                setState(() {
                                  _isLoginError = true;
                                });
                              }
                              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CalendarPage()));
                            } else {
                              setState(() {
                                _isLoginError = true;
                              });
                            }
                            setState(() {
                              _isLoading = false;
                            });
                          } else {
                            null;
                          }
                        },
                        child: const Text('メールアドレスでログイン')),
                    if (_isLoginError)
                      const Center(
                          child: Text(
                        '正しいメールアドレスとパスワードを入力してください。',
                        style: TextStyle(color: Colors.red),
                      )),
                  ],
                ),
              ),
            ),
          ),
          WidgetUtils.loadingStack(_isLoading)
        ],
      )),
    );
  }
}
