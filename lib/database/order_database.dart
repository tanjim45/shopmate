import 'package:shopmate/features/products/models/order_model.dart';
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

    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
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

  // Save order and its products in one transaction.
  Future<int> saveOrder(OrderModel order) async {
    final db = await database;

    return db.transaction((txn) async {
      final orderId = await txn.insert(
        'orders',
        order.toMap(),
      );

      for (final item in order.items) {
        await txn.insert(
          'order_items',
          item.toMap(orderId),
        );
      }

      return orderId;
    });
  }

  // Get all saved orders, newest first.
  Future<List<OrderModel>> getOrders() async {
    final db = await database;

    final orderMaps = await db.query(
      'orders',
      orderBy: 'createdAt DESC',
    );

    final List<OrderModel> orders = [];

    for (final orderMap in orderMaps) {
      final orderId = orderMap['id'] as int;

      final itemMaps = await db.query(
        'order_items',
        where: 'orderId = ?',
        whereArgs: [orderId],
      );

      final items = itemMaps
          .map((item) => OrderItem.fromMap(item))
          .toList();

      orders.add(
        OrderModel.fromMap(
          orderMap,
          items: items,
        ),
      );
    }

    return orders;
  }

  // Get one order using its database ID.
  Future<OrderModel?> getOrderById(int id) async {
    final db = await database;

    final orderMaps = await db.query(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (orderMaps.isEmpty) {
      return null;
    }

    final itemMaps = await db.query(
      'order_items',
      where: 'orderId = ?',
      whereArgs: [id],
    );

    final items = itemMaps
        .map((item) => OrderItem.fromMap(item))
        .toList();

    return OrderModel.fromMap(
      orderMaps.first,
      items: items,
    );
  }
}
