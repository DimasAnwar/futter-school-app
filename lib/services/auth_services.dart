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
    try {
      final dataMap = <String, dynamic>{
        'full_name': fullName,
        'role': role,
      };
      if (nim != null && nim.isNotEmpty) dataMap['nim'] = nim;
      if (jurusan != null && jurusan.isNotEmpty) dataMap['jurusan'] = jurusan;

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: dataMap,
      );

      final user = response.user;
      if (user == null) {
        throw 'Akun tidak berhasil dibuat. Coba lagi.';
      }

      // Auto-assign nim & jurusan to profiles table if user session is available
      final updatePayload = <String, dynamic>{};
      if (nim != null && nim.isNotEmpty) updatePayload['nim'] = nim;
      if (jurusan != null && jurusan.isNotEmpty) updatePayload['jurusan'] = jurusan;
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
      throw 'Gagal mendaftar: $e';
    }
  }

  Future<String> loginAkun({
    required String email,
    required String password,
    required String expectedRole,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
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
        throw StateError('Profil akun tidak ditemukan. Hubungi admin.');
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
      throw e is StateError ? e.message : 'Login gagal: $e';
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
