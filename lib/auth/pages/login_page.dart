import 'package:bestpractice/services/auth_services.dart';
import 'package:flutter/material.dart';
import './widgets/custom_input.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authService = AuthServices();
  int selectedIndex = 0;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

Future<void> _prosesLogin() async{
  try{
    await _authService.loginAkun(email: _emailController.text.trim(), password: _passwordController.text.trim());

    if (mounted){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login Berhasil")));
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }catch (e){
    if (mounted){
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text(e.toString())));
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.school,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              const Text(
                "EduSchool",
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
              ),
              const Text("Sign In To EduSchool"),
              const SizedBox(height: 20),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 400,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(25),
                              offset: const Offset(2, 1),
                              blurRadius: 2,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20), // Perbaikan disini
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 300,
                                    height: 45, // Gua naikin dikit jadi 45 biar nggak sempit pas dikasih padding
                                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4), // Jarak luar ke tombol
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEAF1FF),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      // Ini yang bikin tombolnya nyebar rata ada jaraknya
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // TOMBOL 1: STUDENTS (Index 0)
                                        Container(
                                          width: 90, // Lebar diubah jadi 90
                                          decoration: BoxDecoration(
                                            color: selectedIndex == 0 ? Colors.white : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: TextButton(
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero, // Biar text gak kepotong di ruang sempit
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                selectedIndex = 0;
                                              });
                                            },
                                            child: Text(
                                              "Students",
                                              style: TextStyle(
                                                color: selectedIndex == 0 ? Colors.black : Colors.black54,
                                                fontWeight: selectedIndex == 0 ? FontWeight.bold : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                                        
                                        // TOMBOL 2: PARENTS (Index 1)
                                        Container(
                                          width: 90,
                                          decoration: BoxDecoration(
                                            color: selectedIndex == 1 ? Colors.white : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: TextButton(
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                selectedIndex = 1;
                                              });
                                            },
                                            child: Text(
                                              "Parents",
                                              style: TextStyle(
                                                color: selectedIndex == 1 ? Colors.black : Colors.black54,
                                                fontWeight: selectedIndex == 1 ? FontWeight.bold : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                  
                                        // TOMBOL 3: TEACHER (Index 2)
                                        Container(
                                          width: 90,
                                          decoration: BoxDecoration(
                                            color: selectedIndex == 2 ? Colors.white : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: TextButton(
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                selectedIndex = 2;
                                              });
                                            },
                                            child: Text(
                                              "Teacher",
                                              style: TextStyle(
                                                color: selectedIndex == 2 ? Colors.black : Colors.black54,
                                                fontWeight: selectedIndex == 2 ? FontWeight.bold : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                  children: [
                                    Text("Email or ID"),
                                    SizedBox(height: 5),
                                    CustomTextField(
                                      controller: _emailController, hintText: "Email or ID",icon: Icons.person,),
                                      SizedBox(height: 10),
                                    Text("Password"),
                                    SizedBox(height: 5),
                                    CustomTextField(
                                      controller: _passwordController, hintText: "Password",icon: Icons.lock, isPassword: true,),
                                      SizedBox(height: 5,),
                                      SizedBox(
                                        width: double.infinity,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            TextButton(onPressed: (){}, child: Text("Forget Password?",style: TextStyle(color: Color(0xFF2563EB)),)),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: ElevatedButton(style:ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadiusGeometry.circular(10)
                                          ),
                                          backgroundColor: Color(0xFF2563EB)
                                        ), onPressed: (){
                                          _prosesLogin();
                                        }, child: Text("Sign In",style: TextStyle(color: Colors.white,fontSize: 20)))
                                        )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      
                      Text("Doesnt Have Account?"),
                      TextButton(onPressed: (){
                        Navigator.pushNamed(context, '/register');
                      }, child: Text("Sign Up", style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.bold
                      ),))
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}