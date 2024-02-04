import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodcost/model/food.dart';
import 'package:foodcost/model/menu.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:intl/intl.dart';


class PostFirestore {
  static final _firestoreInstance = FirebaseFirestore.instance;
  static final CollectionReference menus = _firestoreInstance.collection('menus');
  static final CollectionReference foods = _firestoreInstance.collection('foods');

  static Future<dynamic> addFood(Food newFood) async {
    try {
      final CollectionReference _menu = _firestoreInstance.collection('menus')
      .doc(newFood.menuId).collection('foods');
      var result = await foods.add({
        'name': newFood.name,
        'unit_price': newFood.unitPrice,
        'cost_count': newFood.costCount,
        'price': newFood.price
      });
      _menu.doc(result.id).set({
        'food_id': result.id,
        'created_time': Timestamp.now()
      });
      print('材料を登録しました。');
      return true;
    } on FirebaseException catch (e) {
      print('登録エラー: $e');
      return false;
    }
  }

  static Future<dynamic> addMenu(Menu newMenu) async {
    try {
      final CollectionReference _userPosts = _firestoreInstance.collection('users')
      .doc(newMenu.userId).collection('my_menu');
      var result = await menus.add({
        'name': newMenu.name,
        'user_id': newMenu.userId,
        'created_time': Timestamp.now()
      });
      _userPosts.doc(result.id).set({
        'menu_id': result.id,
        'created_time': Timestamp.now()
      });
      print('メニュー登録完了');
      return result.id;
    } on FirebaseException catch(e) {
      print('メニュー登録エラー: $e');
      return false;
    }
  }

  static Future<List<Menu>?> getPostMenuMap(DateTime? selectedDate) async {
    List<Menu> menuList = [];
    String userId = Authentication.myAccount!.id;
    DateFormat format = DateFormat('yyyy-MM-dd');
    try {
      var menus = await _firestoreInstance.collection('menus').where('user_id', isEqualTo: userId).get();
      for (var menu in menus.docs) {
        print(menu);
        Timestamp createdTime = menu.data()['created_time'];
        var formattedDate = format.format(createdTime.toDate());
        if (format.format(selectedDate!) == formattedDate) {
          Menu registeredMenu = Menu(
              id: menu.id,
              name: menu.data()['name'],
              createdTime: menu.data()['created_time']
          );
          menuList.add(registeredMenu);
        }
      }
      return menuList;
    } on FirebaseException catch(e) {
      print('メニュー取得エラー: $e');
      return null;
    }
  }

}