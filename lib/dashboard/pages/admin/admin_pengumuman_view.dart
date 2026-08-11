import 'package:bestpractice/dashboard/pages/widgets/admin/admin_header.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/card_container.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/custom_buttons.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/empty_state.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/section_header.dart';
import 'package:bestpractice/services/admin_services.dart';
import 'package:flutter/material.dart';

class AdminPengumumanView extends StatefulWidget {
  const AdminPengumumanView({
    super.key,
    required this.onOpenBuatPengumuman,
    required this.onShowNotification,
    required this.onShowToast,
  });

  final VoidCallback onOpenBuatPengumuman;
  final VoidCallback onShowNotification;
  final Function(String message, {bool isError}) onShowToast;

  @override
  State<AdminPengumumanView> createState() => _AdminPengumumanViewState();
}

class _AdminPengumumanViewState extends State<AdminPengumumanView> {
  final AdminServices _adminServices = AdminServices();
  late final Stream<List<Map<String, dynamic>>> _announcementsStream;

  @override
  void initState() {
    super.initState();
    _announcementsStream = _adminServices.getAnnouncementsStream();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // Header
        AdminHeader(onNotificationTap: widget.onShowNotification),
        const SizedBox(height: 20),

        // Section Header
        const SectionHeader(
          title: 'Pengumuman Global',
          subtitle: 'Daftar pengumuman dan informasi resmi untuk seluruh pengguna.',
        ),

        // Create Announcement Button
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            label: 'Buat Pengumuman Baru',
            icon: Icons.campaign_rounded,
            onPressed: widget.onOpenBuatPengumuman,
          ),
        ),

        const SizedBox(height: 20),

        // Realtime Stream of Announcements
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: _announcementsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: CardContainer(
                  child: Column(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 36, color: Color(0xFF3B82F6)),
                      const SizedBox(height: 10),
                      const Text(
                        'Belum dapat memuat pengumuman realtime.',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              );
            }

            final rawList = snapshot.data ?? [];
            final uniqueMap = <String, Map<String, dynamic>>{};
            for (final item in rawList) {
              final id = item['id'] as String? ?? '';
              if (id.isNotEmpty) {
                uniqueMap[id] = item;
              } else {
                uniqueMap['${item['judul']}_${item['created_at']}'] = item;
              }
            }
            final announcements = uniqueMap.values.toList();

            if (announcements.isEmpty) {
              return const EmptyStateWidget(
                message: 'Belum ada pengumuman. Klik "Buat Pengumuman Baru" di atas untuk mengirim pengumuman.',
                padding: EdgeInsets.symmetric(vertical: 36),
              );
            }

            return Column(
              children: announcements.map((item) {
                final id = item['id'] as String? ?? '';
                final title = item['judul'] as String? ?? 'Pengumuman';
                final body = item['isi'] as String? ?? '';
                final isUrgent = item['is_urgent'] as bool? ?? false;
                final createdAtRaw = item['created_at'] as String?;
                final formattedDate = _formatDate(createdAtRaw);

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: CardContainer(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isUrgent ? const Color(0xFFFEE2E2) : const Color(0xFFEFF6FF),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isUrgent ? Icons.priority_high_rounded : Icons.campaign_rounded,
                                color: isUrgent ? const Color(0xFFEF4444) : const Color(0xFF2563EB),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                      ),
                                      if (isUrgent) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEE2E2),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'URGENT',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFEF4444),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                              onPressed: () => _confirmDelete(context, id, title),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Color(0xFFF1F5F9), height: 1),
                        const SizedBox(height: 12),
                        Text(
                          body,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF334155),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),

        const SizedBox(height: 80),
      ],
    );
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return 'Baru saja';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      final month = months[dt.month - 1];
      final minute = dt.minute.toString().padLeft(2, '0');
      final hour = dt.hour.toString().padLeft(2, '0');
      return '${dt.day} $month ${dt.year} • $hour:$minute';
    } catch (_) {
      return raw;
    }
  }

  void _confirmDelete(BuildContext context, String id, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Pengumuman'),
        content: Text('Apakah Anda yakin ingin menghapus pengumuman "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _adminServices.deleteAnnouncement(id);
                widget.onShowToast('Pengumuman berhasil dihapus.');
              } catch (e) {
                widget.onShowToast('Gagal menghapus pengumuman: $e', isError: true);
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
