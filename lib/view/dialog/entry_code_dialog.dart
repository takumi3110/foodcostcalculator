import 'package:flutter/material.dart';
import 'package:foodcost/component/cancel_button.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/utils/firestore/groups.dart';
import 'package:foodcost/utils/widget_utils.dart';

class EntryCodeDialog extends StatefulWidget {
  const EntryCodeDialog({super.key});

  @override
  State<EntryCodeDialog> createState() => _EntryCodeDialogState();
}

class _EntryCodeDialogState extends State<EntryCodeDialog> {
  bool _isVerifying = false;
  bool _isVerified = false;
  bool _isDifferent = false;
  String? _groupName;

  void getGroup(String groupId) async {
    final result = await GroupFirestore.getGroup(groupId);
    if (result != null) {
      setState(() {
        _groupName = result.name;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (Authentication.myAccount != null && Authentication.myAccount!.groupId != null) {
      getGroup(Authentication.myAccount!.groupId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      title: const Text(
        '招待コードを入力してください',
        style: TextStyle(fontSize: 18),
      ),
      actions: [
        CancelButton(onPressed: () {
          if (!_isVerifying) {
            Navigator.pop(context);
          }
        }, text: '閉じる')
      ],
      content: SizedBox(
              height: 70,
              child: !_isVerified
                  ? Column(
                      children: [
                        if (!_isVerifying)
                          SizedBox(
                            // width: 170,
                            child: Authentication.myAccount!.groupId == null
                                ? TextField(
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.characters,
                              onChanged: (String value) async {
                                if (value.length == 5) {
                                  setState(() {
                                    _isDifferent = false;
                                    _isVerifying = true;
                                  });
                                  var result = await GroupFirestore.getGroupOnCode(value);
                                  await Future.delayed(const Duration(seconds: 3));
                                  if (result != null) {
                                    setState(() {
                                      _isVerified = true;
                                      _groupName = result.name;
                                    });
                                  } else {
                                    setState(() {
                                      _isDifferent = true;
                                    });
                                  }
                                  setState(() {
                                    _isVerifying = false;
                                  });
                                }
                              },
                            )
                            : _groupName != null ? Text('【$_groupName】\nに参加しています。'): Container(),
                          ),
                        if (_isVerifying) WidgetUtils.loadingVerifying(),
                        if (_isDifferent)
                          const Text(
                            '正しい認証コードを入力してください。',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                      ],
                    )
                  : Center(child: Text('【$_groupName】\nに参加しました！')),
            )
              // child: FutureBuilder(
              //     future: GroupFirestore.getGroup(Authentication.myAccount!.groupId!),
              //     builder: (context, snapshot) {
              //       if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
              //         var data = snapshot.data!;
              //         return Text('【${data.name}】に参加しています。');
              //       } else {
              //         return Container();
              //       }
              //     }),

    );
  }
}
