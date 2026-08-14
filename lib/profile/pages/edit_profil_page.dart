import 'package:bestpractice/common/utils/ui_utils.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilPage extends StatefulWidget {
  const EditProfilPage({
    super.key,
    required this.fullName,
    required this.email,
    required this.dept,
    required this.phone,
  });

  final String fullName;
  final String email;
  final String dept;
  final String phone;

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _deptController;
  late TextEditingController _phoneController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.fullName);
    _emailController = TextEditingController(text: widget.email);
    _deptController = TextEditingController(text: widget.dept);
    _phoneController = TextEditingController(text: widget.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _deptController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      UiUtils.showToast(context, 'Nama lengkap tidak boleh kosong', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() => _isSaving = false);
      UiUtils.showToast(context, 'Sesi pengguna tidak ditemukan', isError: true);
      return;
    }

    final phoneVal = _phoneController.text.trim();
    final deptVal = _deptController.text.trim();

    try {
      final updatePayload = <String, dynamic>{
        'full_name': name,
        'jurusan': deptVal,
        'nohp': phoneVal,
      };

      // Try update first (satisfies standard UPDATE RLS policy)
      final res = await Supabase.instance.client
          .from('profiles')
          .update(updatePayload)
          .eq('id', user.id)
          .select();

      // If profile row doesn't exist yet, perform upsert with ID
      if (res.isEmpty) {
        final insertPayload = <String, dynamic>{
          'id': user.id,
          'full_name': name,
          'jurusan': deptVal,
          'nohp': phoneVal,
        };
        await Supabase.instance.client
            .from('profiles')
            .upsert(insertPayload);
      }

      if (mounted) {
        setState(() => _isSaving = false);
        UiUtils.showToast(context, 'Profil berhasil disimpan!');
        Navigator.pop(context, {
          'fullName': name,
          'email': _emailController.text.trim(),
          'dept': deptVal,
          'phone': phoneVal,
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        UiUtils.showToast(context, 'Gagal menyimpan ke Supabase: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);
    final nameStr = _nameController.text.isNotEmpty ? _nameController.text : widget.fullName;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profil Pengguna',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Edit Header Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withValues(alpha: 0.3) : const Color(0x262563EB),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: Text(
                            nameStr.isNotEmpty ? nameStr[0].toUpperCase() : 'U',
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2563EB),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ubah Foto & Informasi Diri',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Pastikan data terdaftar Anda akurat dan up to date.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF93C5FD)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Form Container Card
              Container(
                padding: const EdgeInsets.all(20),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.edit_note_rounded, color: Color(0xFF2563EB), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Form Perubahan Profil',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Perbarui nama, email, program studi, dan kontak Anda',
                                style: TextStyle(fontSize: 12, color: subTextColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
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
                      label: 'Program Studi / Departemen',
                      prefixIcon: Icons.school_outlined,
                    ),
                    const SizedBox(height: 14),
                    CustomFormField(
                      controller: _phoneController,
                      label: 'Nomor Telepon / WhatsApp',
                      prefixIcon: Icons.phone_android_rounded,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isSaving ? null : _saveChanges,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.save_rounded, size: 20),
                        label: Text(
                          _isSaving ? 'Menyimpan...' : 'Simpan Perubahan Profil',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
