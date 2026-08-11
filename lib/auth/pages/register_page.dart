import 'package:bestpractice/auth/pages/widgets/role_selector.dart';
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
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmController.text.trim();
    final nim = _nimController.text.trim();
    final jurusan = _jurusanController.text.trim();

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
    if (!email.contains('@')) {
      _showMessage('Masukkan alamat email yang valid.', isError: true);
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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create Account",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const Text("Sign up to get started"),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 2,
                      offset: Offset(4, 4),
                      spreadRadius: 2,
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Full Name"),
                          SizedBox(height: 5),
                          CustomTextField(
                            controller: _fullnameController,
                            hintText: "Jhoen Doe",
                            icon: Icons.person,
                          ),
                          SizedBox(height: 10),
                          Text("Email"),
                          SizedBox(height: 5),
                          CustomTextField(
                            controller: _emailController,
                            hintText: "email@domain.com",
                            icon: Icons.email,
                          ),
                          if (_isStudentRole) ...[
                            SizedBox(height: 10),
                            Text("NIM"),
                            SizedBox(height: 5),
                            CustomTextField(
                              controller: _nimController,
                              hintText: "Nomor Induk Mahasiswa",
                              icon: Icons.badge_outlined,
                            ),
                            SizedBox(height: 10),
                            Text("Jurusan"),
                            SizedBox(height: 5),
                            CustomTextField(
                              controller: _jurusanController,
                              hintText: "Teknik Informatika",
                              icon: Icons.school_outlined,
                            ),
                          ],
                          SizedBox(height: 10),
                          Text("Password"),
                          SizedBox(height: 5),
                          CustomTextField(
                            controller: _passwordController,
                            hintText: "Password",
                            icon: Icons.lock,
                            isPassword: true,
                          ),
                          SizedBox(height: 10),
                          Text("Confirm Password"),
                          SizedBox(height: 5),
                          CustomTextField(
                            controller: _confirmController,
                            hintText: "Password",
                            icon: Icons.lock_reset,
                            isPassword: true,
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    10,
                                  ),
                                ),
                                backgroundColor: Color(0xFF2563EB),
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
                                      "Sign up",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already Have Account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Sign ",
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
