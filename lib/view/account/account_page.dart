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
  Account _myAccount = Authentication.myAccount!;
  Group? _group;

  // lineのメッセージを送るurl
  final String lineUrl = 'https://line.me/R/share?text=';

  ImageProvider? getForeGroundImage(imagePath) {
    if (imagePath != null) {
      return NetworkImage(imagePath);
    } else {
      return null;
    }
  }
  
  // member
  List<Member> _memberList = [];
  bool _isOwner = false;
  void getMembers(String groupId) async {
    final results = await GroupFirestore.getGroupMembers(groupId);
    if (results != null) {
      setState(() {
        _memberList = results;
        // for (var result in results) {
        //   if (result.name == _myAccount.name) {
        //     _isOwner = result.isOwner;
        //   }
        // }
        _isOwner = results.any((result) => (result.id == _myAccount.id) && result.isOwner);
      });
    }
  }
  
  
  @override
  void initState() {
    super.initState();
    if (_myAccount.groupId != null) {
      getMembers(_myAccount.groupId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        image: _myAccount.imagePath != null
                            ? DecorationImage(
                                image: NetworkImage(_myAccount.imagePath!), fit: BoxFit.cover, opacity: 0.2)
                            : null),
                    child: Column(
                      children: [
                        Container(
                            padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                                onPressed: () async {
                                  var result = await Navigator.push(
                                      context, MaterialPageRoute(builder: (context) => EditAccountPage(isOwner: _isOwner,)));
                                  if (result == true) {
                                    setState(() {
                                      if (Authentication.myAccount != null) {
                                        _myAccount = Authentication.myAccount!;
                                      }
                                    });
                                  }
                                },
                                child: const Text('編集'))),
                        Container(
                          // color: Colors.red,
                          padding: const EdgeInsets.only(left: 50.0, right: 50.0, bottom: 5.0),
                          // height: 200,
                          child: CircleAvatar(
                            radius: 40,
                            foregroundImage: getForeGroundImage(_myAccount.imagePath),
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
                                child: Text('名前', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0))),
                            const SizedBox(
                              width: 30.0,
                            ),
                            Text('${_myAccount.name}さん', style: const TextStyle(fontSize: 18.0))
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        if (_myAccount.email.isNotEmpty)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(
                                  width: 80.0,
                                  child: Text('メール', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0))),
                              const SizedBox(
                                width: 30.0,
                              ),
                              Text(_myAccount.email, style: const TextStyle(fontSize: 18.0))
                            ],
                          ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 80.0,
                              child: Text(
                                'グループ',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                              ),
                            ),
                            const SizedBox(
                              width: 30.0,
                            ),
                            StreamBuilder<DocumentSnapshot>(
                                stream: _myAccount.groupId != null
                                    ? GroupFirestore.groups.doc(_myAccount.groupId).snapshots()
                                    : null,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                                    Group getGroup =
                                        Group(id: _myAccount.groupId, name: data['name'], code: data['code']);
                                    _group = getGroup;
                                    final groupName = data['name'];
                                    return Text(
                                      groupName,
                                      style: const TextStyle(fontSize: 18.0),
                                    );
                                  } else {
                                    return Container();
                                  }
                                })
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
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
                  if (_myAccount.groupId != null)
                    // FutureBuilder<dynamic>(
                    //     future: GroupFirestore.getGroupMembers(_myAccount.groupId!),
                    //     builder: (context, memberSnapshot) {
                    //       if (memberSnapshot.hasData && memberSnapshot.connectionState == ConnectionState.done) {
                    //         return SizedBox(
                    //           height: memberSnapshot.data!.length > 3 ? 120 : null,
                    //           child: ListView.builder(
                    //               shrinkWrap: true,
                    //               itemCount: memberSnapshot.data!.length,
                    //               itemBuilder: (context, index) {
                    //                 // Map<String, dynamic> data = memberSnapshot.data! as Map<String, dynamic>;
                    //                 if (memberSnapshot.data![index].id != _myAccount.id) {
                    //                   return Padding(
                    //                     padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                    //                     child: Row(
                    //                       children: [
                    //                         CircleAvatar(
                    //                           radius: 13,
                    //                           foregroundImage:
                    //                               getForeGroundImage(memberSnapshot.data![index].imagePath),
                    //                           child: const Icon(Icons.person),
                    //                         ),
                    //                         const SizedBox(
                    //                           width: 15.0,
                    //                         ),
                    //                         Text('${memberSnapshot.data![index].name} さん'),
                    //                         const SizedBox(
                    //                           width: 10.0,
                    //                         ),
                    //                         if (memberSnapshot.data![index].isOwner)
                    //                           const Icon(
                    //                             Icons.star,
                    //                             color: Colors.yellow,
                    //                           )
                    //                       ],
                    //                     ),
                    //                   );
                    //                 } else {
                    //                   return Container();
                    //                 }
                    //               }),
                    //         );
                    //       } else {
                    //         return Container();
                    //       }
                    //     }),
                    SizedBox(
                      height: _memberList.length > 3 ? 120 : null,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _memberList.length,
                          itemBuilder: (context, index) {
                            // Map<String, dynamic> data = memberSnapshot.data! as Map<String, dynamic>;
                            if (_memberList[index].id != _myAccount.id) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 13,
                                      foregroundImage:
                                      getForeGroundImage(_memberList[index].imagePath),
                                      child: const Icon(Icons.person),
                                    ),
                                    const SizedBox(
                                      width: 15.0,
                                    ),
                                    Text('${_memberList[index].name} さん'),
                                    const SizedBox(
                                      width: 10.0,
                                    ),
                                    if (_memberList[index].isOwner)
                                      const Icon(
                                        Icons.star,
                                        color: Colors.yellow,
                                      )
                                  ],
                                ),
                              );
                            } else {
                              return Container();
                            }
                          }),
                    ),
                  if (_myAccount.groupId == null)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                        onPressed: () async {
                          var result = await Navigator.push(
                              context, MaterialPageRoute(builder: (context) => EditAccountPage(isOwner: _isOwner,)));
                          if (result == true) {
                            setState(() {
                              if (Authentication.myAccount != null) {
                                _myAccount = Authentication.myAccount!;
                              }
                            });
                          }
                        },
                        icon: const Icon(Icons.supervisor_account),
                        label: const Text('グループを作成', style: TextStyle(fontWeight: FontWeight.bold),)),
                  if (_myAccount.groupId != null)
                    ElevatedButton.icon(
                        onPressed: () async {
                          //   送りたいメッセージを追加
                          // TODO: メッセージ編集
                          if (_group != null) {
                            final String message1 = '${_myAccount.name}さんからグループ【${_group!.name}】へ招待されました！';
                            const String message2 = '\nログイン時に招待コードを入力してください。';
                            final String message3 = '\n招待コード: ${_group!.code}';
                            final String allMessage = message1 + message2 + message3;
                            final String addTextUrl = lineUrl + allMessage;
                            //   LINEの処理を追加
                            await FunctionUtils.launchLine(addTextUrl);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(
                          // Icons.add_comment_rounded,
                          Icons.messenger_rounded,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'LINEでメンバーを招待',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
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
                        stream: MenuFirestore.menus.where('user_id', isEqualTo: _myAccount.id).snapshots(),
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
              )),
        ),
      ),
    );
  }
}
