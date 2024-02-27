import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodcost/model/target.dart';

class TargetFirestore {
  static final _firestoreInstance = FirebaseFirestore.instance;
  static final CollectionReference targets = _firestoreInstance.collection('target');

  static Future<dynamic> addTarget(Target newTarget) async {
    try {
      final CollectionReference userTarget =
          _firestoreInstance.collection('users').doc(newTarget.userId).collection('my_target');
      var result = await targets.add({
        'month_amount': newTarget.monthAmount,
        'day_amount': newTarget.dayAmount,
        'user_id': newTarget.userId,
        'updated_time': Timestamp.now()
      });
      await userTarget.doc(result.id).set({
        'target_id': result.id,
      });
      print('目標金額登録完了');
      return result;
    } on FirebaseException catch (e) {
      print('目標金額登録エラー: $e');
      return null;
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
      print('目標金額更新完了');
      return true;
    } on FirebaseException catch (e) {
      print('目標金額更新エラー: $e');
      return null;
    }
  }

  static Future<dynamic> getTarget(String accountId) async {
    try {
      final CollectionReference userTarget =
          _firestoreInstance.collection('users').doc(accountId).collection('my_target');
      final userTargetSnapshot = await userTarget.get();
      Map<String, dynamic> userTargetData = userTargetSnapshot.docs[0].data() as Map<String, dynamic>;
      // var myTarget = await targets.where('user_id', isEqualTo: accountId).get();
      // myTarget.docs.forEach((doc) {
      //   Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      final targetSnapshot = await targets.doc(userTargetData['target_id']).get();
      Map<String, dynamic> targetData = targetSnapshot.data() as Map<String, dynamic>;
      Target target = Target(
          id: targetSnapshot.id,
          monthAmount: targetData['month_amount'],
          dayAmount: targetData['day_amount'],
          userId: targetData['user_id'],
          updatedTime: targetData['updated_time']);
      //
      // });
      return target;
    } on FirebaseException catch (e) {
      print('目標金額取得エラー: $e');
      return null;
    }
  }
}
