import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class NumberKeyboard extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;

  const NumberKeyboard({super.key, required this.controller, this.hintText});

  @override
  State<NumberKeyboard> createState() => _NumberKeyboardState();
}

class _NumberKeyboardState extends State<NumberKeyboard> {
  String hintText = '';
  TextEditingController numberController = TextEditingController();

  // keyboard actions
  final FocusNode _nodeText1 = FocusNode();

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
        keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
        keyboardBarColor: Colors.grey[200],
        nextFocus: true,
        actions: [
          KeyboardActionsItem(focusNode: _nodeText1, toolbarButtons: [
            (node) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: GestureDetector(
                onTap: () => node.unfocus(),
                child: const Text('完了', style: TextStyle(color: Colors.blue)),
                // child: Container(
                //   width: 70,
                //   decoration: BoxDecoration(
                //     color: Colors.blue,
                //     borderRadius: BorderRadius.circular(10)
                //   ),
                //   padding: const EdgeInsets.all(10),
                //   child: const Center(child: Text('done', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),))
                // ),
              ),
            );
            }
          ]),
        ]);
  }

  @override
  void initState() {
    if (widget.hintText != '') {
      hintText = widget.hintText!;
    }
    numberController = widget.controller;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardActions(
      config: _buildConfig(context),
      child: Column(
        children: [
          const TextField(),
          TextField(
            controller: numberController,
            keyboardType: TextInputType.number,
            focusNode: _nodeText1,
            decoration: InputDecoration(hintText: hintText),
          ),
          const TextField()
        ],
      ),
    );
  }
}
