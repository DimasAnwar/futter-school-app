import 'package:flutter/material.dart';

class RoleOption {
  final String label;
  final String roleKey;

  const RoleOption({required this.label, required this.roleKey});
}

class RoleSelector extends StatelessWidget {
  const RoleSelector({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onRoleSelected,
    this.height = 45,
  });

  final List<RoleOption> options;
  final int selectedIndex;
  final ValueChanged<int> onRoleSelected;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFEAF1FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(options.length, (index) {
          final isSelected = selectedIndex == index;
          final option = options[index];

          return Expanded(
            child: GestureDetector(
              onTap: () => onRoleSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? const Color(0xFF2563EB) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.3)
                                : Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  option.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: options.length > 3 ? 12 : 13,
                    color: isSelected
                        ? (isDark ? Colors.white : const Color(0xFF2563EB))
                        : (isDark ? const Color(0xFF94A3B8) : Colors.black54),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
