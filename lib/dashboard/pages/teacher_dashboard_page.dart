import 'package:bestpractice/dashboard/pages/student_dashboard_page.dart';
import 'package:flutter/material.dart';

class TeacherDashboardPage extends StatelessWidget {
  const TeacherDashboardPage({super.key, required this.fullName});

  final String fullName;

  @override
  Widget build(BuildContext context) {
    return RoleDashboard(
      fullName: fullName,
      roleLabel: 'Teacher',
      bannerTitle: 'Kelola kelasmu dengan mudah',
      bannerSubtitle: 'Ada 12 pengumpulan tugas yang perlu diperiksa.',
      bannerIcon: Icons.cast_for_education_rounded,
      summaries: const [
        ('3', 'Kelas aktif', Icons.class_rounded, Color(0xFF2563EB)),
        ('12', 'Perlu dinilai', Icons.fact_check_rounded, Color(0xFFF59E0B)),
        ('98', 'Total siswa', Icons.groups_rounded, Color(0xFF10B981)),
      ],
      actions: const [
        ('Kelola kelas', Icons.class_rounded, Color(0xFF2563EB)),
        ('Buat tugas', Icons.add_task_rounded, Color(0xFFF59E0B)),
        ('Upload materi', Icons.upload_file_rounded, Color(0xFF8B5CF6)),
        ('Penilaian', Icons.rule_rounded, Color(0xFF10B981)),
      ],
      activityTitle: 'Butuh perhatian',
      activity: '12 tugas Pemrograman Mobile belum dinilai',
    );
  }
}
