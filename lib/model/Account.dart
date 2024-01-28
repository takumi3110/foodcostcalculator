import 'package:cloud_firestore/cloud_firestore.dart';

class Account {
  String id;
  String name;
  String imagePath;
  Timestamp? createdTime;

  Account({this.id = '', this.name = '', this.imagePath = '', this.createdTime});
}
