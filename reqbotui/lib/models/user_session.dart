class UserSession {
  final String userId; // Supabase Auth User ID
  final String email;
  final String accessToken; // Supabase session token

  UserSession({
    required this.userId,
    required this.email,
    required this.accessToken,
  });

  /// Convert a Supabase session response to UserSession model
  factory UserSession.fromSupabaseSession(Map<String, dynamic> sessionData) {
    return UserSession(
      userId: sessionData['user']['id'], // Supabase user ID
      email: sessionData['user']['email'],
      accessToken: sessionData['access_token'], // Supabase Auth token
    );
  }

  /// Convert UserSession to a map (if needed)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'accessToken': accessToken,
    };
  }
}
