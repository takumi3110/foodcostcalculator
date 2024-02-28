import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodcost/model/food.dart';

class Menu {
  String id;
  String name;
  String userId;
  int? totalAmount;
  String? imagePath;
  Timestamp? createdTime;
  List<Food> foods;

  Menu({
    this.id = '',
    required this.name,
    this.userId = '',
    this.totalAmount,
    this.createdTime,
    this.imagePath,
    required this.foods
  });
}
