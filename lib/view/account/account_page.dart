import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodcost/model/Account.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/utils/firestore/posts.dart';
import 'package:foodcost/utils/widget_utils.dart';
import 'package:foodcost/view/account/edit_account_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  Account myAccount = Authentication.myAccount!;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('マイページ', style: TextStyle(color: Colors.black),),
        // elevation: 1,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                // Container(
                //   color: Colors.grey,
                //   padding: const EdgeInsets.only(left: 20.0, bottom: 8.0),
                //   height: 120,
                //   child: Container(
                //     alignment: Alignment.bottomLeft,
                //     child: CircleAvatar(
                //       radius: 30,
                //       foregroundImage: NetworkImage(myAccount.imagePath),
                //     ),
                //   ),
                // ),
                Container(
                  padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                        onPressed: () async {
                          var result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const  EditAccountPage()));
                          if (result == true) {
                            setState(() {
                              myAccount = Authentication.myAccount!;
                            });
                          }
                        },
                        child: const Text('編集')
                    )
                ),
                Container(
                  // color: Colors.red,
                  padding: const EdgeInsets.only(left: 40.0, right: 40.0, bottom: 15.0),
                  // height: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        foregroundImage: myAccount.imagePath != null ? NetworkImage(myAccount.imagePath!): null,
                        child: const  Icon(Icons.person, size: 50,),
                      ),
                      const SizedBox(height: 10.0,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 60.0,
                              child: Text('名前', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0))),
                          const SizedBox(width: 30.0,),
                          Text(myAccount.name, style: const TextStyle(fontSize: 18.0))
                        ],
                      ),
                      const SizedBox(height: 10.0,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 60.0,
                              child: Text('メール', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0))),
                          const SizedBox(width: 30.0,),
                          Text(myAccount.email, style: const TextStyle(fontSize: 18.0))
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  alignment: Alignment.center,
                  width: double.infinity,
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.grey))),
                  child: const Text(
                    '登録したメニュー(最新5件)'
                  ),
                ),
                const SizedBox(height: 10.0,),
                Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: PostFirestore.menus.where('user_id', isEqualTo: myAccount.id).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return WidgetUtils.menuListTile(snapshot, null);
                        } else {
                          return Container();
                        }

                        // if (snapshot.hasData) {
                        //   List<Menu> getMenus =[];
                        //   for (var doc in snapshot.data!.docs) {
                        //     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                        //     Menu getMenu = Menu(
                        //       name: data['name'],
                        //       userId: data['user_id'],
                        //       totalAmount: data['total_amount'],
                        //       imagePath: data['image_path'],
                        //       createdTime: data['created_time'],
                        //     );
                        //     getMenus.add(getMenu);
                        //   }
                        //   return Column(
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     children: [
                        //       Container(
                        //         alignment: Alignment.centerRight,
                        //
                        //       )
                        //     ],
                        //   );
                        // } else {
                        //   return Container();
                        // }
                      },
                    )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
