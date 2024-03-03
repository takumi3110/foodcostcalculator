import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodcost/model/account.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/utils/firestore/users.dart';
import 'package:foodcost/utils/functionUtils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodcost/utils/widget_utils.dart';
import 'dart:io';

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

  bool _isLoading = false;
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新規登録'), elevation: 1,),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(children: [
            SizedBox(
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
                          controller: nameController,
                          decoration: const InputDecoration(hintText: '名前'),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        width: 300,
                        child: TextField(
                          controller: emailController,
                          decoration: const InputDecoration(hintText: 'メールアドレス'),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        width: 300,
                        child: TextField(
                          controller: passController,
                          decoration: InputDecoration(
                              hintText: 'パスワード',
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isObscure = !_isObscure;
                                    });
                                  },
                                  icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility)
                              )
                          ),
                          obscureText: _isObscure,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    ElevatedButton(
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
                              var _result = await createAccount(result.user!.uid);
                              if (_result == true) {
                                // TODO: 戻ったらメールアドレスとパスワードに入力したものが反映されて欲しい
                                Navigator.pop(context);
                              }
                            }
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                        child: const Text('アカウント作成'))
                  ],
                ),
              ),
            ),
            WidgetUtils.loadingStack(_isLoading)
          ]),
        ),
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
      String? groupId;
      Account newAccount = Account(
          id: uid,
          name: nameController.text,
          email: emailController.text,
          imagePath: imagePath,
          groupId: groupId,
          createdTime: Timestamp.now(),
          updatedTime: Timestamp.now());
      var result = await UserFirestore.setUser(newAccount);
      return result;
    } on FirebaseException catch (e) {
      print('アカウント作成エラー: $e');
      return false;
    }
  }
}
