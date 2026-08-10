import 'package:flutter/material.dart';
import 'package:bestpractice/services/auth_services.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final AuthServices _authService = AuthServices();

  Future<void> _prosesLogout(BuildContext context) async {
    try {
      await _authService.logoutAkun();

      if (context.mounted) {
        // Tampilkan pesan sukses
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Berhasil Logout")));

        // Navigasi yang paling aman buat Logout
        Navigator.pushNamed(context, '/');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: ClipOval(
                          child: Image.network(
                            'https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcSXohgsDoQdoPoxPYX--BKhIvfpM9j3AMLVXTLr2Kk2yeLP6Cdr',
                            width: 100, // Tentukan lebar
                            height:
                                100, // Tentukan tinggi (harus sama persis sama width biar jadi lingkaran pas)
                            fit: BoxFit.cover, // Biar gambarnya nggak gepeng/distorsi
                          ),
                        ),
                      ),
                      SizedBox(width: 5,),
                      Text("Hello Dimas", style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
                      Spacer(),
                      IconButton(
                        onPressed: () {
                          _prosesLogout(context);
                        },
                        icon: Icon(Icons.logout),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Text("Hello World")
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
