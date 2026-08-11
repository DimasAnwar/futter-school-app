import 'package:flutter/material.dart';

class SubPageHeader extends StatelessWidget {
  const SubPageHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.trailing,
    this.isTitleBrand = false,
  });

  final String title;
  final VoidCallback onBack;
  final Widget? trailing;
  final bool isTitleBrand;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: isTitleBrand ? FontWeight.w800 : FontWeight.bold,
            color: isTitleBrand ? const Color(0xFF2563EB) : const Color(0xFF0F172A),
          ),
        ),
        const Spacer(),
        if (trailing case final t?) t,
      ],
    );
  }
}
