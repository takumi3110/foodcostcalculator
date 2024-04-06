import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodcost/component/error_text.dart';
import 'package:foodcost/component/login_text_field.dart';
import 'package:foodcost/component/primary_button.dart';
import 'package:foodcost/model/account.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/utils/extension.dart';
import 'package:foodcost/utils/firestore/users.dart';
import 'package:foodcost/utils/widget_utils.dart';
import 'package:foodcost/view/calendar/calendar_page.dart';
import 'package:foodcost/view/start_up/check_email_page.dart';
import 'package:foodcost/view/start_up/create_account_page.dart';
import 'package:foodcost/view/start_up/forget_password_page.dart';

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
  bool _isNotMailVerified = false;
  bool _isLineLoginError = false;
  bool _isGoogleLoginError = false;
  bool _isValidEmail = true;

  @override
  Widget build(BuildContext context) {
    // final bottomSpace = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      backgroundColor: Colors.white,
      // resizeToAvoidBottomInset: false,
      body: SafeArea(
          child: Stack(
        children: [
          SingleChildScrollView(
            // reverse: true,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              // padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: bottomSpace * 0.3),
              child: Center(
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 50.0),
                        child: Text(
                          'まんまのじぇんこ',
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, fontFamily: 'AmeChan', color: Colors.green,),
                        ),
                      ),
                      LoginTextField(
                          hintText: 'メールアドレス',
                          textInputType: TextInputType.emailAddress,
                          textEditingController: emailController,
                        onChanged: (String value) {
                            setState(() {
                              _isValidEmail = value.isValidEmail();
                            });
                        },
                      ),
                      if (!_isValidEmail)
                        const ErrorText(text: '正しい形式で入力してください。'),
                      LoginTextField(
                        hintText: 'パスワード',
                        textInputType: TextInputType.visiblePassword,
                        textEditingController: passController,
                        isObscureText: _isObscureText,
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isObscureText = !_isObscureText;
                              });
                            },
                            icon: Icon(_isObscureText ? Icons.visibility_off : Icons.visibility)),
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
                                    Navigator.push(
                                        context, MaterialPageRoute(builder: (context) => const CreateAccountPage()));
                                  })
                          ])),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: RichText(text: TextSpan(
                            children: [
                              TextSpan(
                                  text: 'パスワードを忘れた場合',
                                  style: const TextStyle(color: Colors.blue),
                                  recognizer: TapGestureRecognizer()..onTap = () {
                                    Navigator.push(
                                        context, MaterialPageRoute(builder: (context) => const ForgetPasswordPage())
                                    );
                                  }
                              )
                            ]
                        )),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Column(
                          children: [

                            PrimaryButton(
                              onPressed: () async {
                                if (emailController.text.isNotEmpty && passController.text.isNotEmpty) {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  var result = await Authentication.emailSignIn(
                                      email: emailController.text, password: passController.text);
                                  // resultがUserCredentialタイプだったらtrue
                                  if (result is UserCredential) {
                                    if (result.user != null) {
                                      if (result.user!.emailVerified == true) {
                                        var getUserResult = await UserFirestore.getUser(result.user!.uid);
                                        if (getUserResult == true) {
                                          Navigator.pushReplacement(
                                              context, MaterialPageRoute(builder: (context) => const CalendarPage()));
                                        }
                                      } else {
                                        debugPrint('メール認証なし');
                                        // result.user!.sendEmailVerification();
                                        setState(() {
                                          _isNotMailVerified = true;
                                        });
                                      }
                                    } else {
                                      setState(() {
                                        _isMailLoginError = true;
                                      });
                                    }
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
                              childText: 'メールアドレスでログイン',
                            ),if (_isNotMailVerified)
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const ErrorText(text: 'メールの認証が完了していません。'),
                                  RichText(
                                      text: TextSpan(style: const TextStyle(color: Colors.black), children: [
                                        TextSpan(
                                            text: 'ここをタップ',
                                            style: const TextStyle(color: Colors.blue),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                if (Authentication.currentFirebaseUser != null &&
                                                    emailController.text.isNotEmpty &&
                                                    passController.text.isNotEmpty) {
                                                  Authentication.currentFirebaseUser!.sendEmailVerification();
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => CheckEmailPage(
                                                            email: emailController.text,
                                                            pass: passController.text,
                                                            user: Authentication.currentFirebaseUser!,
                                                          )));
                                                }
                                              }),
                                        const TextSpan(text: 'して認証を完了してください。', style: TextStyle(color: Colors.red))
                                      ])),
                                ],
                              ),
                            if (_isMailLoginError)
                              const Center(
                                child: ErrorText(text: '正しいメールアドレスとパスワードを入力してください。'),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 5.0,
                              ),
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.grey))),
                              width: double.infinity,
                              child: const Text('他の方法でログインする'),
                            ),
                            // LINE Login
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Ink.image(
                                    width: 45,
                                    height: 45,
                                    image: const AssetImage('assets/images/line/btn_base.png'),
                                    child: InkWell(
                                        borderRadius: BorderRadius.circular(15),
                                        onTap: () async {
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
                                        splashColor: const Color(0xff000000).withAlpha(30)),
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Container(
                                    width: 45,
                                    height: 45,
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey.shade400),
                                        borderRadius: BorderRadius.circular(10)),
                                    child: Ink.image(
                                      // padding: EdgeInsets.all(8),
                                      // width: 45,
                                      // height: 45,
                                      image: const AssetImage('assets/images/google_logo.png'),
                                      child: InkWell(
                                          borderRadius: BorderRadius.circular(10),
                                          onTap: () async {
                                            setState(() {
                                              _isLoading = true;
                                            });
                                            var result = await Authentication.signInWithGoogle();
                                            if (result is UserCredential) {
                                              var getGoogleUserResult = await UserFirestore.getUser(result.user!.uid);
                                              if (getGoogleUserResult == true) {
                                                Navigator.pushReplacement(context,
                                                    MaterialPageRoute(builder: (context) => const CalendarPage()));
                                              } else {
                                                // user作成処理
                                                if (result.user != null) {
                                                  final user = result.user!;
                                                  Account newAccount = Account(
                                                      id: user.uid,
                                                      createdTime: Timestamp.now(),
                                                      email: user.email!,
                                                      groupId: null,
                                                      imagePath: user.photoURL,
                                                      isInitialAccess: true,
                                                      name: user.displayName!,
                                                      updatedTime: Timestamp.now());
                                                  var createGoogleUserResult = await UserFirestore.setUser(newAccount);
                                                  if (createGoogleUserResult == true) {
                                                    Navigator.pushReplacement(context,
                                                        MaterialPageRoute(builder: (context) => const CalendarPage()));
                                                  } else {
                                                    setState(() {
                                                      _isGoogleLoginError = true;
                                                    });
                                                  }
                                                } else {
                                                  setState(() {
                                                    _isGoogleLoginError = true;
                                                  });
                                                }
                                              }
                                            } else {
                                              setState(() {
                                                _isGoogleLoginError = true;
                                              });
                                            }
                                            setState(() {
                                              _isLoading = false;
                                            });
                                          },
                                          // highlightColor: Colors.red,
                                          splashColor: const Color(0xff000000).withAlpha(30)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_isLineLoginError == true)
                              const Center(
                                child: ErrorText(text: 'LINE認証できませんでした。'),
                              ),
                            if (_isGoogleLoginError == true)
                              const Center(
                                  child: ErrorText(text: 'Googleの認証ができませんでした。')
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
