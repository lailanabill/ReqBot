import 'package:supabase_flutter/supabase_flutter.dart';

class AuthServices {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResponse> signInWithEmailPassword(
      String email, String password) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<AuthResponse> signUpWithEmailPassword(
    String name,
    String email,
    String phone,
    String password,
    String company,
    String position,
  ) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'phone': phone,
          'company': company,
          'position': position,
        },
      );

      if (response.user != null) {
        await _supabase.from('users').insert({
          'id': response.user!.id,
          'name': name,
          'phone': phone,
          'email': email,
          'company': company,
          'position': position,
        });
      }

      return response;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Exception _handleAuthError(dynamic error) {
    if (error.toString().contains('network')) {
      return Exception('Network error. Please check your connection.');
    }
    if (error.toString().contains('email')) {
      return Exception('This email is already registered.');
    }
    return Exception(error.toString());
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
