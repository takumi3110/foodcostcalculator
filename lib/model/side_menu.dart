import 'package:flutter/material.dart';

class SideMenu {
  String title;
  IconData icons;
  Function() onTap;

  SideMenu({
    required this.title,
    required this.icons,
    required this.onTap
});
}