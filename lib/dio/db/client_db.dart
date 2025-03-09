import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/client.dart';

class ClientDatabase {
  static final ClientDatabase instance = ClientDatabase._init();
  static Database? _database;

  ClientDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('clients.db');
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
      CREATE TABLE clients (
        id INTEGER PRIMARY KEY,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        full_name TEXT NOT NULL,
        content TEXT NOT NULL,
        debt REAL NOT NULL
      )
    ''');
  }

  Future<void> insertClients(List<Client> clients) async {
    final db = await database;

    // Используем транзакцию для массовой вставки
    await db.transaction((txn) async {
      for (var client in clients) {
        await txn.insert(
          'clients',
          {
            'id': client.id,
            'created_at': client.created_at,
            'updated_at': client.updated_at,
            'full_name': client.full_name,
            'content': client.content,
            'debt': client.debt,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<Client>> getClients() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('clients');

    return List.generate(maps.length, (i) {
      return Client(
        id: maps[i]['id'],
        created_at: maps[i]['created_at'],
        updated_at: maps[i]['updated_at'],
        full_name: maps[i]['full_name'],
        content: maps[i]['content'],
        debt: maps[i]['debt'],
      );
    });
  }

  Future<void> deleteClient(int clientId) async {
    final db = await database;
    await db.delete(
      'clients',
      where: 'id = ?',
      whereArgs: [clientId],
    );
  }

  Future<void> deleteAllClients() async {
    final db = await database;
    await db.delete('clients');
  }

  Future<void> updateClient(
    int clientId, {
    String? fullName,
    String? content,
    double? debt,
    String? createdAt,
    String? updatedAt,
  }) async {
    final db = await database;

    // Создаём Map только с теми полями, которые не null
    Map<String, dynamic> updateData = {};

    if (fullName != null) updateData["full_name"] = fullName;
    if (content != null) updateData["content"] = content;
    if (debt != null) updateData["debt"] = debt;
    if (createdAt != null) updateData["created_at"] = createdAt;
    if (updatedAt != null) updateData["updated_at"] = updatedAt;

    await db.update(
      'clients',
      updateData,
      where: 'id = ?',
      whereArgs: [clientId],
    );
  }
}
