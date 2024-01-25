import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodcost/model/Account.dart';
import 'package:foodcost/utils/authentication.dart';

class UserFirestore {
  static final _firestoreInstance = FirebaseFirestore.instance;
  static final CollectionReference users = _firestoreInstance.collection('users');

  static Future<dynamic> setUser(Account newAccount) async{
    try {
      await users.doc(newAccount.id).set({
        'name': newAccount.name,
        'image_path': newAccount.imagePath,
        'created_time': newAccount.createdTime,
      });
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
          imagePath: data['image_path'],
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
}