class ProjectModel {
  final int id;
  final String name;
  final String transcription;

  ProjectModel({
    required this.id,
    required this.name,
    required this.transcription,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'],
      name: map['name'],
      transcription: map['transcription'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'transcription': transcription,
    };
  }
}