import 'package:bestpractice/chat/pages/obrolan_page.dart';
import 'package:bestpractice/common/utils/ui_utils.dart';
import 'package:bestpractice/dashboard/pages/student/student_academics_view.dart';
import 'package:bestpractice/dashboard/pages/student/student_home_view.dart';
import 'package:bestpractice/dashboard/pages/widgets/student/student_bottom_nav.dart';
import 'package:bestpractice/profile/pages/profil_page.dart';
import 'package:bestpractice/services/student_services.dart';
import 'package:flutter/material.dart';

class StudentDashboardPage extends StatefulWidget {
  const StudentDashboardPage({super.key, required this.fullName});

  final String fullName;

  @override
  State<StudentDashboardPage> createState() => _StudentDashboardPageState();
}

class _StudentDashboardPageState extends State<StudentDashboardPage> {
  final StudentServices _studentServices = StudentServices();

  int _currentNavIndex = 0;
  late Future<StudentDashboardData> _dashboardData;
  String _studentId = '';

  @override
  void initState() {
    super.initState();
    _studentId = _studentServices.currentStudentId ?? '';
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      final currentId = _studentServices.currentStudentId ?? _studentId;
      _studentId = currentId;
      _dashboardData = _studentServices.getDashboardData(currentId);
    });
  }

  void _showToast(String message, {bool isError = false}) {
    UiUtils.showToast(context, message, isError: isError);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: _currentNavIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentNavIndex != 0) {
          setState(() {
            _currentNavIndex = 0;
          });
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _buildBodyContent(),
          ),
        ),
        bottomNavigationBar: StudentBottomNav(
          currentIndex: _currentNavIndex,
          onTap: (index) {
            setState(() {
              _currentNavIndex = index;
            });
          },
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    switch (_currentNavIndex) {
      case 0:
        return FutureBuilder<StudentDashboardData>(
          future: _dashboardData,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text('Gagal memuat data: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshData,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }

            final data = snapshot.data ??
                const StudentDashboardData(
                  enrolledCourses: [],
                  announcements: [],
                  tugasList: [],
                  materiList: [],
                  submissions: [],
                  totalSks: 0,
                );

            return StudentHomeView(
              fullName: widget.fullName,
              nim: data.nim,
              jurusan: data.jurusan,
              studentId: _studentId,
              submissions: data.submissions,
              totalSks: data.totalSks,
              courseCount: data.courseCount,
              tugasCount: data.tugasCount,
              announcements: data.announcements,
              tugasList: data.tugasList,
              onRefresh: () async => _refreshData(),
              onOpenAcademicsTab: () => setState(() => _currentNavIndex = 1),
              onShowToast: _showToast,
            );
          },
        );

      case 1:
        return FutureBuilder<StudentDashboardData>(
          future: _dashboardData,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data ??
                const StudentDashboardData(
                  enrolledCourses: [],
                  announcements: [],
                  tugasList: [],
                  materiList: [],
                  submissions: [],
                  totalSks: 0,
                );

            return StudentAcademicsView(
              studentId: _studentId,
              enrolledCourses: data.enrolledCourses,
              materiList: data.materiList,
              tugasList: data.tugasList,
              submissions: data.submissions,
              onRefresh: () async => _refreshData(),
              onShowToast: _showToast,
            );
          },
        );

      case 2:
        return ObrolanPage(
          currentUserRole: 'Mahasiswa',
          currentUserName: widget.fullName,
        );

      case 3:
        return ProfilPage(
          fullName: widget.fullName,
          userRole: 'Mahasiswa',
          userEmail: _studentServices.currentStudentEmail ?? 'mahasiswa@kampus.ac.id',
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
