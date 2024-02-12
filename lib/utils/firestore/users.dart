import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:foodcost/model/Account.dart';
import 'package:foodcost/model/menu.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/utils/firestore/posts.dart';

class UserFirestore {
  static final _firestoreInstance = FirebaseFirestore.instance;
  static final CollectionReference users = _firestoreInstance.collection('users');

  static Future<dynamic> setUser(Account newAccount) async{
    try {
      await users.doc(newAccount.id).set({
        'name': newAccount.name,
        'email': newAccount.email,
        'image_path': newAccount.imagePath,
        'created_time': newAccount.createdTime,
        'updated_time': newAccount.updatedTime
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
          email: data['email'],
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

  static Future<Map<String, Account>?> getPostUserMap(String userId) async{
    Map<String, Account> map = {};
    try {
      var doc = await users.doc(userId).get();
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      Account postAccount = Account(
        id: userId,
        name: data['name'],
        email: data['email'],
        imagePath: data['image_path'],
        createdTime: data['created_time'],
        updatedTime: data['updated_time']
      );
      map[userId] = postAccount;
      print('投稿ユーザーの取得完了');
      return map;
    } on FirebaseException catch (e) {
      print('投稿ユーザー取得エラー: $e');
      return null;
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
      print('update成功');
      return true;
    } on FirebaseException catch (e) {
      print('updateエラー: $e');
      return false;
    }
  }

  static Future<dynamic> deleteUser(String accountId) async {
    users.doc(accountId).delete();
    PostFirestore.deletePosts(accountId);
  }
}