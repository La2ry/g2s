import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final Size size;
  const LogoWidget({
    super.key,
    this.size = const Size(100, 100),
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'lib/asset/image/Logo.png',
      width: size.width,
      height: size.height,
      filterQuality: FilterQuality.high,
      fit: BoxFit.fill,
    );
  }
}
