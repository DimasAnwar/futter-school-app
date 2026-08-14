import 'package:bestpractice/common/theme/theme_controller.dart';
import 'package:bestpractice/common/utils/ui_utils.dart';
import 'package:bestpractice/profile/pages/edit_profil_page.dart';
import 'package:bestpractice/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  late String _currentName;
  late String _currentEmail;
  String _currentDept = '-';
  String _currentPhone = '-';
  String _currentIdNumber = '-';

  String? _avatarUrl;
  bool _isUploadingAvatar = false;
  bool _isNotificationEnabled = true;

  @override
  void initState() {
    super.initState();
    _currentName = widget.fullName;
    _currentEmail = widget.userEmail;
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        if (user.email != null && user.email!.isNotEmpty) {
          _currentEmail = user.email!;
        }
        final profile = await _authServices.getProfile(user.id);
        if (profile != null && mounted) {
          setState(() {
            _avatarUrl = profile['avatar_url'] as String?;
            if (profile['full_name'] != null && (profile['full_name'] as String).trim().isNotEmpty) {
              _currentName = (profile['full_name'] as String).trim();
            }
            if (profile['nim'] != null && (profile['nim'] as String).trim().isNotEmpty) {
              _currentIdNumber = (profile['nim'] as String).trim();
            } else if (profile['nip'] != null && (profile['nip'] as String).trim().isNotEmpty) {
              _currentIdNumber = (profile['nip'] as String).trim();
            }
            if (profile['jurusan'] != null && (profile['jurusan'] as String).trim().isNotEmpty) {
              _currentDept = (profile['jurusan'] as String).trim();
            } else if (profile['dept'] != null && (profile['dept'] as String).trim().isNotEmpty) {
              _currentDept = (profile['dept'] as String).trim();
            }
            if (profile['nohp'] != null && (profile['nohp'] as String).trim().isNotEmpty) {
              _currentPhone = (profile['nohp'] as String).trim();
            } else if (profile['phone'] != null && (profile['phone'] as String).trim().isNotEmpty) {
              _currentPhone = (profile['phone'] as String).trim();
            } else if (user.phone != null && user.phone!.trim().isNotEmpty) {
              _currentPhone = user.phone!.trim();
            }
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      UiUtils.showToast(context, 'Sesi user tidak ditemukan.', isError: true);
      return;
    }

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() => _isUploadingAvatar = true);
      final bytes = await pickedFile.readAsBytes();

      final newAvatarUrl = await _authServices.uploadAvatar(
        userId: user.id,
        bytes: bytes,
        fileName: pickedFile.name,
      );

      if (mounted) {
        setState(() {
          _avatarUrl = newAvatarUrl;
        });
        UiUtils.showToast(context, 'Foto profil berhasil diperbarui!');
      }
    } catch (e) {
      if (mounted) {
        UiUtils.showToast(context, 'Gagal mengunggah foto profil: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
    }
  }

  void _showAvatarOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final txt = isDark ? Colors.white : const Color(0xFF0F172A);

    showModalBottomSheet(
      context: context,
      backgroundColor: bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ganti Foto Profil',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: txt),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF2563EB)),
                  title: Text('Pilih dari Galeri', style: TextStyle(color: txt)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAndUploadAvatar(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFF2563EB)),
                  title: Text('Ambil Foto via Kamera', style: TextStyle(color: txt)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAndUploadAvatar(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openEditProfilPage() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilPage(
          fullName: _currentName,
          email: _currentEmail,
          dept: _currentDept,
          phone: _currentPhone,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _currentName = result['fullName'] ?? _currentName;
        _currentEmail = result['email'] ?? _currentEmail;
        _currentDept = result['dept'] ?? _currentDept;
        _currentPhone = result['phone'] ?? _currentPhone;
      });
      _loadProfileData();
    }
  }



  Future<void> _confirmLogout() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              'Keluar Akun?',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin mengakhiri sesi login saat ini?',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Batal', style: TextStyle(color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Keluar Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authServices.logoutAkun();
    }
  }

  Color _getRoleBadgeColor(String role) {
    final r = role.toLowerCase();
    if (r.contains('admin')) return const Color(0xFFDC2626);
    if (r.contains('dosen') || r.contains('teacher')) return const Color(0xFF8B5CF6);
    return const Color(0xFF2563EB);
  }

  String _getRoleLabel(String role) {
    final r = role.toLowerCase();
    if (r.contains('admin')) return 'Administrator Sistem';
    if (r.contains('dosen') || r.contains('teacher')) return 'Dosen Pengajar';
    return 'Mahasiswa Aktif';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);
    final dividerColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final nameStr = _currentName.isNotEmpty ? _currentName : widget.fullName;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_rounded, color: Color(0xFF2563EB), size: 22),
            ),
            const SizedBox(width: 12),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: Color(0xFF2563EB)),
            tooltip: 'Edit Profil',
            onPressed: _openEditProfilPage,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. HERO PROFILE CARD BANNER ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withValues(alpha: 0.4) : const Color(0x262563EB),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: _isUploadingAvatar ? null : _showAvatarOptions,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF60A5FA), Color(0xFFA78BFA)],
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 34,
                                  backgroundColor: const Color(0xFF1E293B),
                                  backgroundImage: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                                      ? NetworkImage(_avatarUrl!)
                                      : null,
                                  child: _isUploadingAvatar
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : (_avatarUrl == null || _avatarUrl!.isEmpty)
                                          ? Text(
                                              nameStr.isNotEmpty ? nameStr[0].toUpperCase() : 'U',
                                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                                            )
                                          : null,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: _isUploadingAvatar ? null : _showAvatarOptions,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2563EB),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      nameStr,
                                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.verified_rounded, color: Color(0xFF60A5FA), size: 18),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _currentEmail,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF93C5FD)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getRoleBadgeColor(widget.userRole).withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.shield_rounded, color: Colors.white, size: 12),
                                    const SizedBox(width: 6),
                                    Text(
                                      _getRoleLabel(widget.userRole),
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Divider(height: 1, color: Colors.white24),
                    const SizedBox(height: 14),

                    // Quick Stats Chips inside Banner (Real Supabase data)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildHeaderStatItem('NIM / NIP', _currentIdNumber.isNotEmpty ? _currentIdNumber : '-', Icons.badge_rounded),
                        Container(width: 1, height: 28, color: Colors.white24),
                        _buildHeaderStatItem('Program Studi', _currentDept.isNotEmpty ? _currentDept : '-', Icons.school_rounded),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // --- 2. INFORMASI AKUN & DATA DIRI ---
              Text(
                'Informasi Diri & Akademik',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0x08000000),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildProfileInfoRow(
                      icon: Icons.person_outline_rounded,
                      iconColor: const Color(0xFF2563EB),
                      label: 'Nama Lengkap',
                      value: _currentName,
                      textColor: textColor,
                      subTextColor: subTextColor,
                    ),
                    Divider(height: 22, color: dividerColor),
                    _buildProfileInfoRow(
                      icon: Icons.email_outlined,
                      iconColor: const Color(0xFF0EA5E9),
                      label: 'Email Terdaftar',
                      value: _currentEmail,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      onCopy: () {
                        Clipboard.setData(ClipboardData(text: _currentEmail));
                        UiUtils.showToast(context, 'Email disalin ke clipboard');
                      },
                    ),
                    Divider(height: 22, color: dividerColor),
                    _buildProfileInfoRow(
                      icon: Icons.school_outlined,
                      iconColor: const Color(0xFF8B5CF6),
                      label: 'Program Studi / Departemen',
                      value: _currentDept,
                      textColor: textColor,
                      subTextColor: subTextColor,
                    ),
                    Divider(height: 22, color: dividerColor),
                    _buildProfileInfoRow(
                      icon: Icons.phone_android_rounded,
                      iconColor: const Color(0xFF10B981),
                      label: 'Nomor Telepon / WhatsApp',
                      value: _currentPhone,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      onCopy: () {
                        Clipboard.setData(ClipboardData(text: _currentPhone));
                        UiUtils.showToast(context, 'Nomor telepon disalin');
                      },
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _openEditProfilPage,
                        icon: const Icon(Icons.edit_note_rounded, size: 20),
                        label: const Text('Edit Data Diri & Profil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // --- 3. PENGATURAN & KEAMANAN AKUN ---
              Text(
                'Pengaturan & Keamanan Sesi',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0x08000000),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.lock_reset_rounded, color: Color(0xFF2563EB), size: 20),
                      ),
                      title: Text('Ubah Kata Sandi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
                      subtitle: Text('Perbarui keamanan kata sandi akun', style: TextStyle(fontSize: 11, color: subTextColor)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                      onTap: () {
                        Navigator.pushNamed(context, '/change-password');
                      },
                    ),
                    Divider(height: 1, color: dividerColor),
                    SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.notifications_active_rounded, color: Color(0xFFF59E0B), size: 20),
                      ),
                      title: Text('Notifikasi Aplikasi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
                      subtitle: Text('Pemberitahuan tugas & pengumuman', style: TextStyle(fontSize: 11, color: subTextColor)),
                      value: _isNotificationEnabled,
                      activeTrackColor: const Color(0xFF2563EB),
                      onChanged: (val) => setState(() => _isNotificationEnabled = val),
                    ),
                    Divider(height: 1, color: dividerColor),
                    SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.dark_mode_rounded, color: Color(0xFF8B5CF6), size: 20),
                      ),
                      title: Text('Mode Gelap (Dark Theme)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
                      subtitle: Text('Sesuaikan tampilan antarmuka', style: TextStyle(fontSize: 11, color: subTextColor)),
                      value: ThemeController.instance.isDarkMode,
                      activeTrackColor: const Color(0xFF8B5CF6),
                      onChanged: (val) {
                        ThemeController.instance.toggleDarkMode(val);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // --- 4. LAINNYA & INFORMASI SISTEM ---
              Text(
                'Informasi Aplikasi',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0x08000000),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.info_outline_rounded, color: Color(0xFF10B981), size: 20),
                      ),
                      title: Text('Versi Aplikasi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
                      trailing: Text('v2.4.0 (Build 2026)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: subTextColor)),
                    ),
                    Divider(height: 1, color: dividerColor),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.verified_user_outlined, color: Color(0xFF6366F1), size: 20),
                      ),
                      title: Text('Kebijakan Privasi & Ketentuan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                      onTap: () {
                        UiUtils.showToast(context, 'Sistem Akademik Sekolah Terintegrasi v2.4');
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              // --- 5. LOGOUT BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: isDark ? const Color(0xFF991B1B) : const Color(0xFFFCA5A5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    backgroundColor: isDark ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2),
                  ),
                  onPressed: _confirmLogout,
                  icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
                  label: const Text(
                    'Keluar Sesi Akun',
                    style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: const Color(0xFF93C5FD)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF93C5FD), fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildProfileInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color textColor,
    required Color subTextColor,
    VoidCallback? onCopy,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: subTextColor, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (onCopy != null)
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF94A3B8)),
            onPressed: onCopy,
            tooltip: 'Salin',
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(6),
          ),
      ],
    );
  }
}
