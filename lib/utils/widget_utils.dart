import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodcost/component/side_menu_list_tile.dart';
import 'package:foodcost/model/menu.dart';
import 'package:foodcost/model/select_picture_modal.dart';
import 'package:foodcost/model/side_menu.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/utils/firestore/users.dart';
import 'package:foodcost/utils/functionUtils.dart';
import 'package:foodcost/view/account/account_page.dart';
import 'package:foodcost/view/calendar/calendar_page.dart';
import 'package:foodcost/view/cost/cost_page.dart';
import 'package:foodcost/view/dialog/entry_code_dialog.dart';
import 'package:foodcost/view/menu/create_menu_page.dart';
import 'package:foodcost/view/news/news_page.dart';
import 'package:foodcost/view/start_up/login_page.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class WidgetUtils {

  static AppBar createAppBar(String title, GlobalKey<ScaffoldState> key) {
    // Account myAccount = Authentication.myAccount!;

    return AppBar(
      // backgroundColor: Colors.transparent,
      elevation: 1,
      iconTheme: const IconThemeData(color: Colors.black),
      title: Text(
        title,
        style: const TextStyle(color: Colors.black),
      ),
      leading: IconButton(
        icon: StreamBuilder<DocumentSnapshot>(
          stream: Authentication.myAccount != null ? UserFirestore.users.doc(Authentication.myAccount!.id).snapshots(): null,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.data() != null) {
              Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
              return CircleAvatar(
                // foregroundImage: myAccount.imagePath != null ? NetworkImage(myAccount.imagePath!) : null,
                foregroundImage: data['image_path'] != null ? NetworkImage(data['image_path']) : null,
                child: const Icon(Icons.person),
              );
            } else {
              return const CircleAvatar(
                child: Icon(Icons.person),
              );
            }

          }
        ),
        onPressed: () {
          key.currentState!.openDrawer();
        },
      ),
    );
  }

  static SizedBox sideMenuDrawer(BuildContext context) {
    // Account myAccount = Authentication.myAccount!;
    final List<SideMenu> menuList = [
      SideMenu(
          title: 'お知らせ',
          icons: Icons.notifications_rounded,
          onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const NewsPage()));
      }
      ),
      SideMenu(
          title: 'カレンダー',
          icons: Icons.calendar_month_rounded,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CalendarPage()));
          }
      ),
      SideMenu(
          title: '今月の食費',
          icons: Icons.assessment_rounded,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CostPage()));
          }
      ),
      SideMenu(
          title: 'マイページ',
          icons: Icons.account_box_rounded,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountPage()));
          }
      ),
      SideMenu(
          title: '招待コード入力',
          icons: Icons.edit_note_rounded,
          onTap: () {
            showDialog(context: context, builder: (_) {
              return const EntryCodeDialog();
            });
          }
      ),
      SideMenu(
          title: 'ログアウト',
          icons: Icons.logout_rounded,
          onTap: () {
            Authentication.signOut();
            while (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
          }
      )
    ];
    

    return SizedBox(
      width: 230,
      child: Drawer(
        child: Container(
          color: Colors.white,
          child: ListView(
            children: [
              StreamBuilder<DocumentSnapshot>(
                stream: Authentication.myAccount != null ? UserFirestore.users.doc(Authentication.myAccount!.id).snapshots(): null,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.data() != null) {
                    Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                    return UserAccountsDrawerHeader(
                      accountName: Text(
                        // myAccount.name,
                        data['name'],
                        style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 18, color: Colors.black),
                      ),
                      accountEmail: Text(
                        // myAccount.email,
                        data['email'],
                        style: const TextStyle(color: Colors.black),
                      ),
                      currentAccountPicture: CircleAvatar(
                        // foregroundImage: myAccount.imagePath != null ? NetworkImage(myAccount.imagePath!): null,
                        foregroundImage: data['image_path'] != null ? NetworkImage(data['image_path']!): null,
                        child: const Icon(Icons.person, size: 50,),
                      ),
                      decoration: const BoxDecoration(color: Colors.white),
                    );
                  }else {
                   return Container();
                  }
                }
              ),
              // TODO: お知らせだけFutureで取得して、新規があればわかりやすく表示？
              for(var menu in menuList)
                SideMenuListTile(
                    icons: menu.icons,
                    menuTitle: menu.title,
                    onTap: menu.onTap
                ),
            ],
          ),
        ),
      ),
    );
  }

  static SizedBox loadingImage() {
    return SizedBox(
        width: 100,
        height: 100,
        child: Lottie.asset('assets/images/green_rice_bowl.json')
    );
  }

  static Stack loadingStack(bool isLoading) {
    return Stack(
      children: [
        if (isLoading)
          const Opacity(
            opacity: 0.8,
            child: ModalBarrier(dismissible: false, color: Colors.white),
          ),
        if (isLoading)
          Center(
            // child: LoadingAnimationWidget.twoRotatingArc(color: Colors.deepOrange, size: 70),
            child: loadingImage()
          ),
      ],
    );
  }

  static Column loadingVerifying() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Text('認証中...'),
        // const SizedBox(height: 10,),
        Center(
          child: LoadingAnimationWidget.fourRotatingDots(color: Colors.orangeAccent, size: 50),
        ),
      ],
    );
  }

  static dynamic menuListTile(List<Menu> menus) {
    final formatter = NumberFormat('#,###');

    return menus.isNotEmpty ? ListView.builder(
        shrinkWrap: true,
        itemCount: menus.length,
        itemBuilder: (context, index) {
          // Map<String, dynamic> data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
          return
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListTile(
                    onTap: () {
                      final selectedDay =
                      menus[index].createdTime != null ? menus[index].createdTime!.toDate() : DateTime.now();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateMenuPage(
                                selectedDay: selectedDay,
                                selectedMenu: menus[index],
                              )));
                    },
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            FutureBuilder(
                              future: UserFirestore.getAccountImage(menus[index].userId),
                              builder: (context, snapshot) {
                                return CircleAvatar(
                                  radius: 15,
                                  foregroundImage: snapshot.hasData ? FunctionUtils.getForeGroundImage(snapshot.data): null,
                                  child: const Icon(Icons.person, size: 20,),
                                );
                              },
                            ),
                            const SizedBox(width: 10,),
                            Text(menus[index].name),
                          ],
                        ),

                        Text('${formatter.format(menus[index].totalAmount)} 円')
                      ],
                    ),
                  ),
                ),
                // if (index == getMenus.length) const Divider()
                const Divider(),
              ],
            );
        }): const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('登録がありません。'),
        );

  }

  static Container welcomeModal(Column child) {
    return Container(
      color: Colors.white,
      width: 324,
      height: 200,
      padding: const EdgeInsets.all(10.0),
      // margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          // border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [BoxShadow(
              color: Colors.orangeAccent,
              offset: Offset(3, 3),
              blurRadius: 10.0,
              spreadRadius: 0.5
          )]
      ),
      child: child,
    );
  }

  static Future<dynamic> selectPictureModalBottomSheet(BuildContext context, Function setImage) {
    List<SelectPictureModal> selectList = [
      SelectPictureModal(
        title: '写真ライブラリ',
        icon: Icons.photo_rounded,
        onTap: () async {
          var result = await FunctionUtils.getImageFromGallery();
          if (result != null) {
            setImage(result.path);
            Navigator.pop(context);
          }
        },
      ),
      SelectPictureModal(
        title: '写真を撮る',
        icon: Icons.photo_camera_rounded,
        onTap: () async {
          var result = await FunctionUtils.getImageFromCamera();
          if (result != null) {
            setImage(result.path);
            Navigator.pop(context);
          }
        },
      ),
    ];

    return showBarModalBottomSheet(
        barrierColor: Colors.black54,
        context: context,
        builder: (context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: selectList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(selectList[index].title),
                        leading: Icon(
                          selectList[index].icon,
                          size: 30,
                        ),
                        onTap: selectList[index].onTap
                      );
                    }
                  ),
                ],
              ),
            ),
          );
        });
  }

  // Future<dynamic> _showCupertinoModalBottomSheet(BuildContext context) {
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
}
