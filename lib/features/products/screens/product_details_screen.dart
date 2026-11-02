
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopmate/features/products/screens/cart_screen.dart';
import 'package:shopmate/l10n/app_localizations.dart';

import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';

class ProductDetailsScreen extends ConsumerWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final wishlistIds = ref.watch(wishlistProvider);
    final isWishlisted = wishlistIds.contains(product.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.productDetails),
        actions: [
          IconButton(
            tooltip: isWishlisted
                ? l10n.removeFromWishlist
                : l10n.addToWishlist,
            onPressed: () {
              ref
                  .read(wishlistProvider.notifier)
                  .toggleWishlist(product.id);

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      isWishlisted
                          ? l10n.removedFromWishlist
                          : l10n.addedToWishlist,
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
            },
            icon: Icon(
              isWishlisted
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: isWishlisted
                  ? Colors.red
                  : theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isWideScreen = screenWidth >= 700;

          final content = isWideScreen
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: _buildProductImage(
                        theme,
                        height: 420,
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      flex: 5,
                      child: _buildProductInformation(
                        context,
                        ref,
                        theme,
                        l10n,
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductImage(
                      theme,
                      height: screenWidth < 400 ? 250 : 300,
                    ),
                    const SizedBox(height: 24),
                    _buildProductInformation(
                      context,
                      ref,
                      theme,
                      l10n,
                    ),
                  ],
                );

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth >= 1000
                  ? 40
                  : screenWidth >= 600
                      ? 28
                      : 20,
              vertical: 16,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1100,
                ),
                child: content,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductImage(
    ThemeData theme, {
    required double height,
  }) {
    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Hero(
        tag: 'product_${product.id}',
        child: Image.network(
          product.image,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.image_not_supported_outlined,
              size: 70,
              color: Colors.grey,
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductInformation(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            product.category,
            style: TextStyle(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Title
        Text(
          product.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),

        const SizedBox(height: 16),

        // Rating
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            const Icon(
              Icons.star_rounded,
              color: Colors.amber,
              size: 25,
            ),
            Text(
              '${product.rating.toStringAsFixed(1)} / 5',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '(${product.ratingCount} ${l10n.ratings})',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Price
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer
                .withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.price,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // Description
        Text(
          l10n.productDescription,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          product.description,
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.7,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 32),

        // Add to cart
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              ref.read(cartProvider.notifier).addToCart(product);

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(l10n.productAddedToCart),
                    action: SnackBarAction(
                      label: l10n.viewCart,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CartScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                );
            },
            icon: const Icon(Icons.shopping_cart_outlined),
            label: Text(l10n.addToCart),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 17),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
