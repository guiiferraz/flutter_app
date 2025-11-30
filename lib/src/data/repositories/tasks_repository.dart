// src/data/repositories/tasks_repository.dart
import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models/tasks.dart';

class TasksRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // =====================
  // CREATE - Inserir tarefa
  // =====================
  Future<int> createTask(Tarefa task) async {
    final db = await _dbHelper.db;
    return await db.insert(
      'tarefas',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // substitui se id já existir
    );
  }

  // =====================
  // READ - Listar todas as tarefas
  // =====================
  Future<List<Tarefa>> getTasksByUserId(int usuarioId) async {
    final db = await _dbHelper.db;
    final maps = await db.query(
      'tarefas',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
    );

    return List.generate(maps.length, (i) => Tarefa.fromMap(maps[i]));
  }

  // =====================
  // READ - Buscar tarefa por ID
  // =====================
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

  // =====================
  // UPDATE - Atualizar tarefa
  // =====================
  Future<int> updateTask(Tarefa task) async {
    final db = await _dbHelper.db;
    return await db.update(
      'tarefas',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // =====================
  // DELETE - Deletar tarefa por ID
  // =====================
  Future<int> deleteTask(int id) async {
    final db = await _dbHelper.db;
    return await db.delete(
      'tarefas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =====================
  // DELETE - Deletar todas as tarefas (útil para testes)
  // =====================
  Future<int> deleteAllTasks() async {
    final db = await _dbHelper.db;
    return await db.delete('tarefas');
  }
}
