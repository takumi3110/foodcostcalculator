import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodcost/model/Account.dart';
import 'package:foodcost/utils/functionUtils.dart';

class Authentication {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static User? currentFirebaseUser;
  static Account? myAccount;

  static Future<dynamic> signUp({required String email, required String pass}) async {
    try {
      UserCredential newAccount = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: pass);
      print('認証完了');
      return newAccount;
    } on FirebaseAuthException catch(e) {
      print('認証エラー: $e');
      return false;
    }
  }

  static Future<dynamic> emailSignIn({required String email, required String password}) async {
    try {
      final UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      currentFirebaseUser = result.user;
      print('ログイン完了');
      return result;
    } on FirebaseAuthException catch (e) {
      print('サインインエラー: $e');
      return false;
    }
  }

  static Future<void> signOut() async{
    await _firebaseAuth.signOut();
  }
}