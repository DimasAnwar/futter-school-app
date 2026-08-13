import 'dart:async';
import 'package:bestpractice/dashboard/pages/student/submit_tugas_page.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/card_container.dart';
import 'package:bestpractice/dashboard/pages/widgets/announcement_slider_widget.dart';
import 'package:bestpractice/dashboard/pages/widgets/student/stat_sub_item.dart';
import 'package:bestpractice/dashboard/pages/widgets/task_card_widget.dart';
import 'package:flutter/material.dart';

class StudentHomeView extends StatelessWidget {
  const StudentHomeView({
    super.key,
    required this.fullName,
    required this.nim,
    required this.jurusan,
    required this.studentId,
    required this.submissions,
    required this.totalSks,
    required this.courseCount,
    required this.tugasCount,
    required this.announcements,
    required this.tugasList,
    required this.onRefresh,
    required this.onOpenAcademicsTab,
    required this.onShowToast,
  });

  final String fullName;
  final String nim;
  final String jurusan;
  final String studentId;
  final List<Map<String, dynamic>> submissions;
  final int totalSks;
  final int courseCount;
  final int tugasCount;
  final List<Map<String, dynamic>> announcements;
  final List<Map<String, dynamic>> tugasList;
  final Future<void> Function() onRefresh;
  final VoidCallback onOpenAcademicsTab;
  final Function(String message, {bool isError}) onShowToast;

  String _toTitleCase(String text) {
    if (text.trim().isEmpty) return text;
    final words = text.trim().split(RegExp(r'\s+'));
    return words
        .map((w) {
          if (w.isEmpty) return '';
          return '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}';
        })
        .join(' ');
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 3 && hour < 11) {
      return 'Selamat Pagi 🌅';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat Siang ☀️';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat Sore 🌇';
    } else {
      return 'Selamat Malam 🌙';
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedName = _toTitleCase(fullName);
    final formattedJurusan = _toTitleCase(jurusan);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header Section: Top Left Greeting, Name, NIM & Jurusan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTimeBasedGreeting(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formattedName,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (nim.isNotEmpty && nim != '-')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'NIM: $nim',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E8FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            formattedJurusan,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B5CF6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  await onRefresh();
                  onShowToast('Data berhasil diperbarui.');
                },
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: Color(0xFF2563EB),
                ),
                tooltip: 'Refresh Data',
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Total SKS & Stats Container
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x332563EB),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOTAL SKS DITEMPUH',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$totalSks SKS',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white38),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onPressed: onOpenAcademicsTab,
                      child: const Text(
                        'Lihat Matkul',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    StatSubItem(
                      label: 'Mata Kuliah',
                      value: '$courseCount Matkul',
                      icon: Icons.menu_book_rounded,
                    ),
                    Container(width: 1, height: 28, color: Colors.white24),
                    StatSubItem(
                      label: 'Tugas Aktif',
                      value: '$tugasCount Tugas',
                      icon: Icons.assignment_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- 1. PENGUMUMAN CAROUSEL SLIDER (PALING ATAS) ---
          Row(
            children: const [
              Icon(Icons.campaign_rounded, color: Color(0xFFF59E0B), size: 22),
              SizedBox(width: 8),
              Text(
                'Pengumuman Kampus',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          AnnouncementSliderWidget(announcements: announcements),

          const SizedBox(height: 24),

          // --- 2. CLEAN TUGAS KULIAH AKTIF SECTION WITH PROFESSIONAL DEADLINE ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.assignment_rounded,
                    color: Color(0xFF2563EB),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tugas Kuliah Aktif',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$tugasCount Tugas',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (tugasList.isEmpty)
            CardContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: const [
                  Icon(
                    Icons.task_alt_rounded,
                    size: 40,
                    color: Color(0xFF10B981),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Tidak Ada Tugas Aktif',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Semua tugas telah diselesaikan atau belum ada tugas baru dari dosen.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            )
          else
            ...tugasList.map((tugas) {
              final tugasId = tugas['id'] as String;
              final existingSub = submissions
                  .cast<Map<String, dynamic>?>()
                  .firstWhere(
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
                        studentId: studentId,
                        existingSubmission: existingSub,
                      ),
                    ),
                  );

                  if (updated == true) {
                    await onRefresh();
                  }
                },
              );
            }),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

