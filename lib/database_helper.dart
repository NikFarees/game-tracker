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
    return openDatabase(path, version: 1, onCreate: _create);
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

    await db.execute('''
      CREATE TABLE profile (
        id INTEGER PRIMARY KEY,
        name TEXT,
        username TEXT,
        email TEXT,
        phone TEXT,
        genre TEXT
      )
    ''');

    // Seed one profile row. The username shown comes from login,
    // the rest of these fields are the defaults.
    await db.insert('profile', {
      'id': 1,
      'name': 'Alex Carter',
      'username': 'player',
      'email': 'alex.carter@gamelog.app',
      'phone': '+1 555 0142',
      'genre': 'Action RPG',
    });
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
}
