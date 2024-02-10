import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodcost/model/food.dart';
import 'package:foodcost/model/menu.dart';


class PostFirestore {
  static final _firestoreInstance = FirebaseFirestore.instance;
  static final CollectionReference menus = _firestoreInstance.collection('menus');
  static final CollectionReference foods = _firestoreInstance.collection('foods');

  static Future<dynamic> addFood(List<Food> newFoods) async {
    try {
      for (var newFood in newFoods) {
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
      }
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
        'image_path': newMenu.imagePath,
        'total_amount': newMenu.totalAmount,
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
      return null;
    }
  }

  static Future<List<Food>?> getFoodFromIds(List<String> ids) async {
    List<Food> foodList = [];
    try {
      await Future.forEach(ids, (String id) async {
        var doc = await foods.doc(id).get();
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Food food = Food(
          id: doc.id,
          menuId: data['menu_id'],
          name: data['name'],
          unitPrice: data['unit_price'],
          costCount: data['cost_count'],
          price: data['price']
        );
        foodList.add(food);
      });
      if (foodList.length > 0) {
        print('food取得完了');
      }
      return foodList;
    } on FirebaseException catch(e) {
      print('food取得エラー: $e');
      return null;
    }
  }
}