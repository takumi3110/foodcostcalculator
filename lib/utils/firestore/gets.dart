import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodcost/model/food.dart';
import 'package:foodcost/model/menu.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:intl/intl.dart';

class GetFirestore {
  static final _firestoreInstance = FirebaseFirestore.instance;

  static Future<List<Menu>?> getMenuList(DateTime? selectedDate) async {
    List<Menu> menuList = [];
    String userId = Authentication.myAccount!.id;
    DateFormat format = DateFormat('yyyy-MM-dd');
    try {
      var menus = await _firestoreInstance.collection('menus').where('user_id', isEqualTo: userId).get();
      for (var menu in menus.docs) {
        Timestamp createdTime = menu.data()['created_time'];
        var formattedDate = format.format(createdTime.toDate());
        if (format.format(selectedDate!) == formattedDate) {
          Menu newMenu = Menu(
              id: menu.id,
              name: menu.data()['name'],
              createdTime: menu.data()['created_time']
          );
          menuList.add(newMenu);
        }
      }
      return menuList;
    } on FirebaseException catch(e) {
      print('メニュー取得エラー: $e');
      return null;
    }
  }
}