import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodcost/model/account.dart';
import 'package:foodcost/model/food.dart';
import 'package:foodcost/model/group.dart';
import 'package:foodcost/model/menu.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/utils/firestore/groups.dart';
import 'package:foodcost/utils/firestore/menus.dart';
import 'package:foodcost/utils/functionUtils.dart';
import 'package:foodcost/utils/widget_utils.dart';
import 'package:foodcost/view/account/edit_account_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  Account myAccount = Authentication.myAccount!;
  // lineのメッセージを送るurl
  final String lineUrl = 'https://line.me/R/share?text=';


  ImageProvider? getForeGroundImage(imagePath) {
    if (imagePath != null) {
      return NetworkImage(imagePath);
    } else{
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    if (myAccount.groupId != null) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'マイページ',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 1,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: StreamBuilder<DocumentSnapshot>(
              stream: myAccount.groupId != null ? GroupFirestore.groups.doc(myAccount.groupId!).snapshots(): null,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                  final groupName = data['name'];
                  return Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            image: myAccount.imagePath != null
                                ? DecorationImage(image: NetworkImage(myAccount.imagePath!), fit: BoxFit.cover, opacity: 0.2)
                                : null),
                        child: Column(
                          children: [
                            Container(
                                padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                    onPressed: () async{
                                      var result = await Navigator.push(
                                          context, MaterialPageRoute(builder: (context) => const EditAccountPage()));
                                      if (result == true) {
                                        setState(() {
                                          if (Authentication.myAccount != null) {
                                            myAccount = Authentication.myAccount!;
                                          }
                                        });
                                      }
                                    },
                                    child: const Text('編集'))),
                            Container(
                              // color: Colors.red,
                              padding: const EdgeInsets.only(left: 50.0, right: 50.0, bottom: 15.0),
                              // height: 200,
                              child: CircleAvatar(
                                radius: 40,
                                foregroundImage: getForeGroundImage(myAccount.imagePath),
                                child: const Icon(
                                  Icons.person,
                                  size: 50,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                    width: 80.0,
                                    child: Text('名前', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0))),
                                const SizedBox(
                                  width: 30.0,
                                ),
                                Text('${myAccount.name}さん', style: const TextStyle(fontSize: 18.0))
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                    width: 80.0,
                                    child: Text('メール', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0))),
                                const SizedBox(
                                  width: 30.0,
                                ),
                                Text(myAccount.email, style: const TextStyle(fontSize: 18.0))
                              ],
                            ),
                            const SizedBox(height: 10.0,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: 80.0,
                                  child: Text('グループ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),),
                                ),
                                const SizedBox(width: 30.0,),
                                Text(groupName , style: const TextStyle(fontSize: 18.0),)
                              ],
                            ),
                            const SizedBox(height: 20,),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        alignment: Alignment.center,
                        width: double.infinity,
                        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.grey))),
                        child: const Text('メンバー'),
                      ),
                      FutureBuilder<List<Member>?>(
                        future: GroupFirestore.getGroupMembers(myAccount.groupId!),
                        builder: (context, memberSnapshot) {
                          if (memberSnapshot.hasData && memberSnapshot.connectionState == ConnectionState.done) {
                            return SizedBox(
                              height: memberSnapshot.data!.length > 3 ? 120: null,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: memberSnapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    // Map<String, dynamic> data = memberSnapshot.data! as Map<String, dynamic>;
                                    if (memberSnapshot.data![index].name != myAccount.name) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 13,
                                              foregroundImage: getForeGroundImage(memberSnapshot.data![index].imagePath),
                                              child: const Icon(Icons.person),
                                            ),
                                            const SizedBox(width: 15.0,),
                                            Text('${memberSnapshot.data![index].name} さん'),
                                            const SizedBox(width: 10.0,),
                                            if (memberSnapshot.data![index].isOwner)
                                            const Icon(Icons.star, color: Colors.yellow,)
                                          ],
                                        ),
                                      );
                                    } else {
                                      return Container();
                                    }
                                  }),
                            );
                          } else {
                            return Container();
                          }

                        }
                      ),
                      if (myAccount.groupId == null)
                        ElevatedButton.icon(
                            onPressed: () async{
                              var result = await Navigator.push(
                                  context, MaterialPageRoute(builder: (context) => const EditAccountPage()));
                              if (result == true) {
                                setState(() {
                                  if (Authentication.myAccount != null) {
                                    myAccount = Authentication.myAccount!;
                                  }
                                });
                              }
                            },
                            icon: const Icon(Icons.supervisor_account),
                            label: const Text('グループを作成')
                        ),
                      if (myAccount.groupId != null)
                        ElevatedButton.icon(
                            onPressed: () async{
                              //   送りたいメッセージを追加
                              final String message = '${myAccount.name}さんからメンバーへ招待されました！';
                              final String addTextUrl = lineUrl + message;
                              //   LINEの処理を追加
                              await FunctionUtils.launchLine(addTextUrl);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.messenger_rounded, color: Colors.white,),
                            label: const Text('LINEでメンバーを招待', style: TextStyle(fontWeight: FontWeight.bold),)
                        ),
                      const SizedBox(
                        height: 10.0,
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        alignment: Alignment.center,
                        width: double.infinity,
                        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.grey))),
                        child: const Text('最近登録したメニュー'),
                      ),
                      // const SizedBox(
                      //   height: 10.0,
                      // ),
                      Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SingleChildScrollView(
                              child: StreamBuilder<QuerySnapshot>(
                                stream: MenuFirestore.menus.where('user_id', isEqualTo: myAccount.id).snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    List<Menu> getMenus = [];
                                    var docs = snapshot.data!.docs;
                                    var length = docs.length < 6 ? docs.length : 5;
                                    for (var i = 0; i < length; i++) {
                                      Map<String, dynamic> data = docs[i].data() as Map<String, dynamic>;
                                      List<Food> foods = [];
                                      for (var food in data['foods']) {
                                        Food getFood = Food(
                                            name: food['name'],
                                            unitPrice: food['unit_price'],
                                            costCount: food['cost_count'],
                                            price: food['price']);
                                        foods.add(getFood);
                                      }
                                      Menu getMenu = Menu(
                                        // id: data['id'] is null ? data['id']: '',
                                          name: data['name'],
                                          userId: data['user_id'],
                                          totalAmount: data['total_amount'],
                                          imagePath: data['image_path'],
                                          createdTime: data['created_time'],
                                          foods: foods);
                                      getMenus.add(getMenu);
                                    }

                                    return WidgetUtils.menuListTile(getMenus);
                                  } else {
                                    return Container();
                                  }
                                },
                              ),
                            ),
                          ))
                    ],
                  );
                } else {
                  return Container();
                }

              }
            ),
          ),
        ),
      ),
    );
  }
// void _showEditModal(BuildContext context) {
//   showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return Container(
//           height: MediaQuery.sizeOf(context).height,
//           child: SingleChildScrollView(
//             child: Stack(
//                 children: [
//                   SizedBox(
//                     width: double.infinity,
//                     child: Column(
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               TextButton(
//                                   onPressed: () {
//                                     Navigator.pop(context);
//                                   },
//                                   child: const Text('キャンセル')
//                               ),
//                               ElevatedButton(
//                                   onPressed: () async{
//                                     setState(() {
//                                       _isLoading = true;
//                                     });
//                                     if (nameController.text.isNotEmpty && emailController.text.isNotEmpty){
//                                       String imagePath = '';
//                                       if (image != null)  {
//                                         var result = await FunctionUtils.uploadImage(myAccount.id, image!);
//                                         imagePath = result;
//                                       }
//                                       Account updateAccount = Account(
//                                           id: myAccount.id,
//                                           name: nameController.text,
//                                           email: emailController.text,
//                                           imagePath: imagePath
//                                       );
//                                       Authentication.myAccount = updateAccount;
//                                       var result = await UserFirestore.updateUser(updateAccount);
//                                       if (result == true) {
//                                         Navigator.pop(context, true);
//                                       }
//                                     }
//                                     setState(() {
//                                       _isLoading = false;
//                                     });
//                                   },
//
//                                   child: const Text('更新')),
//                             ],
//                           ),
//                         ),
//                         // Container(
//                         //   padding: const EdgeInsets.only(top: 8.0, right: 15.0),
//                         //   alignment: Alignment.centerRight,
//                         //   child: OutlinedButton(
//                         //       onPressed: _showAlertDialog,
//                         //       style: OutlinedButton.styleFrom(
//                         //           shape: RoundedRectangleBorder(
//                         //               borderRadius: BorderRadius.circular(10)
//                         //           ),
//                         //           foregroundColor: Colors.red,
//                         //           side: const BorderSide(
//                         //             color: Colors.red,
//                         //             // width: 4
//                         //           )
//                         //       ),
//                         //       child: const Text('削除', style: TextStyle(fontWeight: FontWeight.bold),)
//                         //   ),
//                         // ),
//                         Container(
//                           width: double.infinity,
//                           // height: 300,
//                           padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               GestureDetector(
//                                 onTap: () async{
//                                   var result = await FunctionUtils.getImageFromGallery();
//                                   if (result != null) {
//                                     setState(() {
//                                       image = File(result.path);
//                                     });
//                                   }
//                                 },
//                                 child: CircleAvatar(
//                                   radius:40,
//                                   foregroundImage: getImage(),
//                                   child: const Icon(Icons.add_a_photo_outlined, size: 30,),
//                                 ),
//                               ),
//                               // SizedBox(
//                               //   width: double.maxFinite,
//                               //   child: TextButton(
//                               //       onPressed: () {},
//                               //       child: const Row(
//                               //         mainAxisAlignment: MainAxisAlignment.center,
//                               //         children: [
//                               //           Icon(Icons.cancel_outlined, size: 12,),
//                               //           Text('アイコン削除', style: TextStyle(fontSize: 12),)
//                               //         ],
//                               //       )
//                               //   ),
//                               // ),
//                               const SizedBox(height: 10.0,),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   const SizedBox(
//                                     width: 80.0,
//                                     child: Text('名前',
//                                         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
//                                     ),
//                                   ),
//                                   const SizedBox(width: 30.0),
//                                   SizedBox(
//                                     width: 200,
//                                     child: TextField(
//                                       controller: nameController,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 20.0,),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   const SizedBox(
//                                     width: 80.0,
//                                     child: Text('メール',
//                                         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
//                                     ),
//                                   ),
//                                   const SizedBox(width: 30.0),
//                                   SizedBox(
//                                     width: 200,
//                                     child: TextField(
//                                       controller: emailController,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 10.0,),
//                         OutlinedButton.icon(
//                             onPressed: _showAlertDialog,
//                             style: OutlinedButton.styleFrom(
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(10)
//                                 ),
//                                 foregroundColor: Colors.red,
//                                 side: const BorderSide(
//                                   color: Colors.red,
//                                   // width: 4
//                                 )
//                             ),
//                             icon: const Icon(Icons.cancel),
//                             label: const Text('アカウント削除', style: TextStyle(fontWeight: FontWeight.bold),)
//                         ),
//                         // ElevatedButton(
//                         //     onPressed: () async{
//                         //       setState(() {
//                         //         _isLoading = true;
//                         //       });
//                         //       if (nameController.text.isNotEmpty && emailController.text.isNotEmpty){
//                         //         String imagePath = '';
//                         //         if (image != null)  {
//                         //           var result = await FunctionUtils.uploadImage(myAccount.id, image!);
//                         //           imagePath = result;
//                         //         }
//                         //         Account updateAccount = Account(
//                         //             id: myAccount.id,
//                         //             name: nameController.text,
//                         //             email: emailController.text,
//                         //             imagePath: imagePath
//                         //         );
//                         //         Authentication.myAccount = updateAccount;
//                         //         var result = await UserFirestore.updateUser(updateAccount);
//                         //         if (result == true) {
//                         //           Navigator.pop(context, true);
//                         //         }
//                         //       }
//                         //       setState(() {
//                         //         _isLoading = false;
//                         //       });
//                         //     },
//                         //     child: const Text('更新')),
//                       ],
//                     ),
//                   ),
//                   // WidgetUtils.loadingStack(_isLoading)
//                 ]
//             ),
//           ),
//         );
//       }
//   );
// }

// void _showAlertDialog() async {
//   await showDialog(
//       context: context,
//       builder: (_) {
//         return AlertDialog(
//           title: const Text('アカウント削除'),
//           content: const Text('本当に削除しますか？'),
//           actions: [
//             ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     _isLoading = true;
//                   });
//                   UserFirestore.deleteUser(myAccount.id);
//                   Authentication.deleteAuth();
//                   while(Navigator.canPop(context)) {
//                     Navigator.pop(context);
//                   }
//                   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
//                   setState(() {
//                     _isLoading = false;
//                   });
//                 },
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     foregroundColor: Colors.white
//                 ),
//                 child: const Text('はい', style: TextStyle(fontWeight: FontWeight.bold),)
//             ),
//             ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context, false);
//                 },
//                 child: const Text('いいえ'))
//           ],
//         );
//       }
//   );
// }
}
