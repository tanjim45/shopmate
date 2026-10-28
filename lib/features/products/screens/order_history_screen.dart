import 'package:flutter/material.dart';
import 'package:shopmate/features/products/models/order_model.dart';
import 'package:shopmate/features/products/screens/order_details_screen.dart';
import '../../../database/order_database.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late Future<List<OrderModel>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    _ordersFuture = OrderDatabase.instance.getOrders();
  }

  Future<void> _refreshOrders() async {
    setState(() {
      _loadOrders();
    });

    await _ordersFuture;
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();
    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    final year = localDate.year;
    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');

    return '$day/$month/$year  $hour:$minute';
  }

  void _openOrderDetails(OrderModel order) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderDetailsScreen(order: order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh orders',
            onPressed: _refreshOrders,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<OrderModel>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 52,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Could not load orders.',
                      style: TextStyle(fontSize: 17),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _refreshOrders,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 80,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Orders Yet',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your placed orders will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Continue Shopping'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshOrders,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = orders[index];

                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.receipt_long,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: Text(
                      'Order #${order.id ?? '-'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_formatDate(order.createdAt)),
                          const SizedBox(height: 5),
                          Text(
                            '${order.items.length} product type(s) • '
                            '\$${order.total.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Details button; expansion behavior remains unchanged.
                    trailing: IconButton(
                      tooltip: 'View Order Details',
                      icon: const Icon(Icons.open_in_new),
                      onPressed: () => _openOrderDetails(order),
                    ),

                    children: [
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _detailRow('Customer', order.customerName),
                            _detailRow('Phone', order.phone),
                            _detailRow('Address', order.address),
                            _detailRow('Delivery', order.deliveryMethod),
                            _detailRow('Status', order.status),

                            const SizedBox(height: 12),

                            const Text(
                              'Products',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),

                            ...order.items.map(
                              (item) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: item.thumbnail != null &&
                                        item.thumbnail!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          item.thumbnail!,
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return const SizedBox(
                                              width: 48,
                                              height: 48,
                                              child: Icon(
                                                Icons.image_not_supported,
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : const SizedBox(
                                        width: 48,
                                        height: 48,
                                        child: Icon(
                                          Icons.shopping_bag_outlined,
                                        ),
                                      ),
                                title: Text(
                                  item.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  '\$${item.price.toStringAsFixed(2)}'
                                  ' × ${item.quantity}',
                                ),
                                trailing: Text(
                                  '\$${item.totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            const Divider(),

                            _detailRow(
                              'Subtotal',
                              '\$${order.subtotal.toStringAsFixed(2)}',
                            ),
                            _detailRow(
                              'Delivery Fee',
                              '\$${order.deliveryFee.toStringAsFixed(2)}',
                            ),
                            _detailRow(
                              'Total',
                              '\$${order.total.toStringAsFixed(2)}',
                              isBold: true,
                            ),

                            const SizedBox(height: 12),

                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: () => _openOrderDetails(order),
                                icon: const Icon(Icons.open_in_new),
                                label: const Text('View Full Details'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}