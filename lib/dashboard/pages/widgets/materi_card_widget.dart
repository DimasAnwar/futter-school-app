import 'package:bestpractice/dashboard/pages/widgets/admin/card_container.dart';
import 'package:flutter/material.dart';

class MateriCardWidget extends StatelessWidget {
  const MateriCardWidget({
    super.key,
    required this.materi,
    this.role = 'student',
    this.onTapCard,
    this.onEdit,
    this.onDelete,
  });

  final Map<String, dynamic> materi;
  final String role; // 'student' or 'teacher'
  final VoidCallback? onTapCard;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final judul = (materi['judul_materi'] as String?) ?? (materi['judul'] as String?) ?? 'Materi Perkuliahan';
    final deskripsi = (materi['deskripsi'] as String?) ?? '-';
    final fileUrl = (materi['file_url'] as String?) ?? (materi['link_materi'] as String?) ?? '';
    final hasFile = fileUrl.trim().isNotEmpty;

    // Course info
    String mkLabel = '';
    if (materi['mata_kuliah'] is Map) {
      final mk = materi['mata_kuliah'] as Map<String, dynamic>;
      final n = (mk['nama_mk'] as String?) ?? (mk['nama'] as String?) ?? '';
      final k = (mk['kode_mk'] as String?) ?? (mk['kode'] as String?) ?? '';
      if (n.isNotEmpty) {
        mkLabel = k.isNotEmpty ? '$n ($k)' : n;
      }
    } else if (materi['nama_mk'] != null) {
      mkLabel = materi['nama_mk'].toString();
    }

    return InkWell(
      onTap: onTapCard,
      borderRadius: BorderRadius.circular(16),
      child: CardContainer(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: Color(0xFF8B5CF6),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (mkLabel.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            mkLabel,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2563EB),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        judul,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (role == 'teacher' && (onEdit != null || onDelete != null)) ...[
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, color: Color(0xFF2563EB), size: 20),
                      onPressed: onEdit,
                      tooltip: 'Edit Materi',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                      onPressed: onDelete,
                      tooltip: 'Hapus Materi',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                ] else
                  const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              deskripsi,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (hasFile) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.attach_file_rounded, size: 14, color: Color(0xFF8B5CF6)),
                    SizedBox(width: 6),
                    Text(
                      'File / Link Lampiran Tersedia',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
