import 'package:bestpractice/dashboard/pages/widgets/admin/card_container.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/stat_card.dart';
import 'package:bestpractice/dashboard/pages/widgets/announcement_slider_widget.dart';
import 'package:bestpractice/dashboard/pages/widgets/teacher/quick_action_tile.dart';
import 'package:bestpractice/dashboard/pages/widgets/teacher/role_badge.dart';
import 'package:bestpractice/services/auth_services.dart';
import 'package:flutter/material.dart';

class TeacherHomeView extends StatelessWidget {
  const TeacherHomeView({
    super.key,
    required this.fullName,
    required this.courseCount,
    required this.totalStudentsCount,
    required this.materiCount,
    required this.tugasCount,
    this.announcements = const [],
    required this.onRefresh,
    required this.onOpenAcademicsTab,
    required this.onShowToast,
  });

  final String fullName;
  final int courseCount;
  final int totalStudentsCount;
  final int materiCount;
  final int tugasCount;
  final List<Map<String, dynamic>> announcements;
  final Future<void> Function() onRefresh;
  final Function(int subTabIndex) onOpenAcademicsTab;
  final Function(String message, {bool isError}) onShowToast;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Header Row with Profile & Logout
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFDCE8FF),
                child: Text(
                  fullName.isEmpty ? 'D' : fullName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, $fullName',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const RoleBadge(role: 'Dosen / Pengampu'),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => onShowToast('Tidak ada notifikasi baru.'),
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF64748B),
                ),
                tooltip: 'Notifikasi',
              ),
              IconButton(
                onPressed: () async {
                  await AuthServices().logoutAkun();
                },
                icon: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFEF4444),
                ),
                tooltip: 'Logout',
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Welcome Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kelola kelas & pembelajaran',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Pantau materi, assign tugas, dan berikan nilai siswa.',
                        style: TextStyle(color: Color(0xFFDCE8FF)),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.cast_for_education_rounded, color: Colors.white, size: 48),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // --- PENGUMUMAN CAROUSEL SLIDER ---
          const Row(
            children: [
              Icon(Icons.campaign_rounded, color: Color(0xFFF59E0B), size: 22),
              SizedBox(width: 8),
              Text(
                'Pengumuman Kampus',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnnouncementSliderWidget(
            announcements: announcements,
            emptyMessage: 'Informasi penting pengajaran akan muncul di sini.',
          ),

          const SizedBox(height: 24),

          // Section Title
          const Text(
            'Statistik Pengajaran',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),

          // Primary Stat Cards (2 Columns)
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.class_rounded,
                  value: '$courseCount',
                  label: 'Total Matkul',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.groups_rounded,
                  value: '$totalStudentsCount',
                  label: 'Jumlah Siswa',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.folder_copy_rounded,
                  value: '$materiCount',
                  label: 'Total Materi',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.assignment_rounded,
                  value: '$tugasCount',
                  label: 'Total Tugas',
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Menu Cepat / Quick Actions
          CardContainer(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Menu Cepat Dosen',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.6,
                  children: [
                    QuickActionTile(
                      title: 'Kelola Kelas',
                      subtitle: '$courseCount Matkul Aktif',
                      icon: Icons.class_rounded,
                      color: const Color(0xFF2563EB),
                      onTap: () => onOpenAcademicsTab(0),
                    ),
                    QuickActionTile(
                      title: 'Upload Materi',
                      subtitle: 'Bagikan Modul/File',
                      icon: Icons.upload_file_rounded,
                      color: const Color(0xFF8B5CF6),
                      onTap: () => onOpenAcademicsTab(1),
                    ),
                    QuickActionTile(
                      title: 'Assign Tugas',
                      subtitle: 'Buat Tugas Baru',
                      icon: Icons.add_task_rounded,
                      color: const Color(0xFFF59E0B),
                      onTap: () => onOpenAcademicsTab(2),
                    ),
                    QuickActionTile(
                      title: 'Beri Nilai',
                      subtitle: 'Penilaian Siswa',
                      icon: Icons.fact_check_rounded,
                      color: const Color(0xFF10B981),
                      onTap: () => onOpenAcademicsTab(3),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
