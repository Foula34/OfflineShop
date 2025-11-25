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

    return await openDatabase(
      path,
      version: 3, // ⚠️ Version incrémentée pour la migration
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        price REAL NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        image TEXT NOT NULL,
        localImagePath TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE cart(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER NOT NULL,
        title TEXT NOT NULL,
        price REAL NOT NULL,
        image TEXT NOT NULL,
        localImagePath TEXT,
        quantity INTEGER NOT NULL,
        UNIQUE(productId)
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS cart(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          productId INTEGER NOT NULL,
          title TEXT NOT NULL,
          price REAL NOT NULL,
          image TEXT NOT NULL,
          quantity INTEGER NOT NULL,
          UNIQUE(productId)
        )
      ''');
    }

    // Migration pour ajouter la colonne localImagePath
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE products ADD COLUMN localImagePath TEXT');
        print('✅ Colonne localImagePath ajoutée à products');
      } catch (e) {
        print('⚠️ Colonne localImagePath existe déjà dans products');
      }

      try {
        await db.execute('ALTER TABLE cart ADD COLUMN localImagePath TEXT');
        print('✅ Colonne localImagePath ajoutée à cart');
      } catch (e) {
        print('⚠️ Colonne localImagePath existe déjà dans cart');
      }
    }
  }

  // Products methods
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

  Future<int> deleteAllProducts() async {
    final db = await database;
    return await db.delete('products');
  }

  Future<int> updateProductImagePath(
    int productId,
    String localImagePath,
  ) async {
    final db = await database;
    return await db.update(
      'products',
      {'localImagePath': localImagePath},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  // Cart methods
  Future<int> insertCartItem(Map<String, Object?> data) async {
    final db = await database;
    return await db.insert(
      'cart',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, Object?>>> getCartItems() async {
    final db = await database;
    return await db.query('cart');
  }

  Future<int> updateCartItemQuantity(int productId, int quantity) async {
    final db = await database;
    return await db.update(
      'cart',
      {'quantity': quantity},
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }

  Future<int> updateCartItemImagePath(
    int productId,
    String localImagePath,
  ) async {
    final db = await database;
    return await db.update(
      'cart',
      {'localImagePath': localImagePath},
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }

  Future<int> deleteCartItem(int productId) async {
    final db = await database;
    return await db.delete(
      'cart',
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }

  Future<int> clearCart() async {
    final db = await database;
    return await db.delete('cart');
  }

  Future<Map<String, Object?>?> getCartItemByProductId(int productId) async {
    final db = await database;
    final results = await db.query(
      'cart',
      where: 'productId = ?',
      whereArgs: [productId],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }
}
