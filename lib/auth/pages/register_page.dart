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
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();


  Future<void> _prosesRegister() async {
    try{
      await _authServices.daftarAkun(email: _emailController.text.trim(), password: _passwordController.text.trim());

      if (mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registrasi Berhasil!"))
        );
        Navigator.pop(context);
      }
    }catch (e){
      if (mounted){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
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
              Container(
                width: double.infinity,
                height: 45, // Naikkan sedikit supaya tidak terlalu sempit
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // TOMBOL 1: STUDENTS (Index 0)
                    Container(
                      width: 90,
                      decoration: BoxDecoration(
                        color: selectedIndex == 0
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextButton(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        onPressed: () {
                          setState(() => selectedIndex = 0);
                        },
                        child: Text(
                          "Students",
                          style: TextStyle(
                            color: selectedIndex == 0
                                ? Colors.black
                                : Colors.black54,
                            fontWeight: selectedIndex == 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),

                    // TOMBOL 2: PARENTS (Index 1)
                    Container(
                      width: 90,
                      decoration: BoxDecoration(
                        color: selectedIndex == 1
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextButton(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        onPressed: () {
                          setState(() => selectedIndex = 1);
                        },
                        child: Text(
                          "Parents",
                          style: TextStyle(
                            color: selectedIndex == 1
                                ? Colors.black
                                : Colors.black54,
                            fontWeight: selectedIndex == 1
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),

                    // TOMBOL 3: TEACHER (Index 2)
                    Container(
                      width: 90,
                      decoration: BoxDecoration(
                        color: selectedIndex == 2
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextButton(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        onPressed: () {
                          setState(() => selectedIndex = 2);
                        },
                        child: Text(
                          "Teacher",
                          style: TextStyle(
                            color: selectedIndex == 2
                                ? Colors.black
                                : Colors.black54,
                            fontWeight: selectedIndex == 2
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
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
                      spreadRadius: 2
                    )
                  ]
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
                          SizedBox(height: 5,),
                          CustomTextField(
                          controller: _fullnameController, hintText: "Jhoen Doe",icon: Icons.person,),
                           SizedBox(height: 10),
                           Text("Email"),
                           SizedBox(height: 5,),
                            CustomTextField(
                          controller: _emailController, hintText: "Jhoen Doe",icon: Icons.email,),
                           SizedBox(height: 10),
                           Text("Full Name"),
                           SizedBox(height: 5),
                            CustomTextField(
                             controller: _passwordController, hintText: "Password",icon: Icons.lock, isPassword: true,),
                             SizedBox(height: 10,),
                             Text("Confirm Password"),
                             SizedBox(height:5),
                             CustomTextField(
                            controller: _confirmController, hintText: "Password",icon: Icons.lock_reset, isPassword: true,),
                            SizedBox(height: 20,),
                            SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: ElevatedButton(style:ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadiusGeometry.circular(10)
                                          ),
                                          backgroundColor: Color(0xFF2563EB)
                                        ), onPressed: (
                                        ){
                                          _prosesRegister();
                                        }, child: Text("Sign up",style: TextStyle(color: Colors.white,fontSize: 20)))
                                       )
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
                      TextButton(onPressed: (){
                       Navigator.pop(context);
                      }, child: Text("Sign ", style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.bold
                      ),))
                    ],
                  )
            ],
            
          ),
        ),
      ),
    );
  }
}