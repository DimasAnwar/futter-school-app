import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentDashboardData {
  const StudentDashboardData({
    required this.enrolledCourses,
    required this.announcements,
    required this.tugasList,
    required this.materiList,
    required this.submissions,
    required this.totalSks,
    this.profile,
  });

  final List<Map<String, dynamic>> enrolledCourses;
  final List<Map<String, dynamic>> announcements;
  final List<Map<String, dynamic>> tugasList;
  final List<Map<String, dynamic>> materiList;
  final List<Map<String, dynamic>> submissions;
  final int totalSks;
  final Map<String, dynamic>? profile;

  int get courseCount => enrolledCourses.length;
  int get tugasCount => tugasList.length;

  String get nim => (profile?['nim'] as String?) ?? '-';
  String get jurusan =>
      (profile?['jurusan'] as String?) ??
      (profile?['program_studi'] as String?) ??
      (profile?['prodi'] as String?) ??
      'Teknik Informatika';
}

class StudentServices {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get currentStudentId => _supabase.auth.currentUser?.id;
  String? get currentStudentEmail => _supabase.auth.currentUser?.email;

  Future<StudentDashboardData> getDashboardData(String studentId) async {
    try {
      // Fetch Profile
      Map<String, dynamic>? profile;
      if (studentId.isNotEmpty) {
        try {
          final profileData = await _supabase
              .from('profiles')
              .select('*')
              .eq('id', studentId)
              .maybeSingle();
          if (profileData != null) {
            profile = Map<String, dynamic>.from(profileData);
          }
        } catch (e) {
          if (kDebugMode) print('Error fetching profile: $e');
        }
      }

      // 1. Fetch Enrolled Courses
      List<Map<String, dynamic>> enrolledCourses = [];
      try {
        final enrollData = await _supabase
            .from('enrollments')
            .select('*, mata_kuliah(*)')
            .eq('student_id', studentId);
        
        for (final e in List<Map<String, dynamic>>.from(enrollData)) {
          if (e['mata_kuliah'] != null) {
            enrolledCourses.add(Map<String, dynamic>.from(e['mata_kuliah']));
          }
        }
      } catch (e) {
        if (kDebugMode) print('Error fetching enrollments: $e');
        // Fallback: fetch all courses if no enrollments policy yet
        final allCourses = await _supabase.from('mata_kuliah').select('*');
        enrolledCourses = List<Map<String, dynamic>>.from(allCourses);
      }

      final courseIds = enrolledCourses.map((c) => c['id'] as String).toList();

      // Calculate Total SKS
      int totalSks = 0;
      for (final course in enrolledCourses) {
        final sks = course['sks'];
        if (sks != null) {
          totalSks += (sks is int) ? sks : (int.tryParse(sks.toString()) ?? 0);
        }
      }

      // 2. Fetch Announcements
      List<Map<String, dynamic>> announcements = [];
      try {
        final annData = await _supabase
            .from('pengumuman')
            .select('*')
            .order('created_at', ascending: false);
        announcements = List<Map<String, dynamic>>.from(annData);
      } catch (e) {
        if (kDebugMode) print('Error fetching pengumuman: $e');
      }

      // 3. Fetch Tasks
      List<Map<String, dynamic>> tugasList = [];
      try {
        final tData = await _supabase
            .from('tugas')
            .select('*, mata_kuliah(nama_mk, kode_mk)');
        final allTugas = List<Map<String, dynamic>>.from(tData);
        if (courseIds.isEmpty) {
          tugasList = allTugas;
        } else {
          tugasList = allTugas.where((t) => courseIds.contains(t['course_id'])).toList();
        }
      } catch (e) {
        if (kDebugMode) print('Error fetching tugas: $e');
      }

      // 4. Fetch Materi
      List<Map<String, dynamic>> materiList = [];
      try {
        final mData = await _supabase
            .from('materi')
            .select('*, mata_kuliah(nama_mk, kode_mk)');
        final allMateri = List<Map<String, dynamic>>.from(mData);
        if (courseIds.isEmpty) {
          materiList = allMateri;
        } else {
          materiList = allMateri.where((m) => courseIds.contains(m['course_id'])).toList();
        }
      } catch (e) {
        if (kDebugMode) print('Error fetching materi: $e');
      }

      // 5. Fetch Submissions
      List<Map<String, dynamic>> submissions = [];
      if (studentId.isNotEmpty) {
        try {
          final subData = await _supabase
              .from('pengumpulan_tugas')
              .select('*')
              .eq('student_id', studentId);
          submissions = List<Map<String, dynamic>>.from(subData);
        } catch (e) {
          if (kDebugMode) print('Error fetching submissions: $e');
        }
      }

      return StudentDashboardData(
        enrolledCourses: enrolledCourses,
        announcements: announcements,
        tugasList: tugasList,
        materiList: materiList,
        submissions: submissions,
        totalSks: totalSks,
        profile: profile,
      );
    } catch (e) {
      if (kDebugMode) print('StudentServices getDashboardData error: $e');
      return const StudentDashboardData(
        enrolledCourses: [],
        announcements: [],
        tugasList: [],
        materiList: [],
        submissions: [],
        totalSks: 0,
      );
    }
  }

  /// Submit assignment response with Bad Request protection & fallback schema handling
  Future<void> submitTugas({
    required String tugasId,
    required String studentId,
    required String jawaban,
    String? fileUrl,
  }) async {
    final authUid = _supabase.auth.currentUser?.id;
    final validStudentId = (authUid != null && authUid.isNotEmpty)
        ? authUid
        : studentId.trim();

    if (validStudentId.isEmpty) {
      throw Exception('Sesi akun siswa tidak valid. Silakan login kembali.');
    }

    // Verify if assignment deadline has passed
    try {
      final tugasData = await _supabase
          .from('tugas')
          .select('deadline')
          .eq('id', tugasId)
          .maybeSingle();

      if (tugasData != null && tugasData['deadline'] != null) {
        final deadlineStr = tugasData['deadline'] as String;
        if (deadlineStr.trim().isNotEmpty && deadlineStr != 'Tidak ada deadline') {
          final dt = DateTime.tryParse(deadlineStr.trim());
          if (dt != null && dt.isBefore(DateTime.now())) {
            throw Exception('Tenggat waktu pengumpulan tugas ini telah berakhir. Jawaban tidak dapat dikirim.');
          }
        }
      }
    } catch (e) {
      if (e.toString().contains('Tenggat waktu')) rethrow;
    }

    final Map<String, dynamic> payload = {
      'tugas_id': tugasId,
      'student_id': validStudentId,
      'status': 'submitted',
      'tanggal_kumpul': DateTime.now().toIso8601String(),
    };

    if (jawaban.trim().isNotEmpty) {
      payload['jawaban'] = jawaban.trim();
    }
    if (fileUrl != null && fileUrl.trim().isNotEmpty) {
      payload['file_url'] = fileUrl.trim();
    }

    try {
      final existing = await _supabase
          .from('pengumpulan_tugas')
          .select('id')
          .eq('tugas_id', tugasId)
          .eq('student_id', validStudentId)
          .maybeSingle();

      if (existing != null) {
        await _supabase
            .from('pengumpulan_tugas')
            .update(payload)
            .eq('id', existing['id']);
      } else {
        await _supabase.from('pengumpulan_tugas').insert(payload);
      }
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        print('PostgrestException submitTugas: ${e.message} | Code: ${e.code} | Details: ${e.details}');
      }
      // If error is caused by unrecognized column in schema (e.g. 42703 or PGRST100)
      if (e.code == '42703' || (e.message.contains('column') && e.message.contains('does not exist'))) {
        try {
          // Fallback with base columns only
          final basePayload = {
            'tugas_id': tugasId,
            'student_id': validStudentId,
            'status': 'submitted',
            'tanggal_kumpul': DateTime.now().toIso8601String(),
          };

          final existing = await _supabase
              .from('pengumpulan_tugas')
              .select('id')
              .eq('tugas_id', tugasId)
              .eq('student_id', validStudentId)
              .maybeSingle();

          if (existing != null) {
            await _supabase
                .from('pengumpulan_tugas')
                .update(basePayload)
                .eq('id', existing['id']);
          } else {
            await _supabase.from('pengumpulan_tugas').insert(basePayload);
          }
          return;
        } catch (_) {}
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) print('Error submitting tugas: $e');
      rethrow;
    }
  }
}
