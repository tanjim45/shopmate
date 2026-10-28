
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

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] as int,
      title: map['title'] as String,
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] as int,
      thumbnail: map['thumbnail'] as String?,
    );
  }
}

class OrderModel {
  final int? id;
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

  factory OrderModel.fromMap(
    Map<String, dynamic> map, {
    List<OrderItem> items = const [],
  }) {
    return OrderModel(
      id: map['id'] as int?,
      customerName: map['customerName'] as String,
      phone: map['phone'] as String,
      address: map['address'] as String,
      deliveryMethod: map['deliveryMethod'] as String,
      subtotal: (map['subtotal'] as num).toDouble(),
      deliveryFee: (map['deliveryFee'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
      status: map['status'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      items: items,
    );
  }
}
