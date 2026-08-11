import 'package:bestpractice/dashboard/pages/widgets/admin/admin_header.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/card_container.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/custom_buttons.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/custom_text_field.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/section_header.dart';
import 'package:flutter/material.dart';

class AdminBuatPengumumanView extends StatefulWidget {
  const AdminBuatPengumumanView({
    super.key,
    required this.fullName,
    required this.onSendAnnouncement,
    required this.onShowNotification,
  });

  final String fullName;
  final Function({
    required String title,
    required String content,
    required bool isUrgent,
  }) onSendAnnouncement;
  final VoidCallback onShowNotification;

  @override
  State<AdminBuatPengumumanView> createState() => _AdminBuatPengumumanViewState();
}

class _AdminBuatPengumumanViewState extends State<AdminBuatPengumumanView> {
  final _announcementTitleController = TextEditingController();
  final _announcementContentController = TextEditingController();
  bool _isUrgentAnnouncement = false;
  bool _isSending = false;

  @override
  void dispose() {
    _announcementTitleController.dispose();
    _announcementContentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleText = _announcementTitleController.text;
    final bodyText = _announcementContentController.text;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // Top Header
        AdminHeader(onNotificationTap: widget.onShowNotification),
        const SizedBox(height: 16),

        const SectionHeader(
          title: 'Buat Pengumuman',
          subtitle: 'Sampaikan informasi penting kepada siswa dan staf.',
        ),

        // Card 1: Announcement Input Form
        CardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul Pengumuman
              CustomFormField(
                label: 'Judul Pengumuman',
                hintText: 'Contoh: Perubahan Jadwal Ujian',
                controller: _announcementTitleController,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Isi Pengumuman
              CustomFormField(
                label: 'Isi Pengumuman',
                hintText: 'Tuliskan detail pengumuman di sini...',
                controller: _announcementContentController,
                maxLines: 4,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 18),

              // Urgent Switch Banner Container
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEE2E2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.priority_high_rounded,
                        color: Color(0xFFEF4444),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tandai sebagai Penting/Urgent',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Akan menonjolkan pengumuman ini.',
                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isUrgentAnnouncement,
                      onChanged: (val) => setState(() => _isUrgentAnnouncement = val),
                      activeColor: const Color(0xFF2563EB),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Kirim Pengumuman Button
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: _isSending ? 'Mengirim...' : 'Kirim Pengumuman',
                  icon: Icons.send_rounded,
                  onPressed: _isSending ? () {} : _handleSend,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Card 2: Live Preview Card (Pratinjau Pengumuman)
        CardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.remove_red_eye_outlined, size: 20, color: Color(0xFF64748B)),
                  SizedBox(width: 8),
                  Text(
                    'Pratinjau Pengumuman',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Preview Card Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isUrgentAnnouncement ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
                    width: _isUrgentAnnouncement ? 1.5 : 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: Color(0xFF2563EB),
                          child: Icon(Icons.person, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.fullName.isNotEmpty ? widget.fullName : 'Admin Sekolah',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                            ),
                            const Text(
                              'Baru saja',
                              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (_isUrgentAnnouncement)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'URGENT',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFEF4444),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      titleText.isEmpty ? 'Judul akan muncul di sini' : titleText,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: titleText.isEmpty ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      bodyText.isEmpty ? 'Isi pengumuman akan ditampilkan secara langsung saat Anda mengetik...' : bodyText,
                      style: TextStyle(
                        fontSize: 13,
                        color: bodyText.isEmpty ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 80),
      ],
    );
  }

  void _handleSend() async {
    if (_isSending) return;
    setState(() => _isSending = true);
    try {
      await widget.onSendAnnouncement(
        title: _announcementTitleController.text.trim(),
        content: _announcementContentController.text.trim(),
        isUrgent: _isUrgentAnnouncement,
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }
}
