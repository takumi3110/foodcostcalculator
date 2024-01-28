import 'package:cloud_firestore/cloud_firestore.dart';

class Menu {
  String id;
  String name;
  Timestamp? createdTime;

  Menu({this.id = '', required this.name, this.createdTime});
}
