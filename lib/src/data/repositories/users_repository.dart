import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models/users.dart';

class UsersRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> createUser(Usuario user) async {
    final db = await _dbHelper.db;
    return await db.insert(
      'usuarios',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, 
    );
  }

  Future<List<Usuario>> getAllUsers() async {
    final db = await _dbHelper.db;
    final maps = await db.query('usuarios');

    return List.generate(maps.length, (i) {
      return Usuario.fromMap(maps[i]);
    });
  }

  Future<Usuario?> getUserById(int id) async {
    final db = await _dbHelper.db;
    final maps = await db.query(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Usuario.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<Usuario?> getUserByEmail(String email) async {
    final db = await _dbHelper.db;

    final maps = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return Usuario.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> updateUser(Usuario user) async {
    final db = await _dbHelper.db;
    return await db.update(
      'usuarios',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await _dbHelper.db;
    return await db.delete(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
