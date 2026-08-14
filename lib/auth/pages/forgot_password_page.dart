import 'package:bestpractice/auth/pages/widgets/custom_input.dart';
import 'package:bestpractice/common/theme/app_colors.dart';
import 'package:bestpractice/common/utils/ui_utils.dart';
import 'package:bestpractice/services/auth_services.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _authServices = AuthServices();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  int _currentStep = 1; // 1: Send OTP email, 2: Enter OTP & New Password
  bool _isSubmitting = false;
  bool _isVerified = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    UiUtils.showToast(context, message, isError: isError);
  }

  Future<void> _handleSendResetEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('Email wajib diisi.', isError: true);
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showMessage('Format email tidak valid.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _authServices.resetPasswordForEmail(email: email);
      if (mounted) {
        _showMessage('Kode OTP / Link reset telah dikirim ke $email');
        setState(() {
          _currentStep = 2;
        });
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

  Future<void> _handleVerifyAndResetPassword() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (otp.isEmpty) {
      _showMessage('Kode OTP wajib diisi.', isError: true);
      return;
    }

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showMessage('Kata sandi baru dan konfirmasi wajib diisi.', isError: true);
      return;
    }

    if (newPassword.length < 6) {
      _showMessage('Kata sandi minimal 6 karakter.', isError: true);
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage('Konfirmasi kata sandi tidak cocok.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      // 1. Verify OTP token first if not yet verified
      if (!_isVerified) {
        await _authServices.verifyResetOtp(email: email, token: otp);
        _isVerified = true;
      }

      // 2. Update password
      await _authServices.updatePassword(newPassword: newPassword);

      // 3. Logout to ensure clean state after reset
      await _authServices.logoutAkun();

      if (mounted) {
        _showMessage('Kata sandi berhasil diperbarui! Silakan login kembali.');
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppColors.bgCard(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final borderColor = AppColors.border(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header Icon
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.lock_reset,
                    size: 38,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Lupa Kata Sandi",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _currentStep == 1
                      ? "Masukkan email akun EduSchool Anda"
                      : "Masukkan kode OTP & kata sandi baru",
                  style: TextStyle(color: textSecondary, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Card Form
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
                        offset: const Offset(0, 4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: AnimatedCrossFade(
                      duration: const Duration(milliseconds: 300),
                      crossFadeState: _currentStep == 1
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      firstChild: _buildStep1Content(textPrimary, textSecondary),
                      secondChild: _buildStep2Content(textPrimary, textSecondary),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Back to Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Sudah ingat kata sandi? ",
                      style: TextStyle(color: textSecondary),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Masuk",
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
      ),
    );
  }

  Widget _buildStep1Content(Color textPrimary, Color textSecondary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Email Terdaftar",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: _emailController,
          hintText: "contoh@email.com",
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 20),
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
            onPressed: _isSubmitting ? null : _handleSendResetEmail,
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
                    'Kirim Kode OTP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: () {
              if (_emailController.text.trim().isEmpty) {
                _showMessage('Masukkan email terlebih dahulu.', isError: true);
                return;
              }
              setState(() {
                _currentStep = 2;
              });
            },
            child: const Text(
              "Sudah dapat kode OTP? Masukkan di sini",
              style: TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2Content(Color textPrimary, Color textSecondary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sent info banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFF2563EB), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Kode OTP dikirim ke: ${_emailController.text}",
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentStep = 1;
                    _isVerified = false;
                  });
                },
                child: const Text(
                  "Ubah",
                  style: TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // OTP Code Input
        Text(
          "Kode OTP (6 Digit)",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: _otpController,
          hintText: "Masukkan kode OTP dari email",
          icon: Icons.vpn_key_outlined,
        ),
        const SizedBox(height: 16),

        // New Password Input
        Text(
          "Kata Sandi Baru",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: _newPasswordController,
          hintText: "Minimal 6 karakter",
          icon: Icons.lock_outline,
          isPassword: true,
        ),
        const SizedBox(height: 16),

        // Confirm Password Input
        Text(
          "Konfirmasi Kata Sandi Baru",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: _confirmPasswordController,
          hintText: "Ulangi kata sandi baru",
          icon: Icons.lock_clock_outlined,
          isPassword: true,
        ),
        const SizedBox(height: 20),

        // Submit Button
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
            onPressed: _isSubmitting ? null : _handleVerifyAndResetPassword,
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
                    'Simpan Kata Sandi Baru',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),

        // Resend OTP link
        Align(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: _isSubmitting ? null : _handleSendResetEmail,
            child: const Text(
              "Kirim ulang kode OTP",
              style: TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
