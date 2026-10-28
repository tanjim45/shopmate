
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_model.dart';

class CartItem {
  final Product product;
  final int quantity;

  const CartItem({
    required this.product,
    required this.quantity,
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartController extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() {
    return [];
  }

  void addToCart(Product product) {
    final index = state.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (index == -1) {
      state = [
        ...state,
        CartItem(product: product, quantity: 1),
      ];
    } else {
      final updatedCart = [...state];

      updatedCart[index] = updatedCart[index].copyWith(
        quantity: updatedCart[index].quantity + 1,
      );

      state = updatedCart;
    }
  }

  void increaseQuantity(int productId) {
    state = [
      for (final item in state)
        if (item.product.id == productId)
          item.copyWith(quantity: item.quantity + 1)
        else
          item,
    ];
  }

  void decreaseQuantity(int productId) {
    state = [
      for (final item in state)
        if (item.product.id == productId && item.quantity > 1)
          item.copyWith(quantity: item.quantity - 1)
        else
          item,
    ];
  }

  void removeFromCart(int productId) {
    state = state
        .where((item) => item.product.id != productId)
        .toList();
  }

  void clearCart() {
    state = [];
  }

  int get totalQuantity {
    return state.fold(
      0,
      (total, item) => total + item.quantity,
    );
  }

  double get totalPrice {
    return state.fold(
      0.0,
      (total, item) => total + item.product.price * item.quantity,
    );
  }
}

final cartProvider =
    NotifierProvider<CartController, List<CartItem>>(
  CartController.new,
);
