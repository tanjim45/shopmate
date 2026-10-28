
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

const int productsBatchSize = 10;

class ProductsPaginationState {
  final List<Product> products;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;

  const ProductsPaginationState({
    this.products = const [],
    this.isLoadingMore = false,
    this.hasMore = true,
    this.errorMessage,
  });

  ProductsPaginationState copyWith({
    List<Product>? products,
    bool? isLoadingMore,
    bool? hasMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProductsPaginationState(
      products: products ?? this.products,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

final productsPaginationProvider = StateNotifierProvider<
    ProductsPaginationNotifier, ProductsPaginationState>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return ProductsPaginationNotifier(repository)..loadInitial();
});

class ProductsPaginationNotifier
    extends StateNotifier<ProductsPaginationState> {
  final ProductRepository _repository;

  ProductsPaginationNotifier(this._repository)
      : super(const ProductsPaginationState());

  Future<void> loadInitial() async {
    state = const ProductsPaginationState(isLoadingMore: true);

    try {
      final products =
          await _repository.getProductsByLimit(productsBatchSize);

      state = ProductsPaginationState(
        products: products,
        hasMore: products.length == productsBatchSize,
      );
    } catch (e) {
      state = ProductsPaginationState(
        hasMore: true,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(
      isLoadingMore: true,
      clearError: true,
    );

    try {
      final nextLimit = state.products.length + productsBatchSize;
      final allProducts = await _repository.getProductsByLimit(nextLimit);

      final existingIds = state.products.map((p) => p.id).toSet();
      final newProducts = allProducts
          .where((product) => !existingIds.contains(product.id))
          .toList();

      state = state.copyWith(
        products: [...state.products, ...newProducts],
        isLoadingMore: false,
        hasMore: allProducts.length == nextLimit &&
            newProducts.isNotEmpty,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> retry() async {
    if (state.products.isEmpty) {
      await loadInitial();
    } else {
      await loadMore();
    }
  }
}

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProducts();
});

