import 'package:bestpractice/common/utils/ui_utils.dart';
import 'package:bestpractice/dashboard/pages/admin/admin_academics_view.dart';
import 'package:bestpractice/dashboard/pages/admin/admin_buat_pengumuman_view.dart';
import 'package:bestpractice/dashboard/pages/admin/admin_home_view.dart';
import 'package:bestpractice/dashboard/pages/admin/admin_pengumuman_view.dart';
import 'package:bestpractice/dashboard/pages/admin/admin_penugasan_view.dart';
import 'package:bestpractice/dashboard/pages/admin/admin_tambah_matkul_view.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/admin_bottom_nav.dart';
import 'package:bestpractice/services/admin_services.dart';
import 'package:flutter/material.dart';

enum AdminScreen { home, academics, pengumuman, penugasan, tambahMatkul, buatPengumuman }

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key, required this.fullName});

  final String fullName;

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final AdminServices _adminServices = AdminServices();

  AdminScreen _currentScreen = AdminScreen.home;
  AdminScreen _previousScreen = AdminScreen.home;
  int _currentNavIndex = 0;

  // Data Future
  late Future<AdminDashboardData> _dashboardData;

  // Penugasan selection state
  String _selectedCourseId = '';
  String _participantType = 'Siswa'; // 'Siswa' or 'Dosen'

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _dashboardData = _loadData();
    });
  }

  Future<AdminDashboardData> _loadData() async {
    final data = await _adminServices.getDashboardData();

    if (_selectedCourseId.isEmpty && data.courses.isNotEmpty) {
      _selectedCourseId = data.courses.first['id'] as String;
    }

    return data;
  }

  void _showToast(String message, {bool isError = false}) {
    UiUtils.showToast(context, message, isError: isError);
  }

  void _openPenugasan(String type) {
    setState(() {
      _previousScreen = _currentScreen;
      _participantType = type;
      _currentScreen = AdminScreen.penugasan;
    });
  }

  void _openBuatPengumuman() {
    setState(() {
      _previousScreen = _currentScreen;
      _currentScreen = AdminScreen.buatPengumuman;
    });
  }

  void _openTambahMatkul() {
    setState(() {
      _previousScreen = _currentScreen;
      _currentScreen = AdminScreen.tambahMatkul;
    });
  }

  void _navigateBack() {
    setState(() {
      _currentScreen = _previousScreen;
      if (_currentScreen == AdminScreen.home) {
        _currentNavIndex = 0;
      } else if (_currentScreen == AdminScreen.academics) {
        _currentNavIndex = 1;
      } else if (_currentScreen == AdminScreen.pengumuman) {
        _currentNavIndex = 2;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildBodyContent(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AdminBottomNav(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
            if (index == 0) {
              _currentScreen = AdminScreen.home;
              _previousScreen = AdminScreen.home;
            }
            if (index == 1) {
              _currentScreen = AdminScreen.academics;
              _previousScreen = AdminScreen.academics;
            }
            if (index == 2) {
              _currentScreen = AdminScreen.pengumuman;
              _previousScreen = AdminScreen.pengumuman;
            }
          });
        },
      ),
    );
  }

  Widget _buildBodyContent() {
    switch (_currentScreen) {
      case AdminScreen.home:
        return FutureBuilder<AdminDashboardData>(
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
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text('Gagal memuat data: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshData,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              );
            }
            final data = snapshot.requireData;
            return AdminHomeView(
              studentCount: data.students.length,
              teacherCount: data.teachers.length,
              onRefresh: () async => _refreshData(),
              onOpenPenugasan: _openPenugasan,
              onOpenPengumuman: () {
                setState(() {
                  _currentNavIndex = 2;
                  _currentScreen = AdminScreen.pengumuman;
                });
              },
              onShowToast: _showToast,
            );
          },
        );

      case AdminScreen.academics:
        return FutureBuilder<AdminDashboardData>(
          future: _dashboardData,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final data =
                snapshot.data ??
                const AdminDashboardData(
                  courses: [],
                  teachers: [],
                  students: [],
                );
            return AdminAcademicsView(
              courses: data.courses,
              teachers: data.teachers,
              students: data.students,
              onRefresh: () async => _refreshData(),
              onOpenPenugasanForCourse: (courseId, type) {
                setState(() {
                  _previousScreen = _currentScreen;
                  if (courseId.isNotEmpty) _selectedCourseId = courseId;
                  _participantType = type;
                  _currentScreen = AdminScreen.penugasan;
                });
              },
              onOpenBuatPengumuman: _openBuatPengumuman,
              onOpenTambahMatkul: _openTambahMatkul,
              onUnassignTeacher: _handleUnassignTeacher,
              onRemoveStudentFromCourse: _handleRemoveStudentFromCourse,
              onConfirmDeleteCourse: _confirmDeleteCourse,
              onShowToast: _showToast,
            );
          },
        );

      case AdminScreen.pengumuman:
        return AdminPengumumanView(
          onOpenBuatPengumuman: _openBuatPengumuman,
          onShowNotification: () => _showToast('Tidak ada notifikasi baru.'),
          onShowToast: _showToast,
        );

      case AdminScreen.penugasan:
        return FutureBuilder<AdminDashboardData>(
          future: _dashboardData,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final data =
                snapshot.data ??
                const AdminDashboardData(
                  courses: [],
                  teachers: [],
                  students: [],
                );
            return AdminPenugasanView(
              courses: data.courses,
              students: data.students,
              teachers: data.teachers,
              selectedCourseId: _selectedCourseId,
              participantType: _participantType,
              onBack: _navigateBack,
              onCourseSelected: (id) => setState(() => _selectedCourseId = id),
              onParticipantTypeChanged: (type) =>
                  setState(() => _participantType = type),
              onConfirmAssignment: _handleConfirmAssignment,
              onShowNotification: () =>
                  _showToast('Tidak ada notifikasi baru.'),
            );
          },
        );

      case AdminScreen.tambahMatkul:
        return AdminTambahMatkulView(
          onBack: _navigateBack,
          onSaveCourse: _handleSaveNewCourse,
        );

      case AdminScreen.buatPengumuman:
        return AdminBuatPengumumanView(
          fullName: widget.fullName,
          onSendAnnouncement: _handleSendAnnouncement,
          onShowNotification: () => _showToast('Tidak ada notifikasi baru.'),
        );
    }
  }

  // --- HANDLERS & MODALS ---
  Future<void> _handleConfirmAssignment(
    String courseId,
    String participantType,
    List<String> selectedParticipantIds,
  ) async {
    if (courseId.isEmpty) {
      _showToast('Silakan pilih mata kuliah terlebih dahulu.', isError: true);
      return;
    }
    try {
      if (participantType == 'Dosen') {
        if (selectedParticipantIds.length > 1) {
          _showToast(
            'Mata kuliah hanya dapat memiliki 1 dosen pengampu.',
            isError: true,
          );
          return;
        }

        final currentData = await _dashboardData;
        final selectedCourse = currentData.courses.firstWhere(
          (c) => c['id'] == courseId,
          orElse: () => <String, dynamic>{},
        );

        final currentDosenId = selectedCourse['dosen_id'] as String?;
        final newTeacherId = selectedParticipantIds.isNotEmpty
            ? selectedParticipantIds.first
            : null;

        if (newTeacherId != null &&
            currentDosenId != null &&
            currentDosenId != newTeacherId) {
          final currentTeacher = currentData.teachers.firstWhere(
            (t) => t['id'] == currentDosenId,
            orElse: () => <String, dynamic>{},
          );
          final teacherName =
              currentTeacher['full_name'] as String? ?? 'dosen lain';
          _showToast(
            'Mata kuliah ini sudah ditugaskan ke $teacherName. Lepas penugasan dosen terlebih dahulu.',
            isError: true,
          );
          return;
        }

        await _adminServices.assignTeacher(
          courseId: courseId,
          teacherId: newTeacherId,
        );
        if (newTeacherId == null) {
          _showToast('Berhasil melepas penugasan Dosen pengampu.');
        } else {
          _showToast('Berhasil menetapkan Dosen pengampu.');
        }
      } else {
        await _adminServices.assignStudents(
          courseId: courseId,
          studentIds: selectedParticipantIds,
        );
        _showToast(
          'Berhasil memproses penugasan ${selectedParticipantIds.length} siswa.',
        );
      }
      _refreshData();
      _navigateBack();
    } catch (e) {
      _showToast('Gagal memproses penugasan: $e', isError: true);
    }
  }

  Future<void> _handleUnassignTeacher(String courseId) async {
    try {
      await _adminServices.assignTeacher(courseId: courseId, teacherId: null);
      _showToast('Berhasil melepas Dosen pengampu.');
      _refreshData();
    } catch (e) {
      _showToast('Gagal melepas Dosen: $e', isError: true);
    }
  }

  Future<void> _handleRemoveStudentFromCourse(
    String courseId,
    String studentId,
  ) async {
    try {
      await _adminServices.removeStudentFromCourse(
        courseId: courseId,
        studentId: studentId,
      );
      _showToast('Berhasil menghapus siswa dari mata kuliah.');
      _refreshData();
    } catch (e) {
      _showToast('Gagal menghapus siswa: $e', isError: true);
    }
  }

  Future<void> _handleSaveNewCourse({
    required String name,
    required String code,
    required int sks,
    required int semester,
    String? department,
    String? description,
  }) async {
    try {
      await _adminServices.addCourse(
        code: code,
        name: name,
        credits: sks,
        semester: semester,
      );
      _showToast('Mata kuliah "$name" berhasil ditambahkan!');
      _refreshData();
      _navigateBack();
    } catch (e) {
      _showToast('Gagal menyimpan mata kuliah: $e', isError: true);
    }
  }

  Future<void> _handleSendAnnouncement({
    required String title,
    required String content,
    required bool isUrgent,
  }) async {
    if (title.isEmpty || content.isEmpty) {
      _showToast('Judul dan isi pengumuman tidak boleh kosong.', isError: true);
      return;
    }
    try {
      await _adminServices.createAnnouncement(
        title: title,
        content: content,
        isUrgent: isUrgent,
      );
      _showToast('Pengumuman telah berhasil dikirim!');
      _navigateBack();
    } catch (e) {
      _showToast('Gagal mengirim pengumuman: $e', isError: true);
    }
  }

  Future<void> _confirmDeleteCourse(Map<String, dynamic> course) async {
    final name = course['nama_mk'] ?? 'Mata Kuliah';
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus mata kuliah?'),
        content: Text('"$name" akan dihapus secara permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await _adminServices.deleteCourse(course['id'] as String);
        _refreshData();
        _showToast('Mata kuliah berhasil dihapus.');
      } catch (e) {
        _showToast('Gagal menghapus mata kuliah: $e', isError: true);
      }
    }
  }
}
