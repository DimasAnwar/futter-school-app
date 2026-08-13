import 'package:bestpractice/common/utils/ui_utils.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/custom_text_field.dart';
import 'package:bestpractice/services/teacher_services.dart';
import 'package:flutter/material.dart';

class UploadMateriPage extends StatefulWidget {
  const UploadMateriPage({
    super.key,
    required this.teacherId,
    required this.courses,
    this.preselectedCourseId,
    this.existingMateri,
    required this.onRefreshParent,
  });

  final String teacherId;
  final List<Map<String, dynamic>> courses;
  final String? preselectedCourseId;
  final Map<String, dynamic>? existingMateri;
  final VoidCallback onRefreshParent;

  @override
  State<UploadMateriPage> createState() => _UploadMateriPageState();
}

class _UploadMateriPageState extends State<UploadMateriPage> {
  final TeacherServices _teacherServices = TeacherServices();

  late String _selectedCourseId;
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _fileUrlController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingMateri;
    if (existing != null) {
      _selectedCourseId = (existing['course_id'] as String?) ??
          ((existing['mata_kuliah'] as Map<String, dynamic>?)?['id'] as String?) ??
          widget.preselectedCourseId ??
          (widget.courses.isNotEmpty ? widget.courses.first['id'] as String : '');
      _judulController.text = (existing['judul_materi'] as String?) ?? (existing['judul'] as String?) ?? '';
      _deskripsiController.text = (existing['deskripsi'] as String?) ?? '';
      _fileUrlController.text = (existing['file_url'] as String?) ?? (existing['link_file'] as String?) ?? '';
    } else if (widget.courses.isNotEmpty) {
      _selectedCourseId = widget.preselectedCourseId ?? (widget.courses.first['id'] as String);
    } else {
      _selectedCourseId = '';
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _fileUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitMateri() async {
    if (_selectedCourseId.isEmpty) {
      UiUtils.showToast(context, 'Pilih mata kuliah terlebih dahulu.', isError: true);
      return;
    }
    if (_judulController.text.trim().isEmpty) {
      UiUtils.showToast(context, 'Judul materi harus diisi.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (widget.existingMateri != null) {
        final materiId = widget.existingMateri!['id'] as String;
        await _teacherServices.updateMateri(
          materiId: materiId,
          judul: _judulController.text.trim(),
          deskripsi: _deskripsiController.text.trim(),
          fileUrl: _fileUrlController.text.trim(),
        );
        if (mounted) {
          UiUtils.showToast(context, 'Materi perkuliahan berhasil diperbarui!');
          widget.onRefreshParent();
          Navigator.pop(context);
        }
      } else {
        await _teacherServices.addMateri(
          courseId: _selectedCourseId,
          judul: _judulController.text.trim(),
          deskripsi: _deskripsiController.text.trim(),
          fileUrl: _fileUrlController.text.trim(),
          teacherId: widget.teacherId,
        );

        if (mounted) {
          UiUtils.showToast(context, 'Materi perkuliahan berhasil diunggah!');
          widget.onRefreshParent();
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        UiUtils.showToast(context, 'Gagal menyimpan materi: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.existingMateri != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditMode ? 'Edit Materi Perkuliahan' : 'Upload Materi Perkuliahan',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Color(0x332563EB), blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Unggah Materi Baru',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Bagikan slide, modul PDF, atau link referensi kepada mahasiswa kelas Anda.',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Form Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilih Mata Kuliah',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedCourseId.isNotEmpty ? _selectedCourseId : null,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        prefixIcon: const Icon(Icons.class_rounded, color: Color(0xFF2563EB), size: 20),
                      ),
                      hint: const Text('Pilih mata kuliah...'),
                      items: widget.courses.map((course) {
                        final name = course['nama_mk'] as String? ?? 'Matkul';
                        final code = course['kode_mk'] as String? ?? '-';
                        return DropdownMenuItem<String>(
                          value: course['id'] as String,
                          child: Text('$name ($code)', overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCourseId = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    CustomFormField(
                      controller: _judulController,
                      label: 'Judul Materi Perkuliahan',
                      hintText: 'Contoh: Pertemuan 1 - Pengenalan Flutter & State',
                    ),
                    const SizedBox(height: 16),

                    CustomFormField(
                      controller: _deskripsiController,
                      label: 'Deskripsi / Catatan Singkat',
                      hintText: 'Tuliskan rangkuman isi materi atau instruksi bacaan...',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),

                    CustomFormField(
                      controller: _fileUrlController,
                      label: 'Link File / Slide Drive (Optional)',
                      hintText: 'https://drive.google.com/file/...',
                      prefixIcon: Icons.link_rounded,
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isSubmitting ? null : _submitMateri,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Icon(isEditMode ? Icons.save_rounded : Icons.cloud_upload_rounded),
                        label: Text(
                          _isSubmitting
                              ? 'Menyimpan...'
                              : (isEditMode ? 'Simpan Perubahan Materi' : 'Unggah Materi Sekarang'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
