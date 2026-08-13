import 'package:bestpractice/dashboard/pages/widgets/admin/empty_state.dart';
import 'package:bestpractice/services/teacher_services.dart';
import 'package:flutter/material.dart';

class EnrolledStudentsSheet extends StatefulWidget {
  const EnrolledStudentsSheet({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.teacherServices,
  });

  final String courseId;
  final String courseName;
  final TeacherServices teacherServices;

  @override
  State<EnrolledStudentsSheet> createState() => _EnrolledStudentsSheetState();
}

class _EnrolledStudentsSheetState extends State<EnrolledStudentsSheet> {
  late Future<List<Map<String, dynamic>>> _studentsFuture;

  @override
  void initState() {
    super.initState();
    _studentsFuture = widget.teacherServices.getEnrolledStudentsForCourse(widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Siswa Terdaftar (${widget.courseName})',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const Divider(height: 20),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _studentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final students = snapshot.data ?? [];
                if (students.isEmpty) {
                  return EmptyStateWidget(
                    message: 'Belum ada siswa yang terdaftar di kelas ini.',
                  );
                }

                return ListView.separated(
                  itemCount: students.length,
                  separatorBuilder: (context, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final rawName = (student['full_name'] as String?) ?? (student['name'] as String?);
                    final email = (student['email'] as String?) ?? '-';
                    final nim = (student['nim'] as String?);
                    final studentId = student['id']?.toString() ?? '';

                    final name = (rawName != null && rawName.trim().isNotEmpty && rawName != 'Siswa')
                        ? rawName.trim()
                        : (email != '-' && email.contains('@')
                            ? email.split('@').first
                            : 'Siswa ${studentId.length > 5 ? "(${studentId.substring(0, 5)})" : ""}');

                    final subtitleText = [
                      if (nim != null && nim.isNotEmpty && nim != '-') 'NIM: $nim',
                      if (email != '-') email,
                    ].join(' • ');

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFEFF6FF),
                        child: Text(
                          name.isEmpty ? 'S' : name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(subtitleText.isEmpty ? 'NIM: Belum diatur' : subtitleText),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
