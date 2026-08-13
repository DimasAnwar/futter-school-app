import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TeacherDashboardData {
  const TeacherDashboardData({
    required this.courses,
    required this.enrolledStudents,
    required this.materiList,
    required this.tugasList,
    required this.submissions,
    this.announcements = const [],
  });

  final List<Map<String, dynamic>> courses;
  final List<Map<String, dynamic>> enrolledStudents;
  final List<Map<String, dynamic>> materiList;
  final List<Map<String, dynamic>> tugasList;
  final List<Map<String, dynamic>> submissions;
  final List<Map<String, dynamic>> announcements;

  int get courseCount => courses.length;
  int get totalStudentsCount {
    final studentIds = enrolledStudents.map((s) => s['id'] as String?).whereType<String>().toSet();
    return studentIds.length;
  }
  int get materiCount => materiList.length;
  int get tugasCount => tugasList.length;
}

class TeacherServices {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get currentTeacherId => _supabase.auth.currentUser?.id;
  String? get currentTeacherEmail => _supabase.auth.currentUser?.email;

  /// Fetch unified dashboard data for a teacher
  Future<TeacherDashboardData> getDashboardData(String teacherId) async {
    final courses = await getTeacherCourses(teacherId);
    final courseIds = courses.map((c) => c['id'] as String).toList();

    final enrolledStudentsFuture = getStudentsForCourses(courseIds);
    final materiFuture = getMateriForCourses(courseIds, teacherId);
    final tugasFuture = getTugasForCourses(courseIds, teacherId);
    final submissionsFuture = getSubmissionsForTeacher(teacherId);
    final announcementsFuture = getAnnouncements();

    final results = await Future.wait([
      enrolledStudentsFuture,
      materiFuture,
      tugasFuture,
      submissionsFuture,
      announcementsFuture,
    ]);

    return TeacherDashboardData(
      courses: courses,
      enrolledStudents: results[0],
      materiList: results[1],
      tugasList: results[2],
      submissions: results[3],
      announcements: results[4],
    );
  }

  Future<List<Map<String, dynamic>>> getAnnouncements() async {
    try {
      final data = await _supabase.from('pengumuman').select('*').order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  /// Get courses taught by this teacher
  Future<List<Map<String, dynamic>>> getTeacherCourses(String teacherId) async {
    try {
      final data = await _supabase
          .from('mata_kuliah')
          .select('id, kode_mk, nama_mk, sks, semester, dosen_id, created_at')
          .eq('dosen_id', teacherId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      if (kDebugMode) print('Error getTeacherCourses: $e');
      return [];
    }
  }

  /// Get students enrolled in a list of course IDs (fetches enrollments + profile matching)
  Future<List<Map<String, dynamic>>> getStudentsForCourses(List<String> courseIds) async {
    try {
      // 1. Fetch enrollments for teacher's courses
      final rawEnrollments = await _supabase
          .from('enrollments')
          .select('course_id, student_id');

      final enrollments = List<Map<String, dynamic>>.from(rawEnrollments);
      final filteredEnrollments = courseIds.isEmpty
          ? enrollments
          : enrollments.where((e) => courseIds.contains(e['course_id'])).toList();

      final studentIds = filteredEnrollments
          .map((e) => e['student_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      if (studentIds.isEmpty) return [];

      // 2. Fetch profiles and match by ID
      try {
        final rawProfiles = await _supabase
            .from('profiles')
            .select('id, full_name, email, role, nim');

        final allProfiles = List<Map<String, dynamic>>.from(rawProfiles);
        final matchedProfiles = allProfiles.where((p) => studentIds.contains(p['id'])).toList();

        if (matchedProfiles.isNotEmpty) {
          return matchedProfiles;
        }
      } catch (e) {
        if (kDebugMode) print('Error fetching profiles: $e');
      }

      return studentIds.map((id) => {'id': id, 'full_name': 'Siswa', 'email': '-'}).toList();
    } catch (e) {
      if (kDebugMode) print('Error getStudentsForCourses: $e');
      return [];
    }
  }

  /// Get enrolled student profiles for a specific course
  Future<List<Map<String, dynamic>>> getEnrolledStudentsForCourse(String courseId) async {
    try {
      // 1. Get student_ids from enrollments
      final rawEnrollments = await _supabase
          .from('enrollments')
          .select('student_id')
          .eq('course_id', courseId);

      final studentIds = (rawEnrollments as List)
          .map((e) => e['student_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      if (studentIds.isEmpty) return [];

      // 2. Fetch profiles and match by ID
      try {
        final rawProfiles = await _supabase
            .from('profiles')
            .select('id, full_name, email, role, nim');

        final allProfiles = List<Map<String, dynamic>>.from(rawProfiles);
        final matchedProfiles = allProfiles.where((p) => studentIds.contains(p['id'])).toList();

        if (matchedProfiles.isNotEmpty) {
          return matchedProfiles;
        }
      } catch (e) {
        if (kDebugMode) print('Error fetching profiles for course: $e');
      }

      return studentIds.map((id) => {'id': id, 'full_name': 'Siswa', 'email': '-'}).toList();
    } catch (e) {
      if (kDebugMode) print('Error getEnrolledStudentsForCourse: $e');
      return [];
    }
  }

  // --- MATERI SERVICES ---

  /// Fetch learning materials for courses or teacher
  Future<List<Map<String, dynamic>>> getMateriForCourses(
    List<String> courseIds,
    String teacherId,
  ) async {
    try {
      final rawData = await _supabase
          .from('materi')
          .select('*, mata_kuliah(nama_mk, kode_mk)')
          .order('created_at', ascending: false);

      final list = List<Map<String, dynamic>>.from(rawData);
      if (courseIds.isEmpty) return list;
      return list.where((m) => courseIds.contains(m['course_id'])).toList();
    } catch (_) {
      return [];
    }
  }

  /// Upload / Add new material
  Future<void> addMateri({
    required String courseId,
    required String judul,
    required String deskripsi,
    String? fileUrl,
    required String teacherId,
  }) async {
    try {
      await _supabase.from('materi').insert({
        'course_id': courseId,
        'judul_materi': judul,
        'file_url': fileUrl ?? '',
        'tipe_materi': 'document',
      });
    } catch (_) {
      await _supabase.from('materi').insert({
        'course_id': courseId,
        'judul': judul,
        'deskripsi': deskripsi,
        'file_url': fileUrl ?? '',
        'dosen_id': teacherId,
      });
    }
  }

  /// Delete material by ID
  Future<void> deleteMateri(String materiId) async {
    await _supabase.from('materi').delete().eq('id', materiId);
  }

  // --- TUGAS SERVICES ---

  /// Fetch assignments for courses or teacher
  Future<List<Map<String, dynamic>>> getTugasForCourses(
    List<String> courseIds,
    String teacherId,
  ) async {
    try {
      final rawData = await _supabase
          .from('tugas')
          .select('*, mata_kuliah(nama_mk, kode_mk)')
          .order('created_at', ascending: false);

      final list = List<Map<String, dynamic>>.from(rawData);
      if (courseIds.isEmpty) return list;
      return list.where((t) => courseIds.contains(t['course_id'])).toList();
    } catch (_) {
      return [];
    }
  }

  /// Create / Assign new task
  Future<void> addTugas({
    required String courseId,
    required String judul,
    required String deskripsi,
    required String deadline,
    DateTime? deadlineDateTime,
    required String teacherId,
  }) async {
    final isoDeadline = deadlineDateTime?.toIso8601String() ?? deadline;
    try {
      await _supabase.from('tugas').insert({
        'course_id': courseId,
        'judul_tugas': judul,
        'deskripsi': deskripsi,
        'deadline': isoDeadline,
      });
    } catch (e1) {
      if (kDebugMode) print('addTugas e1: $e1');
      try {
        await _supabase.from('tugas').insert({
          'course_id': courseId,
          'judul_tugas': judul,
          'deskripsi': deskripsi,
          'deadline': deadline,
        });
      } catch (e2) {
        if (kDebugMode) print('addTugas e2: $e2');
        await _supabase.from('tugas').insert({
          'course_id': courseId,
          'judul': judul,
          'deskripsi': deskripsi,
          'deadline': isoDeadline,
          'dosen_id': teacherId,
        });
      }
    }
  }

  /// Delete assignment by ID
  Future<void> deleteTugas(String tugasId) async {
    await _supabase.from('tugas').delete().eq('id', tugasId);
  }

  /// Update existing material by ID
  Future<void> updateMateri({
    required String materiId,
    required String judul,
    required String deskripsi,
    String? fileUrl,
  }) async {
    final payload = <String, dynamic>{
      'judul_materi': judul,
      'deskripsi': deskripsi,
      'file_url': fileUrl ?? '',
    };
    try {
      await _supabase.from('materi').update(payload).eq('id', materiId);
    } catch (_) {
      await _supabase.from('materi').update({
        'judul': judul,
        'deskripsi': deskripsi,
        'link_file': fileUrl ?? '',
      }).eq('id', materiId);
    }
  }

  /// Update existing task by ID
  Future<void> updateTugas({
    required String tugasId,
    required String judul,
    required String deskripsi,
    required String deadline,
    DateTime? deadlineDateTime,
  }) async {
    final isoDeadline = deadlineDateTime?.toIso8601String() ?? deadline;
    final payload = <String, dynamic>{
      'judul_tugas': judul,
      'deskripsi': deskripsi,
      'deadline': isoDeadline,
    };
    try {
      await _supabase.from('tugas').update(payload).eq('id', tugasId);
    } catch (_) {
      await _supabase.from('tugas').update({
        'judul': judul,
        'deskripsi': deskripsi,
        'deadline': deadline,
      }).eq('id', tugasId);
    }
  }

  // --- PENILAIAN / SUBMISSIONS SERVICES ---

  /// Get submissions for a teacher's assignments
  Future<List<Map<String, dynamic>>> getSubmissionsForTeacher(String teacherId) async {
    try {
      final data = await _supabase
          .from('pengumpulan_tugas')
          .select('*, tugas(id, judul_tugas, deskripsi, course_id, mata_kuliah(nama_mk, kode_mk)), profiles(id, full_name, email, nim)');
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  /// Save or update grade for a student submission or task assignment
  Future<void> gradeSubmission({
    required String tugasId,
    required String studentId,
    required double nilai,
    String? catatanDosen,
  }) async {
    try {
      final existing = await _supabase
          .from('pengumpulan_tugas')
          .select('id')
          .eq('tugas_id', tugasId)
          .eq('student_id', studentId)
          .maybeSingle();

      if (existing != null) {
        await _supabase.from('pengumpulan_tugas').update({
          'nilai': nilai,
          'status': 'graded',
        }).eq('id', existing['id']);
      } else {
        await _supabase.from('pengumpulan_tugas').insert({
          'tugas_id': tugasId,
          'student_id': studentId,
          'nilai': nilai,
          'status': 'graded',
          'tanggal_kumpul': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      rethrow;
    }
  }
}
