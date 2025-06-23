import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'place.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'favorites.db');
    return openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE favorites(
            id INTEGER PRIMARY KEY,
            name TEXT,
            image TEXT,
            description TEXT,
            url TEXT
          )
          ''',
        );
      },
      version: 1,
    );
  }

  static Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<void> insertFavorite(Place place) async {
    final dbClient = await db;
    await dbClient.insert(
      'favorites',
      place.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteFavorite(int id) async {
    final dbClient = await db;
    await dbClient.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Place>> getFavorites() async {
    final dbClient = await db;
    final maps = await dbClient.query('favorites');
    return maps.map((map) => Place.fromMap(map)).toList();
  }
 static Future<void> clearFavorites() async {
  final dbClient = await db; // ✅ هذا هو الاسم الصحيح المستخدم في بقية الدوال
  await dbClient.delete('favorites');
}
}