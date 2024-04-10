import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodcost/model/news.dart';

class NewsFirestore {
  static final _firestoreInstance = FirebaseFirestore.instance;
  static final CollectionReference news = _firestoreInstance.collection('news');

  static Future<dynamic> getNews() async {
    try {
      final snapshot = await news.get();
      List<News> newsList = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        newsList.add(News(title: data['title'], description: data['description'], createdDate: data['created_date']));
      }
      if (newsList.isNotEmpty) {
        debugPrint('お知らせ取得完了');
      }
      newsList.sort((a, b) => b.createdDate.toDate().compareTo(a.createdDate.toDate()));
      return newsList;
    } on FirebaseException catch (e) {
      print('お知らせ取得エラー: $e');
      return null;
    }
  }
}
