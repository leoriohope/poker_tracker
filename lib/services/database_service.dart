import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import '../models/session.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      if (kIsWeb) {
        var factory = databaseFactoryFfiWeb;
        return await factory.openDatabase('poker_tracker.db',
          options: OpenDatabaseOptions(
            version: 1,
            onCreate: (Database db, int version) async {
              await db.execute('''
                CREATE TABLE sessions(
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  date TEXT NOT NULL,
                  buyIn REAL NOT NULL,
                  cashOut REAL NOT NULL,
                  location TEXT NOT NULL,
                  duration INTEGER NOT NULL,
                  notes TEXT
                )
              ''');
            },
          ),
        );
      } else {
        String path = join(await getDatabasesPath(), 'poker_tracker.db');
        return await openDatabase(
          path,
          version: 1,
          onCreate: (Database db, int version) async {
            await db.execute('''
              CREATE TABLE sessions(
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                date TEXT NOT NULL,
                buyIn REAL NOT NULL,
                cashOut REAL NOT NULL,
                location TEXT NOT NULL,
                duration INTEGER NOT NULL,
                notes TEXT
              )
            ''');
          },
        );
      }
    } catch (e) {
      print('Database initialization error: $e');
      rethrow;
    }
  }

  Future<int> insertSession(Session session) async {
    try {
      final db = await database;
      final result = await db.insert('sessions', session.toMap());
      print('Session inserted with id: $result');
      return result;
    } catch (e) {
      print('Insert session error: $e');
      throw Exception('Failed to insert session: $e');
    }
  }

  Future<List<Session>> getSessions() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('sessions');
      print('Retrieved ${maps.length} sessions');
      return List.generate(maps.length, (i) => Session.fromMap(maps[i]));
    } catch (e) {
      print('Get sessions error: $e');
      throw Exception('Failed to get sessions: $e');
    }
  }
}