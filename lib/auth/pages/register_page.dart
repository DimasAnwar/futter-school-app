import 'package:bestpractice/auth/pages/widgets/role_selector.dart';
import 'package:bestpractice/common/theme/app_colors.dart';
import 'package:bestpractice/common/utils/ui_utils.dart';
import 'package:bestpractice/services/auth_services.dart';
import 'package:flutter/material.dart';
import './widgets/custom_input.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _authServices = AuthServices();
  int selectedIndex = 0;
  String selectedRole = 'Students';
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _jurusanController = TextEditingController();
  bool _isSubmitting = false;

  bool get _isStudentRole =>
      selectedRole.toLowerCase() == 'students' ||
      selectedRole.toLowerCase() == 'student';

  static const List<RoleOption> _roleOptions = [
    RoleOption(label: 'Students', roleKey: 'Students'),
    RoleOption(label: 'Parents', roleKey: 'Parents'),
    RoleOption(label: 'Teacher', roleKey: 'Teachers'),
  ];

  Future<void> _prosesRegister() async {
    final fullName = _fullnameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmController.text;
    final nim = _nimController.text.trim();
    final jurusan = _jurusanController.text.trim();

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage('Semua field wajib diisi.', isError: true);
      return;
    }
    if (_isStudentRole && (nim.isEmpty || jurusan.isEmpty)) {
      _showMessage('NIM dan Jurusan wajib diisi untuk siswa.', isError: true);
      return;
    }
    if (!emailRegex.hasMatch(email)) {
      _showMessage('Masukkan alamat email yang valid (contoh: user@domain.com).', isError: true);
      return;
    }
    if (password.length < 6) {
      _showMessage('Password minimal 6 karakter.', isError: true);
      return;
    }
    if (password != confirmPassword) {
      _showMessage('Konfirmasi password tidak sama.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final response = await _authServices.daftarAkun(
        email: email,
        password: password,
        role: selectedRole,
        fullName: fullName,
        nim: _isStudentRole ? nim : null,
        jurusan: _isStudentRole ? jurusan : null,
      );
      if (mounted) {
        _showMessage(
          response.session == null
              ? 'Akun dibuat. Cek email untuk mengonfirmasi akun.'
              : 'Registrasi berhasil!',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showMessage(e.toString(), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    UiUtils.showToast(context, message, isError: isError);
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _nimController.dispose();
    _jurusanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppColors.bgCard(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final borderColor = AppColors.border(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              Text(
                "Sign up to get started",
                style: TextStyle(color: textSecondary),
              ),
              const SizedBox(height: 20),
              RoleSelector(
                options: _roleOptions,
                selectedIndex: selectedIndex,
                onRoleSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                    selectedRole = _roleOptions[index].roleKey;
                  });
                },
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Full Name",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      CustomTextField(
                        controller: _fullnameController,
                        hintText: "Jhoen Doe",
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "Email",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      CustomTextField(
                        controller: _emailController,
                        hintText: "email@domain.com",
                        icon: Icons.email,
                      ),
                      if (_isStudentRole) ...[
                        const SizedBox(height: 15),
                        Text(
                          "NIM",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 5),
                        CustomTextField(
                          controller: _nimController,
                          hintText: "Nomor Induk Mahasiswa",
                          icon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "Jurusan",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 5),
                        CustomTextField(
                          controller: _jurusanController,
                          hintText: "Teknik Informatika",
                          icon: Icons.school_outlined,
                        ),
                      ],
                      const SizedBox(height: 15),
                      Text(
                        "Password",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      CustomTextField(
                        controller: _passwordController,
                        hintText: "Password",
                        icon: Icons.lock,
                        isPassword: true,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "Confirm Password",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      CustomTextField(
                        controller: _confirmController,
                        hintText: "Confirm Password",
                        icon: Icons.lock_reset,
                        isPassword: true,
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: const Color(0xFF2563EB),
                          ),
                          onPressed: _isSubmitting ? null : _prosesRegister,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already Have Account? ",
                    style: TextStyle(color: textSecondary),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Sign In",
                      style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
