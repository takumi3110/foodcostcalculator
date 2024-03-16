import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:foodcost/model/account.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authentication {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static User? currentFirebaseUser;
  static Account? myAccount;
  static final _lineSdk = LineSDK.instance;

  static Future<dynamic> signUp({required String email, required String pass}) async {
    try {
      UserCredential newAccount = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: pass);
      currentFirebaseUser = newAccount.user;
      debugPrint('認証完了');
      return newAccount;
    } on FirebaseAuthException catch(e) {
      debugPrint('認証エラー: $e');
      return false;
    }
  }

  static Future<dynamic> emailSignIn({required String email, required String password}) async {
    try {
      final UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      currentFirebaseUser = result.user;
      debugPrint('ログイン完了');
      return result;
    } on FirebaseAuthException catch (e) {
      debugPrint('サインインエラー: $e');
      return false;
    }
  }

  static Future<dynamic> lineSignIn() async {
    try {
      // LINEにログインして、結果からアクセストークンを取得
      final loginResult = await _lineSdk.login();
      final accessToken = loginResult.accessToken.data['access_token'] as String;

      // FirebaseFunctionsのhttpsCallableを使用してバックエンドサーバーと通信
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast2').httpsCallable('createfirebaseauthcustomtoken');
      final response = await callable.call<Map<String, dynamic>>(
          <String, dynamic>{'accessToken': accessToken}
      );

      // バックエンドサーバーで作成されたカスタムトークンを取得
      final customToken = response.data['customToken'] as String;
      // カスタムトークンを使用して、Firebase Authenticationにサインインする
      final UserCredential result = await _firebaseAuth.signInWithCustomToken(customToken);
      currentFirebaseUser = result.user;
      debugPrint('LINEログイン完了');
      return result;
    } on PlatformException catch(e) {
      debugPrint('LINEログインエラー: $e');
      return false;
    }
  }

  static Future<dynamic> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn(scopes: ['email']).signIn();
      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken
        );
        final UserCredential result = await _firebaseAuth.signInWithCredential(credential);
        currentFirebaseUser = result.user;
        debugPrint('Googleログイン完了');
        return result;
      } else {
        return false;
      }
    } on FirebaseException catch (e) {
      debugPrint('Google認証エラー:$e');
      return false;
    } on PlatformException catch (e) {
      debugPrint('Googleエラー: $e');
      return false;
    }
  }

  static Future<void> signOut() async{
    await _firebaseAuth.signOut();
    debugPrint('サインアウト');
  }

  static Future<void> deleteAuth() async{
    if (currentFirebaseUser != null) {
      await currentFirebaseUser!.delete();
      debugPrint('ユーザー削除完了');
    }
  }
}