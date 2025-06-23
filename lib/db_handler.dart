import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHandler {
  //Init.
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    // Initialize the database
    _database = await _initDb();
    return _database!;
  }

  static Future<Database> _initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, './data/todo.db');

    return await openDatabase(path, version: 1, onCreate: _createTable);
  }

  static Future<void> _createTable(Database database, int version) async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS todos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL
      )
    ''');
  }

  // Handling.
  static Future<int> insertTodo(String content) async {
    final db = await database;
    return await db.insert('todos', {'content': content});
  }

  static Future<List<Map<String, dynamic>>> getTodos() async {
    final database = await DbHandler.database;
    return await database.query('todos');
  }

  static Future<int> updateTodo(int id, String content) async {
    final db = await database;
    return await db.update(
      'todos',
      {'content': content},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteTodo(int id) async {
    final db = await database;
    return await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }
}
