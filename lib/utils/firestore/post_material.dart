import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodcost/model/food.dart';


class MaterialFirestore {
  static final _firestoreInstance = FirebaseFirestore.instance;
  static final CollectionReference material = _firestoreInstance.collection(('materials'));

  static Future<dynamic> addMaterial(Food newMaterial) async {
    try {
      final CollectionReference _menu = _firestoreInstance.collection('menus')
      .doc(newMaterial.menuId).collection('materials');
      var result = await material.add({
        'name': newMaterial.name,
        'unit_price': newMaterial.unitPrice,
        'cost_count': newMaterial.costCount,
        'price': newMaterial.price
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