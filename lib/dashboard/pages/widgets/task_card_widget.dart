import 'package:bestpractice/dashboard/pages/widgets/admin/card_container.dart';
import 'package:flutter/material.dart';

class TaskCardWidget extends StatelessWidget {
  const TaskCardWidget({
    super.key,
    required this.tugas,
    this.submission,
    this.role = 'student',
    this.onTapCard,
    this.onPrimaryAction,
    this.primaryActionLabel,
    this.primaryActionIcon,
    this.onEdit,
    this.onDelete,
    this.onGrade,
    this.gradedCount,
    this.totalStudentsCount,
    this.showEvaluationDetails = true,
  });

  final Map<String, dynamic> tugas;
  final Map<String, dynamic>? submission;
  final String role; // 'student' or 'teacher'
  final VoidCallback? onTapCard;
  final VoidCallback? onPrimaryAction;
  final String? primaryActionLabel;
  final IconData? primaryActionIcon;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onGrade;
  final int? gradedCount;
  final int? totalStudentsCount;
  final bool showEvaluationDetails;

  String _formatDeadline(String raw) {
    final str = raw.trim();
    if (str.isEmpty || str == 'Tidak ada deadline') {
      return 'Tidak ada batas waktu';
    }

    final dt = DateTime.tryParse(str);
    if (dt == null) {
      return str;
    }

    final local = dt.toLocal();
    final dayNames = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final monthNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];

    final dayName = dayNames[local.weekday - 1];
    final day = local.day.toString().padLeft(2, '0');
    final month = monthNames[local.month - 1];
    final year = local.year;
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$dayName, $day $month $year • $hour:$minute WIB';
  }

  String? _getRemainingBadge(String raw) {
    final dt = DateTime.tryParse(raw.trim());
    if (dt == null) return null;

    final now = DateTime.now();
    final diff = dt.difference(now);

    if (diff.isNegative) {
      return 'Tenggat Lewat';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} Hari Lagi';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} Jam Lagi';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} Mnt Lagi';
    } else {
      return 'Segera Berakhir';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final descColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);
    final courseBadgeBg = isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF);
    final courseBadgeText = isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB);
    final deadlineBg = isDark ? const Color(0xFF451A03).withValues(alpha: 0.6) : const Color(0xFFFFFBEB);
    final deadlineBorder = isDark ? const Color(0xFF78350F) : const Color(0xFFFDE68A);
    final deadlineText = isDark ? const Color(0xFFFDE047) : const Color(0xFFB45309);

    final judulTugas = (tugas['judul_tugas'] as String?) ?? (tugas['judul'] as String?) ?? 'Tugas Kuliah';
    final deskripsi = tugas['deskripsi'] as String? ?? 'Tidak ada deskripsi.';
    final deadline = tugas['deadline'] as String? ?? 'Tidak ada deadline';

    final courseMap = tugas['mata_kuliah'] as Map<String, dynamic>?;
    final namaMatkul = courseMap?['nama_mk'] as String? ?? 'Mata Kuliah';
    final kodeMatkul = courseMap?['kode_mk'] as String? ?? '-';
    final courseBadgeStr = kodeMatkul != '-' ? '$namaMatkul ($kodeMatkul)' : namaMatkul;

    final nilai = submission?['nilai'];
    final isGraded = submission != null && (submission!['status'] == 'graded' || nilai != null);
    final isSubmitted = submission != null;
    final catatanDosen = submission?['catatan_dosen'] as String? ?? '';

    final remainingBadgeStr = _getRemainingBadge(deadline);

    return InkWell(
      onTap: onTapCard,
      borderRadius: BorderRadius.circular(16),
      child: CardContainer(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Subject Pill Badge & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: courseBadgeBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      courseBadgeStr,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: courseBadgeText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (role == 'teacher')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.assignment_rounded, size: 12, color: isDark ? const Color(0xFFFDE047) : const Color(0xFFD97706)),
                        const SizedBox(width: 4),
                        Text(
                          'TUGAS AKTIF',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFFFDE047) : const Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isGraded
                          ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5))
                          : (isSubmitted
                              ? (isDark ? const Color(0xFF075985) : const Color(0xFFE0F2FE))
                              : (isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7))),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isGraded
                              ? Icons.stars_rounded
                              : (isSubmitted ? Icons.check_circle_rounded : Icons.pending_actions_rounded),
                          size: 12,
                          color: isGraded
                              ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF059669))
                              : (isSubmitted
                                  ? (isDark ? const Color(0xFF7DD3FC) : const Color(0xFF0284C7))
                                  : (isDark ? const Color(0xFFFDE047) : const Color(0xFFD97706))),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isGraded
                              ? 'Sudah Dinilai'
                              : (isSubmitted ? 'Sudah Dikumpulkan' : 'Belum Dikumpulkan'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isGraded
                                ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF059669))
                                : (isSubmitted
                                    ? (isDark ? const Color(0xFF7DD3FC) : const Color(0xFF0284C7))
                                    : (isDark ? const Color(0xFFFDE047) : const Color(0xFFD97706))),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Task Title
            Text(
              judulTugas,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 4),

            // Instruction Excerpt
            Text(
              deskripsi,
              style: TextStyle(fontSize: 12, color: descColor, height: 1.4),
              maxLines: onTapCard != null ? 2 : null,
              overflow: onTapCard != null ? TextOverflow.ellipsis : null,
            ),
            const SizedBox(height: 12),

            // Professional Deadline Container with Easy-to-Read Date Format & Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: deadlineBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: deadlineBorder, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule_rounded, size: 16, color: deadlineText),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DEADLINE PENGERJAAN',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: deadlineText.withValues(alpha: 0.8),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          _formatDeadline(deadline),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: deadlineText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (remainingBadgeStr != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: deadlineText.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        remainingBadgeStr,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: deadlineText,
                        ),
                      ),
                    ),
                  ],
                  if (role == 'teacher') ...[
                    if (onEdit != null)
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF2563EB)),
                        tooltip: 'Edit Tugas',
                      ),
                    if (onDelete != null) ...[
                      const SizedBox(width: 6),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                        tooltip: 'Hapus Tugas',
                      ),
                    ],
                  ],
                ],
              ),
            ),

            // Graded Score / Feedback Card for Student
            if (showEvaluationDetails && isGraded && role == 'student') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.5) : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? const Color(0xFF047857) : const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF047857) : const Color(0xFF059669),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          const Text('NILAI', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white70)),
                          Text(
                            '${nilai ?? '-'}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hasil Evaluasi Dosen',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            catatanDosen.isNotEmpty ? catatanDosen : 'Tidak ada catatan tambahan dari dosen.',
                            style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF047857), height: 1.3),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Teacher Action Footer (Beri Nilai & Student Count)
            if (role == 'teacher' && onGrade != null) ...[
              const SizedBox(height: 14),
              Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sudah Dinilai: ${gradedCount ?? 0} / ${totalStudentsCount ?? 0} Siswa',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF059669),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: onGrade,
                    icon: const Icon(Icons.fact_check_rounded, size: 16),
                    label: const Text('Beri Nilai', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ],

            // Student Action Button Footer
            if (role == 'student' && onPrimaryAction != null) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isGraded
                        ? const Color(0xFF059669)
                        : (isSubmitted ? const Color(0xFF0284C7) : const Color(0xFF2563EB)),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: onPrimaryAction,
                  icon: Icon(
                    primaryActionIcon ??
                        (isGraded
                            ? Icons.star_rounded
                            : (isSubmitted ? Icons.edit_note_rounded : Icons.assignment_turned_in_rounded)),
                    size: 18,
                  ),
                  label: Text(
                    primaryActionLabel ??
                        (isGraded
                            ? 'Lihat Detail Penilaian'
                            : (isSubmitted ? 'Edit Jawaban Tugas' : 'Kerjakan Tugas Sekarang')),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
