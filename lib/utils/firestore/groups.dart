import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:foodcost/model/account.dart';
import 'package:foodcost/model/group.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/utils/firestore/menus.dart';
import 'package:foodcost/utils/firestore/targets.dart';
import 'package:foodcost/utils/firestore/users.dart';

class GroupFirestore {
  static final _firestoreInstance = FirebaseFirestore.instance;
  static final CollectionReference groups = _firestoreInstance.collection('groups');

  static Future<bool> createGroup(Group newGroup) async {
    try {
      var result = await groups.add({
        'name': newGroup.name,
        'code': newGroup.code,
        // 'owner': newGroup.owner
      });
      final myAccount = Authentication.myAccount;
      if (myAccount != null) {
        final CollectionReference groupMembers = groups.doc(result.id).collection('members');
        await groupMembers
            .doc(myAccount.id)
            // .set({'name': myAccount.name, 'image_path': myAccount.imagePath, 'is_owner': true});
            .set({'is_owner': true});
        // ユーザーのグループIDに追加
        await UserFirestore.users.doc(myAccount.id).update({'group_id': result.id});
        Authentication.myAccount!.groupId = result.id;
      // 自分が登録してるメニュー全部にgroupIdを追加
        await MenuFirestore.updateMenuAddGroup(result.id);
        // 目標金額があれば、目標金額にgroup_idを追加
        final targetSnapshots = await TargetFirestore.targets.where('created_user_id', isEqualTo: myAccount.id).get();
        for (var doc in targetSnapshots.docs) {
          // await TargetFirestore.addTargetToUserCollection(myAccount.id, doc.id);
          await TargetFirestore.targets.doc(doc.id).set({'group_id': result.id});
        }
      }
      debugPrint('グループ登録完了');
      return true;
    } on FirebaseException catch (e) {
      debugPrint('グループ登録エラー: $e');
      return false;
    }
  }

  static Future<bool> updateGroup(Group newGroup) async {
    try {
      await groups.doc(newGroup.id).update({
        'name': newGroup.name,
      });
      debugPrint('グループ更新完了');
      return true;
    } on FirebaseException catch (e) {
      debugPrint('グループ更新エラー:$e');
      return false;
    }
  }

  static Future<dynamic> getGroup(String groupId) async {
    try {
      DocumentSnapshot doc = await groups.doc(groupId).get();
      if (doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Group newGroup = Group(
          id: doc.id,
          name: data['name'],
          code: data['code'],
        );
        debugPrint('グループ取得完了');
        return newGroup;
      } else {
        return null;
      }
    } on FirebaseException catch (e) {
      debugPrint('グループ取得エラー: $e');
      return null;
    }
  }

  static Future<dynamic> getGroupMembers(String groupId) async {
    try {
      final CollectionReference members = groups.doc(groupId).collection('members');
      List<Member> memberList = [];
      QuerySnapshot snapshot = await members.get();
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final user = await UserFirestore.users.doc(doc.id).get();
        memberList
            .add(Member(id: doc.id, name: user['name'], imagePath: user['image_path'], isOwner: data['is_owner']));
      }
      if (memberList.isNotEmpty) {
        debugPrint('メンバー取得完了');
        return memberList;
      } else {
        return null;
      }
    } on FirebaseException catch (e) {
      debugPrint('グループ取得エラー: $e');
      return null;
    }
  }

  static Future<dynamic> addGroupOnCode(String code) async {
    try {
      List<Group> groupList = [];
      var snapshot = await groups.where('code', isEqualTo: code).get();
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['code'] == code) {
          groupList.add(Group(id: doc.id, name: data['name'], code: data['code']));
        }
      }
      if (groupList.isNotEmpty) {
        // groupのメンバーに追加する処理
        Account myAccount = Authentication.myAccount!;
        final group = groupList[0];
        final CollectionReference myGroup = groups.doc(group.id).collection('members');
        await myGroup
            .doc(myAccount.id)
            .set({'is_owner': false});
        await UserFirestore.users.doc(myAccount.id).update({
          'group_id': group.id,
          'is_initial_access': false,
        });
        // 大元のAuthentication.myAccountを更新
        Authentication.myAccount!.groupId = group.id;
        if (group.id != null) {
          // それまで作ったメニューにグループIDを追加
          await MenuFirestore.updateMenuAddGroup(group.id!);
          // 目標金額があれば、my_targetsに追加
          final targetSnapshots = await TargetFirestore.targets.where('group_id', isEqualTo: group.id).get();
          for (var doc in targetSnapshots.docs) {
            await TargetFirestore.addTargetToUserCollection(myAccount.id, doc.id);
          }
        }
        debugPrint('グループに参加しました。');
        return group;
      } else {
        debugPrint('コードに適合するグループがないです。');
        return null;
      }
    } on FirebaseException catch (e) {
      debugPrint('グループ参加エラー: $e');
      return null;
    }
  }

  static Future<void> deleteMember(String accountId) async {
    try {
      final DocumentSnapshot user = await _firestoreInstance.collection('users').doc(accountId).get();
      if (user.data() != null) {
        Map<String, dynamic> data = user.data() as Map<String, dynamic>;
        final groupId = data['group_id'];
        if (groupId != null) {
          final CollectionReference members = groups.doc(groupId).collection('members');
          await members.doc(accountId).delete();
          debugPrint('メンバー削除');
        }
      }
    } on FirebaseException catch (e) {
      debugPrint('メンバー削除エラー: $e');
    }
  }
}
