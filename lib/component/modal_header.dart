import 'package:flutter/material.dart';

class ModalHeader extends StatelessWidget {
  final VoidCallback onPressCancel;
  final VoidCallback onPressAdd;

  const ModalHeader({super.key, required this.onPressAdd, required this.onPressCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric( horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        color: Colors.orangeAccent[100],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
              onPressed: onPressCancel,
              child: const Text(
                'キャンセル',
                style: TextStyle(color: Colors.grey),
              )),
          TextButton(
              onPressed: onPressAdd,
              child: const Text('登録', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)))
        ],
      ),
    );
  }
}
