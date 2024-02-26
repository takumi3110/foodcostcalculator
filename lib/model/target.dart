import 'package:cloud_firestore/cloud_firestore.dart';

class Target {
  String id;
  int monthAmount;
  int dayAmount;
  String userId;
  Timestamp? updatedTime;

  Target({
    this.id = '',
    required this.monthAmount,
    required this.dayAmount,
    required this.userId,
    this.updatedTime
  });
}