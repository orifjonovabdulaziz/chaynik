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
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE incomes (
        id INTEGER PRIMARY KEY,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        product INTEGER NOT NULL,
        price_sum TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
  }

  // Получить все приходы
  Future<List<Income>> getIncomes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('incomes');
    return List.generate(maps.length, (i) => Income.fromJson(maps[i]));
  }

  // Получить приход по ID
  Future<Income?> getIncomeById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'incomes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Income.fromJson(maps.first);
    }
    return null;
  }

  // Добавить список приходов
  Future<void> insertIncomes(List<Income> incomes) async {
    final db = await database;

    await db.transaction((txn) async {
      for (var income in incomes) {
        await txn.insert(
          'incomes',
          {
            'id': income.id,
            'quantity': income.quantity,
            'price': income.price,
            'product': income.product,
            'price_sum': income.priceSum,
            'created_at': income.createdAt,
            'updated_at': income.updatedAt,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  // Обновить приход
  Future<void> updateIncome(Income income) async {
    final db = await database;

    await db.update(
      'incomes',
      {
        'quantity': income.quantity,
        'price': income.price,
        'product': income.product,
        'price_sum': income.priceSum,
        'created_at': income.createdAt,
        'updated_at': income.updatedAt,
      },
      where: 'id = ?',
      whereArgs: [income.id],
    );
  }

  // Удалить приход
  Future<void> deleteIncome(int id) async {
    final db = await database;
    await db.delete(
      'incomes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Удалить все приходы
  Future<void> deleteAllIncomes() async {
    final db = await database;
    await db.delete('incomes');
  }

  // Получить приходы по ID продукта
  Future<List<Income>> getIncomesByProductId(int productId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'incomes',
      where: 'product = ?',
      whereArgs: [productId],
    );
    return List.generate(maps.length, (i) => Income.fromJson(maps[i]));
  }

  // Закрыть базу данных
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}