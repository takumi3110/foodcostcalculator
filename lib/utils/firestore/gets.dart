import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodcost/model/food.dart';
import 'package:foodcost/model/menu.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:intl/intl.dart';

class GetFirestore {
  static final _firestoreInstance = FirebaseFirestore.instance;
  static final CollectionReference menus = _firestoreInstance.collection('menus');
  static final CollectionReference foods = _firestoreInstance.collection('foods');

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

  static Future<List<Food>?> getFoodList(String menuId) async {
    List<Food> foodList = [];
    try {
      var foods = await _firestoreInstance.collection('food').where('menu_id', isEqualTo: menuId).get();
      for (var food in foods.docs) {
        Food newFood = Food(
            id: food.id,
            menuId: menuId,
            name: food.data()['name'],
            unitPrice: food.data()['unit_price'],
            costCount: food.data()['cost_count'],
            price: food.data()['price']
        );
        foodList.add(newFood);
      }
      print('food取得完了');
      return foodList;
    } on FirebaseException catch (e) {
      print('フード取得エラー: $e');
      return null;
    }
  }
}