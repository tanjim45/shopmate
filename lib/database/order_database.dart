
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class OrderDatabase {
  OrderDatabase._privateConstructor();

  static final OrderDatabase instance =
      OrderDatabase._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'shopmate_orders.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customerName TEXT NOT NULL,
            phone TEXT NOT NULL,
            address TEXT NOT NULL,
            deliveryMethod TEXT NOT NULL,
            subtotal REAL NOT NULL,
            deliveryFee REAL NOT NULL,
            total REAL NOT NULL,
            status TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE order_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            orderId INTEGER NOT NULL,
            productId INTEGER NOT NULL,
            title TEXT NOT NULL,
            price REAL NOT NULL,
            quantity INTEGER NOT NULL,
            thumbnail TEXT,
            FOREIGN KEY (orderId) REFERENCES orders (id)
              ON DELETE CASCADE
          )
        ''');
      },
    );
  }
}
