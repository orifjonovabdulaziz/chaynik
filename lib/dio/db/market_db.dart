import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/market.dart';


class MarketDatabase {
  static final MarketDatabase instance = MarketDatabase._init();
  static Database? _database;

  MarketDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('markets.db');
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
      CREATE TABLE markets (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        token TEXT NOT NULL,
        shop_id TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
  }

  /// 🔹 **Вставка списка маркетов**
  Future<void> insertMarkets(List<Market> markets) async {
    final db = await database;

    await db.transaction((txn) async {
      for (var market in markets) {
        await txn.insert(
          'markets',
          {
            'id': market.id,
            'name': market.name,
            'token': market.token,
            'shop_id': market.shopId,
            'created_at': market.createdAt,
            'updated_at': market.updatedAt,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  /// 🔹 **Получение всех маркетов**
  Future<List<Market>> getMarkets() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('markets');

    return List.generate(maps.length, (i) {
      return Market(
        id: maps[i]['id'],
        name: maps[i]['name'],
        token: maps[i]['token'],
        shopId: maps[i]['shop_id'],
        createdAt: maps[i]['created_at'],
        updatedAt: maps[i]['updated_at'],
      );
    });
  }

  /// 🔹 **Получение маркета по ID**
  Future<Market?> getMarketById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'markets',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Market(
        id: maps[0]['id'],
        name: maps[0]['name'],
        token: maps[0]['token'],
        shopId: maps[0]['shop_id'],
        createdAt: maps[0]['created_at'],
        updatedAt: maps[0]['updated_at'],
      );
    }
    return null;
  }

  /// 🔹 **Удаление маркета**
  Future<void> deleteMarket(int id) async {
    final db = await database;
    await db.delete(
      'markets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 🔹 **Удаление всех маркетов**
  Future<void> deleteAllMarkets() async {
    final db = await database;
    await db.delete('markets');
  }

  /// 🔹 **Обновление маркета**
  Future<void> updateMarket(Market market) async {
    final db = await database;
    await db.update(
      'markets',
      {
        'name': market.name,
        'token': market.token,
        'shop_id': market.shopId,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [market.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 🔹 **Проверка существования маркета**
  Future<bool> marketExists(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'markets',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty;
  }

  /// 🔹 **Получение количества маркетов**
  Future<int> getMarketsCount() async {
    final db = await database;
    return Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM markets'),
    ) ??
        0;
  }

  /// 🔹 **Закрытие базы данных**
  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}