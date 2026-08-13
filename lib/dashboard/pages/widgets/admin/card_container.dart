import 'package:flutter/material.dart';

class CardContainer extends StatelessWidget {
  const CardContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.borderRadius = 20,
    this.borderColor = const Color(0xFFF1F5F9),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? const Color(0xFF1E294D) : Colors.white;
    final defaultBorder = isDark ? const Color(0xFF2563EB).withValues(alpha: 0.35) : const Color(0xFFF1F5F9);
    final effectiveBorder = borderColor == const Color(0xFFF1F5F9) ? defaultBorder : borderColor;

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: defaultBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: effectiveBorder),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
