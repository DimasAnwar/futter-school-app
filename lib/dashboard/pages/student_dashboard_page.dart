import 'package:bestpractice/dashboard/pages/widgets/dashboard_widgets.dart';
import 'package:bestpractice/services/auth_services.dart';
import 'package:flutter/material.dart';

class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({super.key, required this.fullName});

  final String fullName;

  @override
  Widget build(BuildContext context) {
    return RoleDashboard(
      fullName: fullName,
      roleLabel: 'Student',
      bannerTitle: 'Siap belajar hari ini?',
      bannerSubtitle: 'Jangan lupa cek tugas dan materi terbaru.',
      bannerIcon: Icons.school_rounded,
      summaries: const [
        ('4', 'Mata kuliah', Icons.menu_book_rounded, Color(0xFF2563EB)),
        ('2', 'Tugas aktif', Icons.assignment_rounded, Color(0xFFF59E0B)),
        ('86', 'Rata-rata nilai', Icons.grade_rounded, Color(0xFF10B981)),
      ],
      actions: const [
        ('Mata kuliah', Icons.auto_stories_rounded, Color(0xFF2563EB)),
        ('Tugas', Icons.assignment_rounded, Color(0xFFF59E0B)),
        ('Materi', Icons.folder_copy_rounded, Color(0xFF8B5CF6)),
        ('Nilai', Icons.bar_chart_rounded, Color(0xFF10B981)),
      ],
      activityTitle: 'Tugas terdekat',
      activity: 'Pemrograman Mobile - dikumpulkan besok',
    );
  }
}

class RoleDashboard extends StatelessWidget {
  const RoleDashboard({
    required this.fullName,
    required this.roleLabel,
    required this.bannerTitle,
    required this.bannerSubtitle,
    required this.bannerIcon,
    required this.summaries,
    required this.actions,
    required this.activityTitle,
    required this.activity,
  });

  final String fullName;
  final String roleLabel;
  final String bannerTitle;
  final String bannerSubtitle;
  final IconData bannerIcon;
  final List<(String, String, IconData, Color)> summaries;
  final List<(String, IconData, Color)> actions;
  final String activityTitle;
  final String activity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            DashboardHeader(
              name: fullName,
              roleLabel: roleLabel,
              onLogout: () => AuthServices().logoutAkun(),
            ),
            const SizedBox(height: 24),
            WelcomeBanner(title: bannerTitle, subtitle: bannerSubtitle, icon: bannerIcon),
            const SizedBox(height: 22),
            const Text('Ringkasan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 126,
              child: Row(
                children: [
                  for (final item in summaries) ...[
                    Expanded(child: SummaryCard(label: item.$2, value: item.$1, icon: item.$3, color: item.$4)),
                    if (item != summaries.last) const SizedBox(width: 10),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text('Menu cepat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.7,
              children: [for (final item in actions) ActionTile(title: item.$1, icon: item.$2, color: item.$3)],
            ),
            const SizedBox(height: 22),
            Text(activityTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              leading: const CircleAvatar(child: Icon(Icons.notifications_active_outlined)),
              title: Text(activity),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
