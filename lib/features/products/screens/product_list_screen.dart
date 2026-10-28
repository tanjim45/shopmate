
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopmate/features/products/providers/cart_provider.dart';
import 'package:shopmate/features/products/screens/cart_screen.dart';
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
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController =TextEditingController();
  final TextEditingController _maxPriceController =TextEditingController();

  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedSort = 'Default';
  String? _priceFilterError;

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final cartItems = ref.watch(cartProvider);

    final cartCount = cartItems.fold<int>(
      0,
      (total, item) => total + item.quantity,
    );
    final wishlistCount = ref.watch(wishlistProvider).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ShopMate',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
        
          IconButton(
            tooltip: 'My Wishlist',
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
              tooltip: 'My Cart',
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
      body: productsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Products load kora jayni!',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    ref.invalidate(productsProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
        data: (products) {
          final categories = [
            'All',
            ...products.map((product) => product.category).toSet(),
          ];

          var filteredProducts = products.where((product) {
            final matchesSearch = product.title
                .toLowerCase()
                .contains(_searchQuery);

            final matchesCategory = _selectedCategory == 'All' ||
                product.category == _selectedCategory;

            return matchesSearch && matchesCategory;
          }).toList();

          final minPrice =
              double.tryParse(_minPriceController.text.trim());
          final maxPrice =
              double.tryParse(_maxPriceController.text.trim());

          // Apply price filtering only when the entered values are valid.
          // Keep the previous search and category filtering intact.
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

        

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim().toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search products...',
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              const Icon(Icons.sort),
                              const SizedBox(width: 8),
                              const Text('Sort by:'),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: _selectedSort,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Default',
                                      child: Text('Default'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Price: Low to High',
                                      child: Text('Price: Low to High'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Price: High to Low',
                                      child: Text('Price: High to Low'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Rating: Highest First',
                                      child: Text('Rating: Highest First'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Name: A to Z',
                                      child: Text('Name: A to Z'),
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
                        Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _minPriceController,
                                          keyboardType: const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                          decoration: const InputDecoration(
                                            labelText: 'Min Price',
                                            prefixText: '\$ ',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          controller: _maxPriceController,
                                          keyboardType: const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                          decoration: const InputDecoration(
                                            labelText: 'Max Price',
                                            prefixText: '\$ ',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton.filled(
                                        tooltip: 'Apply Price Filter',
                                        onPressed: () {
                                          final minText =
                                              _minPriceController.text.trim();
                                          final maxText =
                                              _maxPriceController.text.trim();
                                          final minPrice =
                                              double.tryParse(minText);
                                          final maxPrice =
                                              double.tryParse(maxText);

                                          String? error;

                                          if (minText.isNotEmpty &&
                                              (minPrice == null || minPrice < 0)) {
                                            error =
                                                'Enter a valid minimum price.';
                                          } else if (maxText.isNotEmpty &&
                                              (maxPrice == null || maxPrice < 0)) {
                                            error =
                                                'Enter a valid maximum price.';
                                          } else if (minPrice != null &&
                                              maxPrice != null &&
                                              minPrice > maxPrice) {
                                            error =
                                                'Minimum price cannot exceed maximum price.';
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
                                            child: const Text('Reset'),
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
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 12),

              SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category == _selectedCategory;

                    return ChoiceChip(
                      label: Text(
                        category == 'All'
                            ? 'All'
                            : category[0].toUpperCase() +
                                category.substring(1),
                      ),
                      selected: isSelected,
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
              Expanded(
                child: filteredProducts.isEmpty
                    ? const Center(
                        child: Text('No products found'),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(productsProvider);
                          await ref.read(productsProvider.future);
                        },
                        child: GridView.builder(
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
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            return ProductCard(
                              product: filteredProducts[index],
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
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
                              ? 'Remove from Wishlist'
                              : 'Add to Wishlist',
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            ref
                                .read(wishlistProvider.notifier)
                                .toggleWishlist(product.id);

                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  duration: const Duration(
                                    seconds: 1,
                                  ),
                                  content: Text(
                                    isFavorite
                                        ? 'Removed from Wishlist'
                                        : 'Added to Wishlist',
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
