import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class FunctionUtils {
  static Future<dynamic> getImageFromGallery() async{
    ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    return pickedFile;
  }

  static Future<dynamic> uploadImage(String id, File image) async {
    try {
      final FirebaseStorage storageInstance = FirebaseStorage.instance;
      final Reference ref = storageInstance.ref();
      await ref.child(id).putFile(image);
      String downloadUrl = await storageInstance.ref(id).getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      print(e);
      return null;
    }
  }

  static Future<void> deleteImage(String id) async {
    try {
      final FirebaseStorage storageInstance = FirebaseStorage.instance;
      final Reference ref = storageInstance.ref();
      await ref.child(id).delete();
      print('image削除完了');
    } catch (e) {
      print('image削除エラー: $e');
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
      print('URL起動エラー');
    }
  }
}