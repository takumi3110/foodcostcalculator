import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:foodcost/model/food.dart';
import 'package:foodcost/model/menu.dart';
import 'package:foodcost/utils/firestore/foods.dart';
import 'package:foodcost/utils/functionUtils.dart';

class MenuFirestore {
  static final _firestoreInstance = FirebaseFirestore.instance;
  static final CollectionReference menus = _firestoreInstance.collection('menus');

  static Future<dynamic> addMenu(Menu newMenu) async {
    try {
      final CollectionReference userMenus =
          _firestoreInstance.collection('users').doc(newMenu.userId).collection('my_menus');
      List<Map<String, dynamic>> foods = [];
      for (var food in newMenu.foods) {
        foods.add({'name': food.name, 'unit_price': food.unitPrice, 'cost_count': food.costCount, 'price': food.price});
      }
      var result = await menus.add({
        'name': newMenu.name,
        'user_id': newMenu.userId,
        'image_path': newMenu.imagePath,
        'total_amount': newMenu.totalAmount,
        'created_time': newMenu.createdTime,
        'foods': foods
      });
      await userMenus.doc(result.id).set({'menu_id': result.id, 'created_time': newMenu.createdTime});
      debugPrint('メニュー登録完了');
      // return result.id;
      return true;
    } on FirebaseException catch (e) {
      debugPrint('メニュー登録エラー: $e');
      return null;
    }
  }

  static Future<dynamic> updateMenu(Menu newMenu) async {
    try {
      List<Map<String, dynamic>> foods = [];
      for (var food in newMenu.foods) {
        foods.add({'name': food.name, 'unit_price': food.unitPrice, 'cost_count': food.costCount, 'price': food.price});
      }
      await menus.doc(newMenu.id).update({
        'name': newMenu.name,
        'image_path': newMenu.imagePath,
        'total_amount': newMenu.totalAmount,
        'foods': foods,
      });
      debugPrint('メニュー更新完了');
      return true;
    } on FirebaseException catch (e) {
      debugPrint('メニュー更新エラー: $e');
      return false;
    }
  }

  static Future<dynamic> getMenus(String accountId) async {
    try {
      DateTime now = DateTime.now();
      var currentMonth = now.month;
      List<Menu> menuList = [];
      var snapshot = await menus.where('user_id', isEqualTo: accountId).get();
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // 今の月と同じものを取得
        if (currentMonth == data['created_time'].toDate().month) {
          List<Food> foods = [];
          for (var food in data['foods']) {
            Food getFood = Food(
                name: food['name'], unitPrice: food['unit_price'], costCount: food['cost_count'], price: food['price']);
            foods.add(getFood);
          }
          Menu menu = Menu(
              name: data['name'],
              userId: data['user_id'],
              imagePath: data['image_path'],
              totalAmount: data['total_amount'],
              createdTime: data['created_time'],
              foods: foods
          );
          menuList.add(menu);
        }
      }
      if (menuList.isNotEmpty) {
        debugPrint('メニュー取得完了');
      }
      return menuList;
    } on FirebaseException catch (e) {
      debugPrint('メニュー取得エラー: $e');
      return null;
    }
  }

  static Future<void> deleteMenus(String accountId) async {
    try {
      final CollectionReference userMenus = _firestoreInstance.collection('users').doc(accountId).collection('my_menus');
      var snapshot = await userMenus.get();
      for (var doc in snapshot.docs) {
        final CollectionReference collectionFoods = menus.doc(doc.id).collection('foods');
        await FoodFirestore.deleteFoods(collectionFoods);
        await FunctionUtils.deleteImage(doc.id);
        await menus.doc(doc.id).delete();
        await userMenus.doc(doc.id).delete();
      }
      debugPrint('メニュー削除完了');
    } on FirebaseException catch (e) {
      debugPrint('メニュー削除エラー: $e');
    }

  }
}
