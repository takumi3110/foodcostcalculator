import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:foodcost/model/Account.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/utils/firestore/users.dart';
import 'package:foodcost/utils/functionUtils.dart';
import 'package:foodcost/utils/widget_utils.dart';
import 'package:foodcost/view/start_up/login_page.dart';

class EditAccountPage extends StatefulWidget {
  const EditAccountPage({super.key});

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  Account myAccount = Authentication.myAccount!;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  // TextEditingController passController = TextEditingController();
  File? image;

  bool _isLoading = false;
  // bool _isObscure = true;

  ImageProvider getImage() {
    if (image == null) {
      return NetworkImage(myAccount.imagePath);
    } else {
      return FileImage(image!);
    }
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: myAccount.name);
    emailController = TextEditingController(text: myAccount.email);
    // passController = TextEditingController(text: myAccount.pass);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('アカウント編集'),
        // elevation: 1,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 8.0, right: 15.0),
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                        onPressed: () {
                          UserFirestore.deleteUser(myAccount.id);
                          Authentication.deleteAuth();
                          while(Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                          ),
                          foregroundColor: Colors.red,
                          side: const BorderSide(
                            color: Colors.red,
                            // width: 4
                          )
                        ),
                        child: const Text('削除', style: TextStyle(fontWeight: FontWeight.bold),)
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 300,
                    padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () async{
                            var result = await FunctionUtils.getImageFromGallery();
                            if (result != null) {
                              setState(() {
                                image = File(result.path);
                              });
                            }
                          },
                          child: CircleAvatar(
                            radius:40,
                            foregroundImage: getImage(),
                            child: const Icon(Icons.add_a_photo_outlined),
                          ),
                        ),
                        const SizedBox(height: 10.0,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 60.0,
                              child: Text('名前',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                              ),
                            ),
                            const SizedBox(width: 30.0),
                            SizedBox(
                              width: 200,
                              child: TextField(
                                controller: nameController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 60.0,
                              child: Text('メール',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                              ),
                            ),
                            const SizedBox(width: 30.0),
                            SizedBox(
                              width: 200,
                              child: TextField(
                                controller: emailController,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0,),
                  ElevatedButton(
                      onPressed: () async{
                        if (nameController.text.isNotEmpty && emailController.text.isNotEmpty){
                          String imagePath = '';
                          if (image == null) {
                            imagePath = myAccount.imagePath;
                          } else {
                            var result = await FunctionUtils.uploadImage(myAccount.id, image!);
                            imagePath = result;
                          }
                          Account updateAccount = Account(
                            id: myAccount.id,
                            name: nameController.text,
                            email: emailController.text,
                            imagePath: imagePath
                          );
                          Authentication.myAccount = updateAccount;
                          var result = await UserFirestore.updateUser(updateAccount);
                          if (result == true) {
                            Navigator.pop(context, true);
                          }
                        }
                      },
                      child: const Text('更新')),
                ],
              ),
            ),
            WidgetUtils.loadingStack(_isLoading)
          ]
        ),
      ),
    );
  }
}
