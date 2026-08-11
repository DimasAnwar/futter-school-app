import 'package:bestpractice/dashboard/pages/widgets/admin/custom_text_field.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/empty_state.dart';
import 'package:bestpractice/services/admin_services.dart';
import 'package:flutter/material.dart';

class ManageCourseStudentsSheet extends StatefulWidget {
  const ManageCourseStudentsSheet({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.adminServices,
    required this.onRemoveStudent,
  });

  final String courseId;
  final String courseName;
  final AdminServices adminServices;
  final Function(String studentId) onRemoveStudent;

  @override
  State<ManageCourseStudentsSheet> createState() => _ManageCourseStudentsSheetState();
}

class _ManageCourseStudentsSheetState extends State<ManageCourseStudentsSheet> {
  late Future<List<Map<String, dynamic>>> _studentsFuture;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _studentsFuture = widget.adminServices.getEnrolledStudents(widget.courseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Indicator
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Modal Header Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.people_alt_rounded, color: Color(0xFF2563EB), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Siswa Terdaftar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      widget.courseName,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Search Field
          CustomSearchInput(
            hintText: 'Cari siswa terdaftar...',
            onChanged: (val) => setState(() => _search = val),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _studentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final enrolled = snapshot.data ?? [];
                final filtered = enrolled.where((s) {
                  final name = (s['full_name'] as String? ?? '').toLowerCase();
                  final email = (s['email'] as String? ?? '').toLowerCase();
                  final q = _search.toLowerCase();
                  return name.contains(q) || email.contains(q);
                }).toList();

                if (filtered.isEmpty) {
                  return const EmptyStateWidget(
                    message: 'Tidak ada siswa terdaftar dalam mata kuliah ini.',
                    padding: EdgeInsets.symmetric(vertical: 30),
                  );
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const Divider(color: Color(0xFFF1F5F9), height: 1),
                  itemBuilder: (context, index) {
                    final student = filtered[index];
                    final id = student['id'] as String;
                    final name = student['full_name'] as String? ?? 'Siswa';
                    final email = student['email'] as String? ?? '';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFFD1FAE5),
                            child: Text(
                              name
                                  .split(' ')
                                  .map((e) => e.isEmpty ? '' : e[0])
                                  .take(2)
                                  .join(),
                              style: const TextStyle(
                                color: Color(0xFF047857),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
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
                                    fontSize: 13,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                if (email.isNotEmpty)
                                  Text(
                                    email,
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.person_remove_outlined, color: Color(0xFFEF4444), size: 20),
                            tooltip: 'Hapus dari mata kuliah',
                            onPressed: () => _confirmRemove(context, id, name),
                          ),
                        ],
                      ),
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

  void _confirmRemove(BuildContext context, String studentId, String studentName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluarkann Siswa?'),
        content: Text('Apakah Anda yakin ingin mengeluarkan "$studentName" dari mata kuliah ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () {
              Navigator.pop(context);
              widget.onRemoveStudent(studentId);
              _load(); // refresh enrolled student list
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
