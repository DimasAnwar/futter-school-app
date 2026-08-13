import 'package:bestpractice/common/theme/theme_controller.dart';
import 'package:bestpractice/common/utils/ui_utils.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/custom_text_field.dart';
import 'package:bestpractice/services/auth_services.dart';
import 'package:flutter/material.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({
    super.key,
    required this.fullName,
    required this.userRole,
    required this.userEmail,
  });

  final String fullName;
  final String userRole;
  final String userEmail;

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final AuthServices _authServices = AuthServices();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final TextEditingController _deptController = TextEditingController(text: 'Teknik Informatika & Komputer');
  final TextEditingController _phoneController = TextEditingController(text: '+62 812-3456-7890');

  bool _isNotificationEnabled = true;
  bool _isDarkModeEnabled = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.fullName);
    _emailController = TextEditingController(text: widget.userEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _deptController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfileChanges() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _isSaving = false);
      UiUtils.showToast(context, 'Profil berhasil diperbarui!');
    }
  }

  Future<void> _showChangePasswordDialog() async {
    final oldPasswordCtrl = TextEditingController();
    final newPasswordCtrl = TextEditingController();
    final confirmPasswordCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_reset_rounded, color: Color(0xFF2563EB)),
            SizedBox(width: 8),
            Text('Ubah Kata Sandi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomFormField(
              controller: oldPasswordCtrl,
              label: 'Kata Sandi Saat Ini',
              obscureText: true,
            ),
            const SizedBox(height: 10),
            CustomFormField(
              controller: newPasswordCtrl,
              label: 'Kata Sandi Baru',
              obscureText: true,
            ),
            const SizedBox(height: 10),
            CustomFormField(
              controller: confirmPasswordCtrl,
              label: 'Konfirmasi Kata Sandi Baru',
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
            onPressed: () {
              if (newPasswordCtrl.text.isEmpty || oldPasswordCtrl.text.isEmpty) {
                UiUtils.showToast(dialogContext, 'Semua bidang harus diisi', isError: true);
                return;
              }
              if (newPasswordCtrl.text != confirmPasswordCtrl.text) {
                UiUtils.showToast(dialogContext, 'Kata sandi baru tidak cocok', isError: true);
                return;
              }
              Navigator.pop(dialogContext);
              UiUtils.showToast(context, 'Kata sandi berhasil diperbarui!');
            },
            child: const Text('Simpan Sandi', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar dari Akun?'),
        content: const Text('Apakah Anda yakin ingin keluar dari sesi pengguna saat ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authServices.logoutAkun();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final dividerColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final nameStr = _nameController.text.isNotEmpty ? _nameController.text : widget.fullName;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Icon(Icons.person_rounded, color: Color(0xFF2563EB), size: 24),
            const SizedBox(width: 10),
            Text(
              'Profil Pengguna',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // User Header Card Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Color(0x1A2563EB), blurRadius: 12, offset: Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      nameStr.isNotEmpty ? nameStr[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nameStr,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.userEmail,
                          style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Peran: ${widget.userRole}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Account Info Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informasi Akun & Data Diri',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 16),
                  CustomFormField(
                    controller: _nameController,
                    label: 'Nama Lengkap',
                    prefixIcon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 14),
                  CustomFormField(
                    controller: _emailController,
                    label: 'Email Terdaftar',
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 14),
                  CustomFormField(
                    controller: _deptController,
                    label: 'Program Studi / Jurusan',
                    prefixIcon: Icons.school_outlined,
                  ),
                  const SizedBox(height: 14),
                  CustomFormField(
                    controller: _phoneController,
                    label: 'Nomor WhatsApp / Telepon',
                    prefixIcon: Icons.phone_android_rounded,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isSaving ? null : _saveProfileChanges,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Simpan Perubahan Profil',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Settings Section
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_outline_rounded, color: Color(0xFF2563EB)),
                    title: Text('Ubah Kata Sandi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                    onTap: _showChangePasswordDialog,
                  ),
                  Divider(height: 1, color: dividerColor),
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_none_rounded, color: Color(0xFF2563EB)),
                    title: Text('Notifikasi Aplikasi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
                    value: _isNotificationEnabled,
                    activeTrackColor: const Color(0xFF2563EB),
                    onChanged: (val) => setState(() => _isNotificationEnabled = val),
                  ),
                  Divider(height: 1, color: dividerColor),
                  SwitchListTile(
                    secondary: const Icon(Icons.dark_mode_outlined, color: Color(0xFF2563EB)),
                    title: Text('Mode Gelap (Tampilan)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
                    value: ThemeController.instance.isDarkMode,
                    activeTrackColor: const Color(0xFF2563EB),
                    onChanged: (val) {
                      setState(() => _isDarkModeEnabled = val);
                      ThemeController.instance.toggleDarkMode(val);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Logout Button
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFFFCA5A5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                backgroundColor: const Color(0xFFFEF2F2),
              ),
              onPressed: _confirmLogout,
              icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
              label: const Text(
                'Keluar Sesi Akun',
                style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
