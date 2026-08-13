import 'package:bestpractice/chat/pages/obrolan_page.dart';
import 'package:bestpractice/common/utils/ui_utils.dart';
import 'package:bestpractice/dashboard/pages/teacher/teacher_academics_view.dart';
import 'package:bestpractice/dashboard/pages/teacher/teacher_home_view.dart';
import 'package:bestpractice/dashboard/pages/widgets/teacher/teacher_bottom_nav.dart';
import 'package:bestpractice/profile/pages/profil_page.dart';
import 'package:bestpractice/services/teacher_services.dart';
import 'package:flutter/material.dart';

class TeacherDashboardPage extends StatefulWidget {
  const TeacherDashboardPage({super.key, required this.fullName});

  final String fullName;

  @override
  State<TeacherDashboardPage> createState() => _TeacherDashboardPageState();
}

class _TeacherDashboardPageState extends State<TeacherDashboardPage> {
  final TeacherServices _teacherServices = TeacherServices();

  int _currentNavIndex = 0;
  int _academicsSubTabIndex = 0;

  late Future<TeacherDashboardData> _dashboardData;
  String _teacherId = '';

  @override
  void initState() {
    super.initState();
    _teacherId = _teacherServices.currentTeacherId ?? '';
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      final currentId = _teacherServices.currentTeacherId ?? _teacherId;
      _teacherId = currentId;
      _dashboardData = _teacherServices.getDashboardData(currentId);
    });
  }

  void _showToast(String message, {bool isError = false}) {
    UiUtils.showToast(context, message, isError: isError);
  }

  void _openAcademicsSubTab(int subTabIndex) {
    setState(() {
      _academicsSubTabIndex = subTabIndex;
      _currentNavIndex = 1; // Switch to Academics tab
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _buildBodyContent(),
        ),
      ),
      bottomNavigationBar: TeacherBottomNav(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildBodyContent() {
    switch (_currentNavIndex) {
      case 0:
        return FutureBuilder<TeacherDashboardData>(
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
                const TeacherDashboardData(
                  courses: [],
                  enrolledStudents: [],
                  materiList: [],
                  tugasList: [],
                  submissions: [],
                );

            return TeacherHomeView(
              fullName: widget.fullName,
              courseCount: data.courseCount,
              totalStudentsCount: data.totalStudentsCount,
              materiCount: data.materiCount,
              tugasCount: data.tugasCount,
              announcements: data.announcements,
              onRefresh: () async => _refreshData(),
              onOpenAcademicsTab: _openAcademicsSubTab,
              onShowToast: _showToast,
            );
          },
        );

      case 1:
        return FutureBuilder<TeacherDashboardData>(
          future: _dashboardData,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data ??
                const TeacherDashboardData(
                  courses: [],
                  enrolledStudents: [],
                  materiList: [],
                  tugasList: [],
                  submissions: [],
                );

            return TeacherAcademicsView(
              teacherId: _teacherId,
              courses: data.courses,
              materiList: data.materiList,
              tugasList: data.tugasList,
              submissions: data.submissions,
              initialSubTabIndex: _academicsSubTabIndex,
              onRefresh: () async => _refreshData(),
              onShowToast: _showToast,
            );
          },
        );

      case 2:
        return ObrolanPage(
          currentUserRole: 'Dosen',
          currentUserName: widget.fullName,
        );

      case 3:
        return ProfilPage(
          fullName: widget.fullName,
          userRole: 'Dosen',
          userEmail: _teacherServices.currentTeacherEmail ?? 'dosen@kampus.ac.id',
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
