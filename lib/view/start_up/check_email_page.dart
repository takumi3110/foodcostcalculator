import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodcost/component/primary_button.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/utils/firestore/users.dart';
import 'package:foodcost/utils/widget_utils.dart';
import 'package:foodcost/view/calendar/calendar_page.dart';

class CheckEmailPage extends StatefulWidget {
  final String email;
  final String pass;
  final User user;

  const CheckEmailPage({
    super.key,
    required this.email,
    required this.pass,
    required this.user,
  });

  @override
  State<CheckEmailPage> createState() => _CheckEmailPageState();
}

class _CheckEmailPageState extends State<CheckEmailPage> {
  bool _isLoading = false;
  bool _isVerified = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('メールアドレス確認'),
        elevation: 1,
      ),
      body: Stack(children: [
        Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              const Text('登録いただいたメールアドレス宛に確認のメールを送信しました。\nそちらに記載されているURLをクリックして認証をお願いします。'),
              const SizedBox(
                height: 30,
              ),
              const Text('認証が完了したら、完了ボタンをタップしてください。'),
              const SizedBox(
                height: 10,
              ),
              PrimaryButton(
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      var result = await Authentication.emailSignIn(email: widget.email, password: widget.pass);
                      if (result is UserCredential) {
                        if (result.user != null && result.user!.emailVerified == true) {
                          if (!context.mounted) return;
                          while (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                          await UserFirestore.getUser(result.user!.uid);
                          if (!context.mounted) return;
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CalendarPage()));
                        } else {
                          setState(() {
                            _isVerified = true;
                          });
                        }
                      }
                      setState(() {
                        _isLoading = false;
                      });
                    },
                  childText: '認証完了'
              ),
              if (_isVerified == true)
                const Center(child: Text('メールを確認して認証してください。',style: TextStyle(color: Colors.red),)),
              const SizedBox(height: 40,),
              // ElevatedButton(
              //     onPressed: () async{
              //       // TODO: うまく消せない？？
              //       await widget.user.delete();
              //       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CreateAccountPage()));
              //     },
              //     child: const Text('戻る')
              // )
            ],
          ),
        ),
        WidgetUtils.loadingStack(_isLoading)
      ]),
    );
  }
}
