import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodcost/model/item.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/utils/firestore/users.dart';

class ItemFirestore {
  static final _firestoreInstance = FirebaseFirestore.instance;
  static final CollectionReference items = _firestoreInstance.collection('items');
  static final CollectionReference purchases = _firestoreInstance.collection('purchases');
  static final CollectionReference userPurchases = UserFirestore.users.doc(Authentication.myAccount!.id).collection('my_purchases');

  static Future<dynamic> addItems(List<Item> newItems) async {
    try {
      List<String> ids = [];
      for (var item in newItems) {
        var result = await items.add({
          'name': item.name,
          'price': item.price,
          'remaining_quantity': item.remainingQuantity,
          'shop': item.shop,
          'registered_user': item.registeredUser,
          'quantity': item.quantity
        });
        ids.add(result.id);
      }
      debugPrint('item取得完了');
      return ids;
    } on FirebaseException catch (e) {
      debugPrint('item登録エラー: $e');
      return null;
    }
  }

  static Future<dynamic> getItems(List<dynamic> ids) async{
    try {
      List<Item> getItems = [];
      for (var id in ids) {
        DocumentSnapshot doc = await items.doc(id).get();
        if (doc.data() != null) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          getItems.add(
            Item(
              id: doc.id,
              name: data['name'],
              price: data['price'],
              remainingQuantity: data['remaining_quantity'],
              shop: data['shop'],
              registeredUser: data['registered_user'],
              quantity: data['quantity']
            )
          );
        }
      }
      if (getItems.isNotEmpty) {
        debugPrint('item取得完了');
        return getItems;
      } else {
        debugPrint('itemは空です。');
        return null;
      }
    } on FirebaseException catch (e) {
      debugPrint('item取得エラー: $e');
      return null;
    }
  }

  static Future<dynamic> addPurchase(Purchase newPurchase) async {
    try {
      var result = await purchases.add({
        'date': newPurchase.date,
        'item_ids': newPurchase.itemIds,
        'group_id': newPurchase.groupId,
      });
      await userPurchases.doc(result.id).set({
        'purchase_id': result.id,
        'date': newPurchase.date
      });
      debugPrint('買ったものリスト登録完了');
      return newPurchase.itemIds;
    } on FirebaseException catch (e) {
      debugPrint('買ったものリスト登録エラー: $e');
      return null;
    }
  }

  static Future<dynamic> updatePurchaseItems(DateTime date, List<dynamic> itemIds) async {
    try {
      // ユーザーからmy_purchaseで同じ日付のidを取得
      final timestampDate = Timestamp.fromDate(date);
      var snapshot = await userPurchases.where('date', isEqualTo: timestampDate).get();
      List<dynamic> newIds = [];
      for (var doc in snapshot.docs) {
        DocumentSnapshot purchaseDoc = await purchases.doc(doc.id).get();
        if (purchaseDoc.data() != null) {
          Map<String, dynamic> data = purchaseDoc.data() as Map<String, dynamic>;
          List<dynamic> oldIds = data['item_ids'];
          await purchases.doc(doc.id).update({
            'item_ids': [...oldIds, ...itemIds]
          });
          newIds.add([...oldIds, ...itemIds]);
        }
      }
      newIds.toSet().toList();
      return newIds;
    } on FirebaseException catch (e) {
      debugPrint('買ったものリスト更新エラー: $e');
      return null;
    } catch (e) {
      debugPrint('買ったものリスト更新エラー(group): $e');
      return null;
    }
  }

  static Future<dynamic> updateGroupPurchaseItems(String groupId, DateTime date, List<dynamic> itemIds) async {
    try {
      final timestampDate = Timestamp.fromDate(date);
      var snapshot = await purchases.where('date', isEqualTo: timestampDate).where('group_id', isEqualTo: groupId).get();
      List<dynamic> newIds = [];
      for (var doc in snapshot.docs) {
        DocumentSnapshot purchaseDoc = await purchases.doc(doc.id).get();
        if (purchaseDoc.data() != null) {
          Map<String, dynamic> data = purchaseDoc.data() as Map<String, dynamic>;
          List<dynamic> oldIds = data['item_ids'];
          await purchases.doc(doc.id).update({
            'item_ids': [...oldIds, ...itemIds]
          });
          newIds.add([...oldIds, ...itemIds]);
        }
      }
      newIds.toSet().toList();
      return newIds;
    }on FirebaseException catch (e) {
      debugPrint('買ったものリスト更新エラー(group): $e');
      return null;
    } catch (e) {
      debugPrint('買ったものリスト更新エラー(group): $e');
      return null;
    }
  }

  static Future<dynamic> getGroupPurchase(String groupId) async {
    try {
      List<Purchase> getPurchases = [];
      var snapshot = await purchases.where('group_id', isEqualTo: groupId).get();
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Purchase purchase = Purchase(
          id: doc.id,
            date: data['date'],
            itemIds: data['item_ids'],
            groupId: data['group_id'],
        );
        getPurchases.add(purchase);
      }
      if (getPurchases.isNotEmpty) {
        getPurchases.sort((a, b) => b.date.compareTo(a.date));
        debugPrint('買ったものリスト取得完了(group)');
        return getPurchases;
      } else {
        debugPrint('買ったものリストは空です。(group)');
        return null;
      }
    } on FirebaseException catch (e) {
      debugPrint('買ったものリスト取得エラー(group): $e');
      return null;
    } catch (e) {
      debugPrint('買ったものリスト取得エラー(group): $e');
      return null;
    }
  }

  static Future<dynamic> getMyPurchase(String accountId) async {
    try {
      List<Purchase> getPurchases = [];
      final CollectionReference userPurchases = UserFirestore.users.doc(accountId).collection('my_purchases');
      var snapshot = await userPurchases.get();
      for (var doc in snapshot.docs){
        DocumentSnapshot purchaseDoc = await purchases.doc(doc.id).get();
        if (purchaseDoc.data() != null) {
          Map<String, dynamic> data = purchaseDoc.data() as Map<String, dynamic>;
          Purchase purchase = Purchase(
            id: doc.id,
              date: data['date'],
              itemIds: data['item_ids'],
              groupId: data['group_id'],
          );
          getPurchases.add(purchase);
        }
      }
      if (getPurchases.isNotEmpty) {
        getPurchases.sort((a, b) => b.date.compareTo(a.date));
        debugPrint('買ったものリスト取得完了');
        return getPurchases;
      } else {
        debugPrint('買ったものリストは空です。');
        return null;
      }
    } on FirebaseException catch (e) {
      debugPrint('買ったものリスト取得エラー: $e');
      return null;
    }
  }

}