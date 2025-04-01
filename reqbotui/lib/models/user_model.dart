class UserModel {
  final String id; // Supabase Auth user ID
  final String name;
  final String email;
  final String phone;
  final String company;
  final String position;

  UserModel({
    required this.id, // Supabase assigns this
    required this.name,
    required this.email,
    required this.phone,
    required this.company,
    required this.position,
  });

  /// Convert a Supabase response map into a UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'], // Supabase user ID
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      company: map['company'],
      position: map['position'],
    );
  }

  /// Convert UserModel to a map (for Supabase insert/update)
  Map<String, dynamic> toMap() {
    return {
      'id': id, 
      'name': name,
      'email': email,
      'phone': phone,
      'company': company,
      'position': position,
    };
  }
}
