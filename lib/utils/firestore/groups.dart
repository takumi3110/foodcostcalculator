import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodcost/model/account.dart';
import 'package:foodcost/model/group.dart';
import 'package:foodcost/utils/authentication.dart';
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
            .set({'name': myAccount.name, 'image_path': myAccount.imagePath, 'is_owner': true});
        // ユーザーのグループIDに追加
        await UserFirestore.users.doc(myAccount.id).update({'group_id': result.id});
        Authentication.myAccount!.groupId = result.id;
      }
      print('グループ登録完了');
      return true;
    } on FirebaseException catch (e) {
      print('グループ登録エラー: $e');
      return false;
    }
  }

  static Future<bool> updateGroup(Group newGroup) async {
    try {
      await groups.doc(newGroup.id).update({
        'name': newGroup.name,
      });
      print('グループ更新完了');
      return true;
    } on FirebaseException catch (e) {
      print('グループ更新エラー:$e');
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
        print('グループ取得完了');
        return newGroup;
      } else {
        return null;
      }
    } on FirebaseException catch (e) {
      print('グループ取得エラー: $e');
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
        memberList
            .add(Member(id: doc.id, name: data['name'], imagePath: data['image_path'], isOwner: data['is_owner']));
      }
      if (memberList.isNotEmpty) {
        print('メンバー取得完了');
        return memberList;
      } else {
        return null;
      }
    } on FirebaseException catch (e) {
      print('グループ取得エラー: $e');
      return null;
    }
  }

  static Future<dynamic> getGroupOnCode(String code) async {
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
        //   TODO: groupのメンバーに追加する処理
        Account myAccount = Authentication.myAccount!;
        final group = groupList[0];
        final CollectionReference myGroup = groups.doc(group.id).collection('members');
        await myGroup
            .doc(myAccount.id)
            .set({'name': myAccount.name, 'image_path': myAccount.imagePath, 'is_owner': false});
        await UserFirestore.users.doc(myAccount.id).update({
          'group_id': group.id,
          'is_initial_access': false,
        });
        // myAccount.groupId = group.id;
        Authentication.myAccount!.groupId = group.id;
        return group;
      } else {
        return null;
      }
    } on FirebaseException catch (e) {
      print('グループ取得エラー: $e');
      return false;
    }
  }
}
