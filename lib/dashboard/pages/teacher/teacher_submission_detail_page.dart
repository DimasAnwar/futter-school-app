import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bestpractice/common/utils/ui_utils.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/card_container.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/custom_text_field.dart';
import 'package:bestpractice/services/teacher_services.dart';
import 'package:flutter/material.dart';

class TeacherSubmissionDetailPage extends StatefulWidget {
  const TeacherSubmissionDetailPage({
    super.key,
    required this.submission,
    required this.tugasTitle,
    required this.courseName,
    this.studentName,
    this.studentEmail,
    this.studentNim,
  });

  final Map<String, dynamic> submission;
  final String tugasTitle;
  final String courseName;
  final String? studentName;
  final String? studentEmail;
  final String? studentNim;

  @override
  State<TeacherSubmissionDetailPage> createState() => _TeacherSubmissionDetailPageState();
}

class _TeacherSubmissionDetailPageState extends State<TeacherSubmissionDetailPage> {
  final TeacherServices _teacherServices = TeacherServices();
  late Map<String, dynamic> _currentSubmission;

  @override
  void initState() {
    super.initState();
    _currentSubmission = Map<String, dynamic>.from(widget.submission);
    _loadProfileIfMissing();
  }

  Future<void> _loadProfileIfMissing() async {
    final profileMap = _currentSubmission['profiles'] as Map<String, dynamic>?;
    final studentId = _currentSubmission['student_id'] as String?;

    if ((profileMap == null || profileMap['full_name'] == null || profileMap['nim'] == null) &&
        studentId != null &&
        studentId.isNotEmpty) {
      try {
        final profile = await Supabase.instance.client
            .from('profiles')
            .select('id, full_name, email, nim')
            .eq('id', studentId)
            .maybeSingle();

        if (profile != null && mounted) {
          setState(() {
            _currentSubmission['profiles'] = profile;
          });
        }
      } catch (e) {
        if (kDebugMode) print('Error loading student profile in submission detail: $e');
      }
    }
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'Tanggal tidak tersedia';
    try {
      final dt = DateTime.parse(rawDate);
      return '${dt.day}/${dt.month}/${dt.year} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} WIB';
    } catch (_) {
      return rawDate;
    }
  }

  void _showGradeDialog() {
    final rawGrade = _currentSubmission['nilai']?.toString() ?? '';
    final rawCatatan = _currentSubmission['catatan_dosen'] as String? ?? '';

    final nilaiController = TextEditingController(text: rawGrade);
    final catatanController = TextEditingController(text: rawCatatan);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: const Row(
                children: [
                  Icon(Icons.grade_rounded, color: Color(0xFF2563EB)),
                  SizedBox(width: 8),
                  Text('Beri Nilai Tugas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomFormField(
                        label: 'Nilai (0 - 100)',
                        hintText: 'Contoh: 85',
                        controller: nilaiController,
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Nilai wajib diisi.';
                          final parsed = double.tryParse(val.trim());
                          if (parsed == null || parsed < 0 || parsed > 100) {
                            return 'Masukkan angka nilai antara 0 sampai 100.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      CustomFormField(
                        label: 'Catatan / Feedback Dosen (Opsional)',
                        hintText: 'Tuliskan masukan atau evaluasi tugas...',
                        controller: catatanController,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          setDialogState(() => isSubmitting = true);
                          try {
                            final tugasId = _currentSubmission['tugas_id'] as String;
                            final studentId = _currentSubmission['student_id'] as String;
                            final nilaiDouble = double.parse(nilaiController.text.trim());
                            final catatanText = catatanController.text.trim();

                            await _teacherServices.gradeSubmission(
                              tugasId: tugasId,
                              studentId: studentId,
                              nilai: nilaiDouble,
                              catatanDosen: catatanText.isEmpty ? null : catatanText,
                            );

                            setState(() {
                              _currentSubmission['nilai'] = nilaiDouble;
                              _currentSubmission['catatan_dosen'] = catatanText;
                              _currentSubmission['status'] = 'graded';
                            });

                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                            if (mounted) {
                              UiUtils.showToast(context, 'Nilai berhasil disimpan!');
                            }
                          } catch (e) {
                            if (mounted) {
                              UiUtils.showToast(context, 'Gagal menyimpan nilai: $e', isError: true);
                            }
                          } finally {
                            setDialogState(() => isSubmitting = false);
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Simpan Nilai'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileMap = _currentSubmission['profiles'] as Map<String, dynamic>?;
    final tugasMap = _currentSubmission['tugas'] as Map<String, dynamic>?;
    final courseMap = tugasMap?['mata_kuliah'] as Map<String, dynamic>?;

    final rawName = widget.studentName ?? profileMap?['full_name'] as String?;
    final studentName = (rawName != null && rawName.trim().isNotEmpty) ? rawName.trim() : 'Siswa';

    final rawEmail = widget.studentEmail ?? profileMap?['email'] as String?;
    final studentEmail = (rawEmail != null && rawEmail.trim().isNotEmpty) ? rawEmail.trim() : '-';

    final rawNim = widget.studentNim ?? profileMap?['nim'] as String?;
    final studentNim = (rawNim != null && rawNim.trim().isNotEmpty) ? rawNim.trim() : '-';

    final tugasTitle = (tugasMap?['judul_tugas'] as String?) ?? widget.tugasTitle;
    final courseName = (courseMap?['nama_mk'] as String?) ?? widget.courseName;

    final rawJawaban = (_currentSubmission['jawaban'] as String?) ?? (_currentSubmission['jawaban_teks'] as String?);
    final jawabanTeks = (rawJawaban != null && rawJawaban.trim().isNotEmpty)
        ? rawJawaban.trim()
        : 'Siswa belum menyertakan uraian jawaban teks.';

    final fileUrl = (_currentSubmission['file_url'] as String?) ??
        (_currentSubmission['file_jawaban_url'] as String?) ??
        (_currentSubmission['link_file'] as String?) ??
        '';
    final tanggalKumpul = _currentSubmission['tanggal_kumpul'] as String? ?? _currentSubmission['created_at'] as String?;

    final nilai = _currentSubmission['nilai'];
    final isGraded = _currentSubmission['status'] == 'graded' || nilai != null;
    final catatanDosen = _currentSubmission['catatan_dosen'] as String? ?? '';

    final subInfo = [
      if (studentNim != '-') 'NIM: $studentNim',
      if (studentEmail != '-') studentEmail,
    ].join(' • ');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Detail Tugas Siswa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
              // Student & Task Info Banner Card
              CardContainer(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFFEFF6FF),
                          child: Text(
                            studentName.isEmpty ? 'S' : studentName[0].toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF2563EB),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
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
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                subInfo.isEmpty ? 'NIM: Belum Diatur' : subInfo,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isGraded ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isGraded ? 'Sudah Dinilai' : 'Belum Dinilai',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isGraded ? const Color(0xFF059669) : const Color(0xFFD97706),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            courseName,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(tanggalKumpul),
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tugasTitle,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Student Written Response Section
              const Text(
                'Jawaban / Uraian Tugas Siswa',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 10),
              CardContainer(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jawabanTeks,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.5),
                    ),
                    if (fileUrl.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 12),
                      const Text(
                        'Lampiran Berkas / Tautan:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.insert_drive_file_rounded, color: Color(0xFF2563EB), size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                fileUrl,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF2563EB), fontWeight: FontWeight.w500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Grading Status Card
              CardContainer(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isGraded ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isGraded ? Icons.workspace_premium_rounded : Icons.pending_rounded,
                        color: isGraded ? const Color(0xFF059669) : const Color(0xFFD97706),
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isGraded ? 'NILAI SAAT INI' : 'STATUS PENILAIAN',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isGraded ? '$nilai / 100' : 'Belum Dinilai',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isGraded ? const Color(0xFF059669) : const Color(0xFFD97706),
                            ),
                          ),
                          if (catatanDosen.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Masukan Dosen: "$catatanDosen"',
                              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF475569)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Prominent Action Button: "Beri / Edit Nilai"
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _showGradeDialog,
                  icon: const Icon(Icons.rate_review_rounded, size: 20),
                  label: Text(
                    isGraded ? 'Edit Nilai Tugas Siswa' : 'Beri Nilai Tugas Siswa',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
