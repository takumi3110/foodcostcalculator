import 'package:cloud_firestore/cloud_firestore.dart';

class Menu {
  String id;
  String name;
  String userId;
  int? totalAmount;
  Timestamp? createdTime;

  Menu({this.id = '', required this.name, this.userId = '', this.totalAmount, this.createdTime});
}
