
import 'package:supabase_flutter/supabase_flutter.dart';


class AuthServices {
  final _supabase = Supabase.instance.client;

  Future<void> daftarAkun({required String email, required String password}) async {
    try{
      await _supabase.auth.signUp(email: email, password: password);
    } on AuthException catch (e){
      throw e.message;
    } catch (e){
      throw 'Terjadi Kesalahan,Coba lagi';
    }
    
  }


  Future<void> loginAkun({required String email, required String password}) async{
    try{
      await _supabase.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e){
      throw e.message;
    }catch (e){
      throw "Login Gagal";
    }
  }
  
  Future<void> logoutAkun() async {
  try {
    await _supabase.auth.signOut();
  } catch (e) {
    throw "Gagal logout, coba lagi.";
  }
}
}
