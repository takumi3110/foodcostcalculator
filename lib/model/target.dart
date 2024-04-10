import 'package:cloud_firestore/cloud_firestore.dart';

class Target {
  String id;
  int monthAmount;
  int dayAmount;
  String createdUserId;
  String? groupId;
  Timestamp? updatedTime;

  Target({
    this.id = '',
    required this.monthAmount,
    required this.dayAmount,
    required this.createdUserId,
    this.groupId,
    this.updatedTime
  });
}