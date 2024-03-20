import 'package:cloud_firestore/cloud_firestore.dart';

class News {
  String id;
  String title;
  String description;
  Timestamp createdDate;

  News({
    this.id = '',
    required this.title,
    required this.description,
    required this.createdDate
});
}