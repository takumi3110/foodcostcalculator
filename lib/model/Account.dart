import 'package:cloud_firestore/cloud_firestore.dart';

class Account {
  String id;
  String name;
  String email;
  String imagePath;
  Timestamp? createdTime;

  Account({this.id = '', this.name = '', this.email = '', this.imagePath = '', this.createdTime});
}
