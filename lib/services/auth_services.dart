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
  }) async {
    final cleanEmail = email.trim();
    try {
      final dataMap = <String, dynamic>{
        'full_name': fullName.trim(),
        'role': role,
      };
      if (nim != null && nim.trim().isNotEmpty) dataMap['nim'] = nim.trim();
      if (jurusan != null && jurusan.trim().isNotEmpty) dataMap['jurusan'] = jurusan.trim();

      final response = await _supabase.auth.signUp(
        email: cleanEmail,
        password: password,
        data: dataMap,
      );

      final user = response.user;
      if (user == null) {
        throw 'Akun tidak berhasil dibuat. Coba beberapa saat lagi.';
      }

      // Auto-assign nim & jurusan to profiles table if user session is available
      final updatePayload = <String, dynamic>{};
      if (nim != null && nim.trim().isNotEmpty) updatePayload['nim'] = nim.trim();
      if (jurusan != null && jurusan.trim().isNotEmpty) updatePayload['jurusan'] = jurusan.trim();
      if (updatePayload.isNotEmpty) {
        try {
          await _supabase.from('profiles').update(updatePayload).eq('id', user.id);
        } catch (_) {
          // Handled gracefully if session pending email confirmation
        }
      }

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

  Future<Map<String, dynamic>?> getProfile(String userId) {
    return _supabase
        .from('profiles')
        .select('full_name, role')
        .eq('id', userId)
        .maybeSingle();
  }

  Future<void> logoutAkun() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw "Gagal logout, coba lagi.";
    }
  }
}
