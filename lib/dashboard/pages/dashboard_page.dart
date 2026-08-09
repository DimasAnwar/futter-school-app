import 'package:flutter/material.dart';
import 'package:bestpractice/services/auth_services.dart';


class DashboardPage extends StatefulWidget {
  const DashboardPage({ Key? key }) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final AuthServices  _authService = AuthServices();

  Future<void> _prosesLogout(BuildContext context) async {
  try {
    await _authService.logoutAkun();
    
    if (context.mounted) {
      // Tampilkan pesan sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Berhasil Logout")),
      );
      
      // Navigasi yang paling aman buat Logout
      Navigator.pushNamed(context, '/');
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Column(
        children: [
          ElevatedButton(onPressed: (){_prosesLogout(context);}, child: Text("Logut"))
        ],
      )),
    );
  }
}