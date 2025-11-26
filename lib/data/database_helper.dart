// Database Helper: criar o banco se nao existir, criar os modelos e abrir a conexao com o db
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    // Inicializa o banco para Web (Chrome/Edge)
    databaseFactory = databaseFactoryFfiWeb;

    return await openDatabase('todo_app.db', version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE status_enum (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        status TEXT
      )
    ''');

    await db.insert('status_enum', {'status': 'pending'});
    await db.insert('status_enum', {'status': 'in_progress'});
    await db.insert('status_enum', {'status': 'finished'});

    await db.execute('''
      CREATE TABLE tarefas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        date TEXT,
        status_id INTEGER,
        usuario_id INTEGER,
        FOREIGN KEY (status_id) REFERENCES status_enum(id),
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
      )
    ''');
  }
}