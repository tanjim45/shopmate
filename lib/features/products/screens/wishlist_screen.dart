
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopmate/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.myWishlist,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (favoriteIds.isNotEmpty)
            IconButton(
              tooltip: l10n.clearWishlist,
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Text(l10n.clearWishlistQuestion),
                    content: Text(l10n.removeAllWishlistProducts),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        child: Text(l10n.cancel),
                      ),
                      FilledButton(
                        onPressed: () {
                          ref
                              .read(wishlistProvider.notifier)
                              .clearWishlist();
                          Navigator.pop(dialogContext);
                        },
                        child: Text(l10n.clear),
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
              Text(l10n.productsLoadFailed),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  ref.invalidate(productsProvider);
                },
                child: Text(l10n.tryAgain),
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
                    Text(
                      l10n.yourWishlistEmpty,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.tapHeartToSave,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: Text(l10n.exploreProducts),
                    ),
                  ],
                ),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1200,
                  ),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: favoriteProducts.length,
                    gridDelegate:
                        SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: screenWidth >= 900
                          ? 560
                          : 600,
                      mainAxisExtent: 150,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) {
                      final product = favoriteProducts[index];

                      return _WishlistProductCard(
                        product: product,
                        removeTooltip: l10n.removeFromWishlist,
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
                              SnackBar(
                                content: Text(
                                  l10n.removedFromWishlist,
                                ),
                              ),
                            );
                        },
                      );
                    },
                  ),
                ),
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
  final String removeTooltip;

  const _WishlistProductCard({
    required this.product,
    required this.onTap,
    required this.onRemove,
    required this.removeTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              SizedBox(
                width: 75,
                height: 110,
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.category.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 17,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${product.rating.toStringAsFixed(1)} (${product.ratingCount})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: removeTooltip,
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
