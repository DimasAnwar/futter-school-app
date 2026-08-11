import 'package:bestpractice/common/utils/course_utils.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/academics_quick_actions.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/admin_header.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/card_container.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/custom_text_field.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/empty_state.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/manage_course_students_sheet.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/section_header.dart';
import 'package:bestpractice/services/admin_services.dart';
import 'package:flutter/material.dart';

class AdminAcademicsView extends StatefulWidget {
  const AdminAcademicsView({
    super.key,
    required this.courses,
    required this.teachers,
    required this.students,
    required this.onRefresh,
    required this.onOpenPenugasanForCourse,
    required this.onOpenBuatPengumuman,
    required this.onOpenTambahMatkul,
    required this.onUnassignTeacher,
    required this.onRemoveStudentFromCourse,
    required this.onConfirmDeleteCourse,
    required this.onShowToast,
  });

  final List<Map<String, dynamic>> courses;
  final List<Map<String, dynamic>> teachers;
  final List<Map<String, dynamic>> students;
  final Future<void> Function() onRefresh;
  final Function(String courseId, String participantType) onOpenPenugasanForCourse;
  final VoidCallback onOpenBuatPengumuman;
  final VoidCallback onOpenTambahMatkul;
  final Function(String courseId) onUnassignTeacher;
  final Function(String courseId, String studentId) onRemoveStudentFromCourse;
  final Function(Map<String, dynamic> course) onConfirmDeleteCourse;
  final Function(String message, {bool isError}) onShowToast;

  @override
  State<AdminAcademicsView> createState() => _AdminAcademicsViewState();
}

class _AdminAcademicsViewState extends State<AdminAcademicsView> {
  String _searchQuery = '';
  final AdminServices _adminServices = AdminServices();

  @override
  Widget build(BuildContext context) {
    final filteredCourses = widget.courses.where((c) {
      final query = _searchQuery.toLowerCase();
      final name = (c['nama_mk'] as String? ?? '').toLowerCase();
      final code = (c['kode_mk'] as String? ?? '').toLowerCase();
      return name.contains(query) || code.contains(query);
    }).toList();

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Header Row
          AdminHeader(
            onNotificationTap: () => widget.onShowToast('Tidak ada notifikasi baru.'),
          ),
          const SizedBox(height: 20),

          // Title Section
          const SectionHeader(
            title: 'Pusat Akademik',
            subtitle: 'Kelola mata kuliah, penugasan dosen, siswa, dan pengumuman.',
          ),

          // 1. Quick Actions Grid (4 Cards)
          AcademicsQuickActions(
            onOpenAssignDosen: () => widget.onOpenPenugasanForCourse('', 'Dosen'),
            onOpenAssignSiswa: () => widget.onOpenPenugasanForCourse('', 'Siswa'),
            onOpenBuatPengumuman: widget.onOpenBuatPengumuman,
            onOpenTambahMatkul: widget.onOpenTambahMatkul,
          ),

          const SizedBox(height: 24),

          // 2. Course Management Header & Search
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pengelolaan Mata Kuliah',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                _searchQuery.trim().isEmpty
                    ? '${widget.courses.length} Total Mata Kuliah'
                    : '${filteredCourses.length} Ditemukan',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          CustomSearchInput(
            hintText: 'Cari mata kuliah atau kode...',
            onChanged: (val) => setState(() => _searchQuery = val),
          ),

          const SizedBox(height: 14),

          // 3. Course List Cards (Only display when searching)
          if (_searchQuery.trim().isEmpty)
            CardContainer(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              child: Column(
                children: const [
                  Icon(
                    Icons.search_rounded,
                    size: 40,
                    color: Color(0xFF94A3B8),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Cari Mata Kuliah',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ketik nama atau kode mata kuliah pada kolom pencarian di atas untuk mengelola.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            )
          else if (filteredCourses.isEmpty)
            EmptyStateWidget(message: 'Tidak ada mata kuliah yang cocok dengan "$_searchQuery".')
          else
            ...filteredCourses.map((course) {
              final id = course['id'] as String;
              final name = (course['nama_mk'] as String?) ?? 'Mata Kuliah';
              final code = (course['kode_mk'] as String?) ?? 'CS101';
              final sks = course['sks'] ?? 3;
              final sem = (course['semester'] as int? ?? 1) % 2 == 1 ? 'Ganjil' : 'Genap';
              final iconData = CourseUtils.getIconForCourse(name);

              final dosenId = course['dosen_id'] as String?;
              final teacher = widget.teachers.firstWhere(
                (t) => t['id'] == dosenId,
                orElse: () => <String, dynamic>{},
              );
              final teacherName = teacher['full_name'] as String?;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                child: CardContainer(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Icon, Title, Code Badge & Delete Button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(iconData, color: const Color(0xFF2563EB), size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$code • $sks SKS • Sem $sem',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                            onPressed: () => widget.onConfirmDeleteCourse(course),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 8),

                      // Dosen Pengampu Row
                      Row(
                        children: [
                          const Icon(Icons.school_rounded, size: 18, color: Color(0xFF2563EB)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: teacherName != null
                                ? Text.rich(
                                    TextSpan(
                                      text: 'Dosen: ',
                                      style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                                      children: [
                                        TextSpan(
                                          text: teacherName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const Text(
                                    'Dosen: Belum ditugaskan',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF94A3B8),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                          ),
                          if (teacherName != null) ...[
                            TextButton(
                              onPressed: () => widget.onOpenPenugasanForCourse(id, 'Dosen'),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF2563EB),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Ganti', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 4),
                            TextButton(
                              onPressed: () => widget.onUnassignTeacher(id),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFFEF4444),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Lepas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ] else
                            ElevatedButton(
                              onPressed: () => widget.onOpenPenugasanForCourse(id, 'Dosen'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEFF6FF),
                                foregroundColor: const Color(0xFF2563EB),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('+ Tetapkan Dosen', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Kelola Siswa Button
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showManageStudentsModal(context, id, name),
                              icon: const Icon(Icons.people_outline_rounded, size: 16),
                              label: const Text('Kelola / Hapus Siswa Terdaftar', style: TextStyle(fontSize: 12)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF3B82F6),
                                side: const BorderSide(color: Color(0xFFBFDBFE)),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.person_add_alt_1_outlined, color: Color(0xFF059669), size: 20),
                            tooltip: 'Tambah Siswa',
                            onPressed: () => widget.onOpenPenugasanForCourse(id, 'Siswa'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _showManageStudentsModal(BuildContext context, String courseId, String courseName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return ManageCourseStudentsSheet(
          courseId: courseId,
          courseName: courseName,
          adminServices: _adminServices,
          onRemoveStudent: (studentId) async {
            widget.onRemoveStudentFromCourse(courseId, studentId);
          },
        );
      },
    );
  }
}
