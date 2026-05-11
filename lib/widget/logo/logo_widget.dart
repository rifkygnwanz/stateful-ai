import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key, this.height, this.width, this.fit});

  final double? height;
  final double? width;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context).brightness == Brightness.dark ? 'light' : 'dark';

    return Image.asset(
      'assets/images/pngs/ic_logo_$theme.png',
      width: width ?? 250,
      height: height,
      fit: fit ?? BoxFit.contain,
    );
  }
}
