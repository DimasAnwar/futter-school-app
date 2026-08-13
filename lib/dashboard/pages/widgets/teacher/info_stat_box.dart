import 'package:flutter/material.dart';

class InfoStatBox extends StatelessWidget {
  const InfoStatBox({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final boxBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final boxBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final valueColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final labelColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: boxBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: boxBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: valueColor),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: labelColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
