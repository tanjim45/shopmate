import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:shopmate/features/products/models/order_model.dart';

class OrderDatabase {
  OrderDatabase._privateConstructor();

  static final OrderDatabase instance =
      OrderDatabase._privateConstructor();

  static const String _boxName = 'shopmate_orders';

  Future<Box<Map>> get database async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<Map>(_boxName);
    }

    return Hive.openBox<Map>(_boxName);
  }

  // Save an order and its products.
  Future<int> saveOrder(OrderModel order) async {
    final box = await database;

    final orderId = await box.add({
      'customerName': order.customerName,
      'phone': order.phone,
      'address': order.address,
      'deliveryMethod': order.deliveryMethod,
      'subtotal': order.subtotal,
      'deliveryFee': order.deliveryFee,
      'total': order.total,
      'status': order.status,
      'createdAt': order.createdAt.toIso8601String(),
      'items': order.items.map((item) {
        return {
          'productId': item.productId,
          'title': item.title,
          'price': item.price,
          'quantity': item.quantity,
          'thumbnail': item.thumbnail,
        };
      }).toList(),
    });

    return orderId;
  }

  // Convert a stored Hive record into an OrderModel.
  OrderModel _orderFromMap(int id, Map<dynamic, dynamic> data) {
    final rawItems = data['items'] as List<dynamic>? ?? [];

    final items = rawItems.map((rawItem) {
      final item = Map<String, dynamic>.from(
        rawItem as Map,
      );

      return OrderItem.fromMap(item);
    }).toList();

    return OrderModel.fromMap(
      Map<String, dynamic>.from(data)..['id'] = id,
      items: items,
    );
  }

  // Get all orders, newest first.
  Future<List<OrderModel>> getOrders() async {
    final box = await database;
    final orders = <OrderModel>[];

    for (final key in box.keys) {
      final data = box.get(key);

      if (key is int && data != null) {
        orders.add(_orderFromMap(key, data));
      }
    }

    orders.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    return orders;
  }

  // Get one order by ID.
  Future<OrderModel?> getOrderById(int id) async {
    final box = await database;
    final data = box.get(id);

    if (data == null) {
      return null;
    }

    return _orderFromMap(id, data);
  }

  // Update an order's status.
  Future<int> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    final box = await database;
    final data = box.get(orderId);

    if (data == null) {
      return 0;
    }

    final updatedData = Map<String, dynamic>.from(data);
    updatedData['status'] = status;

    await box.put(orderId, updatedData);

    return 1;
  }

  // Cancel an order.
  Future<int> cancelOrder(int orderId) async {
    return updateOrderStatus(
      orderId: orderId,
      status: 'Cancelled',
    );
  }
}




