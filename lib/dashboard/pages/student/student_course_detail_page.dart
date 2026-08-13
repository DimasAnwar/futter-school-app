import 'package:bestpractice/dashboard/pages/student/student_materi_detail_page.dart';
import 'package:bestpractice/dashboard/pages/student/submit_tugas_page.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/card_container.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/empty_state.dart';
import 'package:bestpractice/dashboard/pages/widgets/task_card_widget.dart';
import 'package:flutter/material.dart';

class StudentCourseDetailPage extends StatefulWidget {
  const StudentCourseDetailPage({
    super.key,
    required this.course,
    required this.studentId,
    required this.materiList,
    required this.tugasList,
    required this.submissions,
    required this.onRefresh,
  });

  final Map<String, dynamic> course;
  final String studentId;
  final List<Map<String, dynamic>> materiList;
  final List<Map<String, dynamic>> tugasList;
  final List<Map<String, dynamic>> submissions;
  final Future<void> Function() onRefresh;

  @override
  State<StudentCourseDetailPage> createState() => _StudentCourseDetailPageState();
}

class _StudentCourseDetailPageState extends State<StudentCourseDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courseId = (widget.course['id'] as String?) ?? '';
    final namaMk = (widget.course['nama_mk'] as String?) ?? (widget.course['nama'] as String?) ?? 'Mata Kuliah';
    final kodeMk = (widget.course['kode_mk'] as String?) ?? (widget.course['kode'] as String?) ?? '-';
    final sks = widget.course['sks']?.toString() ?? '0';
    final deskripsi = (widget.course['deskripsi'] as String?) ?? 'Tidak ada deskripsi mata kuliah.';

    // Filter materi for this course
    final courseMateri = widget.materiList.where((m) {
      final mCourseId = m['course_id'] as String? ?? (m['mata_kuliah'] as Map<String, dynamic>?)?['id'] as String?;
      return mCourseId == courseId;
    }).toList();

    // Filter tugas for this course
    final courseTugas = widget.tugasList.where((t) {
      final tCourseId = t['course_id'] as String? ?? (t['mata_kuliah'] as Map<String, dynamic>?)?['id'] as String?;
      return tCourseId == courseId;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(namaMk, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0.5,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Course Banner Card
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.class_rounded, color: Color(0xFF2563EB), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              namaMk,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Kode: $kodeMk • $sks SKS',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Mata Kuliah Aktif',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    deskripsi,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
                  ),
                ],
              ),
            ),

            // Tab Navigation Header
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF2563EB),
                indicatorWeight: 3,
                labelColor: const Color(0xFF2563EB),
                unselectedLabelColor: const Color(0xFF64748B),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: [
                  Tab(text: 'Materi (${courseMateri.length})'),
                  Tab(text: 'Tugas (${courseTugas.length})'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // TabBar View Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // --- MATERI TAB ---
                  _buildMateriList(courseMateri),

                  // --- TUGAS TAB ---
                  _buildTugasList(courseTugas),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMateriList(List<Map<String, dynamic>> courseMateri) {
    if (courseMateri.isEmpty) {
      return const EmptyStateWidget(
        message: 'Belum ada materi perkuliahan untuk mata kuliah ini.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: courseMateri.length,
      itemBuilder: (context, index) {
        final materi = courseMateri[index];
        final judul = (materi['judul_materi'] as String?) ?? (materi['judul'] as String?) ?? 'Materi';
        final deskripsi = materi['deskripsi'] as String? ?? '-';
        final fileUrl = (materi['file_url'] as String?) ?? (materi['link_file'] as String?) ?? '';

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudentMateriDetailPage(materi: materi),
              ),
            );
          },
          child: CardContainer(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.menu_book_rounded, color: Color(0xFF2563EB), size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        judul,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  deskripsi,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (fileUrl.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.attachment_rounded, size: 16, color: Color(0xFF2563EB)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Berkas Materi: $fileUrl',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF2563EB)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTugasList(List<Map<String, dynamic>> courseTugas) {
    if (courseTugas.isEmpty) {
      return const EmptyStateWidget(
        message: 'Belum ada tugas perkuliahan untuk mata kuliah ini.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: courseTugas.length,
      itemBuilder: (context, index) {
        final tugas = courseTugas[index];
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
