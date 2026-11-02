import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopmate/l10n/app_localizations.dart';
import 'package:shopmate/features/products/screens/profile_screen.dart';
import 'package:shopmate/features/products/providers/cart_provider.dart';
import 'package:shopmate/features/products/screens/cart_screen.dart';
import 'package:shopmate/features/products/screens/order_history_screen.dart';
import 'package:shopmate/features/products/screens/wishlist_screen.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../providers/wishlist_provider.dart';
import 'product_details_screen.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() =>
      _ProductListScreenState();
}

class _ProductListScreenState
    extends ConsumerState<ProductListScreen> {
  final TextEditingController _searchController =
      TextEditingController();
  final TextEditingController _minPriceController =
      TextEditingController();
  final TextEditingController _maxPriceController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedSort = 'Default';
  String? _priceFilterError;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.extentAfter < 300) {
      ref.read(productsPaginationProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final paginationState = ref.watch(productsPaginationProvider);
    final cartItems = ref.watch(cartProvider);
    final wishlistIds = ref.watch(wishlistProvider);

    final cartCount = cartItems.fold<int>(
      0,
      (total, item) => total + item.quantity,
    );
    final wishlistCount = wishlistIds.length;

    final products = paginationState.products;

    final categories = <String>[
      'All',
      ...products.map((product) => product.category).toSet(),
    ];

    var filteredProducts = products.where((product) {
      final matchesSearch =
          product.title.toLowerCase().contains(_searchQuery);

      final matchesCategory = _selectedCategory == 'All' ||
          product.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    final minPrice =
        double.tryParse(_minPriceController.text.trim());
    final maxPrice =
        double.tryParse(_maxPriceController.text.trim());

    if (_priceFilterError == null) {
      filteredProducts = filteredProducts.where((product) {
        final matchesMinPrice =
            minPrice == null || product.price >= minPrice;
        final matchesMaxPrice =
            maxPrice == null || product.price <= maxPrice;

        return matchesMinPrice && matchesMaxPrice;
      }).toList();
    }

    switch (_selectedSort) {
      case 'Price: Low to High':
        filteredProducts.sort(
          (a, b) => a.price.compareTo(b.price),
        );
        break;

      case 'Price: High to Low':
        filteredProducts.sort(
          (a, b) => b.price.compareTo(a.price),
        );
        break;

      case 'Rating: Highest First':
        filteredProducts.sort(
          (a, b) => b.rating.compareTo(a.rating),
        );
        break;

      case 'Name: A to Z':
        filteredProducts.sort(
          (a, b) => a.title.toLowerCase().compareTo(
                b.title.toLowerCase(),
              ),
        );
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ShopMate',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
           IconButton(
            tooltip: l10n.myProfile,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
            icon: const Icon(Icons.account_circle_outlined),
          ),
  
          IconButton(
            tooltip: l10n.myOrders,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const OrderHistoryScreen(),
                ),
              );
            },
            icon: const Icon(Icons.receipt_long_outlined),
          ),


          IconButton(
            tooltip: l10n.myWishlist,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const WishlistScreen(),
                ),
              );
            },
            icon: Badge(
              isLabelVisible: wishlistCount > 0,
              label: Text('$wishlistCount'),
              child: const Icon(Icons.favorite_border),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: l10n.myCart,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CartScreen(),
                  ),
                );
              },
              icon: Badge(
                isLabelVisible: cartCount > 0,
                label: Text('$cartCount'),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
            ),
          ),
        ],
      ),
      body: products.isEmpty && paginationState.isLoadingMore
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : products.isEmpty && paginationState.errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.cloud_off_outlined,
                          size: 56,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                       Text(
                              l10n.loadProductsError,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.checkInternet,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () {
                            ref
                                .read(productsPaginationProvider.notifier)
                                .retry();
                          },
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.tryAgain),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        8,
                        16,
                        12,
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery =
                                value.trim().toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: l10n.searchProducts,
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                  icon: const Icon(Icons.close),
                                )
                              : null,
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    // Sorting
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.sort),
                          const SizedBox(width: 8),
                          Text(l10n.sortBy),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedSort,
                              isExpanded: true,
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 'Default',
                                  child: Text(l10n.defaultSort),
                                ),
                                DropdownMenuItem(
                                  value: 'Price: Low to High',
                                  child: Text(l10n.priceLowHigh),
                                ),
                                DropdownMenuItem(
                                  value: 'Price: High to Low',
                                  child: Text(l10n.priceHighLow),
                                ),
                                DropdownMenuItem(
                                  value: 'Rating: Highest First',
                                  child: Text(l10n.ratingHighest),
                                ),
                                DropdownMenuItem(
                                  value: 'Name: A to Z',
                                  child: Text(l10n.nameAZ),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  _selectedSort = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Price filter
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _minPriceController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: InputDecoration(
                                labelText: l10n.minPrice,
                                prefixText: '\$ ',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _maxPriceController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: InputDecoration(
                                labelText: l10n.maxPrice,
                                prefixText: '\$ ',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            tooltip: l10n.applyPriceFilter,
                            onPressed: () {
                              final minText =
                                  _minPriceController.text.trim();
                              final maxText =
                                  _maxPriceController.text.trim();

                              final min =
                                  double.tryParse(minText);
                              final max =
                                  double.tryParse(maxText);

                              String? error;

                              if (minText.isNotEmpty &&
                                  (min == null || min < 0)) {
                                error = l10n.validMinPrice;
                              } else if (maxText.isNotEmpty &&
                                  (max == null || max < 0)) {
                                error = l10n.validMaxPrice;
                              } else if (min != null &&
                                  max != null &&
                                  min > max) {
                                error = l10n.minPriceExceedsMax;
                              }

                              setState(() {
                                _priceFilterError = error;
                              });
                            },
                            icon: const Icon(Icons.filter_alt),
                          ),
                          TextButton(
                            onPressed: () {
                              _minPriceController.clear();
                              _maxPriceController.clear();

                              setState(() {
                                _priceFilterError = null;
                              });
                            },
                            child: Text(l10n.reset),
                          ),
                        ],
                      ),
                    ),

                    if (_priceFilterError != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _priceFilterError!,
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.error,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Category filter
                    SizedBox(
                      height: 48,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final category = categories[index];

                          return ChoiceChip(
                            label: Text(
                              category == 'All'
                                  ? l10n.allCategories
                                  : '${category[0].toUpperCase()}${category.substring(1)}',
                            ),
                            selected:
                                category == _selectedCategory,
                            onSelected: (_) {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Infinite scroll product grid
                  Expanded(
                    child: filteredProducts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 70,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  products.isEmpty
                                      ? l10n.noProductsAvailable
                                      : l10n.noProductsFound,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  products.isEmpty
                                      ? l10n.tryAgainLater
                                      : l10n.changeSearchFilters,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium,
                                ),
                                if (products.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: Text(l10n.clearSearch),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              await ref
                                  .read(productsPaginationProvider.notifier)
                                  .loadInitial();
                            },
                              child: GridView.builder(
                                controller: _scrollController,
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 240,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  mainAxisExtent: 315,
                                ),
                                itemCount: filteredProducts.length +
                                    ((paginationState.hasMore ||
                                            paginationState.isLoadingMore ||
                                            paginationState.errorMessage !=
                                                null)
                                        ? 1
                                        : 0),
                                itemBuilder: (context, index) {
                                  if (index >=
                                      filteredProducts.length) {
                                    if (paginationState.errorMessage !=
                                        null) {
                                      return Center(
                                        child: Column(
                                          mainAxisSize:
                                              MainAxisSize.min,
                                          children: [
                                            Text(
                                              l10n.loadMoreError,
                                              textAlign: TextAlign.center,
                                            ),
                                            TextButton.icon(
                                              onPressed: () {
                                                ref
                                                    .read(
                                                      productsPaginationProvider
                                                          .notifier,
                                                    )
                                                    .retry();
                                              },
                                              icon: const Icon(
                                                Icons.refresh,
                                              ),
                                              label: Text(l10n.retry),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    if (paginationState.isLoadingMore) {
                                      return const Center(
                                        child:
                                            CircularProgressIndicator(),
                                      );
                                    }

                                    return const SizedBox.shrink();
                                  }

                                  return ProductCard(
                                    product:
                                        filteredProducts[index],
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }
}

class ProductCard extends ConsumerWidget {
  final Product product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final isFavorite = ref.watch(
      wishlistProvider.select(
        (favoriteIds) => favoriteIds.contains(product.id),
      ),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(
                product: product,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Center(
                      child: Image.network(
                        product.image,
                        fit: BoxFit.contain,
                        errorBuilder: (_, error, stackTrace) {
                          return const Icon(
                            Icons.image_not_supported_outlined,
                            size: 48,
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Material(
                        color: theme.colorScheme.surface.withValues(
                          alpha: 0.9,
                        ),
                        shape: const CircleBorder(),
                        child: IconButton(
                          tooltip: isFavorite
                              ? l10n.removeFromWishlist
                              : l10n.addToWishlist,
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            ref
                                .read(wishlistProvider.notifier)
                                .toggleWishlist(product.id);

                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  duration:
                                      const Duration(seconds: 1),
                                  content: Text(
                                    isFavorite
                                        ? l10n.removedFromWishlist
                                        : l10n.addedToWishlist,
                                  ),
                                ),
                              );
                          },
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isFavorite
                                ? Colors.red
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.category.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                product.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Colors.amber,
                    size: 19,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    product.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '(${product.ratingCount})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
