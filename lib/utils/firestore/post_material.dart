import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodcost/model/food.dart';


class FoodsFirestore {
  static final _firestoreInstance = FirebaseFirestore.instance;
  static final CollectionReference material = _firestoreInstance.collection(('foods'));

  static Future<dynamic> addFood(Food newFood) async {
    try {
      // TODO: 先にメニューを登録してみる
      final CollectionReference _menu = _firestoreInstance.collection('menus')
      .doc(newFood.menuId).collection('foods');
      var result = await material.add({
        'name': newFood.name,
        'unit_price': newFood.unitPrice,
        'cost_count': newFood.costCount,
        'price': newFood.price
      });
      _menu.doc(result.id).set({
        'material_id': result.id,
        'created_time': Timestamp.now()
      });
      print('材料を登録しました。');
      return true;
    } on FirebaseException catch (e) {
      print('登録エラー: $e');
      return false;
    }
  }
}