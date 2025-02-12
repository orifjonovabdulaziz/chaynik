import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../models/category.dart';


class CategoryDatabase {
  static final CategoryDatabase instance = CategoryDatabase._init();
  static Database? _database;

  CategoryDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('category.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        product_count INTEGER NOT NULL
      )
    ''');
  }

  Future<void> insertCategories(List<Category> categories) async {
    final db = await instance.database;

    for (var category in categories) {
      await db.insert(
        'categories',
        category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<Category>> getCategories() async {
    final db = await instance.database;
    final result = await db.query('categories');
    return result.map((json) => Category.fromJson(json)).toList();
  }
}
