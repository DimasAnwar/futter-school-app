import 'package:bestpractice/dashboard/pages/widgets/admin/card_container.dart';
import 'package:flutter/material.dart';

class CourseCardWidget extends StatelessWidget {
  const CourseCardWidget({
    super.key,
    required this.course,
    this.role = 'student',
    this.materiCount,
    this.tugasCount,
    this.enrolledStudentsCount,
    this.onTapCard,
    this.onUploadMateri,
    this.onAssignTugas,
    this.onShowStudents,
  });

  final Map<String, dynamic> course;
  final String role; // 'student' or 'teacher'
  final int? materiCount;
  final int? tugasCount;
  final int? enrolledStudentsCount;
  final VoidCallback? onTapCard;
  final VoidCallback? onUploadMateri;
  final VoidCallback? onAssignTugas;
  final VoidCallback? onShowStudents;

  @override
  Widget build(BuildContext context) {
    final namaMk = (course['nama_mk'] as String?) ?? (course['nama'] as String?) ?? 'Mata Kuliah';
    final kodeMk = (course['kode_mk'] as String?) ?? (course['kode'] as String?) ?? '-';
    final sks = course['sks']?.toString() ?? '3';
    final semester = course['semester']?.toString() ?? '1';

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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.class_rounded, color: Color(0xFF2563EB), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        namaMk,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        role == 'teacher'
                            ? 'Kode: $kodeMk • $sks SKS • Semester $semester'
                            : 'Kode: $kodeMk • $sks SKS',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.folder_copy_rounded, size: 16, color: Color(0xFF8B5CF6)),
                  const SizedBox(width: 6),
                  Text(
                    '${materiCount ?? 0} Modul Materi',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(width: 1, height: 16, color: const Color(0xFFCBD5E1)),
                  const SizedBox(width: 16),
                  const Icon(Icons.assignment_rounded, size: 16, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 6),
                  Text(
                    '${tugasCount ?? 0} Tugas Kuliah',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
            if (role == 'teacher' && (onUploadMateri != null || onAssignTugas != null || onShowStudents != null)) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (onUploadMateri != null)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF8B5CF6),
                          side: const BorderSide(color: Color(0xFF8B5CF6)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: onUploadMateri,
                        icon: const Icon(Icons.cloud_upload_rounded, size: 14),
                        label: const Text('Materi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    if (onAssignTugas != null) ...[
                      const SizedBox(width: 6),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2563EB),
                          side: const BorderSide(color: Color(0xFF2563EB)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: onAssignTugas,
                        icon: const Icon(Icons.add_task_rounded, size: 14),
                        label: const Text('Tugas', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                    if (onShowStudents != null) ...[
                      const SizedBox(width: 6),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF059669),
                          side: const BorderSide(color: Color(0xFF059669)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: onShowStudents,
                        icon: const Icon(Icons.people_alt_rounded, size: 14),
                        label: Text(
                          '${enrolledStudentsCount ?? 0} Siswa',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
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
