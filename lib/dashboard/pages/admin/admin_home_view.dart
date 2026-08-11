import 'package:bestpractice/dashboard/pages/widgets/admin/access_tile.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/admin_header.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/announcement_slider.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/card_container.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/section_header.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/stat_card.dart';
import 'package:flutter/material.dart';

class AdminHomeView extends StatelessWidget {
  const AdminHomeView({
    super.key,
    required this.studentCount,
    required this.teacherCount,
    required this.onRefresh,
    required this.onOpenPenugasan,
    required this.onOpenPengumuman,
    required this.onShowToast,
  });

  final int studentCount;
  final int teacherCount;
  final Future<void> Function() onRefresh;
  final Function(String participantType) onOpenPenugasan;
  final VoidCallback onOpenPengumuman;
  final Function(String message, {bool isError}) onShowToast;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Header Row
          AdminHeader(
            onNotificationTap: () => onShowToast('Tidak ada notifikasi baru.'),
          ),

          const SizedBox(height: 20),

          // Title Section
          const SectionHeader(
            title: 'Admin Dashboard',
            subtitle: 'Selamat datang kembali, kelola sistem dengan mudah.',
          ),

          // Stat Cards (2 Columns)
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.school_rounded,
                  value: '$studentCount',
                  label: 'Siswa Aktif',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: StatCard(
                  icon: Icons.workspace_premium_rounded,
                  value: '$teacherCount',
                  label: 'Dosen Aktif',
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Penugasan Akses Section
          CardContainer(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Penugasan Akses',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 14),
                AccessTile(
                  icon: Icons.person_add_alt_1_rounded,
                  title: 'Assign Dosen',
                  onTap: () => onOpenPenugasan('Dosen'),
                ),
                const SizedBox(height: 10),
                AccessTile(
                  icon: Icons.group_add_rounded,
                  title: 'Assign Siswa',
                  onTap: () => onOpenPenugasan('Siswa'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Horizontal Slider Pengumuman Terbaru
          AnnouncementSlider(
            onOpenPengumuman: onOpenPengumuman,
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
