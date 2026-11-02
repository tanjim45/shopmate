
import 'package:flutter/material.dart';
import 'package:shopmate/features/products/models/order_model.dart';
import 'package:shopmate/l10n/app_localizations.dart';

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

  String _localizedDeliveryMethod(
    String method,
    AppLocalizations l10n,
  ) {
    if (method == 'Standard Delivery') return l10n.standardDelivery;
    if (method == 'Express Delivery') return l10n.expressDelivery;
    return method;
  }

  String _localizedStatus(String status, AppLocalizations l10n) {
    if (status == 'Placed') return l10n.placed;
    return status;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.orderNumber} #${order.id ?? '-'}'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 700;

          final orderInformation = _sectionCard(
            context,
            title: l10n.orderInformation,
            icon: Icons.receipt_long_outlined,
            children: [
              _detailRow(
                context,
                l10n.orderId,
                '#${order.id ?? '-'}',
              ),
              _detailRow(
                context,
                l10n.orderDate,
                _formatDate(order.createdAt),
              ),
              _detailRow(
                context,
                l10n.deliveryMethod,
                _localizedDeliveryMethod(order.deliveryMethod, l10n),
              ),
            ],
          );

          final customerInformation = _sectionCard(
            context,
            title: l10n.customerInformation,
            icon: Icons.person_outline,
            children: [
              _detailRow(context, l10n.name, order.customerName),
              _detailRow(context, l10n.phone, order.phone),
              _detailRow(context, l10n.address, order.address),
            ],
          );

          final productsSection = _sectionCard(
            context,
            title: '${l10n.orderedProducts} (${order.items.length})',
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
          );

          final paymentSection = _sectionCard(
            context,
            title: l10n.paymentSummary,
            icon: Icons.payments_outlined,
            children: [
              _detailRow(
                context,
                l10n.subtotal,
                '\$${order.subtotal.toStringAsFixed(2)}',
              ),
              _detailRow(
                context,
                l10n.deliveryFee,
                '\$${order.deliveryFee.toStringAsFixed(2)}',
              ),
              const Divider(height: 24),
              _detailRow(
                context,
                l10n.totalAmount,
                '\$${order.total.toStringAsFixed(2)}',
                isBold: true,
              ),
            ],
          );

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1100,
              ),
              child: ListView(
                padding: EdgeInsets.all(isWide ? 28 : 16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
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
                                Text(
                                  l10n.orderStatus,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  _localizedStatus(order.status, l10n),
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

                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: orderInformation),
                        const SizedBox(width: 16),
                        Expanded(child: customerInformation),
                      ],
                    )
                  else ...[
                    orderInformation,
                    const SizedBox(height: 16),
                    customerInformation,
                  ],

                  const SizedBox(height: 16),

                  productsSection,

                  const SizedBox(height: 16),

                  paymentSection,

                  const SizedBox(height: 20),

                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: Text(l10n.backToMyOrders),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
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
              softWrap: true,
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
