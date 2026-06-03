import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// A single tracked game.
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
    // Leave id out on insert so SQLite assigns it.
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

/// Wraps the SQLite database. One shared instance for the whole app.
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
      version: 2,
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

    await db.execute('''
      CREATE TABLE profile (
        id INTEGER PRIMARY KEY,
        name TEXT,
        email TEXT,
        phone TEXT,
        genre TEXT
      )
    ''');

    // Seed the single profile row. The displayed username comes from login,
    // so it is not stored here; only these details are.
    await db.insert('profile', {
      'id': 1,
      'name': 'Muhammad Haziq',
      'email': 'haziq.azman@gamelog.app',
      'phone': '+60 12-345 6789',
      'genre': 'MOBA',
    });

    // Seed a few games so the list isn't empty on a fresh install.
    const seedGames = [
      {'title': 'Mobile Legends: Bang Bang', 'platform': 'Mobile', 'hours': 540, 'status': 'Playing'},
      {'title': 'Genshin Impact', 'platform': 'Mobile', 'hours': 213, 'status': 'Playing'},
      {'title': "Marvel's Spider-Man", 'platform': 'PS5', 'hours': 32, 'status': 'Completed'},
      {'title': 'Grand Theft Auto V', 'platform': 'PC', 'hours': 88, 'status': 'Playing'},
    ];
    for (final g in seedGames) {
      await db.insert('games', g);
    }
  }

  Future<void> _createUsers(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');
  }

  // The users table was added in v2, so existing installs get it here
  // without dropping their games or profile.
  Future<void> _upgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createUsers(db);
    }
  }

  // Games CRUD.

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

  // Counts used by the home stat cards.

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

  Future<Map<String, dynamic>> getProfile() async {
    final db = await database;
    final rows = await db.query('profile', where: 'id = ?', whereArgs: [1], limit: 1);
    return rows.isNotEmpty ? rows.first : <String, dynamic>{};
  }

  // Accounts. Passwords are stored as a SHA-256 hex digest, never plain text.

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

  Future<void> registerUser(String username, String password) async {
    final db = await database;
    await db.insert('users', {
      'username': username,
      'password': _hash(password),
    });
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
