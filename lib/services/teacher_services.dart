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
    this.enrollments = const [],
  });

  final List<Map<String, dynamic>> courses;
  final List<Map<String, dynamic>> enrolledStudents;
  final List<Map<String, dynamic>> materiList;
  final List<Map<String, dynamic>> tugasList;
  final List<Map<String, dynamic>> submissions;
  final List<Map<String, dynamic>> announcements;
  final List<Map<String, dynamic>> enrollments;

  int get courseCount => courses.length;
  int get totalStudentsCount {
    final studentIds = enrolledStudents.map((s) => s['id'] as String?).whereType<String>().toSet();
    if (studentIds.isNotEmpty) return studentIds.length;
    final enrollStudentIds = enrollments.map((e) => e['student_id'] as String?).whereType<String>().toSet();
    return enrollStudentIds.length;
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
    final enrollmentsFuture = getRawEnrollmentsForCourses(courseIds);

    final results = await Future.wait([
      enrolledStudentsFuture,
      materiFuture,
      tugasFuture,
      submissionsFuture,
      announcementsFuture,
      enrollmentsFuture,
    ]);

    return TeacherDashboardData(
      courses: courses,
      enrolledStudents: results[0],
      materiList: results[1],
      tugasList: results[2],
      submissions: results[3],
      announcements: results[4],
      enrollments: results[5],
    );
  }

  /// Get raw enrollments list for courseIds
  Future<List<Map<String, dynamic>>> getRawEnrollmentsForCourses(List<String> courseIds) async {
    try {
      var query = _supabase.from('enrollments').select('course_id, student_id');
      if (courseIds.isNotEmpty) {
        query = query.inFilter('course_id', courseIds);
      }
      final raw = await query;
      return List<Map<String, dynamic>>.from(raw);
    } catch (_) {
      return [];
    }
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

  /// Resilient helper to fetch student profiles by IDs without failing on missing columns or RLS
  Future<List<Map<String, dynamic>>> _fetchProfilesByIds(List<String> studentIds) async {
    if (studentIds.isEmpty) return [];

    // Attempt 1: select id, full_name, email, role, nim, jurusan with inFilter
    try {
      final data = await _supabase
          .from('profiles')
          .select('id, full_name, email, role, nim, jurusan')
          .inFilter('id', studentIds);
      final list = List<Map<String, dynamic>>.from(data);
      if (list.isNotEmpty) return list;
    } catch (e) {
      if (kDebugMode) print('Attempt 1 failed: $e');
    }

    // Attempt 2: select id, full_name, email, role, nim with inFilter
    try {
      final data = await _supabase
          .from('profiles')
          .select('id, full_name, email, role, nim')
          .inFilter('id', studentIds);
      final list = List<Map<String, dynamic>>.from(data);
      if (list.isNotEmpty) return list;
    } catch (e) {
      if (kDebugMode) print('Attempt 2 failed: $e');
    }

    // Attempt 3: select id, full_name, email, role (proven to work in admin_services) with inFilter
    try {
      final data = await _supabase
          .from('profiles')
          .select('id, full_name, email, role')
          .inFilter('id', studentIds);
      final list = List<Map<String, dynamic>>.from(data);
      if (list.isNotEmpty) return list;
    } catch (e) {
      if (kDebugMode) print('Attempt 3 failed: $e');
    }

    // Attempt 4: select id, full_name, email, role for all profiles
    try {
      final data = await _supabase
          .from('profiles')
          .select('id, full_name, email, role');
      final allProfiles = List<Map<String, dynamic>>.from(data);
      final matched = allProfiles.where((p) {
        final pId = p['id']?.toString().trim().toLowerCase();
        return studentIds.any((sId) => sId.toLowerCase() == pId);
      }).toList();
      if (matched.isNotEmpty) return matched;
    } catch (e) {
      if (kDebugMode) print('Attempt 4 failed: $e');
    }

    // Attempt 5: select * with inFilter
    try {
      final data = await _supabase
          .from('profiles')
          .select('*')
          .inFilter('id', studentIds);
      final list = List<Map<String, dynamic>>.from(data);
      if (list.isNotEmpty) return list;
    } catch (e) {
      if (kDebugMode) print('Attempt 5 failed: $e');
    }

    // Attempt 6: select * for all profiles
    try {
      final data = await _supabase.from('profiles').select('*');
      final allProfiles = List<Map<String, dynamic>>.from(data);
      final matched = allProfiles.where((p) {
        final pId = p['id']?.toString().trim().toLowerCase();
        return studentIds.any((sId) => sId.toLowerCase() == pId);
      }).toList();
      if (matched.isNotEmpty) return matched;
    } catch (e) {
      if (kDebugMode) print('Attempt 6 failed: $e');
    }

    // Attempt 7: Query individually with select('id, full_name, email, role')
    final result = <Map<String, dynamic>>[];
    for (final sId in studentIds) {
      try {
        final pData = await _supabase
            .from('profiles')
            .select('id, full_name, email, role')
            .eq('id', sId)
            .maybeSingle();
        if (pData != null) {
          result.add(Map<String, dynamic>.from(pData));
        }
      } catch (_) {}
    }
    return result;
  }

  /// Get students enrolled in a list of course IDs (fetches enrollments + profile matching)
  Future<List<Map<String, dynamic>>> getStudentsForCourses(List<String> courseIds) async {
    try {
      final rawEnrollments = await _supabase
          .from('enrollments')
          .select('course_id, student_id');

      final enrollments = List<Map<String, dynamic>>.from(rawEnrollments);
      final filteredEnrollments = courseIds.isEmpty
          ? enrollments
          : enrollments.where((e) => courseIds.contains(e['course_id'])).toList();

      final studentIds = filteredEnrollments
          .map((e) => e['student_id']?.toString().trim())
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      if (studentIds.isEmpty) return [];

      final profiles = await _fetchProfilesByIds(studentIds);
      if (profiles.isNotEmpty) return profiles;

      return studentIds.map((id) => <String, dynamic>{
        'id': id,
        'full_name': 'Siswa (${id.length > 6 ? id.substring(0, 6) : id})',
        'email': '-',
        'nim': '-',
      }).toList();
    } catch (e) {
      if (kDebugMode) print('Error getStudentsForCourses: $e');
      return [];
    }
  }

  /// Get enrolled student profiles for a specific course
  Future<List<Map<String, dynamic>>> getEnrolledStudentsForCourse(String courseId) async {
    try {
      final rawEnrollments = await _supabase
          .from('enrollments')
          .select('student_id')
          .eq('course_id', courseId);

      final studentIds = (rawEnrollments as List)
          .map((e) => e['student_id']?.toString().trim())
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      if (studentIds.isEmpty) return [];

      final profiles = await _fetchProfilesByIds(studentIds);
      if (profiles.isNotEmpty) return profiles;

      return studentIds.map((id) => <String, dynamic>{
        'id': id,
        'full_name': 'Siswa (${id.length > 6 ? id.substring(0, 6) : id})',
        'email': '-',
        'nim': '-',
      }).toList();
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
      List<Map<String, dynamic>> submissions = [];
      try {
        final data = await _supabase
            .from('pengumpulan_tugas')
            .select('*, tugas(id, judul_tugas, deskripsi, course_id, mata_kuliah(nama_mk, kode_mk)), profiles(id, full_name, email, nim)');
        submissions = List<Map<String, dynamic>>.from(data);
      } catch (e) {
        if (kDebugMode) print('Submissions join query failed, falling back: $e');
        final data = await _supabase
            .from('pengumpulan_tugas')
            .select('*, tugas(id, judul_tugas, deskripsi, course_id, mata_kuliah(nama_mk, kode_mk))');
        submissions = List<Map<String, dynamic>>.from(data);
      }

      // Attach profile info manually if profiles join was null
      final studentIds = submissions
          .map((s) => s['student_id']?.toString().trim())
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      if (studentIds.isNotEmpty) {
        try {
          final allProfiles = await _fetchProfilesByIds(studentIds);

          for (final sub in submissions) {
            final currentProf = sub['profiles'];
            if (currentProf == null || (currentProf is Map && currentProf['full_name'] == null)) {
              final subStudentId = sub['student_id']?.toString().trim().toLowerCase();
              final matched = allProfiles.firstWhere(
                (p) => p['id']?.toString().trim().toLowerCase() == subStudentId,
                orElse: () => <String, dynamic>{},
              );
              if (matched.isNotEmpty) {
                sub['profiles'] = matched;
              }
            }
          }
        } catch (e) {
          if (kDebugMode) print('Error manually attaching profiles to submissions: $e');
        }
      }

      return submissions;
    } catch (e) {
      if (kDebugMode) print('Error getSubmissionsForTeacher: $e');
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
