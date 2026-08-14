import 'package:bestpractice/common/utils/ui_utils.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/custom_text_field.dart';
import 'package:bestpractice/dashboard/pages/widgets/task_card_widget.dart';
import 'package:bestpractice/services/student_services.dart';
import 'package:flutter/material.dart';

class SubmitTugasPage extends StatefulWidget {
  const SubmitTugasPage({
    super.key,
    required this.tugas,
    required this.studentId,
    this.existingSubmission,
  });

  final Map<String, dynamic> tugas;
  final String studentId;
  final Map<String, dynamic>? existingSubmission;

  @override
  State<SubmitTugasPage> createState() => _SubmitTugasPageState();
}

class _SubmitTugasPageState extends State<SubmitTugasPage> {
  final StudentServices _studentServices = StudentServices();
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _jawabanController;
  late TextEditingController _fileUrlController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final existingJawaban = widget.existingSubmission?['jawaban'] as String? ?? '';
    final existingFileUrl = (widget.existingSubmission?['file_url'] as String?) ??
        (widget.existingSubmission?['link_file'] as String?) ??
        '';

    _jawabanController = TextEditingController(text: existingJawaban);
    _fileUrlController = TextEditingController(text: existingFileUrl);
  }

  @override
  void dispose() {
    _jawabanController.dispose();
    _fileUrlController.dispose();
    super.dispose();
  }

  bool get _isDeadlinePassed {
    final deadlineStr = widget.tugas['deadline'] as String?;
    if (deadlineStr == null || deadlineStr.trim().isEmpty || deadlineStr == 'Tidak ada deadline') {
      return false;
    }
    final dt = DateTime.tryParse(deadlineStr.trim());
    if (dt == null) return false;
    return dt.isBefore(DateTime.now());
  }

  Future<void> _handleSubmit() async {
    if (_isDeadlinePassed) {
      UiUtils.showToast(
        context,
        'Tenggat waktu pengumpulan tugas ini telah berakhir. Anda tidak dapat mengedit atau mengirimkan jawaban.',
        isError: true,
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final fileUrl = _fileUrlController.text.trim();
    if (fileUrl.isNotEmpty) {
      final uri = Uri.tryParse(fileUrl);
      if (uri == null || !uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
        UiUtils.showToast(context, 'Tautan lampiran berkas harus berupa URL valid (http:// atau https://)', isError: true);
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      final tugasId = widget.tugas['id'] as String;
      await _studentServices.submitTugas(
        tugasId: tugasId,
        studentId: widget.studentId,
        jawaban: _jawabanController.text.trim(),
        fileUrl: fileUrl,
      );

      if (!mounted) return;
      UiUtils.showToast(context, 'Tugas berhasil dikumpulkan!');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      UiUtils.showToast(context, 'Gagal mengumpulkan tugas: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAlreadySubmitted = widget.existingSubmission != null;
    final nilai = widget.existingSubmission?['nilai'];
    final isGraded = isAlreadySubmitted && (widget.existingSubmission!['status'] == 'graded' || nilai != null);
    final catatanDosen = widget.existingSubmission?['catatan_dosen'] as String? ?? '';
    final isExpired = _isDeadlinePassed;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Pengerjaan & Detail Tugas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
        elevation: 0.5,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task Overview Banner using unified TaskCardWidget
                TaskCardWidget(
                  tugas: widget.tugas,
                  submission: widget.existingSubmission,
                  role: 'student',
                ),

                if (isExpired) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF451A03) : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? const Color(0xFF78350F) : const Color(0xFFFDE68A)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.timer_off_rounded, color: Color(0xFFD97706), size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tenggat waktu pengumpulan tugas telah berakhir. Anda tidak dapat lagi mengedit atau mengirimkan jawaban tugas ini.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB45309),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (isGraded) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.5) : const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? const Color(0xFF047857) : const Color(0xFFA7F3D0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'HASIL EVALUASI DOSEN',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Nilai: $nilai / 100',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
                                ),
                              ),
                              if (catatanDosen.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Catatan Dosen: "$catatanDosen"',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF065F46),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                Text(
                  'Form Pengumpulkan Jawaban',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                ),
                const SizedBox(height: 4),
                Text(
                  isExpired
                      ? 'Pengumpulan tugas ini sudah ditutup karena melewati batas tenggat waktu.'
                      : 'Tuliskan uraian jawaban dan sertakan tautan berkas tugas Anda di bawah ini.',
                  style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B)),
                ),

                const SizedBox(height: 16),

                // Jawaban Multiline Field
                CustomFormField(
                  label: 'Jawaban / Uraian Tugas',
                  hintText: isExpired
                      ? 'Pengumpulan telah ditutup.'
                      : 'Ketik uraian atau catatan jawaban tugas Anda di sini...',
                  controller: _jawabanController,
                  enabled: !isExpired,
                  maxLines: 6,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Uraian jawaban tidak boleh kosong.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // File Link / Drive URL Field
                CustomFormField(
                  label: 'Tautan Lampiran Berkas (Google Drive / GitHub / PDF)',
                  hintText: isExpired ? 'Pengumpulan telah ditutup.' : 'https://drive.google.com/file/...',
                  controller: _fileUrlController,
                  enabled: !isExpired,
                  prefixIcon: Icons.link_rounded,
                ),

                const SizedBox(height: 28),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (_isLoading || isExpired) ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isExpired ? const Color(0xFF94A3B8) : const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : Text(
                            isExpired
                                ? 'Tenggat Waktu Telah Berakhir'
                                : (isAlreadySubmitted ? 'Perbarui Pengumpulkan Tugas' : 'Kirim Tugas Sekarang'),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
