import 'package:flutter/material.dart';

import '../../config/style/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    required this.title,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
    super.key,
  });

  final Widget title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: AppColors.slate900,
      foregroundColor: AppColors.white,
      elevation: 0,
      leading: leading,
      actions: actions,
      title: title,
    );
  }
}
