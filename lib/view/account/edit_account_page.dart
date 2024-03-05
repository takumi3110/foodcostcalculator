import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:foodcost/model/account.dart';
import 'package:foodcost/model/group.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/utils/firestore/groups.dart';
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
  // Group myGroup = GroupFirestore.myGroup!;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  // group
  TextEditingController groupNameController = TextEditingController();
  Group? group;

  // TextEditingController passController = TextEditingController();
  File? image;

  bool _isLoading = false;

  // bool _isObscure = true;

  ImageProvider? getImage() {
    if (image == null) {
      if (myAccount.imagePath != null) {
        return NetworkImage(myAccount.imagePath!);
      } else {
        return null;
      }
    } else {
      return FileImage(image!);
    }
  }

  void _showAlertDialog() async {
    await showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('アカウント削除'),
            content: const Text('本当に削除しますか？'),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                    });
                    UserFirestore.deleteUser(myAccount.id);
                    Authentication.deleteAuth();
                    while (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                    setState(() {
                      _isLoading = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  child: const Text(
                    'はい',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('いいえ'))
            ],
          );
        });
  }

  void getGroup(String groupId) async {
    final result = await GroupFirestore.getGroup(groupId);
    if (result != null) {
      setState(() {
        groupNameController = TextEditingController(text: result.name);
        group = result;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: myAccount.name);
    emailController = TextEditingController(text: myAccount.email);
    if (myAccount.groupId != null) {
      getGroup(myAccount.groupId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('アカウント編集'),
        elevation: 1,
      ),
      body: SafeArea(
        child: Stack(children: [
          SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 8.0, right: 15.0),
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                        onPressed: _showAlertDialog,
                        style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            foregroundColor: Colors.red,
                            side: const BorderSide(
                              color: Colors.red,
                              // width: 4
                            )),
                        child: const Text(
                          '削除',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                  ),
                  Container(
                    width: double.infinity,
                    // height: 300,
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Column(
                      children: [
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
                            radius: 40,
                            foregroundImage: getImage(),
                            child: const Icon(
                              Icons.add_a_photo_outlined,
                              size: 30,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 100,
                              child: Text('名前', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                        // const SizedBox(height: 20.0,),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 100,
                                child: Text('メール', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          alignment: Alignment.center,
                          width: double.infinity,
                          decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.grey))),
                          child: const Text('グループ'),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 100,
                              child: Text('グループ名', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                            const SizedBox(width: 30.0),
                            SizedBox(
                              width: 200,
                              child: TextField(
                                controller: groupNameController,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        bool accountResult = false;
                        bool groupResult = false;
                        if (nameController.text != myAccount.name || emailController.text != myAccount.email || image != null) {
                          if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                            String? imagePath = myAccount.imagePath;
                            if (image != null) {
                              imagePath = await FunctionUtils.uploadImage(myAccount.id, image!);
                            }
                            Account updateAccount = Account(
                                id: myAccount.id,
                                name: nameController.text,
                                email: emailController.text,
                                imagePath: imagePath,
                            );
                            // Authentication.myAccount = updateAccount;
                            accountResult = await UserFirestore.updateUser(updateAccount);
                          }
                        }
                        if (groupNameController.text.isNotEmpty && groupNameController.text != (group != null ? group!.name: '')) {
                          // グループ登録
                          // 招待コード作成
                          const String charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
                          final Random random = Random.secure();
                          final String randomCode = List.generate(5, (_) => charset[random.nextInt(charset.length)]).join();
                          Group newGroup = Group(
                            id: group?.id,
                            name: groupNameController.text,
                            code: randomCode,
                          );
                          if (group != null) {
                            groupResult = await GroupFirestore.updateGroup(newGroup);
                          } else {
                            groupResult = await GroupFirestore.createGroup(newGroup);
                          }
                        }
                        // accountResultかグループのresultがtrueなら戻る
                        if (groupResult == true || accountResult == true) {
                          Navigator.pop(context, true);
                        }
                        setState(() {
                          _isLoading = false;
                        });
                      },
                      child: const Text('更新')),
                ],
              ),
            ),
          ),
          WidgetUtils.loadingStack(_isLoading)
        ]
        ),
      ),
    );
  }
}
