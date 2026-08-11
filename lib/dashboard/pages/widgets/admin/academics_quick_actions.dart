import 'package:flutter/material.dart';

class AcademicsQuickActions extends StatelessWidget {
  const AcademicsQuickActions({
    super.key,
    required this.onOpenAssignDosen,
    required this.onOpenAssignSiswa,
    required this.onOpenBuatPengumuman,
    required this.onOpenTambahMatkul,
  });

  final VoidCallback onOpenAssignDosen;
  final VoidCallback onOpenAssignSiswa;
  final VoidCallback onOpenBuatPengumuman;
  final VoidCallback onOpenTambahMatkul;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _QuickActionItemCard(
          icon: Icons.person_add_alt_1_rounded,
          iconBg: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF2563EB),
          title: 'Assign Dosen',
          subtitle: 'Tetapkan Dosen',
          onTap: onOpenAssignDosen,
        ),
        _QuickActionItemCard(
          icon: Icons.group_add_rounded,
          iconBg: const Color(0xFFECFDF5),
          iconColor: const Color(0xFF059669),
          title: 'Assign Siswa',
          subtitle: 'Daftarkan Siswa',
          onTap: onOpenAssignSiswa,
        ),
        _QuickActionItemCard(
          icon: Icons.campaign_rounded,
          iconBg: const Color(0xFFFEF3C7),
          iconColor: const Color(0xFFD97706),
          title: 'Pengumuman',
          subtitle: 'Kirim ke Semua',
          onTap: onOpenBuatPengumuman,
        ),
        _QuickActionItemCard(
          icon: Icons.add_box_rounded,
          iconBg: const Color(0xFFF3E8FF),
          iconColor: const Color(0xFF9333EA),
          title: 'Tambah Matkul',
          subtitle: 'Buat Baru',
          onTap: onOpenTambahMatkul,
        ),
      ],
    );
  }
}

class _QuickActionItemCard extends StatelessWidget {
  const _QuickActionItemCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
