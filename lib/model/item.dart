import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  String? id;
  String name;
  String? registeredUser;
  int price;
  double remainingQuantity;
  int quantity;
  String? shop;

  Item({
    this.id = '',
    required this.name,
    this.registeredUser,
    required this.price,
    this.remainingQuantity = 1,
    required this.quantity,
    this.shop,
  });
}

class Purchase {
  String id;
  Timestamp date;
  List<dynamic> itemIds;
  String? groupId;

  Purchase({this.id = '', required this.date, required this.itemIds, this.groupId});
}
