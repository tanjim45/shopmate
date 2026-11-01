import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _ordersCollection =>
      _firestore.collection('orders');

  // Save a new order to Firestore.
  Future<String> saveOrder(OrderModel order) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Please login before placing an order.');
    }

    final orderData = order.toFirestoreMap();

    // Add logged-in user's UID.
    orderData['userId'] = user.uid;

    // Save server timestamp.
    orderData['createdAt'] = FieldValue.serverTimestamp();

    print('AUTH UID: ${user.uid}');
    print('FIREBASE PROJECT: ${_firestore.app.options.projectId}');
    print('ORDER USER ID: ${orderData['userId']}');

    final docRef = await _ordersCollection.add(orderData);

    print('ORDER SAVED: ${docRef.id}');

    return docRef.id;
  }

  // Get orders belonging to the currently logged-in user.
  Future<List<OrderModel>> getMyOrders() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Please login to view your orders.');
    }

    final snapshot = await _ordersCollection
        .where('userId', isEqualTo: user.uid)
        .get();

    final orders = snapshot.docs.map((doc) {
      final data = doc.data();

      final rawItems = data['items'] as List<dynamic>? ?? [];

      final items = rawItems.map((item) {
        return OrderItem.fromMap(
          Map<String, dynamic>.from(item as Map),
        );
      }).toList();

      return OrderModel.fromMap(
        {
          ...data,
          'documentId': doc.id,
        },
        items: items,
      );
    }).toList();

    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return orders;
  }
}
