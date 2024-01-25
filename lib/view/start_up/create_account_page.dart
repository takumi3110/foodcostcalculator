import 'package:flutter/material.dart';
import 'package:foodcost/model/Account.dart';
import 'package:foodcost/utils/firestore/users.dart';
import 'package:foodcost/utils/functionUtils.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新規登録')
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 30,),
                GestureDetector(
                  onTap: () async{
                    var result = await FunctionUtils.getImageFromGallery();
                    if (result != null) {
                      setState(() {
                        image = File(result.path);
                      });
                    }
                  },
                  child: const CircleAvatar(
                    child: Icon(Icons.add),
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: '名前'
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: SizedBox(
                    width: 300,
                    child: TextField(
                      controller: userIdController,
                      decoration: const InputDecoration(
                        hintText: 'ユーザーID'
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: 'メールアドレス'
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: SizedBox(
                    width: 300,
                    child: TextField(
                      controller: passController,
                      decoration: const InputDecoration(
                        hintText: 'パスワード'
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50,),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('アカウント作成'))
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<dynamic> createAccount(String uid) async {
    String imagePath = await FunctionUtils.uploadImage(uid, image!);
    Account newAccount = Account(
      id: uid,
      name: nameController.text,
      imagePath: imagePath
    );
    var _result = await UserFirestore.setUser(newAccount);
    return _result;
  }
}


