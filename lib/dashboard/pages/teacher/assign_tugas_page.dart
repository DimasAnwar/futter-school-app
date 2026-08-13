import 'package:bestpractice/common/utils/ui_utils.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/custom_text_field.dart';
import 'package:bestpractice/services/teacher_services.dart';
import 'package:flutter/material.dart';

class AssignTugasPage extends StatefulWidget {
  const AssignTugasPage({
    super.key,
    required this.teacherId,
    required this.courses,
    this.preselectedCourseId,
    this.existingTugas,
    required this.onRefreshParent,
  });

  final String teacherId;
  final List<Map<String, dynamic>> courses;
  final String? preselectedCourseId;
  final Map<String, dynamic>? existingTugas;
  final VoidCallback onRefreshParent;

  @override
  State<AssignTugasPage> createState() => _AssignTugasPageState();
}

class _AssignTugasPageState extends State<AssignTugasPage> {
  final TeacherServices _teacherServices = TeacherServices();

  late String _selectedCourseId;
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _deadlineController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingTugas;
    if (existing != null) {
      _selectedCourseId = (existing['course_id'] as String?) ??
          ((existing['mata_kuliah'] as Map<String, dynamic>?)?['id'] as String?) ??
          widget.preselectedCourseId ??
          (widget.courses.isNotEmpty ? widget.courses.first['id'] as String : '');
      _judulController.text = (existing['judul_tugas'] as String?) ?? (existing['judul'] as String?) ?? '';
      _deskripsiController.text = (existing['deskripsi'] as String?) ?? '';
      _deadlineController.text = (existing['deadline'] as String?) ?? '';
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
    _deadlineController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadlineDateTime() async {
    final now = DateTime.now();
    final initialDate = _selectedDate ?? now.add(const Duration(days: 7));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: now,
      lastDate: DateTime(2030),
      helpText: 'Pilih Tanggal Deadline',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: Color(0xFFF59E0B),
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E293B),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: Color(0xFFF59E0B),
                    onPrimary: Colors.white,
                    onSurface: Color(0xFF0F172A),
                  ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    if (!mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 23, minute: 59),
      helpText: 'Pilih Jam Batas Pengumpulan',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: Color(0xFFF59E0B),
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E293B),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: Color(0xFFF59E0B),
                    onPrimary: Colors.white,
                    onSurface: Color(0xFF0F172A),
                  ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

    setState(() {
      _selectedDate = pickedDate;
      _selectedTime = pickedTime;

      final dayName = _getDayName(pickedDate.weekday);
      final monthName = _getMonthName(pickedDate.month);
      final hourStr = pickedTime.hour.toString().padLeft(2, '0');
      final minuteStr = pickedTime.minute.toString().padLeft(2, '0');

      _deadlineController.text = '$dayName, ${pickedDate.day} $monthName ${pickedDate.year} • $hourStr:$minuteStr WIB';
    });
  }

  String _getDayName(int weekday) {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return days[(weekday - 1) % 7];
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[(month - 1) % 12];
  }

  Future<void> _submitTugas() async {
    if (_selectedCourseId.isEmpty) {
      UiUtils.showToast(context, 'Pilih mata kuliah terlebih dahulu.', isError: true);
      return;
    }
    if (_judulController.text.trim().isEmpty) {
      UiUtils.showToast(context, 'Judul tugas harus diisi.', isError: true);
      return;
    }
    if (_deadlineController.text.trim().isEmpty) {
      UiUtils.showToast(context, 'Deadline pengumpulan harus dipilih.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    DateTime? deadlineDt;
    if (_selectedDate != null && _selectedTime != null) {
      deadlineDt = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
    }

    try {
      if (widget.existingTugas != null) {
        final tugasId = widget.existingTugas!['id'] as String;
        await _teacherServices.updateTugas(
          tugasId: tugasId,
          judul: _judulController.text.trim(),
          deskripsi: _deskripsiController.text.trim(),
          deadline: _deadlineController.text.trim(),
          deadlineDateTime: deadlineDt,
        );
        if (mounted) {
          UiUtils.showToast(context, 'Tugas perkuliahan berhasil diperbarui!');
          widget.onRefreshParent();
          Navigator.pop(context);
        }
      } else {
        await _teacherServices.addTugas(
          courseId: _selectedCourseId,
          judul: _judulController.text.trim(),
          deskripsi: _deskripsiController.text.trim(),
          deadline: _deadlineController.text.trim(),
          deadlineDateTime: deadlineDt,
          teacherId: widget.teacherId,
        );

        if (mounted) {
          UiUtils.showToast(context, 'Tugas perkuliahan berhasil dibuat!');
          widget.onRefreshParent();
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        UiUtils.showToast(context, 'Gagal menyimpan tugas: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditMode = widget.existingTugas != null;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditMode ? 'Edit Tugas Perkuliahan' : 'Buat Penugasan Siswa',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
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
                    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withValues(alpha: 0.3) : const Color(0x33F59E0B),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_task_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditMode ? 'Edit Tugas Perkuliahan' : 'Assign Tugas Baru',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Berikan instruksi tugas, kriteria nilai, dan tentukan tanggal batas waktu pengumpulan.',
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
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0x08000000),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih Mata Kuliah',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      dropdownColor: cardBg,
                      style: TextStyle(color: textColor, fontSize: 14),
                      initialValue: _selectedCourseId.isNotEmpty ? _selectedCourseId : null,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        prefixIcon: const Icon(Icons.class_rounded, color: Color(0xFFF59E0B), size: 20),
                      ),
                      hint: Text('Pilih mata kuliah...', style: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8))),
                      items: widget.courses.map((course) {
                        final name = course['nama_mk'] as String? ?? 'Matkul';
                        final code = course['kode_mk'] as String? ?? '-';
                        return DropdownMenuItem<String>(
                          value: course['id'] as String,
                          child: Text('$name ($code)', style: TextStyle(color: textColor), overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCourseId = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    CustomFormField(
                      controller: _judulController,
                      label: 'Judul Tugas',
                      hintText: 'Contoh: Tugas 1 - Membuat Wireframe UI App',
                    ),
                    const SizedBox(height: 16),

                    CustomFormField(
                      controller: _deskripsiController,
                      label: 'Instruksi Pengerjaan Tugas',
                      hintText: 'Tuliskan petunjuk pengerjaan, format pengumpulan, & kriteria nilai...',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Deadline Pengumpulan Tugas',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 8),

                    InkWell(
                      onTap: _pickDeadlineDateTime,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF451A03).withValues(alpha: 0.6) : const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isDark ? const Color(0xFF78350F) : const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, color: isDark ? const Color(0xFFFDE047) : const Color(0xFFD97706), size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'BATAS WAKTU PENGUMPULAN',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? const Color(0xFFFDE047) : const Color(0xFFB45309),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _deadlineController.text.isEmpty
                                        ? 'Klik di sini untuk memilih tanggal & jam'
                                        : _deadlineController.text,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: _deadlineController.text.isEmpty
                                          ? (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8))
                                          : textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.access_time_rounded, color: isDark ? const Color(0xFFFDE047) : const Color(0xFFD97706), size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isSubmitting ? null : _submitTugas,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Icon(isEditMode ? Icons.save_rounded : Icons.send_rounded),
                        label: Text(
                          _isSubmitting
                              ? 'Menyimpan...'
                              : (isEditMode ? 'Simpan Perubahan Tugas' : 'Assign Tugas Sekarang'),
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
