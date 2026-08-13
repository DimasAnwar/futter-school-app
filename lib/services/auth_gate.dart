import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/pages/login_page.dart';
import '../common/widgets/dashboard_skeleton.dart';
import '../dashboard/pages/parent_dashboard_page.dart';
import '../dashboard/pages/admin_dashboard_page.dart';
import '../dashboard/pages/student_dashboard_page.dart';
import '../dashboard/pages/teacher_dashboard_page.dart';
import 'auth_services.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: SafeArea(child: DashboardSkeleton()),
          );
        }

        final session = snapshot.data?.session;

        if (session == null) {
          return const LoginPage();
        }

        return FutureBuilder<Map<String, dynamic>?>(
          future: AuthServices().getProfile(session.user.id),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: SafeArea(child: DashboardSkeleton()),
              );
            }
            final profile = profileSnapshot.data;
            if (profile == null) {
              return const Scaffold(
                body: Center(child: Text('Profil akun tidak ditemukan.')),
              );
            }

            final name = (profile['full_name'] as String?)?.trim();
            final fullName = (name == null || name.isEmpty) ? 'Pengguna' : name;
            final role = (profile['role'] as String? ?? '').toLowerCase();
            if (role == 'admin' || role == 'admins') {
              return AdminDashboardPage(fullName: fullName);
            }
            if (role == 'student' || role == 'students') {
              return StudentDashboardPage(fullName: fullName);
            }
            if (role == 'teacher' || role == 'teachers') {
              return TeacherDashboardPage(fullName: fullName);
            }
            if (role == 'parent' || role == 'parents') {
              return ParentDashboardPage(fullName: fullName);
            }
            return Scaffold(body: Center(child: Text('Role "$role" tidak dikenali.')));
          },
        );
      },
    );
  }
}
