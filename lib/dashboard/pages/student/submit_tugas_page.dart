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

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final tugasId = widget.tugas['id'] as String;
      await _studentServices.submitTugas(
        tugasId: tugasId,
        studentId: widget.studentId,
        jawaban: _jawabanController.text.trim(),
        fileUrl: _fileUrlController.text.trim(),
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
    final isAlreadySubmitted = widget.existingSubmission != null;
    final nilai = widget.existingSubmission?['nilai'];
    final isGraded = isAlreadySubmitted && (widget.existingSubmission!['status'] == 'graded' || nilai != null);
    final catatanDosen = widget.existingSubmission?['catatan_dosen'] as String? ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Pengerjaan & Detail Tugas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
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

                if (isGraded) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
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
                              const Text(
                                'HASIL EVALUASI DOSEN',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF065F46), letterSpacing: 0.5),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Nilai: $nilai / 100',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF047857),
                                ),
                              ),
                              if (catatanDosen.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Catatan Dosen: "$catatanDosen"',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFF065F46),
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

                const Text(
                  'Form Pengumpulan Jawaban',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tuliskan uraian jawaban dan sertakan tautan berkas tugas Anda di bawah ini.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),

                const SizedBox(height: 16),

                // Jawaban Multiline Field
                CustomFormField(
                  label: 'Jawaban / Uraian Tugas',
                  hintText: 'Ketik uraian atau catatan jawaban tugas Anda di sini...',
                  controller: _jawabanController,
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
                  hintText: 'https://drive.google.com/file/...',
                  controller: _fileUrlController,
                  prefixIcon: Icons.link_rounded,
                ),

                const SizedBox(height: 28),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
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
                            isAlreadySubmitted ? 'Perbarui Pengumpulan Tugas' : 'Kirim Tugas Sekarang',
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
