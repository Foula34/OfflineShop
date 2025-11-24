import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('shop.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        price REAL NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        image TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertProduct(Map<String, Object?> data) async {
    final db = await database;
    return await db.insert(
      'products',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, Object?>>> getProducts() async {
    final db = await database;
    return await db.query('products');
  }
}
