
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../providers/wishlist_provider.dart';
import 'product_details_screen.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(wishlistProvider);
    final productsAsync = ref.watch(productsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Wishlist',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (favoriteIds.isNotEmpty)
            IconButton(
              tooltip: 'Clear Wishlist',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Clear Wishlist?'),
                    content: const Text(
                      'Remove all products from your Wishlist?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () {
                          ref
                              .read(wishlistProvider.notifier)
                              .clearWishlist();
                          Navigator.pop(dialogContext);
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: productsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Products load kora jayni!'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  ref.invalidate(productsProvider);
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
        data: (products) {
          final favoriteProducts = products
              .where((product) => favoriteIds.contains(product.id))
              .toList();

          if (favoriteProducts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 80,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your Wishlist is empty',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap the heart on a product to save it here.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: const Text('Explore Products'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: favoriteProducts.length,
            separatorBuilder: (_, index) =>
                const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = favoriteProducts[index];

              return _WishlistProductCard(
                product: product,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsScreen(
                        product: product,
                      ),
                    ),
                  );
                },
                onRemove: () {
                  ref
                      .read(wishlistProvider.notifier)
                      .toggleWishlist(product.id);

                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Removed from Wishlist'),
                      ),
                    );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _WishlistProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _WishlistProductCard({
    required this.product,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 85,
                height: 100,
                child: Image.network(
                  product.image,
                  fit: BoxFit.contain,
                  errorBuilder: (_, error, stackTrace) {
                    return const Icon(
                      Icons.image_not_supported_outlined,
                    );
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.category.toUpperCase(),
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${product.rating.toStringAsFixed(1)} (${product.ratingCount})',
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Remove from Wishlist',
                onPressed: onRemove,
                icon: const Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
