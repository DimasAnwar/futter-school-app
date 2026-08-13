import 'package:bestpractice/dashboard/pages/teacher/teacher_submission_detail_page.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/card_container.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/empty_state.dart';
import 'package:bestpractice/services/teacher_services.dart';
import 'package:flutter/material.dart';

class BeriNilaiModule extends StatefulWidget {
  const BeriNilaiModule({
    super.key,
    required this.teacherServices,
    required this.courses,
    required this.tugasList,
    required this.submissions,
    required this.onRefresh,
    required this.onShowToast,
  });

  final TeacherServices teacherServices;
  final List<Map<String, dynamic>> courses;
  final List<Map<String, dynamic>> tugasList;
  final List<Map<String, dynamic>> submissions;
  final Future<void> Function() onRefresh;
  final Function(String message, {bool isError}) onShowToast;

  @override
  State<BeriNilaiModule> createState() => _BeriNilaiModuleState();
}

class _BeriNilaiModuleState extends State<BeriNilaiModule> {
  late String _selectedTugasId;
  List<Map<String, dynamic>> _enrolledStudents = [];
  bool _isLoadingStudents = false;

  @override
  void initState() {
    super.initState();
    _selectedTugasId = widget.tugasList.first['id'] as String;
    _loadStudentsForSelectedTugas();
  }

  Future<void> _loadStudentsForSelectedTugas() async {
    setState(() => _isLoadingStudents = true);
    final selectedTugas = widget.tugasList.firstWhere(
      (t) => t['id'] == _selectedTugasId,
      orElse: () => widget.tugasList.first,
    );

    final courseId = selectedTugas['course_id'] as String?;
    if (courseId != null) {
      final students = await widget.teacherServices.getEnrolledStudentsForCourse(courseId);
      if (mounted) {
        setState(() {
          _enrolledStudents = students;
          _isLoadingStudents = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoadingStudents = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedTugas = widget.tugasList.firstWhere(
      (t) => t['id'] == _selectedTugasId,
      orElse: () => widget.tugasList.first,
    );
    final tugasTitle = (selectedTugas['judul_tugas'] as String?) ?? (selectedTugas['judul'] as String?) ?? 'Tugas';
    final courseMap = selectedTugas['mata_kuliah'] as Map<String, dynamic>?;
    final courseName = courseMap?['nama_mk'] as String? ?? 'Mata Kuliah';

    final taskSubmissions = widget.submissions
        .where((s) => s['tugas_id'] == _selectedTugasId)
        .toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final dropdownBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CardContainer(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih Tugas untuk Dinilai:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _selectedTugasId,
                dropdownColor: dropdownBg,
                style: TextStyle(color: textColor, fontSize: 14),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                ),
                items: widget.tugasList.map((tugas) {
                  final tTitle = (tugas['judul_tugas'] as String?) ?? (tugas['judul'] as String?) ?? 'Tugas';
                  return DropdownMenuItem<String>(
                    value: tugas['id'] as String,
                    child: Text(tTitle, overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedTugasId = val);
                    _loadStudentsForSelectedTugas();
                  }
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Mata Kuliah: $courseName',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: Text(
                'Pengumpulan Tugas ($tugasTitle)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Total: ${taskSubmissions.length}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        if (_isLoadingStudents)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (taskSubmissions.isEmpty)
          EmptyStateWidget(
            message: 'Belum ada siswa yang mengumpulkan jawaban untuk tugas ini.',
          )
        else
          ...taskSubmissions.map((submission) {
            final studentId = submission['student_id'] as String? ?? '';
            final profileMap = submission['profiles'] as Map<String, dynamic>?;
            final studentMap = _enrolledStudents.cast<Map<String, dynamic>>().firstWhere(
              (s) => s['id']?.toString().trim().toLowerCase() == studentId.trim().toLowerCase(),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFFEFF6FF),
                        child: Text(
                          studentName.isEmpty ? 'S' : studentName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              studentName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              (studentNim != null && studentNim.isNotEmpty) ? 'NIM: $studentNim • $studentEmail' : studentEmail,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isGraded ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
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
                                courseName: courseName,
                                studentName: studentName,
                                studentEmail: studentEmail,
                                studentNim: studentNim,
                              ),
                            ),
                          );
                          widget.onRefresh();
                        },
                        icon: const Icon(Icons.description_rounded, size: 16),
                        label: const Text('Detail & Beri Nilai', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
