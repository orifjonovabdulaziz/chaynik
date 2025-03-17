import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/income.dart';

class IncomeDatabase {
  static final IncomeDatabase instance = IncomeDatabase._init();
  static Database? _database;

  IncomeDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('income.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Увеличена версия базы данных
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  // Обработчик обновления базы данных
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Создаем временную таблицу с новой схемой
      await db.execute('''
        CREATE TABLE income_items_temp (
          id INTEGER PRIMARY KEY,
          income_id INTEGER NOT NULL,
          product INTEGER NULL,
          quantity INTEGER NOT NULL,
          price TEXT NOT NULL,
          price_sum TEXT,
          FOREIGN KEY (income_id) REFERENCES incomes (id) ON DELETE CASCADE
        )
      ''');

      // Копируем данные
      await db.execute('''
        INSERT INTO income_items_temp 
        SELECT * FROM income_items
      ''');

      // Удаляем старую таблицу
      await db.execute('DROP TABLE income_items');

      // Переименовываем временную таблицу
      await db.execute('ALTER TABLE income_items_temp RENAME TO income_items');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // Создаем таблицу для приходов
    await db.execute('''
      CREATE TABLE incomes (
        id INTEGER PRIMARY KEY,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Создаем таблицу для элементов прихода с NULL для product
    await db.execute('''
      CREATE TABLE income_items (
        id INTEGER PRIMARY KEY,
        income_id INTEGER NOT NULL,
        product INTEGER NULL,
        quantity INTEGER NOT NULL,
        price TEXT NOT NULL,
        price_sum TEXT,
        FOREIGN KEY (income_id) REFERENCES incomes (id) ON DELETE CASCADE
      )
    ''');
  }

  // Получить все приходы с их элементами
  Future<List<Income>> getIncomes() async {
    final db = await database;
    final List<Map<String, dynamic>> incomeMaps = await db.query('incomes');

    List<Income> incomes = [];
    for (var incomeMap in incomeMaps) {
      final List<Map<String, dynamic>> itemMaps = await db.query(
        'income_items',
        where: 'income_id = ?',
        whereArgs: [incomeMap['id']],
      );

      final items = itemMaps.map((item) => IncomeItem(
        id: item['id'],
        product: item['product'], // Теперь может быть null
        quantity: item['quantity'],
        price: item['price'],
        priceSum: item['price_sum'],
      )).toList();

      incomes.add(Income(
        id: incomeMap['id'],
        items: items,
        createdAt: incomeMap['created_at'],
        updatedAt: incomeMap['updated_at'],
      ));
    }
    return incomes;
  }

  // Получить приход по ID
  Future<Income?> getIncomeById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> incomeMaps = await db.query(
      'incomes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (incomeMaps.isEmpty) return null;

    final List<Map<String, dynamic>> itemMaps = await db.query(
      'income_items',
      where: 'income_id = ?',
      whereArgs: [id],
    );

    final items = itemMaps.map((item) => IncomeItem(
      id: item['id'],
      product: item['product'], // Теперь может быть null
      quantity: item['quantity'],
      price: item['price'],
      priceSum: item['price_sum'],
    )).toList();

    return Income(
      id: incomeMaps.first['id'],
      items: items,
      createdAt: incomeMaps.first['created_at'],
      updatedAt: incomeMaps.first['updated_at'],
    );
  }

  // Добавить список приходов
  Future<void> insertIncomes(List<Income> incomes) async {
    final db = await database;

    await db.transaction((txn) async {
      for (var income in incomes) {
        final incomeId = await txn.insert(
          'incomes',
          {
            if (income.id != null) 'id': income.id,
            'created_at': income.createdAt,
            'updated_at': income.updatedAt,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        for (var item in income.items) {
          await txn.insert(
            'income_items',
            {
              if (item.id != null) 'id': item.id,
              'income_id': income.id ?? incomeId,
              'product': item.product, // Может быть null
              'quantity': item.quantity,
              'price': item.price,
              'price_sum': item.priceSum,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
  }

  // Остальные методы остаются без изменений...
  Future<void> deleteIncome(int id) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        'income_items',
        where: 'income_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        'incomes',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  Future<void> deleteAllIncomes() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('income_items');
      await txn.delete('incomes');
    });
  }

  Future<List<Income>> getIncomesByProductId(int productId) async {
    final db = await database;
    final List<Map<String, dynamic>> itemMaps = await db.query(
      'income_items',
      where: 'product = ?',
      whereArgs: [productId],
    );

    Set<int> incomeIds = itemMaps.map((item) => item['income_id'] as int).toSet();
    List<Income> incomes = [];

    for (var incomeId in incomeIds) {
      final income = await getIncomeById(incomeId);
      if (income != null) {
        incomes.add(income);
      }
    }

    return incomes;
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}