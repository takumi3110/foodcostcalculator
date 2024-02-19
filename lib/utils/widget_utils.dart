import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodcost/model/Account.dart';
import 'package:foodcost/model/menu.dart';
import 'package:foodcost/presentation/resources/app_colors.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/view/account/account_page.dart';
import 'package:foodcost/view/calendar/calendar_page.dart';
import 'package:foodcost/view/cost/cost_page.dart';
import 'package:foodcost/view/start_up/login_page.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class WidgetUtils {
  static Account myAccount = Authentication.myAccount!;

  static AppBar createAppBar(String title, GlobalKey<ScaffoldState> key) {
    // Account myAccount = Authentication.myAccount!;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      title: Text(
        title,
        style: const TextStyle(color: Colors.black),
      ),
      leading: IconButton(
        icon: CircleAvatar(
          foregroundImage: myAccount.imagePath != null ? NetworkImage(myAccount.imagePath!): null,
          child: const Icon(Icons.person),
        ),
        onPressed: () {
          key.currentState!.openDrawer();
        },
      ),
    );
  }

  static SizedBox sideMenuDrawer(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Drawer(
        child: Container(
          color: Colors.white,
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(
                  myAccount.name,
                  style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 18, color: Colors.black),
                ),
                accountEmail: Text(
                  myAccount.email,
                  style: const TextStyle(color: Colors.black),
                ),
                currentAccountPicture: CircleAvatar(
                  foregroundImage: myAccount.imagePath != null ? NetworkImage(myAccount.imagePath!): null,
                  child: const Icon(Icons.person, size: 50,),
                ),
                decoration: const BoxDecoration(color: Colors.white),
              ),
              ListTile(
                title: const Row(
                  children: [
                    Icon(Icons.calendar_month),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text('カレンダー')
                  ],
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CalendarPage()));
                },
              ),
              ListTile(
                title: const Row(
                  children: [
                    Icon(Icons.bar_chart),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text('今月の食費'),
                  ],
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CostPage()));
                },
              ),
              ListTile(
                title: const Row(
                  children: [
                    Icon(Icons.account_box),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text('マイページ'),
                  ],
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountPage()));
                },
              ),
              ListTile(
                title: const Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text('ログアウト'),
                  ],
                ),
                onTap: () {
                  Authentication.signOut();
                  while (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Stack loadingStack(isLoading) {
    return Stack(
      children: [
        if (isLoading)
          const Opacity(
            opacity: 0.8,
            child: ModalBarrier(dismissible: false, color: Colors.white),
          ),
        if (isLoading)
          Center(
            child: LoadingAnimationWidget.stretchedDots(color: Colors.blue, size: 70),
          ),
      ],
    );
  }

  static Column menuListTile(menus, allTotalAmount) {
    final formatter = NumberFormat('#,###');

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (allTotalAmount != null)
        Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Text(
            '合計金額: ${formatter.format(allTotalAmount)} 円',
            style: const TextStyle(fontSize: 18.0),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: menus.length,
                  itemBuilder: (context, index) {
                    // Map<String, dynamic> data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    return Column(
                      children: [
                        ListTile(
                          onTap: () {},
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(menus[index].name),
                              Text('${formatter.format(menus[index].totalAmount)} 円')
                            ],
                          ),
                        ),
                        // if (index == getMenus.length) const Divider()
                        const Divider(),
                      ],
                    );
                  }),
              if (allTotalAmount == null && menus.length > 6)
                Container(
                    alignment: Alignment.centerRight,
                    child: const Text('and more...')
                )

            ],
          ),
        ),
      ],
    );
  }

}
