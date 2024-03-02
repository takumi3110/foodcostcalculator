import 'package:cloud_firestore/cloud_firestore.dart';

class Account {
  String id;
  String name;
  String email;
  String? imagePath;
  Timestamp? createdTime;
  Timestamp? updatedTime;

  Account(
      {this.id = '',
      this.name = '',
      this.email = '',
      this.imagePath,
      this.createdTime,
      this.updatedTime});
}

class Group {
  String id;
  String name;
  String pass;
  String owner;

  Group({this.id = '', required this.name, required this.pass, required this.owner});
}
