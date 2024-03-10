import 'package:cloud_firestore/cloud_firestore.dart';

class Account {
  String id;
  String name;
  String email;
  String? imagePath;
  String? groupId;
  bool isInitialAccess;
  Timestamp? createdTime;
  Timestamp? updatedTime;

  Account(
      {this.id = '',
      this.name = '',
      this.email = '',
      this.imagePath,
      this.isInitialAccess = true,
      this.groupId,
      this.createdTime,
      this.updatedTime});
}
