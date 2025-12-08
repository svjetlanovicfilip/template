import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      child: SvgPicture.asset(
        'assets/logo_tefter.svg',
        width: 24,
        height: 24,
        fit: BoxFit.cover,
      ),
    );
  }
}
