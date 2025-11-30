import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    // Obtem o caminho padrão para armazenar o banco no dispositivo
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'todo_app.db');

    // Abre ou cria o banco
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Criação da tabela de usuários
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT
      )
    ''');

    // Criação da tabela de tarefas
    await db.execute('''
      CREATE TABLE tarefas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        date TEXT,
        status TEXT,
        usuario_id INTEGER,
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
      )
    ''');
  }

  Future<void> printDatabaseContent() async {
    final db = await DatabaseHelper().db;

    // Ler todas as tabelas
    final usuarios = await db.query('usuarios');
    final tarefas = await db.query('tarefas');

    // Printar no console
    print('--- USUÁRIOS ---');
    for (var u in usuarios) {
      print(u);
    }

    print('--- TAREFAS ---');
    for (var t in tarefas) {
      print(t);
    }
  }
  
}
