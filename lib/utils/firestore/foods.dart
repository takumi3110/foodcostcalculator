import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodcost/model/food.dart';

class FoodFirestore {
  static final _firestoreInstance = FirebaseFirestore.instance;
  static final CollectionReference foods = _firestoreInstance.collection('foods');

  static Future<dynamic> addFood(List<Food> newFoods) async {
    try {
      for (var newFood in newFoods) {
        final CollectionReference menu = _firestoreInstance.collection('menus')
            .doc(newFood.menuId).collection('foods');

        var result = await foods.add({
          'name': newFood.name,
          'unit_price': newFood.unitPrice,
          'cost_count': newFood.costCount,
          'price': newFood.price,
          'menu_id': newFood.menuId
        });
        menu.doc(result.id).set({
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
      if (foodList.isNotEmpty) {
        print('food取得完了');
      }
      return foodList;
    } on FirebaseException catch(e) {
      print('food取得エラー: $e');
      return null;
    }
  }

  // static Future<dynamic> deleteMenus(String accountId) async {
  //   final CollectionReference userMenus = _firestoreInstance.collection('users').doc(accountId).collection('my_menus');
  //   var snapshot = await userMenus.get();
  //   snapshot.docs.forEach((doc) async{
  //     final CollectionReference selectedFoods = menus.doc(doc.id).collection('foods');
  //     var foodSnapshot = await selectedFoods.get();
  //     foodSnapshot.docs.forEach((foodDoc) async{
  //       await foods.doc(foodDoc.id).delete();
  //       await selectedFoods.doc(foodDoc.id).delete();
  //     });
  //     await menus.doc(doc.id).delete();
  //     await userMenus.doc(doc.id).delete();
  //   });
  // }

  static Future<dynamic> deleteFoods(CollectionReference foods) async {
    var snapshot = await foods.get();
    snapshot.docs.forEach((doc) async{
      await foods.doc(doc.id).delete();
      await foods.doc(doc.id).delete();
    });
  }
}