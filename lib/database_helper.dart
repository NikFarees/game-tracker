import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Game {
  final int? id;
  final String title;
  final String platform;
  final int hours;
  final String status;

  Game({
    this.id,
    required this.title,
    required this.platform,
    required this.hours,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'platform': platform,
      'hours': hours,
      'status': status,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory Game.fromMap(Map<String, dynamic> m) => Game(
        id: m['id'] as int?,
        title: m['title'] as String,
        platform: m['platform'] as String,
        hours: m['hours'] as int,
        status: m['status'] as String,
      );
}

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'gamelog.db');
    return openDatabase(
      path,
      version: 4,
      onCreate: _create,
      onUpgrade: _upgrade,
    );
  }

  Future<void> _create(Database db, int version) async {
    await db.execute('''
      CREATE TABLE games (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        platform TEXT NOT NULL,
        hours INTEGER NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    await _createUsers(db);
  }

  Future<void> _createUsers(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        studentId TEXT NOT NULL,
        course TEXT NOT NULL
      )
    ''');
  }

  Future<void> _upgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await db.execute('DROP TABLE IF EXISTS profile');
      await db.execute('DROP TABLE IF EXISTS users');
      await _createUsers(db);
    }
  }

  Future<int> insertGame(Game game) async {
    final db = await database;
    return db.insert('games', game.toMap());
  }

  Future<List<Game>> getGames() async {
    final db = await database;
    final rows = await db.query('games', orderBy: 'id DESC');
    return rows.map(Game.fromMap).toList();
  }

  Future<int> updateGame(Game game) async {
    final db = await database;
    return db.update('games', game.toMap(), where: 'id = ?', whereArgs: [game.id]);
  }

  Future<int> deleteGame(int id) async {
    final db = await database;
    return db.delete('games', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getTotalCount() async {
    final db = await database;
    final res = await db.rawQuery('SELECT COUNT(*) AS c FROM games');
    return Sqflite.firstIntValue(res) ?? 0;
  }

  Future<int> getNowPlayingCount() async {
    final db = await database;
    final res = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM games WHERE status = ?',
      ['Playing'],
    );
    return Sqflite.firstIntValue(res) ?? 0;
  }

  String _hash(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  Future<bool> usernameExists(String username) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> registerUser({
    required String username,
    required String password,
    required String name,
    required String email,
    required String phone,
    required String studentId,
    required String course,
  }) async {
    final db = await database;
    await db.insert('users', {
      'username': username,
      'password': _hash(password),
      'name': name,
      'email': email,
      'phone': phone,
      'studentId': studentId,
      'course': course,
    });
  }

  Future<Map<String, dynamic>> getUser(String username) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : <String, dynamic>{};
  }

  Future<bool> checkLogin(String username, String password) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, _hash(password)],
      limit: 1,
    );
    return rows.isNotEmpty;
  }
}
