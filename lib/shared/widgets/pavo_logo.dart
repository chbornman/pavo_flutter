import 'package:flutter/material.dart';

class PavoLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final bool forceLight;
  final bool forceDark;

  const PavoLogo({
    super.key,
    this.width,
    this.height,
    this.forceLight = false,
    this.forceDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = forceDark || 
        (!forceLight && Theme.of(context).brightness == Brightness.dark);
    
    return Image.asset(
      isDark 
          ? 'assets/images/pavo_logo_white.png'
          : 'assets/images/pavo_logo.png',
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
}

class PavoLogoSmall extends StatelessWidget {
  final double size;
  final bool forceLight;
  final bool forceDark;

  const PavoLogoSmall({
    super.key,
    this.size = 40,
    this.forceLight = false,
    this.forceDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = forceDark || 
        (!forceLight && Theme.of(context).brightness == Brightness.dark);
    
    return Image.asset(
      isDark 
          ? 'assets/images/pavo_logo_white.png'
          : 'assets/images/pavo_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}