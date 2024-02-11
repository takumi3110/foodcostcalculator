import 'package:flutter/material.dart';
import 'package:foodcost/model/Account.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/view/start_up/login_page.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
                accountName: Text(myAccount.name, style: const TextStyle(color: Colors.black),),
                accountEmail: Text(myAccount.email, style: const TextStyle(color: Colors.black),),
              currentAccountPicture: CircleAvatar(
                foregroundImage: NetworkImage(myAccount.imagePath),
              ),
              decoration: const BoxDecoration(
                color: Colors.lime
              ),
            ),
            ListTile(
              title:const Row(
                children: [
                  Icon(Icons.bar_chart),
                  SizedBox(width: 5.0,),
                  Text('今月の食費'),
                ],
              ),
              onTap: () {},
            ),
            ListTile(
              title: const Row(
                children: [
                  Icon(Icons.account_box),
                  SizedBox(width: 5.0,),
                  Text('マイページ'),
                ],
              ),
              onTap: () {},
            ),
            ListTile(
              title: const Row(
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 5.0,),
                  Text('ログアウト'),
                ],
              ),
              onTap: (){
                Authentication.signOut();
                while(Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
              },
            ),
          ],
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
              child: ModalBarrier(
                  dismissible: false,
                  color: Colors.white
              ),
            ),
          if (isLoading)
            Center(
              child: LoadingAnimationWidget.stretchedDots(color: Colors.blue, size: 70),
            ),
        ],
      );
    }

}