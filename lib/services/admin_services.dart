import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboardData {
  const AdminDashboardData({
    required this.courses,
    required this.teachers,
    required this.students,
  });

  final List<Map<String, dynamic>> courses;
  final List<Map<String, dynamic>> teachers;
  final List<Map<String, dynamic>> students;

  int get courseCount => courses.length;
  int get teacherCount => teachers.length;
  int get studentCount => students.length;
}

class AdminServices {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Single unified method to fetch all dashboard data from Supabase
  Future<AdminDashboardData> getDashboardData() async {
    final results = await Future.wait([
      getCourses(),
      getTeachers(),
      getStudents(),
    ]);

    return AdminDashboardData(
      courses: results[0],
      teachers: results[1],
      students: results[2],
    );
  }

  /// Fetch list of courses
  Future<List<Map<String, dynamic>>> getCourses() async {
    final data = await _supabase
        .from('mata_kuliah')
        .select('id, kode_mk, nama_mk, sks, semester, dosen_id, created_at')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  /// Fetch list of teachers/lecturers
  Future<List<Map<String, dynamic>>> getTeachers() async {
    final data = await _supabase
        .from('profiles')
        .select('id, full_name, email, role')
        .order('full_name');
    return List<Map<String, dynamic>>.from(data).where((profile) {
      final role = (profile['role'] as String? ?? '').toLowerCase();
      return role == 'teacher' || role == 'teachers' || role == 'dosen';
    }).toList();
  }

  /// Fetch list of active students
  Future<List<Map<String, dynamic>>> getStudents() async {
    final data = await _supabase
        .from('profiles')
        .select('id, full_name, email, role')
        .order('full_name');
    return List<Map<String, dynamic>>.from(data).where((profile) {
      final role = (profile['role'] as String? ?? '').toLowerCase();
      return role == 'student' || role == 'students' || role == 'siswa';
    }).toList();
  }

  /// Get count of active students
  Future<int> getStudentCount() async {
    try {
      final students = await getStudents();
      return students.length;
    } catch (_) {
      return 0;
    }
  }

  /// Get count of active lecturers/teachers
  Future<int> getTeacherCount() async {
    try {
      final teachers = await getTeachers();
      return teachers.length;
    } catch (_) {
      return 0;
    }
  }

  /// Add a new course
  Future<void> addCourse({
    required String code,
    required String name,
    required int credits,
    required int semester,
    String? teacherId,
  }) {
    return _supabase.from('mata_kuliah').insert({
      'kode_mk': code,
      'nama_mk': name,
      'sks': credits,
      'semester': semester,
      'dosen_id': teacherId,
    });
  }

  /// Assign a teacher to a course
  Future<void> assignTeacher({
    required String courseId,
    String? teacherId,
  }) {
    return _supabase
        .from('mata_kuliah')
        .update({'dosen_id': teacherId})
        .eq('id', courseId);
  }

  /// Get enrolled student IDs for a course
  Future<List<String>> getEnrolledStudentIds(String courseId) async {
    try {
      final data = await _supabase
          .from('enrollments')
          .select('student_id')
          .eq('course_id', courseId);
      return (data as List)
          .map((e) => e['student_id'] as String?)
          .whereType<String>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Get enrolled student profiles for a course
  Future<List<Map<String, dynamic>>> getEnrolledStudents(String courseId) async {
    try {
      final studentIds = await getEnrolledStudentIds(courseId);
      if (studentIds.isEmpty) return [];
      final allStudents = await getStudents();
      return allStudents.where((s) => studentIds.contains(s['id'])).toList();
    } catch (_) {
      return [];
    }
  }

  /// Remove a specific student from a course in `enrollments` table
  Future<void> removeStudentFromCourse({
    required String courseId,
    required String studentId,
  }) async {
    await _supabase
        .from('enrollments')
        .delete()
        .eq('course_id', courseId)
        .eq('student_id', studentId);
  }

  /// Assign multiple students to a course in `enrollments` table
  Future<void> assignStudents({
    required String courseId,
    required List<String> studentIds,
  }) async {
    // 1. Clear existing enrollments for this course if needed or insert missing
    // Delete current enrollments for this course
    try {
      await _supabase.from('enrollments').delete().eq('course_id', courseId);
    } catch (_) {}

    if (studentIds.isEmpty) return;

    final records = studentIds
        .map((studentId) => {
              'course_id': courseId,
              'student_id': studentId,
            })
        .toList();

    await _supabase.from('enrollments').insert(records);
  }

  /// Delete a course by ID
  Future<void> deleteCourse(String courseId) {
    return _supabase.from('mata_kuliah').delete().eq('id', courseId);
  }

  /// Create an announcement (saves to Supabase table 'pengumuman')
  Future<void> createAnnouncement({
    required String title,
    required String content,
    required bool isUrgent,
  }) async {
    await _supabase.from('pengumuman').insert({
      'judul': title,
      'isi': content,
      'is_urgent': isUrgent,
    });
  }

  /// Realtime Stream of Announcements from Supabase
  Stream<List<Map<String, dynamic>>> getAnnouncementsStream() {
    return _supabase
        .from('pengumuman')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }

  /// Delete an announcement by ID
  Future<void> deleteAnnouncement(String announcementId) async {
    await _supabase.from('pengumuman').delete().eq('id', announcementId);
  }
}

