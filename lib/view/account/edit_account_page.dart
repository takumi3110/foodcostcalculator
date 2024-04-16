import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodcost/component/cancel_button.dart';
import 'package:foodcost/component/error_text.dart';
import 'package:foodcost/component/primary_button.dart';
import 'package:foodcost/model/account.dart';
import 'package:foodcost/model/group.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/utils/extension.dart';
import 'package:foodcost/utils/firestore/groups.dart';
import 'package:foodcost/utils/firestore/users.dart';
import 'package:foodcost/utils/function_utils.dart';
import 'package:foodcost/utils/widget_utils.dart';
import 'package:foodcost/view/start_up/login_page.dart';

class EditAccountPage extends StatefulWidget {
  final bool isOwner;

  const EditAccountPage({super.key, required this.isOwner});

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final Account _myAccount = Authentication.myAccount!;
  late bool _isOwner;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool _isNameError = false;
  bool _isEmailError = false;
  bool _isGroupError = false;

  bool _isChangeName = false;
  bool _isChangeEmail = false;

  // group
  TextEditingController groupNameController = TextEditingController();
  Group? group;

  // TextEditingController passController = TextEditingController();
  File? image;

  bool _isLoading = false;

  // bool _isObscure = true;

  ImageProvider? getImage() {
    if (image == null) {
      if (_myAccount.imagePath != null) {
        return NetworkImage(_myAccount.imagePath!);
      } else {
        return null;
      }
    } else {
      return FileImage(image!);
    }
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
    nameController = TextEditingController(text: _myAccount.name);
    emailController = TextEditingController(text: _myAccount.email);
    if (_myAccount.groupId != null) {
      getGroup(_myAccount.groupId!);
    }
    setState(() {
      _isOwner = _myAccount.groupId == null ? true : widget.isOwner;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: WidgetUtils.createAppBar('へんしゅう'),
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
                            // _showCupertinoModalBottomSheet();
                            setImage(String path) {
                              setState(() {
                                image = File(path);
                              });
                            }
                            WidgetUtils.selectPictureModalBottomSheet(context, setImage);
                          },
                          child: CircleAvatar(
                            radius: 70,
                            foregroundImage: getImage(),
                            child: const Icon(
                              Icons.add_a_photo_outlined,
                              size: 40,
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
                              child: Text('名前', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                            const SizedBox(width: 10.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 220,
                                  child: TextField(
                                    keyboardType: TextInputType.name,
                                    onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                                    controller: nameController,
                                    onChanged: (String value) {
                                        setState(() {
                                          _isNameError = value.isEmpty;
                                          _isChangeName = _myAccount.name != value;
                                        });
                                    },
                                  ),
                                ),
                                if (_isNameError)
                                  const ErrorText(text: '名前を入力してください。')
                              ],
                            ),

                          ],
                        ),
                        // const SizedBox(height: 20.0,),
                        if (_myAccount.email.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 100,
                                  child: Text('メール', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                ),
                                const SizedBox(width: 10.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 220,
                                      child: TextField(
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-z0-9@.+_-]'))
                                        ],
                                        keyboardType: TextInputType.emailAddress,
                                        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                                        controller: emailController,
                                        onChanged: (String value) {
                                          setState(() {
                                            _isEmailError = !value.isValidEmail();
                                            _isChangeEmail = _myAccount.email != value;
                                          });
                                        },
                                      ),
                                    ),
                                    if (_isEmailError) const ErrorText(text: '正しい形式で入力してください。'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        if (_myAccount.email.isEmpty)
                          const SizedBox(
                            height: 20,
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
                              child: Text('グループ名', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                            const SizedBox(width: 10.0),
                            SizedBox(
                              width: 220,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  TextField(
                                    keyboardType: TextInputType.text,
                                    readOnly: !_isOwner,
                                    onTap: () {
                                      setState(() {
                                        if (!_isOwner) {
                                          _isGroupError = true;
                                        }
                                      });
                                    },
                                    onTapOutside: (_) => {
                                      FocusManager.instance.primaryFocus?.unfocus(),
                                      setState(() {
                                        _isGroupError = false;
                                      })
                                    },
                                    controller: groupNameController,
                                  ),
                                  if (_isGroupError)
                                    const Text(
                                      'オーナーではないので編集できません',
                                      style: TextStyle(color: Colors.red, fontSize: 12),
                                    )
                                ],
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
                  PrimaryButton(
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        bool accountResult = false;
                        bool groupResult = false;
                        final isError = !_isNameError && !_isEmailError;
                        // final isChangeName = nameController.text != _myAccount.name;
                        // if ((!_isEmailError && !_isNameError) &&
                        //     (nameController.text != _myAccount.name ||
                        //         emailController.text != _myAccount.email ||
                        //         image != null)) {
                        if (isError && _isChangeName || _isChangeEmail || image != null)  {
                          if ((_myAccount.email.isNotEmpty
                                  ? (nameController.text.isNotEmpty && emailController.text.isNotEmpty)
                                  : nameController.text.isNotEmpty) ||
                              image != null) {
                            String? imagePath = _myAccount.imagePath;
                            if (image != null) {
                              imagePath = await FunctionUtils.uploadImage(_myAccount.id, image!);
                            }
                            Account updateAccount = Account(
                                id: _myAccount.id,
                                name: nameController.text,
                                email: emailController.text,
                                imagePath: imagePath,
                                isInitialAccess: false);
                            var result = await UserFirestore.updateUser(updateAccount);
                            if (result == true) {
                              accountResult = result;
                            } else {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
                                backgroundColor: Colors.deepOrange,
                                content: const Text(
                                  'アカウントの更新に失敗しました。',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                actions: [
                                  GestureDetector(
                                    child: const Icon(Icons.close, color: Colors.white),
                                    onTap: () {
                                      ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
                                    },
                                  )
                                ],
                                onVisible: () {
                                  Future.delayed(const Duration(seconds: 5),
                                      () => ScaffoldMessenger.of(context).removeCurrentMaterialBanner());
                                },
                              ));
                            }
                          }
                        }
                        if (groupNameController.text.isNotEmpty &&
                            groupNameController.text != (group != null ? group!.name : '')) {
                          // グループ登録
                          // 招待コード作成
                          // グループのオーナーじゃない場合は編集できない。編集しようとするとオーナーに言えと警告
                          String code = group != null ? group!.code : '';
                          const String charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
                          final Random random = Random.secure();
                          code = List.generate(5, (_) => charset[random.nextInt(charset.length)]).join();
                          Group newGroup = Group(
                            id: group != null ? group!.id : '',
                            name: groupNameController.text,
                            code: code,
                          );
                          if (group != null) {
                            groupResult = await GroupFirestore.updateGroup(newGroup);
                          } else {
                            groupResult = await GroupFirestore.createGroup(newGroup);
                          }
                        }
                        // accountResultかグループのresultがtrueなら戻る
                        if (groupResult == true || accountResult == true) {
                          if (!context.mounted) return;
                          Navigator.pop(context, true);
                        }
                        setState(() {
                          _isLoading = false;
                        });
                      },
                      childText: '更新',
                      isError: _isEmailError),
                ],
              ),
            ),
          ),
          WidgetUtils.loadingStack(_isLoading)
        ]),
      ),
    );
  }

  void _showAlertDialog() async {
    await showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            title: const Text('アカウント削除'),
            content: const Text('本当に削除しますか？'),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                    });
                      UserFirestore.deleteUser(_myAccount.id).then((res){
                        Authentication.deleteAuth().then((authRes) {
                          while (Navigator.canPop(context)) {
                           Navigator.pop(context);
                          }
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                        });
                      });
                    setState(() {
                      _isLoading = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  child: const Text(
                    'はい',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              CancelButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  text: 'いいえ'),
            ],
          );
        });
  }

  // Future<dynamic> _showCupertinoModalBottomSheet() {
  //   return showCupertinoModalBottomSheet(
  //       backgroundColor: Colors.white,
  //       context: context,
  //       builder: (context) {
  //         return Padding(
  //           padding: const EdgeInsets.all(20.0),
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               CircleAvatar(
  //                 radius: 120,
  //                 // TODO: 画像を選んで戻ってきたら更新されない
  //                 // foregroundImage: getImage(),
  //                 foregroundImage: image != null ? FileImage(image!) : null,
  //                 child: const Icon(
  //                   Icons.person,
  //                   size: 120,
  //                 ),
  //               ),
  //               const SizedBox(
  //                 height: 20,
  //               ),
  //               ElevatedButton(
  //                   onPressed: () {
  //                     debugPrint('$image');
  //                     _showBarModalBottomSheet();
  //                     // Navigator.pop(context);
  //                   },
  //                   child: const Text('写真を選択または撮影'))
  //             ],
  //           ),
  //         );
  //       });
  // }

  // Future<dynamic> _showBarModalBottomSheet() {
  //   return showBarModalBottomSheet(
  //       barrierColor: Colors.black54,
  //       context: context,
  //       builder: (context) {
  //         return SafeArea(
  //           child: Padding(
  //             padding: const EdgeInsets.all(20.0),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 ListTile(
  //                   title: const Text('写真ライブラリ'),
  //                   leading: const Icon(
  //                     Icons.photo_rounded,
  //                     size: 30,
  //                   ),
  //                   onTap: () async {
  //                     var result = await FunctionUtils.getImageFromGallery();
  //                     if (result != null) {
  //                       setState(() {
  //                         image = File(result.path);
  //                       });
  //                       Navigator.pop(context);
  //                     }
  //                   },
  //                 ),
  //                 // const Divider(),
  //                 ListTile(
  //                   title: const Text('写真を撮る'),
  //                   leading: const Icon(
  //                     Icons.photo_camera_rounded,
  //                     size: 30,
  //                   ),
  //                   onTap: () async {
  //                     var result = await FunctionUtils.getImageFromCamera();
  //                     if (result != null) {
  //                       setState(() {
  //                         image = File(result.path);
  //                       });
  //                       Navigator.pop(context);
  //                     }
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       });
  // }
}
