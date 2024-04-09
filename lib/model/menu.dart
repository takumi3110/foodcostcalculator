import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodcost/model/food.dart';

class Menu {
  String id;
  String name;
  String userId;
  String? updatedUserId;
  String? groupId;
  int? totalAmount;
  String? imagePath;
  Timestamp createdTime;
  Timestamp? updatedTime;
  List<Food> foods;

  Menu({
    this.id = '',
    required this.name,
    required this.userId,
    this.updatedUserId,
    this.groupId,
    this.totalAmount,
    required this.createdTime,
    this.updatedTime,
    this.imagePath,
    required this.foods
  });
}
