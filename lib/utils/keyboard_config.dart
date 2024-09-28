import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class KeyboardConfig {
  static KeyboardActionsConfig _buildConfig(BuildContext context) {
    final FocusNode node = FocusNode();
    return KeyboardActionsConfig(
        keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
        keyboardBarColor: Colors.grey[200],
        nextFocus: true,
        actions: [
          KeyboardActionsItem(focusNode: node, toolbarButtons: [
            (node) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: GestureDetector(
                onTap: () => node.unfocus(),
                child: const Text('完了', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              ),
            );
            }
          ]),
        ]);
  }
}