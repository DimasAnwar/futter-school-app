import 'package:bestpractice/dashboard/pages/teacher/assign_tugas_page.dart';
import 'package:bestpractice/dashboard/pages/teacher/teacher_course_detail_page.dart';
import 'package:bestpractice/dashboard/pages/teacher/upload_materi_page.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/empty_state.dart';
import 'package:bestpractice/dashboard/pages/widgets/course_card_widget.dart';
import 'package:bestpractice/dashboard/pages/widgets/materi_card_widget.dart';
import 'package:bestpractice/dashboard/pages/widgets/task_card_widget.dart';
import 'package:bestpractice/dashboard/pages/widgets/teacher/beri_nilai_module.dart';
import 'package:bestpractice/dashboard/pages/widgets/teacher/enrolled_students_sheet.dart';
import 'package:bestpractice/services/teacher_services.dart';
import 'package:flutter/material.dart';

class TeacherAcademicsView extends StatefulWidget {
  const TeacherAcademicsView({
    super.key,
    required this.teacherId,
    required this.courses,
    required this.materiList,
    required this.tugasList,
    required this.submissions,
    this.enrollments = const [],
    required this.initialSubTabIndex,
    required this.onRefresh,
    required this.onShowToast,
    this.onGoToHome,
  });

  final String teacherId;
  final List<Map<String, dynamic>> courses;
  final List<Map<String, dynamic>> materiList;
  final List<Map<String, dynamic>> tugasList;
  final List<Map<String, dynamic>> submissions;
  final List<Map<String, dynamic>> enrollments;
  final int initialSubTabIndex;
  final Future<void> Function() onRefresh;
  final Function(String message, {bool isError}) onShowToast;
  final VoidCallback? onGoToHome;

  @override
  State<TeacherAcademicsView> createState() => _TeacherAcademicsViewState();
}

class _TeacherAcademicsViewState extends State<TeacherAcademicsView> {
  late int _selectedTab;
  final TeacherServices _teacherServices = TeacherServices();

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialSubTabIndex;
  }

  @override
  void didUpdateWidget(covariant TeacherAcademicsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSubTabIndex != widget.initialSubTabIndex) {
      setState(() {
        _selectedTab = widget.initialSubTabIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Column(
      children: [
        // Sub Header Tabs Bar
        Container(
          color: headerBg,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (widget.onGoToHome != null) ...[
                    IconButton(
                      onPressed: widget.onGoToHome,
                      icon: Icon(Icons.arrow_back_rounded, color: textColor),
                      tooltip: 'Ke Beranda',
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    'Akademik & Pengajaran',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: widget.onRefresh,
                    icon: const Icon(Icons.refresh_rounded, color: Color(0xFF2563EB)),
                    tooltip: 'Refresh Data',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Segmented Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTabChip(0, 'Kelola Kelas', Icons.class_rounded),
                    const SizedBox(width: 8),
                    _buildTabChip(1, 'Upload Materi', Icons.upload_file_rounded),
                    const SizedBox(width: 8),
                    _buildTabChip(2, 'Assign Tugas', Icons.add_task_rounded),
                    const SizedBox(width: 8),
                    _buildTabChip(3, 'Beri Nilai', Icons.fact_check_rounded),
                  ],
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        // Body Content based on selected tab
        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: _buildTabBodyContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildTabChip(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2563EB)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Colors.white
                  : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBodyContent() {
    switch (_selectedTab) {
      case 0:
        return _buildKelolaKelasTab();
      case 1:
        return _buildUploadMateriTab();
      case 2:
        return _buildAssignTugasTab();
      case 3:
        return _buildBeriNilaiTab();
      default:
        return _buildKelolaKelasTab();
    }
  }

  // --- TAB 1: KELOLA KELAS ---
  Widget _buildKelolaKelasTab() {
    if (widget.courses.isEmpty) {
      return const EmptyStateWidget(
        message: 'Belum ada mata kuliah yang ditugaskan kepada Anda.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.courses.length,
      itemBuilder: (context, index) {
        final course = widget.courses[index];
        final courseId = (course['id'] as String? ?? '').trim();

        final courseMateriCount = widget.materiList.where((m) {
          final cId = m['course_id'] as String? ?? ((m['mata_kuliah'] as Map<String, dynamic>?)?['id'] as String?);
          return cId?.trim() == courseId;
        }).length;

        final courseTugasCount = widget.tugasList.where((t) {
          final cId = t['course_id'] as String? ?? ((t['mata_kuliah'] as Map<String, dynamic>?)?['id'] as String?);
          return cId?.trim() == courseId;
        }).length;

        final courseStudentsCount = widget.enrollments.where((e) {
          final cId = e['course_id']?.toString().trim();
          return cId == courseId;
        }).length;

        return CourseCardWidget(
          course: course,
          role: 'teacher',
          materiCount: courseMateriCount,
          tugasCount: courseTugasCount,
          enrolledStudentsCount: courseStudentsCount,
          onTapCard: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeacherCourseDetailPage(
                  teacherId: widget.teacherId,
                  course: course,
                  onRefreshParent: widget.onRefresh,
                ),
              ),
            );
          },
          onUploadMateri: () => _showUploadMateriModal(preselectedCourseId: courseId),
          onAssignTugas: () => _showAssignTugasModal(),
          onShowStudents: () => _showEnrolledStudentsSheet(courseId, (course['nama_mk'] as String?) ?? 'Mata Kuliah'),
        );
      },
    );
  }

  // --- TAB 2: UPLOAD MATERI ---
  Widget _buildUploadMateriTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Materi Perkuliahan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showUploadMateriModal(),
              icon: const Icon(Icons.cloud_upload_rounded, size: 18),
              label: const Text('Upload Materi Baru'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        if (widget.materiList.isEmpty)
          const EmptyStateWidget(
            message: 'Belum ada materi perkuliahan yang diunggah.',
          )
        else
          ...widget.materiList.map((materi) {
            final id = materi['id'] as String;
            final judul = (materi['judul_materi'] as String?) ?? (materi['judul'] as String?) ?? 'Materi';

            return MateriCardWidget(
              materi: materi,
              role: 'teacher',
              onEdit: () => _showEditMateriModal(materi),
              onDelete: () => _confirmDeleteMateri(id, judul),
            );
          }),
      ],
    );
  }

  // --- TAB 3: ASSIGN TUGAS ---
  Widget _buildAssignTugasTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Penugasan Siswa',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showAssignTugasModal(),
              icon: const Icon(Icons.add_task_rounded, size: 18),
              label: const Text('Buat Tugas Baru'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        if (widget.tugasList.isEmpty)
          const EmptyStateWidget(
            message: 'Belum ada tugas yang dibuat untuk siswa.',
          )
        else
          ...widget.tugasList.map((tugas) {
            final id = tugas['id'] as String;
            final judul = (tugas['judul_tugas'] as String?) ?? (tugas['judul'] as String?) ?? 'Tugas';

            return TaskCardWidget(
              tugas: tugas,
              role: 'teacher',
              onEdit: () => _showEditTugasModal(tugas),
              onDelete: () => _confirmDeleteTugas(id, judul),
            );
          }),
      ],
    );
  }

  // --- TAB 4: BERI NILAI ---
  Widget _buildBeriNilaiTab() {
    if (widget.tugasList.isEmpty) {
      return const EmptyStateWidget(
        message: 'Belum ada tugas untuk dinilai. Buat tugas terlebih dahulu pada tab "Assign Tugas".',
      );
    }

    return BeriNilaiModule(
      teacherServices: _teacherServices,
      courses: widget.courses,
      tugasList: widget.tugasList,
      submissions: widget.submissions,
      onRefresh: widget.onRefresh,
      onShowToast: widget.onShowToast,
    );
  }

  // --- MODALS & DIALOGS ---

  void _showEnrolledStudentsSheet(String courseId, String courseName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EnrolledStudentsSheet(
        courseId: courseId,
        courseName: courseName,
        teacherServices: _teacherServices,
      ),
    );
  }

  void _showUploadMateriModal({String? preselectedCourseId}) {
    if (widget.courses.isEmpty) {
      widget.onShowToast('Anda belum memiliki mata kuliah.', isError: true);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadMateriPage(
          teacherId: widget.teacherId,
          courses: widget.courses,
          preselectedCourseId: preselectedCourseId,
          onRefreshParent: widget.onRefresh,
        ),
      ),
    );
  }

  void _showAssignTugasModal() {
    if (widget.courses.isEmpty) {
      widget.onShowToast('Anda belum memiliki mata kuliah.', isError: true);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssignTugasPage(
          teacherId: widget.teacherId,
          courses: widget.courses,
          onRefreshParent: widget.onRefresh,
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
          courses: widget.courses,
          existingMateri: materi,
          onRefreshParent: widget.onRefresh,
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
          courses: widget.courses,
          existingTugas: tugas,
          onRefreshParent: widget.onRefresh,
        ),
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
        widget.onShowToast('Materi berhasil dihapus.');
        widget.onRefresh();
      } catch (e) {
        widget.onShowToast('Gagal menghapus materi: $e', isError: true);
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
        widget.onShowToast('Tugas berhasil dihapus.');
        widget.onRefresh();
      } catch (e) {
        widget.onShowToast('Gagal menghapus tugas: $e', isError: true);
      }
    }
  }
}


