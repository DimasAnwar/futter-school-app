import 'package:bestpractice/services/auth_services.dart';
import 'package:flutter/material.dart';

class AdminHeader extends StatelessWidget {
  const AdminHeader({
    super.key,
    required this.onNotificationTap,
    this.showLogout = true,
  });

  final VoidCallback onNotificationTap;
  final bool showLogout;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: Color(0xFF2563EB),
          child: Icon(Icons.person, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 10),
        const Text(
          'EduSchool',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2563EB),
          ),
        ),
        const Spacer(),
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFEFF6FF),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: onNotificationTap,
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF2563EB),
              size: 22,
            ),
          ),
        ),
        if (showLogout) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => AuthServices().logoutAkun(),
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF64748B)),
          ),
        ],
      ],
    );
  }
}
