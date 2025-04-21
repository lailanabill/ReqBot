class ProjectModel {
  final int id;
  final int analyzer_id; // Assuming this is an int, adjust if necessary
  final String name;
  final String transcription;
  final String status;
  final String summary;

  ProjectModel({
    required this.id,
    required this.analyzer_id,
    required this.name,
    required this.transcription,
    required this.status,
    required this.summary,
  });

  /// Convert a Supabase response map into a ProjectModel
  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'] ?? 0,
      analyzer_id: map['analyzer_id'] ?? 0,
      name: map['name'] ?? '',
      transcription: map['transcription'] ?? '',
      summary: map['summary'] ?? '',
      status: map['status'] ?? '',
    );
  }

  /// Convert ProjectModel to a map (for Supabase insert/update)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'transcription': transcription,
      'summary': summary,
      'status': status,
    };
  }
}
