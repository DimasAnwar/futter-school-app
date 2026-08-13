import 'package:bestpractice/common/utils/ui_utils.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/card_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StudentMateriDetailPage extends StatelessWidget {
  const StudentMateriDetailPage({
    super.key,
    required this.materi,
  });

  final Map<String, dynamic> materi;

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'Tanggal tidak tersedia';
    try {
      final dt = DateTime.parse(rawDate);
      return '${dt.day}/${dt.month}/${dt.year} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} WIB';
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final judulMateri = (materi['judul_materi'] as String?) ?? (materi['judul'] as String?) ?? 'Materi Perkuliahan';
    final rawDeskripsi = (materi['deskripsi'] as String?) ??
        (materi['isi_materi'] as String?) ??
        (materi['pembahasan'] as String?) ??
        (materi['content'] as String?);
    final deskripsi = (rawDeskripsi != null && rawDeskripsi.trim().isNotEmpty)
        ? rawDeskripsi.trim()
        : 'Tidak ada deskripsi/pembahasan tertulis untuk materi ini.';
    final fileUrl = (materi['file_url'] as String?) ?? (materi['link_file'] as String?) ?? (materi['berkas'] as String?) ?? '';
    final createdAt = materi['created_at'] as String? ?? materi['tanggal'] as String?;

    final courseMap = materi['mata_kuliah'] as Map<String, dynamic>?;
    final namaMatkul = courseMap?['nama_mk'] as String? ?? 'Mata Kuliah';
    final kodeMatkul = courseMap?['kode_mk'] as String? ?? '-';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Detail Materi Perkuliahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0.5,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course & Material Title Banner Card
              CardContainer(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$namaMatkul ($kodeMatkul)',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(createdAt),
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      judulMateri,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Material Description Card
              const Text(
                'Deskripsi & Pembahasan Materi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 10),
              CardContainer(
                padding: const EdgeInsets.all(16),
                child: Text(
                  deskripsi,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.6),
                ),
              ),

              const SizedBox(height: 20),

              // File Attachment Card & Download Actions
              if (fileUrl.isNotEmpty) ...[
                const Text(
                  'Berkas & Tautan Materi Dosen',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 10),
                CardContainer(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color(0xFFEFF6FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.description_rounded, color: Color(0xFF2563EB), size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'FILE / LINK MATERI',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    fileUrl,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: fileUrl));
                            UiUtils.showToast(context, 'Tautan materi telah disalin ke clipboard!');
                          },
                          icon: const Icon(Icons.content_copy_rounded, size: 18),
                          label: const Text('Salin Tautan Berkas Materi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
