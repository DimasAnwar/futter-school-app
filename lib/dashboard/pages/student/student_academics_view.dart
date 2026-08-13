import 'package:bestpractice/dashboard/pages/student/student_course_detail_page.dart';
import 'package:bestpractice/dashboard/pages/student/student_materi_detail_page.dart';
import 'package:bestpractice/dashboard/pages/student/submit_tugas_page.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/empty_state.dart';
import 'package:bestpractice/dashboard/pages/widgets/course_card_widget.dart';
import 'package:bestpractice/dashboard/pages/widgets/materi_card_widget.dart';
import 'package:bestpractice/dashboard/pages/widgets/task_card_widget.dart';
import 'package:flutter/material.dart';

class StudentAcademicsView extends StatefulWidget {
  const StudentAcademicsView({
    super.key,
    required this.studentId,
    required this.enrolledCourses,
    required this.materiList,
    required this.tugasList,
    required this.submissions,
    required this.onRefresh,
    required this.onShowToast,
  });

  final String studentId;
  final List<Map<String, dynamic>> enrolledCourses;
  final List<Map<String, dynamic>> materiList;
  final List<Map<String, dynamic>> tugasList;
  final List<Map<String, dynamic>> submissions;
  final Future<void> Function() onRefresh;
  final Function(String message, {bool isError}) onShowToast;

  @override
  State<StudentAcademicsView> createState() => _StudentAcademicsViewState();
}

class _StudentAcademicsViewState extends State<StudentAcademicsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Header
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF2563EB),
            unselectedLabelColor: const Color(0xFF64748B),
            indicatorColor: const Color(0xFF2563EB),
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(text: 'Mata Kuliah'),
              Tab(text: 'Materi'),
              Tab(text: 'Tugas Kuliah'),
            ],
          ),
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCoursesTab(),
              _buildMateriTab(),
              _buildTugasTab(),
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 1: MATA KULIAH ---
  Widget _buildCoursesTab() {
    if (widget.enrolledCourses.isEmpty) {
      return const EmptyStateWidget(
        message: 'Anda belum terdaftar pada mata kuliah apapun.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.enrolledCourses.length,
      itemBuilder: (context, index) {
        final course = widget.enrolledCourses[index];
        final courseId = course['id'] as String? ?? '';

        final courseMateriCount = widget.materiList.where((m) {
          final cId = m['course_id'] as String? ?? ((m['mata_kuliah'] as Map<String, dynamic>?)?['id'] as String?);
          return cId == courseId;
        }).length;

        final courseTugasCount = widget.tugasList.where((t) {
          final cId = t['course_id'] as String? ?? ((t['mata_kuliah'] as Map<String, dynamic>?)?['id'] as String?);
          return cId == courseId;
        }).length;

        return CourseCardWidget(
          course: course,
          role: 'student',
          materiCount: courseMateriCount,
          tugasCount: courseTugasCount,
          onTapCard: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudentCourseDetailPage(
                  course: course,
                  studentId: widget.studentId,
                  materiList: widget.materiList,
                  tugasList: widget.tugasList,
                  submissions: widget.submissions,
                  onRefresh: widget.onRefresh,
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- TAB 2: MATERI KULIAH ---
  Widget _buildMateriTab() {
    if (widget.materiList.isEmpty) {
      return const EmptyStateWidget(
        message: 'Belum ada materi perkuliahan yang diunggah oleh dosen.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.materiList.length,
      itemBuilder: (context, index) {
        final materi = widget.materiList[index];

        return MateriCardWidget(
          materi: materi,
          role: 'student',
          onTapCard: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudentMateriDetailPage(materi: materi),
              ),
            );
          },
        );
      },
    );
  }

  // --- TAB 3: TUGAS KULIAH ---
  Widget _buildTugasTab() {
    if (widget.tugasList.isEmpty) {
      return const EmptyStateWidget(
        message: 'Belum ada tugas perkuliahan dari dosen.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.tugasList.length,
      itemBuilder: (context, index) {
        final tugas = widget.tugasList[index];
        final tugasId = tugas['id'] as String;
        final existingSub = widget.submissions.cast<Map<String, dynamic>?>().firstWhere(
          (s) => s != null && s['tugas_id'] == tugasId,
          orElse: () => null,
        );

        return TaskCardWidget(
          tugas: tugas,
          submission: existingSub,
          role: 'student',
          onPrimaryAction: () async {
            final updated = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => SubmitTugasPage(
                  tugas: tugas,
                  studentId: widget.studentId,
                  existingSubmission: existingSub,
                ),
              ),
            );

            if (updated == true) {
              await widget.onRefresh();
            }
          },
        );
      },
    );
  }
}
