import 'package:bestpractice/common/widgets/skeleton_item.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/card_container.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/empty_state.dart';
import 'package:bestpractice/services/admin_services.dart';
import 'package:flutter/material.dart';

class AnnouncementSlider extends StatefulWidget {
  const AnnouncementSlider({
    super.key,
    required this.onOpenPengumuman,
  });

  final VoidCallback onOpenPengumuman;

  @override
  State<AnnouncementSlider> createState() => _AnnouncementSliderState();
}

class _AnnouncementSliderState extends State<AnnouncementSlider> {
  final AdminServices _adminServices = AdminServices();
  final PageController _pageController = PageController();
  late final Stream<List<Map<String, dynamic>>> _announcementsStream;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _announcementsStream = _adminServices.getAnnouncementsStream();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pengumuman Terbaru',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            TextButton(
              onPressed: widget.onOpenPengumuman,
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Realtime Stream of Announcements
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: _announcementsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SkeletonItem(
                width: double.infinity,
                height: 140,
                borderRadius: 16,
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
                message: 'Belum ada pengumuman global.',
                padding: EdgeInsets.symmetric(vertical: 24),
              );
            }

            return Column(
              children: [
                SizedBox(
                  height: 160,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: announcements.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      final item = announcements[index];
                      final title = item['judul'] as String? ?? 'Pengumuman';
                      final body = item['isi'] as String? ?? '';
                      final isUrgent = item['is_urgent'] as bool? ?? false;
                      final rawDate = item['created_at'] as String?;
                      final formattedDate = _formatDate(rawDate);

                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: CardContainer(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isUrgent
                                          ? (isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2))
                                          : (isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF)),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isUrgent
                                          ? Icons.priority_high_rounded
                                          : Icons.campaign_rounded,
                                      color: isUrgent
                                          ? const Color(0xFFEF4444)
                                          : const Color(0xFF2563EB),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          formattedDate,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isUrgent) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2),
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
                              const SizedBox(height: 10),
                              Divider(color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9), height: 1),
                              const SizedBox(height: 10),
                              Expanded(
                                child: Text(
                                  body,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                                    height: 1.35,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                if (announcements.length > 1) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      announcements.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _currentPage == index ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color(0xFF2563EB)
                              : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
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
}
