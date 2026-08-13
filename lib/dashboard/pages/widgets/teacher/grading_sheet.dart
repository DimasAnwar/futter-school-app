import 'package:bestpractice/common/utils/ui_utils.dart';
import 'package:bestpractice/dashboard/pages/teacher/teacher_submission_detail_page.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/card_container.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/custom_buttons.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/custom_text_field.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/empty_state.dart';
import 'package:bestpractice/services/teacher_services.dart';
import 'package:flutter/material.dart';

class GradingSheet extends StatelessWidget {
  const GradingSheet({
    super.key,
    required this.tugasId,
    required this.tugasTitle,
    required this.students,
    required this.submissions,
    required this.teacherServices,
    required this.onRefreshDetails,
  });

  final String tugasId;
  final String tugasTitle;
  final List<Map<String, dynamic>> students;
  final List<Map<String, dynamic>> submissions;
  final TeacherServices teacherServices;
  final VoidCallback onRefreshDetails;

  @override
  Widget build(BuildContext context) {
    final taskSubmissions = submissions
        .where((s) => s['tugas_id'] == tugasId)
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Penilaian: $tugasTitle',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const Divider(height: 16),
          Expanded(
            child: taskSubmissions.isEmpty
                ? const EmptyStateWidget(message: 'Belum ada siswa yang mengumpulkan jawaban untuk tugas ini.')
                : ListView.builder(
                    itemCount: taskSubmissions.length,
                    itemBuilder: (context, index) {
                      final submission = taskSubmissions[index];
                      final studentId = submission['student_id'] as String? ?? '';
                      final profileMap = submission['profiles'] as Map<String, dynamic>?;
                      final studentMap = students.firstWhere(
                        (s) => s['id'] == studentId,
                        orElse: () => profileMap ?? <String, dynamic>{},
                      );

                      final studentName = (studentMap['full_name'] as String?) ?? (profileMap?['full_name'] as String?) ?? 'Siswa';
                      final studentEmail = (studentMap['email'] as String?) ?? (profileMap?['email'] as String?) ?? '-';
                      final studentNim = (studentMap['nim'] as String?) ?? (profileMap?['nim'] as String?);
                      final fileJawabanUrl = submission['file_jawaban_url'] as String? ?? '';

                      final currentGrade = submission['nilai']?.toString() ?? 'Belum dinilai';
                      final feedback = submission['catatan_dosen'] as String? ?? '';
                      final isGraded = submission['status'] == 'graded' || submission['nilai'] != null;

                      return CardContainer(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: const Color(0xFFEFF6FF),
                                  child: Text(
                                    studentName.isEmpty ? 'S' : studentName[0].toUpperCase(),
                                    style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      Text(
                                        (studentNim != null && studentNim.isNotEmpty) ? 'NIM: $studentNim • $studentEmail' : studentEmail,
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isGraded ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isGraded ? 'Nilai: $currentGrade' : 'Belum Dinilai',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isGraded ? const Color(0xFF059669) : const Color(0xFFD97706),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (fileJawabanUrl.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.attachment_rounded, size: 16, color: Color(0xFF2563EB)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'File Jawaban: $fileJawabanUrl',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF2563EB),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (feedback.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Catatan Dosen: "$feedback"',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF2563EB),
                                    side: const BorderSide(color: Color(0xFF2563EB)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TeacherSubmissionDetailPage(
                                          submission: submission,
                                          tugasTitle: tugasTitle,
                                          courseName: 'Mata Kuliah',
                                        ),
                                      ),
                                    );
                                    onRefreshDetails();
                                  },
                                  icon: const Icon(Icons.description_rounded, size: 16),
                                  label: const Text('Detail & Beri Nilai', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                                const SizedBox(width: 8),
                                PrimaryButton(
                                  label: isGraded ? 'Edit Nilai' : 'Beri Nilai',
                                  onPressed: () => _openGradeInputDialog(context, studentId, studentName, submission),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _openGradeInputDialog(
    BuildContext context,
    String studentId,
    String studentName,
    Map<String, dynamic> submission,
  ) {
    final gradeController = TextEditingController(
      text: submission['nilai'] != null ? submission['nilai'].toString() : '',
    );
    final feedbackController = TextEditingController(
      text: submission['catatan_dosen'] as String? ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Beri Nilai - $studentName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomFormField(
              controller: gradeController,
              label: 'Nilai (0 - 100)',
              hintText: 'Contoh: 85',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            CustomFormField(
              controller: feedbackController,
              label: 'Catatan / Feedback Dosen',
              hintText: 'Pekerjaan sangat baik, pertahankan...',
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            onPressed: () async {
              final textScore = gradeController.text.trim();
              final score = double.tryParse(textScore);
              if (score == null || score < 0 || score > 100) {
                UiUtils.showToast(dialogContext, 'Masukkan nilai valid antara 0 - 100', isError: true);
                return;
              }

              try {
                await teacherServices.gradeSubmission(
                  tugasId: tugasId,
                  studentId: studentId,
                  nilai: score,
                  catatanDosen: feedbackController.text.trim(),
                );
                if (dialogContext.mounted) {
                  UiUtils.showToast(dialogContext, 'Nilai $studentName berhasil disimpan!');
                  onRefreshDetails();
                  Navigator.pop(dialogContext);
                }
              } catch (e) {
                if (dialogContext.mounted) {
                  UiUtils.showToast(dialogContext, 'Gagal menyimpan nilai: $e', isError: true);
                }
              }
            },
            child: const Text('Simpan Nilai', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
