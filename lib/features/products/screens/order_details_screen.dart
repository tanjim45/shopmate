import 'package:flutter/material.dart';
import 'package:shopmate/features/products/models/order_model.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();

    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    final year = localDate.year;
    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');

    return '$day/$month/$year  $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.id ?? '-'}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Order Status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    size: 36,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Status',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          order.status,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Order Information
          _sectionCard(
            context,
            title: 'Order Information',
            icon: Icons.receipt_long_outlined,
            children: [
              _detailRow(context, 'Order ID', '#${order.id ?? '-'}'),
              _detailRow(
                context,
                'Order Date',
                _formatDate(order.createdAt),
              ),
              _detailRow(
                context,
                'Delivery Method',
                order.deliveryMethod,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Customer Information
          _sectionCard(
            context,
            title: 'Customer Information',
            icon: Icons.person_outline,
            children: [
              _detailRow(context, 'Name', order.customerName),
              _detailRow(context, 'Phone', order.phone),
              _detailRow(context, 'Address', order.address),
            ],
          ),

          const SizedBox(height: 16),

          // Ordered Products
          _sectionCard(
            context,
            title: 'Ordered Products (${order.items.length})',
            icon: Icons.shopping_bag_outlined,
            children: [
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: item.thumbnail != null &&
                                item.thumbnail!.isNotEmpty
                            ? Image.network(
                                item.thumbnail!,
                                width: 65,
                                height: 65,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return _imagePlaceholder(context);
                                },
                              )
                            : _imagePlaceholder(context),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '\$${item.price.toStringAsFixed(2)} × ${item.quantity}',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${item.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Payment Summary
          _sectionCard(
            context,
            title: 'Payment Summary',
            icon: Icons.payments_outlined,
            children: [
              _detailRow(
                context,
                'Subtotal',
                '\$${order.subtotal.toStringAsFixed(2)}',
              ),
              _detailRow(
                context,
                'Delivery Fee',
                '\$${order.deliveryFee.toStringAsFixed(2)}',
              ),
              const Divider(height: 24),
              _detailRow(
                context,
                'Total Amount',
                '\$${order.total.toStringAsFixed(2)}',
                isBold: true,
              ),
            ],
          ),

          const SizedBox(height: 20),

          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to My Orders'),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: isBold ? theme.colorScheme.primary : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder(BuildContext context) {
    return Container(
      width: 65,
      height: 65,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.image_not_supported_outlined),
    );
  }
}