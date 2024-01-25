import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FunctionUtils {
  static Future<dynamic> getImageFromGallery()  async {
    ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    return pickedFile;
  }

  static Future<dynamic> uploadImage(String uid, File image) async {
    final FirebaseStorage storageInstance = FirebaseStorage.instance;
    final Reference ref = storageInstance.ref();
    await ref.child(uid).putFile(image);
    String downloadUrl = await storageInstance.ref(uid).getDownloadURL();
    return downloadUrl;
  }
}