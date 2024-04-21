import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:foodcost/model/food.dart';

class FoodFirestore {
  static final _firestoreInstance = FirebaseFirestore.instance;
  static final CollectionReference foods = _firestoreInstance.collection('foods');

  static Future<List<Food>?> getFoodFromIds(List<String> ids) async {
    List<Food> foodList = [];
    try {
      await Future.forEach(ids, (String id) async {
        var doc = await foods.doc(id).get();
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Food food = Food(
          // id: doc.id,
          // menuId: data['menu_id'],
          name: data['name'],
          unitPrice: data['unit_price'],
          costCount: data['cost_count'],
          price: data['price']
        );
        foodList.add(food);
      });
      if (foodList.isNotEmpty) {
        debugPrint('food取得完了');
      }
      return foodList;
    } on FirebaseException catch(e) {
      debugPrint('food取得エラー: $e');
      return null;
    }
  }

  static Future<dynamic> deleteFoods(CollectionReference collectionFoods) async {
    var snapshot = await collectionFoods.get();
    for (var doc in snapshot.docs) {
      await collectionFoods.doc(doc.id).delete();
    }
  }
}