import 'package:bestpractice/common/utils/ui_utils.dart';
import 'package:bestpractice/dashboard/pages/teacher/assign_tugas_page.dart';
import 'package:bestpractice/dashboard/pages/teacher/upload_materi_page.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/card_container.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/empty_state.dart';
import 'package:bestpractice/dashboard/pages/widgets/task_card_widget.dart';
import 'package:bestpractice/dashboard/pages/widgets/teacher/course_students_sheet.dart';
import 'package:bestpractice/dashboard/pages/widgets/teacher/grading_sheet.dart';
import 'package:bestpractice/dashboard/pages/widgets/teacher/info_stat_box.dart';
import 'package:bestpractice/services/teacher_services.dart';
import 'package:flutter/material.dart';

class TeacherCourseDetailPage extends StatefulWidget {
  const TeacherCourseDetailPage({
    super.key,
    required this.teacherId,
    required this.course,
    required this.onRefreshParent,
  });

  final String teacherId;
  final Map<String, dynamic> course;
  final VoidCallback onRefreshParent;

  @override
  State<TeacherCourseDetailPage> createState() => _TeacherCourseDetailPageState();
}

class _TeacherCourseDetailPageState extends State<TeacherCourseDetailPage> with SingleTickerProviderStateMixin {
  final TeacherServices _teacherServices = TeacherServices();
  late TabController _tabController;

  late String _courseId;
  late String _courseName;
  late String _courseCode;
  late int _sks;
  late int _semester;

  bool _isLoading = true;
  List<Map<String, dynamic>> _materiList = [];
  List<Map<String, dynamic>> _tugasList = [];
  List<Map<String, dynamic>> _submissions = [];
  List<Map<String, dynamic>> _enrolledStudents = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _courseId = widget.course['id'] as String;
    _courseName = widget.course['nama_mk'] as String? ?? 'Mata Kuliah';
    _courseCode = widget.course['kode_mk'] as String? ?? '-';
    _sks = widget.course['sks'] ?? 0;
    _semester = widget.course['semester'] ?? 1;

    _loadCourseDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCourseDetails() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _teacherServices.getMateriForCourses([_courseId], widget.teacherId),
        _teacherServices.getTugasForCourses([_courseId], widget.teacherId),
        _teacherServices.getSubmissionsForTeacher(widget.teacherId),
        _teacherServices.getEnrolledStudentsForCourse(_courseId),
      ]);

      if (mounted) {
        setState(() {
          _materiList = results[0];
          _tugasList = results[1];
          _submissions = results[2];
          _enrolledStudents = results[3];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        UiUtils.showToast(context, 'Gagal memuat detail kelas: $e', isError: true);
      }
    }
  }

  void _showToast(String message, {bool isError = false}) {
    UiUtils.showToast(context, message, isError: isError);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final appBarBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _courseName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Kode: $_courseCode • $_sks SKS • Semester $_semester',
              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF2563EB)),
            onPressed: () async {
              await _loadCourseDetails();
              widget.onRefreshParent();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  await _loadCourseDetails();
                  widget.onRefreshParent();
                },
                child: Column(
                  children: [
                    // Course Header Info Box
                    Container(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: InfoStatBox(
                                  label: 'Siswa',
                                  value: '${_enrolledStudents.length}',
                                  icon: Icons.groups_rounded,
                                  color: const Color(0xFF2563EB),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: InfoStatBox(
                                  label: 'Materi',
                                  value: '${_materiList.length}',
                                  icon: Icons.menu_book_rounded,
                                  color: const Color(0xFF8B5CF6),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: InfoStatBox(
                                  label: 'Tugas',
                                  value: '${_tugasList.length}',
                                  icon: Icons.assignment_rounded,
                                  color: const Color(0xFFF59E0B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _showEnrolledStudentsSheet,
                                  icon: const Icon(Icons.people_alt_rounded, size: 16),
                                  label: const Text('Daftar Siswa', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: isDark ? Colors.white : const Color(0xFF2563EB),
                                    side: BorderSide(color: isDark ? const Color(0xFF60A5FA) : const Color(0xFFBFDBFE)),
                                    backgroundColor: isDark ? const Color(0xFF2563EB).withValues(alpha: 0.25) : Colors.transparent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: _showUploadMateriModal,
                                icon: const Icon(Icons.cloud_upload_rounded, size: 16),
                                label: const Text('Upload Materi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: _showAssignTugasModal,
                                icon: const Icon(Icons.add_task_rounded, size: 16),
                                label: const Text('Buat Tugas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF59E0B),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Tab Bar
                    Container(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      child: TabBar(
                        controller: _tabController,
                        labelColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                        unselectedLabelColor: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                        indicatorColor: const Color(0xFF2563EB),
                        indicatorWeight: 3,
                        tabs: [
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.menu_book_rounded, size: 18),
                                const SizedBox(width: 6),
                                Text('Materi (${_materiList.length})'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.assignment_rounded, size: 18),
                                const SizedBox(width: 6),
                                Text('Tugas (${_tugasList.length})'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),

                    // Tab Bar View Content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildMateriTabContent(),
                          _buildTugasTabContent(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // --- TAB 1: DAFTAR MATERI ---
  Widget _buildMateriTabContent() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final descColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);
    final linkBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final linkBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    if (_materiList.isEmpty) {
      return const EmptyStateWidget(
        message: 'Belum ada materi untuk mata kuliah ini. Klik tombol "Upload Materi" di atas untuk menambahkan.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _materiList.length,
      itemBuilder: (context, index) {
        final materi = _materiList[index];
        final id = materi['id'] as String;
        final judul = (materi['judul_materi'] as String?) ?? (materi['judul'] as String?) ?? 'Materi';
        final deskripsi = materi['deskripsi'] as String? ?? '-';
        final fileUrl = materi['file_url'] as String? ?? '';

        return CardContainer(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(color: Color(0x338B5CF6), blurRadius: 8, offset: Offset(0, 3)),
                  ],
                ),
                child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            judul,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: textColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF3B0764) : const Color(0xFFF3E8FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'MODUL MATERI',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFFC084FC) : const Color(0xFF8B5CF6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      deskripsi,
                      style: TextStyle(fontSize: 13, color: descColor, height: 1.4),
                    ),
                    if (fileUrl.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: linkBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: linkBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.link_rounded, size: 16, color: Color(0xFF3B82F6)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                fileUrl,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                                  fontWeight: FontWeight.w500,
                                ),
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _showEditMateriModal(materi),
                    icon: const Icon(Icons.edit_outlined, color: Color(0xFF2563EB)),
                    tooltip: 'Edit Materi',
                  ),
                  IconButton(
                    onPressed: () => _confirmDeleteMateri(id, judul),
                    icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                    tooltip: 'Hapus Materi',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // --- TAB 2: DAFTAR TUGAS & PENILAIAN ---
  Widget _buildTugasTabContent() {
    if (_tugasList.isEmpty) {
      return const EmptyStateWidget(
        message: 'Belum ada tugas untuk mata kuliah ini. Klik tombol "Buat Tugas" di atas untuk menambahkan.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tugasList.length,
      itemBuilder: (context, index) {
        final tugas = _tugasList[index];
        final id = tugas['id'] as String;
        final judul = (tugas['judul_tugas'] as String?) ?? (tugas['judul'] as String?) ?? 'Tugas';

        final taskSubmissions = _submissions.where((s) => s['tugas_id'] == id).toList();
        final gradedCount = taskSubmissions.where((s) => s['nilai'] != null || s['status'] == 'graded').length;

        final tugasWithCourse = Map<String, dynamic>.from(tugas);
        if (tugasWithCourse['mata_kuliah'] == null) {
          tugasWithCourse['mata_kuliah'] = widget.course;
        }

        return TaskCardWidget(
          tugas: tugasWithCourse,
          role: 'teacher',
          onEdit: () => _showEditTugasModal(tugas),
          onDelete: () => _confirmDeleteTugas(id, judul),
          onGrade: () => _openGradingModal(id, judul),
          gradedCount: gradedCount,
          totalStudentsCount: _enrolledStudents.length,
        );
      },
    );
  }

  // --- ACTIONS & MODALS ---

  void _showEnrolledStudentsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => CourseStudentsSheet(
        students: _enrolledStudents,
        courseName: _courseName,
      ),
    );
  }

  void _showUploadMateriModal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadMateriPage(
          teacherId: widget.teacherId,
          courses: [widget.course],
          preselectedCourseId: _courseId,
          onRefreshParent: () async {
            await _loadCourseDetails();
            widget.onRefreshParent();
          },
        ),
      ),
    );
  }

  void _showAssignTugasModal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssignTugasPage(
          teacherId: widget.teacherId,
          courses: [widget.course],
          preselectedCourseId: _courseId,
          onRefreshParent: () async {
            await _loadCourseDetails();
            widget.onRefreshParent();
          },
        ),
      ),
    );
  }

  void _showEditMateriModal(Map<String, dynamic> materi) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadMateriPage(
          teacherId: widget.teacherId,
          courses: [widget.course],
          preselectedCourseId: _courseId,
          existingMateri: materi,
          onRefreshParent: () async {
            await _loadCourseDetails();
            widget.onRefreshParent();
          },
        ),
      ),
    );
  }

  void _showEditTugasModal(Map<String, dynamic> tugas) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssignTugasPage(
          teacherId: widget.teacherId,
          courses: [widget.course],
          preselectedCourseId: _courseId,
          existingTugas: tugas,
          onRefreshParent: () async {
            await _loadCourseDetails();
            widget.onRefreshParent();
          },
        ),
      ),
    );
  }

  void _openGradingModal(String tugasId, String tugasTitle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => GradingSheet(
        tugasId: tugasId,
        tugasTitle: tugasTitle,
        students: _enrolledStudents,
        submissions: _submissions,
        teacherServices: _teacherServices,
        onRefreshDetails: () async {
          await _loadCourseDetails();
          widget.onRefreshParent();
        },
      ),
    );
  }

  Future<void> _confirmDeleteMateri(String id, String judul) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Materi?'),
        content: Text('"$judul" akan dihapus secara permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _teacherServices.deleteMateri(id);
        _showToast('Materi berhasil dihapus.');
        await _loadCourseDetails();
        widget.onRefreshParent();
      } catch (e) {
        _showToast('Gagal menghapus materi: $e', isError: true);
      }
    }
  }

  Future<void> _confirmDeleteTugas(String id, String judul) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Tugas?'),
        content: Text('"$judul" akan dihapus secara permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _teacherServices.deleteTugas(id);
        _showToast('Tugas berhasil dihapus.');
        await _loadCourseDetails();
        widget.onRefreshParent();
      } catch (e) {
        _showToast('Gagal menghapus tugas: $e', isError: true);
      }
    }
  }
}


