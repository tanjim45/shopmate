
class OrderItem {
  final int productId;
  final String title;
  final double price;
  final int quantity;
  final String? thumbnail;

  const OrderItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.quantity,
    this.thumbnail,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toMap(int orderId) {
    return {
      'orderId': orderId,
      'productId': productId,
      'title': title,
      'price': price,
      'quantity': quantity,
      'thumbnail': thumbnail,
    };
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'productId': productId,
      'title': title,
      'price': price,
      'quantity': quantity,
      'thumbnail': thumbnail,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: (map['productId'] as num).toInt(),
      title: map['title'] as String,
      price: (map['price'] as num).toDouble(),
      quantity: (map['quantity'] as num).toInt(),
      thumbnail: map['thumbnail'] as String?,
    );
  }
}

class OrderModel {
  // Hive-এর পুরোনো integer ID অপরিবর্তিত থাকবে।
  final int? id;

  // Firestore-এর document ID এবং Firebase user ID।
  final String? documentId;
  final String? userId;

  final String customerName;
  final String phone;
  final String address;
  final String deliveryMethod;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String status;
  final DateTime createdAt;
  final List<OrderItem> items;

  const OrderModel({
    this.id,
    this.documentId,
    this.userId,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.deliveryMethod,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.items,
  });

  // Existing Hive database-এর জন্য।
  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'phone': phone,
      'address': address,
      'deliveryMethod': deliveryMethod,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Firestore-এ save করার জন্য।
  Map<String, dynamic> toFirestoreMap() {
    return {
      'userId': userId,
      'customerName': customerName,
      'phone': phone,
      'address': address,
      'deliveryMethod': deliveryMethod,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'items': items.map((item) => item.toFirestoreMap()).toList(),
    };
  }

  factory OrderModel.fromMap(
    Map<String, dynamic> map, {
    List<OrderItem> items = const [],
  }) {
    final rawDate = map['createdAt'];

    DateTime parsedDate;
    if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else if (rawDate is String) {
      parsedDate = DateTime.parse(rawDate);
    } else {
      // Firestore Timestamp support.
      parsedDate = rawDate.toDate() as DateTime;
    }

    return OrderModel(
      id: (map['id'] as num?)?.toInt(),
      documentId: map['documentId'] as String?,
      userId: map['userId'] as String?,
      customerName: map['customerName'] as String,
      phone: map['phone'] as String,
      address: map['address'] as String,
      deliveryMethod: map['deliveryMethod'] as String,
      subtotal: (map['subtotal'] as num).toDouble(),
      deliveryFee: (map['deliveryFee'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
      status: map['status'] as String,
      createdAt: parsedDate,
      items: items,
    );
  }
}
