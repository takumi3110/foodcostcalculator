import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodcost/model/account.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/utils/firestore/foods.dart';
import 'package:foodcost/utils/firestore/groups.dart';
import 'package:foodcost/utils/firestore/menus.dart';
import 'package:foodcost/utils/firestore/targets.dart';
import 'package:foodcost/utils/functionUtils.dart';

class UserFirestore {
  static final _firestoreInstance = FirebaseFirestore.instance;
  static final CollectionReference users = _firestoreInstance.collection('users');

  static Future<dynamic> setUser(Account newAccount) async{
    try {
      await users.doc(newAccount.id).set({
        'name': newAccount.name,
        'email': newAccount.email,
        'image_path': newAccount.imagePath,
        'group_id': newAccount.groupId,
        'is_initial_access': newAccount.isInitialAccess,
        'created_time': newAccount.createdTime,
        'updated_time': newAccount.updatedTime
      });
      Authentication.myAccount = newAccount;
      print('ユーザー登録完了');
      return true;
    } on FirebaseException catch (e) {
      print('ユーザー登録エラー: $e');
      return false;
    }
  }

  static Future<dynamic> getUser(String uid) async {
    try {
      DocumentSnapshot documentSnapshot = await users.doc(uid).get();
      if (documentSnapshot.data() != null) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        Account myAccount = Account(
          id: uid,
          name: data['name'],
          email: data['email'],
          imagePath: data['image_path'],
          isInitialAccess: data['is_initial_access'],
          groupId: data['group_id'],
          createdTime: data['created_time'],
        );

        Authentication.myAccount = myAccount;
        print('ユーザー取得完了');
        return true;
      } else {
        return false;
      }
    } on FirebaseException catch (e) {
      print('ユーザー取得エラー: $e');
      return false;
    }
  }

  static Future<dynamic> updateUser(Account updateAccount) async{
    try {
      await users.doc(updateAccount.id).update({
        'name': updateAccount.name,
        'email': updateAccount.email,
        'image_path': updateAccount.imagePath,
        'updated_time': Timestamp.now()
      });
      Account? myAccount = Authentication.myAccount;
      // 更新した箇所のみを更新
      if (myAccount != null) {
        myAccount.name = updateAccount.name;
        myAccount.email = updateAccount.email;
        myAccount.imagePath = updateAccount.imagePath;
        myAccount.updatedTime = Timestamp.now();
      }
      print('update成功');
      return true;
    } on FirebaseException catch (e) {
      print('updateエラー: $e');
      return false;
    }
  }

  static Future<dynamic> deleteUser(String accountId) async {
    await FunctionUtils.deleteImage(accountId);
    await TargetFirestore.deleteTarget(accountId);
    await MenuFirestore.deleteMenus(accountId);
    await GroupFirestore.deleteMember(accountId);
    users.doc(accountId).delete();
  }


}