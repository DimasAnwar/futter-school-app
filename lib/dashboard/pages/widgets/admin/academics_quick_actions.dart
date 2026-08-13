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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);

    Color getDarkIconBg(Color lightBg) {
      if (lightBg == const Color(0xFFEFF6FF)) return const Color(0xFF1E3A8A);
      if (lightBg == const Color(0xFFECFDF5)) return const Color(0xFF064E3B);
      if (lightBg == const Color(0xFFFEF3C7)) return const Color(0xFF78350F);
      if (lightBg == const Color(0xFFF3E8FF)) return const Color(0xFF581C87);
      return isDark ? const Color(0xFF1E3A8A) : lightBg;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorder),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.02),
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
                color: isDark ? getDarkIconBg(iconBg) : iconBg,
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: titleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: subtitleColor),
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
