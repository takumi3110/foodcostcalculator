import 'package:flutter/material.dart';
import 'package:foodcost/model/Account.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/view/start_up/login_page.dart';

class WidgetUtils {
  static AppBar createAppBar(String title, GlobalKey<ScaffoldState> key) {
    Account myAccount = Authentication.myAccount!;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      title: Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
      leading: IconButton(
        icon: CircleAvatar(
          foregroundImage: NetworkImage(myAccount.imagePath),
        ),
        onPressed: () {
          key.currentState!.openDrawer();
        } ,
      ),
    );
  }

  static SizedBox sideMenuDrawer(BuildContext context) {
    Account myAccount = Authentication.myAccount!;
    return SizedBox(
      width: 200,
      child: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
                accountName: Text(myAccount.name),
                accountEmail: Text(myAccount.email),
              currentAccountPicture: CircleAvatar(
                foregroundImage: NetworkImage(myAccount.imagePath),
                radius: 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.lightBlueAccent
              ),
            ),
            ListTile(
              title: const Text('マイページ'),
              onTap: () {},
            ),
            ListTile(
              title: const Text('ログアウト'),
              onTap: (){
                Authentication.signOut();
                while(Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
              },
            )
          ],
        ),
      ),
    );
  }
}