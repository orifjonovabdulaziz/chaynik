import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/product.dart';

class ProductDatabase {
  static final ProductDatabase instance = ProductDatabase._init();
  static Database? _database;

  ProductDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('products.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        price REAL NOT NULL,
        imageUrl TEXT NOT NULL,
        categoryId INTEGER NOT NULL
      )
    ''');
  }

  Future<void> insertProducts(List<Product> products) async {
    final db = await database;

    // Используем транзакцию для массовой вставки
    await db.transaction((txn) async {
      for (var product in products) {
        await txn.insert(
          'products',
          {
            'id': product.id,
            'title': product.title,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'categoryId': product.categoryId,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');

    return List.generate(maps.length, (i) {
      return Product(
        id: maps[i]['id'],
        title: maps[i]['title'],
        price: maps[i]['price'],
        imageUrl: maps[i]['imageUrl'],
        categoryId: maps[i]['categoryId'],
      );
    });
  }

  Future<void> deleteProduct(int productId) async {
    final db = await database;
    await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  Future<void> deleteAllProducts() async {
    final db = await database;
    await db.delete('products');
  }


  Future<void> updateProduct(int productId, {
    String? title,
    int? category,
    String? image,
    double? price
  }) async {
    final db = await database;

    // Создаём Map только с теми полями, которые не null
    Map<String, dynamic> updateData = {};

    if (title != null) updateData["title"] = title;
    if (category != null) updateData["categoryId"] = category;
    if (image != null) updateData["imageUrl"] = image;
    if (price != null) updateData["price"] = price;


    await db.update(
      'products',
      updateData,
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

}