import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthServices {
  final _supabase = Supabase.instance.client;

  Future<AuthResponse> daftarAkun({
    required String email,
    required String password,
    required String role,
    required String fullName,
    String? nim,
    String? jurusan,
    String? nohp,
  }) async {
    final cleanEmail = email.trim();
    try {
      final cleanRole = role.toLowerCase().trim();
      final dataMap = <String, dynamic>{
        'full_name': fullName.trim(),
        'role': cleanRole,
      };
      if (nim != null && nim.trim().isNotEmpty) dataMap['nim'] = nim.trim();
      if (jurusan != null && jurusan.trim().isNotEmpty) dataMap['jurusan'] = jurusan.trim();
      if (nohp != null && nohp.trim().isNotEmpty) dataMap['nohp'] = nohp.trim();

      final response = await _supabase.auth.signUp(
        email: cleanEmail,
        password: password,
        data: dataMap,
      );

      final user = response.user;
      if (user == null) {
        throw 'Akun tidak berhasil dibuat. Coba beberapa saat lagi.';
      }

      // Auto-assign profile details to profiles table with lowercased role
      final updatePayload = <String, dynamic>{
        'id': user.id,
        'role': cleanRole,
        'full_name': fullName.trim(),
      };
      if (nim != null && nim.trim().isNotEmpty) updatePayload['nim'] = nim.trim();
      if (jurusan != null && jurusan.trim().isNotEmpty) updatePayload['jurusan'] = jurusan.trim();
      if (nohp != null && nohp.trim().isNotEmpty) updatePayload['nohp'] = nohp.trim();
      
      try {
        await _supabase.from('profiles').upsert(updatePayload);
      } catch (_) {}

      return response;
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Gagal mendaftar: Terjadi kesalahan sistem. Silakan coba lagi.';
    }
  }

  Future<String> loginAkun({
    required String email,
    required String password,
    required String expectedRole,
  }) async {
    final cleanEmail = email.trim();
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: cleanEmail,
        password: password,
      );
      final userId = response.user?.id;
      if (userId == null) {
        throw StateError('User tidak ditemukan setelah login.');
      }

      final dataProfile = await _supabase
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .maybeSingle();

      if (dataProfile == null || dataProfile['role'] == null) {
        await _supabase.auth.signOut();
        throw StateError('Profil akun tidak ditemukan. Hubungi administrator.');
      }

      final actualRole = dataProfile['role'] as String;
      if (_normalizeRole(actualRole) != _normalizeRole(expectedRole)) {
        await _supabase.auth.signOut();
        throw StateError(
          'Akun ini terdaftar sebagai $actualRole, bukan $expectedRole.',
        );
      }

      return actualRole;
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw e is StateError ? e.message : 'Login gagal. Periksa kembali email dan kata sandi Anda.';
    }
  }

  String _normalizeRole(String role) {
    final normalized = role.trim().toLowerCase();
    return normalized.endsWith('s')
        ? normalized.substring(0, normalized.length - 1)
        : normalized;
  }

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      try {
        final basicResponse = await _supabase
            .from('profiles')
            .select('full_name, role')
            .eq('id', userId)
            .maybeSingle();
        return basicResponse;
      } catch (_) {
        return null;
      }
    }
  }

  /// Upload atau ganti foto profil ke Supabase Storage bucket 'profiles_images'
  Future<String> uploadAvatar({
    required String userId,
    required List<int> bytes,
    required String fileName,
  }) async {
    try {
      final fileExt = fileName.contains('.') ? fileName.split('.').last : 'jpg';
      final path = '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await _supabase.storage.from('profiles_images').uploadBinary(
        path,
        Uint8List.fromList(bytes),
        fileOptions: FileOptions(
          contentType: 'image/$fileExt',
          upsert: true,
        ),
      );

      final publicUrl = _supabase.storage.from('profiles_images').getPublicUrl(path);

      try {
        await _supabase.from('profiles').update({'avatar_url': publicUrl}).eq('id', userId);
      } catch (_) {
        // Ignored if avatar_url column is not yet created in PostgreSQL profiles table schema
      }

      return publicUrl;
    } on StorageException catch (e) {
      throw e.message;
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Gagal mengunggah foto profil: $e';
    }
  }

  Future<void> logoutAkun() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw "Gagal logout, coba lagi.";
    }
  }

  /// Mengirimkan email permintaan reset password / kode OTP pemulihan
  Future<void> resetPasswordForEmail({required String email}) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty) {
      throw 'Email wajib diisi.';
    }
    try {
      await _supabase.auth.resetPasswordForEmail(cleanEmail);
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('rate limit') || msg.contains('rate_limit')) {
        throw 'Batas pengiriman email Supabase tercapai (rate limit). Silakan hubungkan Custom SMTP (Resend/Gmail) di Supabase Dashboard atau coba beberapa saat lagi.';
      } else if (msg.contains('smtp') || msg.contains('provider disabled')) {
        throw 'Layanan email belum dikonfigurasi di Supabase. Silakan aktifkan Custom SMTP di Dashboard Supabase.';
      }
      throw e.message;
    } catch (e) {
      throw 'Gagal mengirimkan email reset password. Pastikan email valid dan terdaftar.';
    }
  }

  /// Memverifikasi kode OTP pemulihan yang dikirim ke email
  Future<AuthResponse> verifyResetOtp({
    required String email,
    required String token,
  }) async {
    final cleanEmail = email.trim();
    final cleanToken = token.trim();
    if (cleanEmail.isEmpty || cleanToken.isEmpty) {
      throw 'Email dan kode OTP wajib diisi.';
    }
    try {
      final response = await _supabase.auth.verifyOTP(
        email: cleanEmail,
        token: cleanToken,
        type: OtpType.recovery,
      );
      if (response.session == null) {
        throw 'Kode OTP tidak valid atau telah kadaluarsa.';
      }
      return response;
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw e is String ? e : 'Gagal memverifikasi kode OTP. Silakan coba lagi.';
    }
  }

  /// Memperbarui kata sandi pengguna setelah berhasil diverifikasi / login
  Future<UserResponse> updatePassword({required String newPassword}) async {
    final cleanPassword = newPassword.trim();
    if (cleanPassword.length < 6) {
      throw 'Kata sandi baru minimal 6 karakter.';
    }
    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(password: cleanPassword),
      );
      if (response.user == null) {
        throw 'Gagal mengonfirmasi kata sandi baru. Silakan coba lagi.';
      }
      return response;
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw e is String ? e : 'Gagal memperbarui kata sandi. Silakan coba lagi.';
    }
  }
}
