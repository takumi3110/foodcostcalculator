import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class FunctionUtils {
  // ギャラリーから画像を取得
  static Future<dynamic> getImageFromGallery() async{
    ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    return pickedFile;
  }

  // カメラを使用する
  static Future<dynamic> getImageFromCamera() async {
    ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    return pickedFile;
  }

  static Future<dynamic> uploadImage(String id, File image) async {
    try {
      final FirebaseStorage storageInstance = FirebaseStorage.instance;
      final Reference ref = storageInstance.ref();
      await ref.child(id).putFile(image);
      String downloadUrl = await storageInstance.ref(id).getDownloadURL();
      debugPrint('imageアップロード完了');
      return downloadUrl;
    } on FirebaseException catch (e) {
      debugPrint('imageアップロードエラー: $e');
      return null;
    }
  }

  static Future<void> deleteImage(String id) async {
    try {
      final FirebaseStorage storageInstance = FirebaseStorage.instance;
      final Reference ref = storageInstance.ref();
      await ref.child(id).delete();
      debugPrint('image削除完了');
    } catch (e) {
      debugPrint('image削除エラー: $e');
    }
  }

  static Future<void> launchLine(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
          uri,
          mode: LaunchMode.externalApplication
      );
    } else {
      debugPrint('URL起動エラー');
    }
  }
}