import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodcost/model/menu.dart';
import 'package:foodcost/utils/firestore/foods.dart';

class MenuFirestore {
  static final _firestoreInstance = FirebaseFirestore.instance;
  static final CollectionReference menus = _firestoreInstance.collection('menus');

  static Future<dynamic> addMenu(Menu newMenu) async {
    try {
      final CollectionReference userMenus = _firestoreInstance.collection('users')
          .doc(newMenu.userId).collection('my_menus');
      var result = await menus.add({
        'name': newMenu.name,
        'user_id': newMenu.userId,
        // 'image_path': newMenu.imagePath,
        'total_amount': newMenu.totalAmount,
        'created_time': newMenu.createdTime
      });
      await userMenus.doc(result.id).set({
        'menu_id': result.id,
        'created_time': newMenu.createdTime
      });
      print('メニュー登録完了');
      return result.id;
    } on FirebaseException catch(e) {
      print('メニュー登録エラー: $e');
      return null;
    }
  }

  static Future<dynamic> setMenu(Menu newMenu) async {
    try {
      await menus.doc(newMenu.id).set({
        'name': newMenu.name,
        'user_id': newMenu.userId,
        'image_path': newMenu.imagePath,
        'total_amount': newMenu.totalAmount,
      });
      print('メニュー更新完了');
      return true;
    } on FirebaseException catch (e) {
      print('メニュー更新エラー: $e');
      return false;
    }
  }

  static Future<dynamic> updateMenuImage(String menuId, String imagePath) async {
    try {
      await menus.doc(menuId).update({
        'image_path': imagePath
      });
      print('メニュー画像登録完了');
      return true;
    } on FirebaseException catch (e) {
      print('メニュー画像登録エラー: $e');
      return false;
    }
  }

  static Future<dynamic> getMenus(String accountId) async {
    try {
      DateTime now = DateTime.now();
     var  currentMonth = now.month;
      List<Menu> menuList = [];
      var snapshot = await menus.where('user_id', isEqualTo: accountId).get();
      snapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // 今の月と同じものを取得
        if (currentMonth == data['created_time'].toDate().month) {
          Menu menu = Menu(
              name: data['name'],
              userId: data['user_id'],
              imagePath: data['image_path'],
              totalAmount: data['total_amount'],
              createdTime: data['created_time']
          );
          menuList.add(menu);
        }
      });
      if (menuList.isNotEmpty) {
        print('メニュー取得完了');
      }
      return menuList;
    } on FirebaseException catch (e) {
      print('メニュー取得エラー: $e');
      return null;
    }
  }

  static Future<dynamic> deleteMenus(String accountId) async {
    final CollectionReference userMenus = _firestoreInstance.collection('users').doc(accountId).collection('my_menus');
    var snapshot = await userMenus.get();
    snapshot.docs.forEach((doc) async{
      final CollectionReference collectionFoods = menus.doc(doc.id).collection('foods');
      await FoodFirestore.deleteFoods(collectionFoods);
      await menus.doc(doc.id).delete();
      await userMenus.doc(doc.id).delete();
    });
  }


}