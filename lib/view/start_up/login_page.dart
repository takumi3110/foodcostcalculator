import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/utils/firestore/users.dart';
import 'package:foodcost/utils/widget_utils.dart';
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

  bool _isLoading = false;
  bool _isObscureText = true;
  bool _isMailLoginError = false;
  bool _isLineLoginError = false;


  @override
  Widget build(BuildContext context) {
    // final bottomSpace = MediaQuery.of(context).viewInsets.bottom;
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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30.0),
                      child: SizedBox(
                        width: 300,
                        child: TextField(
                          keyboardType: TextInputType.emailAddress,
                          controller: emailController,
                          decoration: const InputDecoration(hintText: 'メールアドレス'),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        keyboardType: TextInputType.visiblePassword,
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
                                  _isMailLoginError = true;
                                });
                              }
                              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CalendarPage()));
                            } else {
                              setState(() {
                                _isMailLoginError = true;
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
                    if (_isMailLoginError)
                      const Center(
                          child: Text(
                        '正しいメールアドレスとパスワードを入力してください。',
                        style: TextStyle(color: Colors.red),
                      )
                      ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 5.0,),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.grey))),
                            width: double.infinity,
                            child: const Text('他の方法でログインする'),
                          ),
                          // LINE Login
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Ink.image(
                              width: 150,
                              height: 45,
                              image: const AssetImage('images/line/btn_login_base.png'),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(15),
                                onTap: () async{
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  var result = await Authentication.lineSignIn();
                                  if (result is UserCredential) {
                                    var getUserResult = await UserFirestore.getUser(result.user!.uid);
                                    if (getUserResult == true) {
                                      Navigator.pushReplacement(
                                          context, MaterialPageRoute(builder: (context) => const CalendarPage()));
                                    } else {
                                      setState(() {
                                        _isLineLoginError = true;
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      _isLineLoginError = true;
                                    });
                                  }
                                  setState(() {
                                    _isLoading = false;
                                  });
                                },
                                splashColor: const Color(0xff000000).withAlpha(30)
                              ),
                            ),
                          ),
                          if (_isLineLoginError == true)
                            const Center(
                              child: Text('LINE認証できませんでした。', style: TextStyle(color: Colors.red),),
                            )



                        ],
                      ),
                    ),

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
