import 'package:cloud_firestore/cloud_firestore.dart';

class Account {
  String id;
  String name;
  String email;
  String? imagePath;
  String? groupId;
  Timestamp? createdTime;
  Timestamp? updatedTime;

  Account(
      {this.id = '',
      this.name = '',
      this.email = '',
      this.imagePath,
      this.groupId,
      this.createdTime,
      this.updatedTime});
}


