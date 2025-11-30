import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models/tasks.dart';

class TasksRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> createTask(Tarefa task) async {
    final db = await _dbHelper.db;
    return await db.insert(
      'tarefas',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Tarefa>> getTasksByUserId(int usuarioId) async {
    final db = await _dbHelper.db;
    final maps = await db.query(
      'tarefas',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
    );

    return List.generate(maps.length, (i) => Tarefa.fromMap(maps[i]));
  }

  Future<Tarefa?> getTaskById(int id) async {
    final db = await _dbHelper.db;
    final maps = await db.query(
      'tarefas',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Tarefa.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> updateTask(Tarefa task) async {
    final db = await _dbHelper.db;
    return await db.update(
      'tarefas',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await _dbHelper.db;
    return await db.delete(
      'tarefas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllTasks() async {
    final db = await _dbHelper.db;
    return await db.delete('tarefas');
  }
}
