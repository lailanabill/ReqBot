class ProjectModel {
  final int id; 
  final String name;
  final String transcription;

  ProjectModel({
    required this.id, 
    required this.name,
    required this.transcription,
  });

  /// Convert a Supabase response map into a ProjectModel
  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'], // ID can be null if not returned
      name: map['name'],
      transcription: map['transcription'],
    );
  }

  /// Convert ProjectModel to a map (for Supabase insert/update)
  Map<String, dynamic> toMap() {
    return {
      'id': id, 
      'name': name,
      'transcription': transcription,
    };
  }
}
