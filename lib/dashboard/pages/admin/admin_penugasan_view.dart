import 'package:bestpractice/dashboard/pages/widgets/admin/card_container.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/custom_buttons.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/custom_text_field.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/empty_state.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/section_header.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/sub_page_header.dart';
import 'package:flutter/material.dart';

class AdminPenugasanView extends StatefulWidget {
  const AdminPenugasanView({
    super.key,
    required this.courses,
    required this.students,
    required this.teachers,
    required this.selectedCourseId,
    required this.participantType,
    required this.onBack,
    required this.onCourseSelected,
    required this.onParticipantTypeChanged,
    required this.onConfirmAssignment,
    required this.onShowNotification,
  });

  final List<Map<String, dynamic>> courses;
  final List<Map<String, dynamic>> students;
  final List<Map<String, dynamic>> teachers;
  final String selectedCourseId;
  final String participantType; // 'Siswa' or 'Dosen'
  final VoidCallback onBack;
  final ValueChanged<String> onCourseSelected;
  final ValueChanged<String> onParticipantTypeChanged;
  final Function(
    String courseId,
    String participantType,
    List<String> selectedParticipantIds,
  )
  onConfirmAssignment;
  final VoidCallback onShowNotification;

  @override
  State<AdminPenugasanView> createState() => _AdminPenugasanViewState();
}

class _AdminPenugasanViewState extends State<AdminPenugasanView> {
  String _courseSearchQuery = '';
  String _participantSearchQuery = '';
  final Set<String> _selectedParticipantIds = {};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);
    final iconBg = isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF);
    final dividerColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final avatarBg = isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
    final avatarText = isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857);

    final isDosenMode = widget.participantType == 'Dosen';

    final selectedCourse = widget.courses.cast<Map<String, dynamic>>().firstWhere(
      (c) => c['id'] == widget.selectedCourseId,
      orElse: () => <String, dynamic>{},
    );
    final currentDosenId = selectedCourse['dosen_id'] as String?;
    final currentDosen = widget.teachers.cast<Map<String, dynamic>>().firstWhere(
      (t) => t['id'] == currentDosenId,
      orElse: () => <String, dynamic>{},
    );
    final currentDosenName = currentDosen['full_name'] as String?;

    final coursesList = widget.courses;

    final filteredCourses = coursesList.where((c) {
      final query = _courseSearchQuery.toLowerCase();
      final name = (c['nama_mk'] as String? ?? '').toLowerCase();
      final code = (c['kode_mk'] as String? ?? '').toLowerCase();
      return name.contains(query) || code.contains(query);
    }).toList();

    final participantsList = widget.participantType == 'Siswa'
        ? widget.students
        : widget.teachers;

    final filteredParticipants = participantsList.where((p) {
      final query = _participantSearchQuery.toLowerCase();
      final name = (p['full_name'] as String? ?? '').toLowerCase();
      final email = (p['email'] as String? ?? '').toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();

    final allSelected =
        !isDosenMode &&
        filteredParticipants.isNotEmpty &&
        filteredParticipants.every(
          (p) => _selectedParticipantIds.contains(p['id']),
        );

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Top Header Row with back button & title
            SubPageHeader(
              title: 'EduSchool',
              onBack: widget.onBack,
              isTitleBrand: true,
              trailing: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: widget.onShowNotification,
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Color(0xFF2563EB),
                    size: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            SectionHeader(
              title: isDosenMode ? 'Penugasan Dosen' : 'Penugasan Siswa',
              subtitle: isDosenMode
                  ? 'Pilih mata kuliah dan tetapkan Dosen Pengampu.'
                  : 'Pilih mata kuliah dan tetapkan Siswa terdaftar.',
            ),

            // Card 1: 1. Pilih Mata Kuliah
            CardContainer(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1. Pilih Mata Kuliah',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Search Input
                  CustomSearchInput(
                    hintText: 'Cari mata kuliah...',
                    onChanged: (val) =>
                        setState(() => _courseSearchQuery = val),
                  ),
                  const SizedBox(height: 12),

                  // Selectable Radio-like Course List
                  if (filteredCourses.isEmpty)
                    const EmptyStateWidget(
                      message: 'Belum ada mata kuliah.',
                      padding: EdgeInsets.symmetric(vertical: 16),
                    )
                  else
                    ...filteredCourses.map((c) {
                      final id = c['id'] as String;
                      final name = c['nama_mk'] as String? ?? 'Mata Kuliah';
                      final code = c['kode_mk'] as String? ?? 'CS101';
                      final sem = (c['semester'] as int? ?? 1) % 2 == 1
                          ? 'Semester Ganjil'
                          : 'Semester Genap';
                      final isSelected = widget.selectedCourseId == id;
                      final courseDosenId = c['dosen_id'] as String?;
                      final courseDosen = widget.teachers.cast<Map<String, dynamic>>().firstWhere(
                        (t) => t['id'] == courseDosenId,
                        orElse: () => <String, dynamic>{},
                      );
                      final courseDosenName =
                          courseDosen['full_name'] as String?;

                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedParticipantIds.clear());
                          widget.onCourseSelected(id);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF))
                                : (isDark ? const Color(0xFF0F172A) : Colors.white),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? (isDark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB))
                                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Radio<String>(
                                value: id,
                                groupValue: widget.selectedCourseId,
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(
                                      () => _selectedParticipantIds.clear(),
                                    );
                                    widget.onCourseSelected(val);
                                  }
                                },
                                activeColor: const Color(0xFF2563EB),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: isSelected
                                            ? (isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF))
                                            : titleColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '$code • $sem',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: subtitleColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (courseDosenName != null)
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.school_rounded,
                                            size: 13,
                                            color: Color(0xFF2563EB),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Dosen: $courseDosenName',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF2563EB),
                                            ),
                                          ),
                                        ],
                                      )
                                    else
                                      const Text(
                                        'Belum ada dosen pengampu',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF94A3B8),
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),

            // Card 2: 2. Pilih Partisipan (Dosen / Siswa sesuai halaman)
            CardContainer(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isDosenMode ? '2. Pilih Dosen' : '2. Pilih Siswa',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                      if (isDosenMode)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Maks. 1 Dosen',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD97706),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Current Assigned Lecturer Status Banner (If Dosen Mode & course has assigned dosen)
                  if (isDosenMode && currentDosenName != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? const Color(0xFF2563EB) : const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.school_rounded,
                            color: Color(0xFF2563EB),
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dosen Pengampu Saat Ini:',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF),
                                  ),
                                ),
                                Text(
                                  currentDosenName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: titleColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              setState(() => _selectedParticipantIds.clear());
                              widget.onConfirmAssignment(
                                widget.selectedCourseId,
                                'Dosen',
                                [],
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFDC2626),
                              side: BorderSide(color: isDark ? const Color(0xFFEF4444) : const Color(0xFFFCA5A5)),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Lepas Dosen',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Search Input
                  CustomSearchInput(
                    hintText: isDosenMode
                        ? 'Cari nama dosen...'
                        : 'Cari nama atau NIM...',
                    icon: isDosenMode
                        ? Icons.person_search_outlined
                        : Icons.search_rounded,
                    onChanged: (val) =>
                        setState(() => _participantSearchQuery = val),
                  ),
                  const SizedBox(height: 10),

                  // Select All Checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: allSelected,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedParticipantIds.addAll(
                                filteredParticipants.map(
                                  (p) => p['id'] as String,
                                ),
                              );
                            } else {
                              _selectedParticipantIds.clear();
                            }
                          });
                        },
                        activeColor: const Color(0xFF2563EB),
                      ),
                      Text(
                        'Pilih Semua',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                    ],
                  ),
                  Divider(color: dividerColor),

                  // Participant items list
                  if (filteredParticipants.isEmpty)
                    const EmptyStateWidget(
                      message: 'Belum ada data partisipan.',
                      padding: EdgeInsets.symmetric(vertical: 16),
                    )
                  else
                    ...filteredParticipants.map((p) {
                      final id = p['id'] as String;
                      final name = p['full_name'] as String? ?? 'Nama User';
                      final email = p['email'] as String? ?? '';
                      final isChecked = _selectedParticipantIds.contains(id);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Checkbox(
                              value: isChecked,
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedParticipantIds.add(id);
                                  } else {
                                    _selectedParticipantIds.remove(id);
                                  }
                                });
                              },
                              activeColor: const Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 4),
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: avatarBg,
                              child: Text(
                                name
                                    .split(' ')
                                    .map((e) => e.isEmpty ? '' : e[0])
                                    .take(2)
                                    .join(),
                                style: TextStyle(
                                  color: avatarText,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
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
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: titleColor,
                                    ),
                                  ),
                                  Text(
                                    email,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: subtitleColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),

        // Bottom Sticky Button: [Konfirmasi Penugasan]
        Positioned(
          left: 20,
          right: 20,
          bottom: 20,
          child: PrimaryButton(
            label: 'Konfirmasi Penugasan',
            icon: Icons.fact_check_outlined,
            padding: const EdgeInsets.symmetric(vertical: 16),
            fontSize: 16,
            onPressed: () => widget.onConfirmAssignment(
              widget.selectedCourseId,
              widget.participantType,
              _selectedParticipantIds.toList(),
            ),
          ),
        ),
      ],
    );
  }
}
