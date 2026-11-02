
import 'package:flutter/material.dart';
import 'package:shopmate/l10n/app_localizations.dart';
import 'package:shopmate/features/products/models/order_model.dart';
import 'package:shopmate/features/products/screens/order_details_screen.dart';
import 'package:shopmate/features/products/services/order_service.dart';

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
    _ordersFuture = OrderService().getMyOrders();
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

  String _localizedDeliveryMethod(
    String method,
    AppLocalizations l10n,
  ) {
    if (method == 'Standard Delivery') {
      return l10n.standardDelivery;
    }

    if (method == 'Express Delivery') {
      return l10n.expressDelivery;
    }

    return method;
  }

  String _localizedStatus(String status, AppLocalizations l10n) {
    if (status == 'Placed') {
      return l10n.placed;
    }

    return status;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.myOrders,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: l10n.refreshOrders,
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
                    Text(
                      l10n.couldNotLoadOrders,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 17),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _refreshOrders,
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.tryAgain),
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
                    Text(
                      l10n.noOrdersYet,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.placedOrdersAppear,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.continueShopping),
                    ),
                  ],
                ),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 900;

              return RefreshIndicator(
                onRefresh: _refreshOrders,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 1100,
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.all(
                        isDesktop ? 28 : 16,
                      ),
                      itemCount: orders.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final order = orders[index];

                        return _buildOrderCard(
                          order,
                          theme,
                          l10n,
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(
    OrderModel order,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        childrenPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.receipt_long,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          '${l10n.orderNumber} #${order.id ?? '-'}',
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
                '${order.items.length} ${l10n.productTypes} • '
                '\$${order.total.toStringAsFixed(2)}',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        trailing: IconButton(
          tooltip: l10n.viewOrderDetails,
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
                _detailRow(
                  l10n.customer,
                  order.customerName,
                ),
                _detailRow(
                  l10n.phone,
                  order.phone,
                ),
                _detailRow(
                  l10n.address,
                  order.address,
                ),
                _detailRow(
                  l10n.delivery,
                  _localizedDeliveryMethod(
                    order.deliveryMethod,
                    l10n,
                  ),
                ),
                _detailRow(
                  l10n.status,
                  _localizedStatus(order.status, l10n),
                ),

                const SizedBox(height: 16),

                Text(
                  l10n.products,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        if (item.thumbnail != null &&
                            item.thumbnail!.isNotEmpty)
                          ClipRRect(
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
                        else
                          const SizedBox(
                            width: 48,
                            height: 48,
                            child: Icon(
                              Icons.shopping_bag_outlined,
                            ),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${item.price.toStringAsFixed(2)}'
                                ' × ${item.quantity}',
                                style: TextStyle(
                                  color: theme
                                      .colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${item.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Divider(height: 28),

                _detailRow(
                  l10n.subtotal,
                  '\$${order.subtotal.toStringAsFixed(2)}',
                ),
                _detailRow(
                  l10n.deliveryFee,
                  '\$${order.deliveryFee.toStringAsFixed(2)}',
                ),
                _detailRow(
                  l10n.total,
                  '\$${order.total.toStringAsFixed(2)}',
                  isBold: true,
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _openOrderDetails(order),
                    icon: const Icon(Icons.open_in_new),
                    label: Text(l10n.viewFullDetails),
                  ),
                ),
              ],
            ),
          ),
        ],
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
                fontWeight: isBold
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              softWrap: true,
              style: TextStyle(
                fontWeight: isBold
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
