import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/sold.dart';

class SoldDatabase {
  static final SoldDatabase instance = SoldDatabase._init();
  static Database? _database;

  SoldDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sold.db');
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

  Future<void> _createDB(Database db, int version) async {
    // Создаем таблицу для продаж
    await db.execute('''
      CREATE TABLE sold (
        id INTEGER PRIMARY KEY,
        client INTEGER NOT NULL,
        paid REAL NOT NULL,
        total REAL
      )
    ''');

    // Создаем таблицу для товаров в продаже
    await db.execute('''
      CREATE TABLE sold_items (
        id INTEGER PRIMARY KEY,
        sold_id INTEGER NOT NULL,
        product INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (sold_id) REFERENCES sold (id) ON DELETE CASCADE
      )
    ''');
  }

  // Вставка продажи с товарами
  Future<void> insertSolds(List<Sold> solds) async {
    final db = await database;

    await db.transaction((txn) async {
      for (var sold in solds) {
        // Вставляем продажу
        final soldId = await txn.insert(
          'sold',
          {
            'id': sold.id,
            'client': sold.client,
            'paid': sold.paid,
            'total': sold.total,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Вставляем товары продажи
        for (var item in sold.outcome) {
          await txn.insert(
            'sold_items',
            {
              'id': item.id,
              'sold_id': soldId,
              'product': item.product,
              'quantity': item.quantity,
              'price': item.price,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
  }

  // Получение всех продаж
  Future<List<Sold>> getSolds() async {
    final db = await database;

    // Получаем все продажи
    final List<Map<String, dynamic>> soldMaps = await db.query('sold');

    return Future.wait(soldMaps.map((soldMap) async {
      // Получаем товары для каждой продажи
      final List<Map<String, dynamic>> itemMaps = await db.query(
        'sold_items',
        where: 'sold_id = ?',
        whereArgs: [soldMap['id']],
      );

      final items = itemMaps.map((itemMap) => SoldItem(
        id: itemMap['id'] as int,
        product: itemMap['product'] as int,
        quantity: itemMap['quantity'] as int,
        price: itemMap['price'] as double,
      )).toList();

      return Sold(
        id: soldMap['id'] as int,
        client: soldMap['client'] as int,
        paid: soldMap['paid'] as double,
        outcome: items,
        total: soldMap['total'] as double?,
      );
    }).toList());
  }

  // Получение продаж по ID клиента
  Future<List<Sold>> getSoldsByClientId(int clientId) async {
    final db = await database;

    final List<Map<String, dynamic>> soldMaps = await db.query(
      'sold',
      where: 'client = ?',
      whereArgs: [clientId],
    );

    return Future.wait(soldMaps.map((soldMap) async {
      final List<Map<String, dynamic>> itemMaps = await db.query(
        'sold_items',
        where: 'sold_id = ?',
        whereArgs: [soldMap['id']],
      );

      final items = itemMaps.map((itemMap) => SoldItem(
        id: itemMap['id'] as int,
        product: itemMap['product'] as int,
        quantity: itemMap['quantity'] as int,
        price: itemMap['price'] as double,
      )).toList();

      return Sold(
        id: soldMap['id'] as int,
        client: soldMap['client'] as int,
        paid: soldMap['paid'] as double,
        outcome: items,
        total: soldMap['total'] as double?,
      );
    }).toList());
  }

  // Удаление всех продаж
  Future<void> deleteAllSolds() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('sold_items');
      await txn.delete('sold');
    });
  }

  // Закрытие базы данных
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}