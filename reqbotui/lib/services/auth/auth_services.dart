import 'package:supabase_flutter/supabase_flutter.dart';

class AuthServices {
  final SupabaseClient _supabase = Supabase.instance.client;

//Signin
  Future<AuthResponse> signInWithEmailPassword(
      String email, String password) async {
    return await _supabase.auth
        .signInWithPassword(email: email, password: password);
  }

//Signup
  Future<AuthResponse> signUpWithEmailPassword(String name, String email,
      String phone, String password, String company, String position) async {
    try {
      // Sign up the user in the authentication system
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final userId = response.user!.id;
        await _supabase.from('users').insert({
          'id': userId,
          'name': name,
          'phone': phone,
          'email': email,
          'company': company,
          'position': position,
        });

        print("User data saved successfully in the 'users' table.");
      } else if (response.error != null) {
        throw Exception(response.error!.message);
      }

      return response;
    } catch (e) {
      print("Error during sign-up: $e");
      rethrow;
    }
  }

//signout
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}

extension on AuthResponse {
  get error => null;
}
