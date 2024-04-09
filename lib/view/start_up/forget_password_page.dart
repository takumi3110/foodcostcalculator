import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodcost/component/primary_button.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/utils/extension.dart';
import 'package:foodcost/utils/widget_utils.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  TextEditingController emailController = TextEditingController();
  bool _isEmailError = false;

  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: WidgetUtils.createAppBar('さいはっこう'),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text('登録したメールアドレスを入力してください。'),
                    const Text('パスワード変更のための確認メールを送信します。'),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 300,
                            child: TextField(
                              // TODO: バリデーションと認証
                              controller: emailController,
                              decoration: const InputDecoration(hintText: 'メールアドレス'),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-z0-9@.+_-]'))],
                              keyboardType: TextInputType.emailAddress,
                              onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                              onChanged: (String value) {
                                setState(() {
                                  _isEmailError = !value.isValidEmail();
                                });
                              },
                            ),
                          ),
                          if (_isEmailError)
                            const Text(
                              '正しい形式で入力してください。',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                    PrimaryButton(
                        onPressed: () async{
                          if (emailController.text.isNotEmpty) {
                            setState(() {
                              _isLoading = true;
                            });
                            var result = await Authentication.passwordReset(emailController.text);
                            if (result == true) {
                              while(Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                            }
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                        childText: '送信する'
                    )
                  ],
                ),
              ),
            ),
            WidgetUtils.loadingStack(_isLoading),
          ],
        ),
      ),
    );
  }
}
