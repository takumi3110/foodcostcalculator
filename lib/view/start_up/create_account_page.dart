import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodcost/component/primary_button.dart';
import 'package:foodcost/model/account.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/utils/extension.dart';
import 'package:foodcost/utils/firestore/users.dart';
import 'package:foodcost/utils/functionUtils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodcost/utils/widget_utils.dart';
import 'dart:io';

import 'package:foodcost/view/start_up/check_email_page.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController userIdController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  File? image;

  bool _isEmailError = false;
  bool _isPasswordError = false;
  bool _isLoading = false;
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新規登録'),
        elevation: 1,
      ),
      body: SafeArea(
        child: Stack(children: [
          SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    GestureDetector(
                      onTap: () async {
                        var result = await FunctionUtils.getImageFromGallery();
                        if (result != null) {
                          setState(() {
                            image = File(result.path);
                          });
                        }
                      },
                      child: CircleAvatar(
                        foregroundImage: image == null ? null : FileImage(image!),
                        radius: 40,
                        child: const Icon(Icons.add),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        width: 300,
                        child: TextField(
                          keyboardType: TextInputType.text,
                          controller: nameController,
                          decoration: const InputDecoration(hintText: '名前'),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 300,
                            child: TextField(
                              // TODO: バリデーションと認証
                              controller: emailController,
                              decoration: const InputDecoration(hintText: 'メールアドレス'),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-z0-9@.+_-]'))],
                              keyboardType: TextInputType.emailAddress,
                              onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                              onChanged: (String value) {
                                setState(() {
                                  _isEmailError = !value.isValidEmail();
                                });
                              },
                            ),
                          ),
                          if (_isEmailError)
                            const Text(
                              '正しい形式で入力してください。',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                                          _isObscure = !_isObscure;
                                        });
                                      },
                                      icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility))),
                              onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                              obscureText: _isObscure,
                              onChanged: (String value) {
                                setState(() {
                                  _isPasswordError = !value.isValidPassword();
                                });
                              },
                            ),
                          ),
                          if (_isPasswordError)
                            const Text(
                              '6文字以上で大文字か記号が1つ以上必要です。',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    // ElevatedButton(
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.orangeAccent,
                    //     foregroundColor: Colors.white
                    //   ),
                    //     onPressed: () async {
                    //       // 入力されてない時は作動しない
                    //       if (nameController.text.isNotEmpty &&
                    //           emailController.text.isNotEmpty &&
                    //           passController.text.isNotEmpty) {
                    //         setState(() {
                    //           _isLoading = true;
                    //         });
                    //         var result =
                    //             await Authentication.signUp(email: emailController.text, pass: passController.text);
                    //         if (result is UserCredential) {
                    //           var createAccountResult = await createAccount(result.user!.uid);
                    //           if (createAccountResult == true) {
                    //             final actionCodeSettings = ActionCodeSettings(
                    //               url: 'https://foodcostcalculator-3f6ab.firebaseapp.com/__/auth/action?mode=action&oobCode=code',
                    //               iOSBundleId:'com.garitto.foodcost',
                    //               androidPackageName: 'com.garitto.foodcost',
                    //               handleCodeInApp: true,
                    //             );
                    //             result.user!.sendEmailVerification();
                    //             Navigator.pushReplacement(
                    //                 context,
                    //                 MaterialPageRoute(
                    //                     builder: (context) =>
                    //                         CheckEmailPage(email: emailController.text, pass: passController.text, user: result.user!,)));
                    //             // Navigator.pop(context);
                    //           }
                    //         }
                    //         setState(() {
                    //           _isLoading = false;
                    //         });
                    //       }
                    //     },
                    //     child: const Text('アカウント作成', style: TextStyle(fontWeight: FontWeight.bold),)),
                    PrimaryButton(
                        onPressed: () async {
                          // 入力されてない時は作動しない
                          if (nameController.text.isNotEmpty &&
                              emailController.text.isNotEmpty &&
                              passController.text.isNotEmpty) {
                            setState(() {
                              _isLoading = true;
                            });
                            var result =
                            await Authentication.signUp(email: emailController.text, pass: passController.text);
                            if (result is UserCredential) {
                              var createAccountResult = await createAccount(result.user!.uid);
                              if (createAccountResult == true) {
                                final actionCodeSettings = ActionCodeSettings(
                                  url: 'https://foodcostcalculator-3f6ab.firebaseapp.com/__/auth/action?mode=action&oobCode=code',
                                  iOSBundleId:'com.garitto.foodcost',
                                  androidPackageName: 'com.garitto.foodcost',
                                  handleCodeInApp: true,
                                );
                                result.user!.sendEmailVerification();
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            CheckEmailPage(email: emailController.text, pass: passController.text, user: result.user!,)));
                                // Navigator.pop(context);
                              }
                            }
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                        childText: 'アカウント作成'
                    ),
                    const SizedBox(height: 20,),
                    // TextButton.icon(
                    //   icon: const Icon(Icons.arrow_back, color: Colors.grey,),
                    //     onPressed: () {
                    //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                    //     },
                    //     label: const Text('戻る', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),)),
                  ],
                ),
              ),
            ),
          ),
          WidgetUtils.loadingStack(_isLoading)
        ]),
      ),
    );
  }

  Future<dynamic> createAccount(String uid) async {
    try {
      String? imagePath;
      if (image != null) {
        var result = await FunctionUtils.uploadImage(uid, image!);
        imagePath = result;
      }
      Account newAccount = Account(
          id: uid,
          name: nameController.text,
          email: emailController.text,
          imagePath: imagePath,
          groupId: null,
          isInitialAccess: true,
          createdTime: Timestamp.now(),
          updatedTime: Timestamp.now());
      var result = await UserFirestore.setUser(newAccount);
      return result;
    } on FirebaseException catch (e) {
      debugPrint('アカウント作成エラー: $e');
      return false;
    }
  }
}
