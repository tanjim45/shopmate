
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WishlistController extends Notifier<Set<int>> {
  @override
  Set<int> build() {
    return {};
  }

  void toggleWishlist(int productId) {
    if (state.contains(productId)) {
      state = {...state}..remove(productId);
    } else {
      state = {...state, productId};
    }
  }

  bool isFavorite(int productId) {
    return state.contains(productId);
  }

  void clearWishlist() {
    state = {};
  }
}

final wishlistProvider =
    NotifierProvider<WishlistController, Set<int>>(
  WishlistController.new,
);
