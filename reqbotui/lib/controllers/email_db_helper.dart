import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class EmailDBHelper {
  static final EmailDBHelper _instance = EmailDBHelper._internal();
  factory EmailDBHelper() => _instance;
  EmailDBHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    return await openDatabase(
      join(dbPath, 'emails.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE emails(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE
          )
        ''');
      },
    );
  }

  Future<void> insertEmail(String email) async {
    final db = await database;
    try {
      await db.insert('emails', {'email': email},
          conflictAlgorithm: ConflictAlgorithm.ignore);
    } catch (e) {
      print('Insert error: $e');
    }
  }

  Future<List<String>> getEmails() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('emails');
    return maps.map((e) => e['email'] as String).toList();
  }
}
