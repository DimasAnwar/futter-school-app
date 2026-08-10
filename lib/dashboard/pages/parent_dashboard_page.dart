import 'package:bestpractice/dashboard/pages/student_dashboard_page.dart';
import 'package:flutter/material.dart';

class ParentDashboardPage extends StatelessWidget {
  const ParentDashboardPage({super.key, required this.fullName});

  final String fullName;

  @override
  Widget build(BuildContext context) {
    return RoleDashboard(
      fullName: fullName,
      roleLabel: 'Parent',
      bannerTitle: 'Pantau perkembangan anak',
      bannerSubtitle: 'Lihat aktivitas akademik terbaru hari ini.',
      bannerIcon: Icons.family_restroom_rounded,
      summaries: const [
        ('4', 'Mata kuliah', Icons.menu_book_rounded, Color(0xFF2563EB)),
        ('2', 'Tugas aktif', Icons.assignment_late_rounded, Color(0xFFF59E0B)),
        ('86', 'Rata-rata nilai', Icons.insights_rounded, Color(0xFF10B981)),
      ],
      actions: const [
        ('Perkembangan', Icons.trending_up_rounded, Color(0xFF2563EB)),
        ('Tugas anak', Icons.assignment_rounded, Color(0xFFF59E0B)),
        ('Jadwal', Icons.calendar_month_rounded, Color(0xFF8B5CF6)),
        ('Nilai anak', Icons.grade_rounded, Color(0xFF10B981)),
      ],
      activityTitle: 'Aktivitas terbaru',
      activity: 'Tugas Basis Data sudah dikumpulkan',
    );
  }
}
