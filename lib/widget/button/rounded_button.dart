import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool fullWidth;
  final bool isLoading;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double minHeight;
  final double iconSize;
  final double gap;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? disabledTextColor;
  final TextStyle? textStyle;

  /// Balikkan skema warna saat dark (dark<->light)
  final bool invertOnDark;

  /// (opsional) paksa status dark untuk preview/storybook
  final bool? isDarkOverride;

  const RoundedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.fullWidth = true,
    this.isLoading = false,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    this.radius = 12,
    this.minHeight = 48,
    this.iconSize = 20,
    this.gap = 8,
    this.backgroundColor,
    this.textColor,
    this.disabledTextColor,
    this.textStyle,
    this.invertOnDark = false,
    this.isDarkOverride,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = isDarkOverride ?? theme.brightness == Brightness.dark;

    // Palet default yang kamu mau (konstan):
    const lightBg = Color(0xFFFAFAFA);
    const darkBg = Color.fromARGB(255, 30, 30, 30);
    const lightFg = Color(0xFFFAFAFA);
    const darkFg = Color(0xFF0A0A0A);

    // Logika: pakai bg gelap ketika (isDark != invertOnDark)
    final useDarkBg = isDark != invertOnDark;

    // Pakai override kalau disuplai; kalau tidak, ikut aturan di atas
    final Color bg = backgroundColor ?? (useDarkBg ? darkBg : lightBg);
    final Color fg = textColor ?? (useDarkBg ? lightFg : darkFg);

    final style = ElevatedButton.styleFrom(
      padding: padding,
      minimumSize: Size(fullWidth ? double.infinity : 0, minHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
    ).copyWith(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return bg.withOpacity(0.12);
        return bg;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return (disabledTextColor ?? fg.withOpacity(0.38));
        }
        return fg;
      }),
      // jangan taruh warna di textStyle supaya nggak nimpuk foregroundColor
      textStyle:
          textStyle != null
              ? WidgetStatePropertyAll(textStyle)
              : const WidgetStatePropertyAll(
                TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
    );

    final child =
        isLoading
            ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: fg),
            )
            : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: Center(child: icon),
                  ),
                  SizedBox(width: gap),
                ],
                Text(label),
              ],
            );

    final btn = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: child,
    );

    return fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}
