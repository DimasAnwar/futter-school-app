import 'package:bestpractice/dashboard/pages/widgets/dashboard_widgets.dart';
import 'package:bestpractice/services/auth_services.dart';
import 'package:flutter/material.dart';

class ParentDashboardPage extends StatelessWidget {
  const ParentDashboardPage({super.key, required this.fullName});

  final String fullName;

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
              roleLabel: 'Orang Tua / Wali',
              onLogout: () => AuthServices().logoutAkun(),
            ),
            const SizedBox(height: 24),
            const WelcomeBanner(
              title: 'Pantau perkembangan anak',
              subtitle: 'Lihat aktivitas akademik terbaru hari ini.',
              icon: Icons.family_restroom_rounded,
            ),
            const SizedBox(height: 22),
            const Text('Ringkasan Akademik Anak', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 126,
              child: Row(
                children: const [
                  Expanded(child: SummaryCard(label: 'Mata kuliah', value: '4', icon: Icons.menu_book_rounded, color: Color(0xFF2563EB))),
                  SizedBox(width: 10),
                  Expanded(child: SummaryCard(label: 'Tugas aktif', value: '2', icon: Icons.assignment_late_rounded, color: Color(0xFFF59E0B))),
                  SizedBox(width: 10),
                  Expanded(child: SummaryCard(label: 'Rata-rata nilai', value: '86', icon: Icons.insights_rounded, color: Color(0xFF10B981))),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text('Menu Cepat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.7,
              children: const [
                ActionTile(title: 'Perkembangan', icon: Icons.trending_up_rounded, color: Color(0xFF2563EB)),
                ActionTile(title: 'Tugas anak', icon: Icons.assignment_rounded, color: Color(0xFFF59E0B)),
                ActionTile(title: 'Jadwal', icon: Icons.calendar_month_rounded, color: Color(0xFF8B5CF6)),
                ActionTile(title: 'Nilai anak', icon: Icons.grade_rounded, color: Color(0xFF10B981)),
              ],
            ),
            const SizedBox(height: 22),
            const Text('Aktivitas Terbaru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              leading: const CircleAvatar(child: Icon(Icons.notifications_active_outlined)),
              title: const Text('Tugas Basis Data telah dikumpulkan'),
              subtitle: const Text('Kemarin, 15:30 WIB'),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
