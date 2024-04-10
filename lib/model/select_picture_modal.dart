import 'package:flutter/cupertino.dart';

class SelectPictureModal {
  String title;
  IconData icon;
  Function() onTap;

  SelectPictureModal({
    required this.title,
    required this.icon,
    required this.onTap
});
}