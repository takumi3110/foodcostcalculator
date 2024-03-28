import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:foodcost/model/target.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/utils/firestore/groups.dart';
import 'package:foodcost/utils/firestore/users.dart';

class TargetFirestore {
  static final _firestoreInstance = FirebaseFirestore.instance;
  static final CollectionReference targets = _firestoreInstance.collection('targets');

  static Future<dynamic> addTarget(Target newTarget) async {
    try {
      var result = await targets.add({
        'month_amount': newTarget.monthAmount,
        'day_amount': newTarget.dayAmount,
        'created_user_id': newTarget.createdUserId,
        'group_id': newTarget.groupId,
        'updated_time': Timestamp.now()
      });
      // groupにいて、目標金額を設定した時コレクションに追加
      if (newTarget.groupId != null) {
        final CollectionReference membersCollection = GroupFirestore.groups.doc(newTarget.groupId).collection('members');
        final memberSnapshots = await membersCollection.get();
        for(var doc in memberSnapshots.docs) {
          await addTargetToUserCollection(doc.id, result.id);
        }
      } else {
        await addTargetToUserCollection(newTarget.createdUserId, result.id);
      }
      debugPrint('目標金額登録完了');
      return result;
    } on FirebaseException catch (e) {
      debugPrint('目標金額登録エラー: $e');
      return null;
    }
  }

  // TODO: groupに加入した時コレクションに追加
  static Future<void> addTargetToUserCollection(String uid, String targetId) async{
    try {
      final CollectionReference userTarget =
      UserFirestore.users.doc(uid).collection('my_targets');
      await userTarget.doc(targetId).set({
        'target_id': targetId,
      });
      debugPrint('目標金額をユーザーコレクションに追加しました。');
    } on FirebaseException catch (e) {
      debugPrint('目標金額をユーザーコレクションに追加できません。: $e');
    }
  }

  static Future<dynamic> updateTarget(Target newTarget) async {
    try {
      await targets.doc(newTarget.id).update(
          {
            'month_amount': newTarget.monthAmount,
            'day_amount': newTarget.dayAmount,
            'updated_time': Timestamp.now()
          });
      debugPrint('目標金額更新完了');
      return true;
    } on FirebaseException catch (e) {
      debugPrint('目標金額更新エラー: $e');
      return null;
    }
  }

  static Future<dynamic> getTarget(String accountId) async {
    try {
      final CollectionReference userTarget =
          UserFirestore.users.doc(accountId).collection('my_targets');
      final userTargetSnapshot = await userTarget.get();
      if (userTargetSnapshot.docs.isNotEmpty) {
        for (var doc in userTargetSnapshot.docs) {
          Map<String, dynamic> userTargetData = doc.data() as Map<String, dynamic>;
          final targetSnapshot = await targets.doc(userTargetData['target_id']).get();
          Map<String, dynamic> targetData = targetSnapshot.data() as Map<String, dynamic>;
          Target target = Target(
              id: targetSnapshot.id,
              monthAmount: targetData['month_amount'],
              dayAmount: targetData['day_amount'],
              createdUserId: targetData['created_user_id'],
              groupId: targetData['group_id'],
              updatedTime: targetData['updated_time']
          );
          if (Authentication.myAccount != null) {
            if (Authentication.myAccount!.groupId != null && Authentication.myAccount!.groupId! == targetData['groupId']) {
              debugPrint('グループ目標金額取得完了');
              return target;
            } else {
              debugPrint('目標金額取得完了');
              return target;
            }
          } else {
            return null;
          }
        }
        // Map<String, dynamic> userTargetData = userTargetSnapshot.docs[0].data() as Map<String, dynamic>;
        // var myTarget = await targets.where('user_id', isEqualTo: accountId).get();
        // myTarget.docs.forEach((doc) {
        //   Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // final targetSnapshot = await targets.doc(userTargetData['target_id']).get();
        // Map<String, dynamic> targetData = targetSnapshot.data() as Map<String, dynamic>;
        // Target target = Target(
        //     id: targetSnapshot.id,
        //     monthAmount: targetData['month_amount'],
        //     dayAmount: targetData['day_amount'],
        //     userId: targetData['user_id'],
        //     groupId: targetData['group_id'],
        //     updatedTime: targetData['updated_time']
        // );
        //
        // });
      } else {
        return null;
      }
    } on FirebaseException catch (e) {
      debugPrint('目標金額取得エラー: $e');
      return null;
    }
  }

  static Future<void> deleteTarget(String accountId) async {
    try {
      final CollectionReference myTargets = _firestoreInstance.collection('users').doc(accountId).collection('my_targets');
      var snapshot = await myTargets.get();
      for (var doc in snapshot.docs) {
        await targets.doc(doc.id).delete();
        await myTargets.doc(doc.id).delete();
      }
      debugPrint('目標金額削除完了');
    } on FirebaseException catch (e) {
      debugPrint('目標金額削除エラー: $e');
    }
  }
}
