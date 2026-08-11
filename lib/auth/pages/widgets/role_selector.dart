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
    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1FF),
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
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
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
                    color: isSelected ? Colors.black : Colors.black54,
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
