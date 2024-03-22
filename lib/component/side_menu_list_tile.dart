import 'package:flutter/material.dart';

class SideMenuListTile extends StatelessWidget {
  final IconData icons;
  final String menuTitle;
  final Function() onTap;

  const SideMenuListTile({
    super.key,
    required this.icons,
    required this.menuTitle,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Icon(icons, color: Colors.teal, size: 32,),
          const SizedBox(
            width: 15.0,
          ),
          Text(menuTitle,)
        ],
      ),
      onTap: onTap,
    );
  }
}
