import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('projects.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS projects (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      transcription TEXT NOT NULL
    )
  ''');
  }

  Future<int> insertProject(String name, String transcription) async {
    final db = await database;
    return await db
        .insert('projects', {'name': name, 'transcription': transcription});
  }

  Future<int> deleteProject(int id) async {
    final db = await database;
    return await db.delete(
      'projects',
      where: 'id = ?', // Match by id
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getProjects() async {
    final db = await database;
    return await db.query('projects');
  }

  Future<Map<String, dynamic>> getProjectById(int id) async {
    final db = await database;
    final result = await db.query('projects', where: 'id = ?', whereArgs: [id]);
    return result.first;
  }
}