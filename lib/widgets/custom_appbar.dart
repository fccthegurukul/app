import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final List<Widget>? actions;

  CustomAppBar({required this.title, this.centerTitle = false, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: TextStyle(color: Colors.black87)),
      centerTitle: centerTitle,
      elevation: 0,
      backgroundColor: Colors.white,
      actions: actions,
      iconTheme: IconThemeData(color: Colors.black87),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
