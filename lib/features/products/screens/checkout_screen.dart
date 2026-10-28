
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopmate/features/products/screens/order_success_screen.dart';
import '../../../database/order_database.dart';
import '../models/order_model.dart';

import '../providers/cart_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() =>
      _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isPlacingOrder = false;

  String _deliveryMethod = 'Standard Delivery';

  
      Future<void> _placeOrder() async {
        if (!_formKey.currentState!.validate()) return;

        final cartItems = ref.read(cartProvider);
        if (cartItems.isEmpty) return;

        setState(() {
          _isPlacingOrder = true;
        });

        try {
          const deliveryFee = 5.00;

          final subtotal = cartItems.fold<double>(
            0.0,
            (sum, item) => sum + item.product.price * item.quantity,
          );

          final orderItems = cartItems.map((item) {
            return OrderItem(
              productId: item.product.id,
              title: item.product.title,
              price: item.product.price,
              quantity: item.quantity,
              thumbnail: item.product.image,
            );
          }).toList();

          final order = OrderModel(
            customerName: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            address: _addressController.text.trim(),
            deliveryMethod: _deliveryMethod,
            subtotal: subtotal,
            deliveryFee: deliveryFee,
            total: subtotal + deliveryFee,
            status: 'Placed',
            createdAt: DateTime.now(),
            items: orderItems,
          );

          await OrderDatabase.instance.saveOrder(order);

          if (!mounted) return;

          ref.read(cartProvider.notifier).clearCart();

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const OrderSuccessScreen(),
            ),
          );
        } catch (e) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to place order: $e'),
              backgroundColor: Colors.red,
            ),
          );
        } finally {
          if (mounted) {
            setState(() {
              _isPlacingOrder = false;
            });
          }
        }
      }


  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final cartController = ref.read(cartProvider.notifier);
    final theme = Theme.of(context);

    final subtotal = cartController.totalPrice;
    const deliveryFee = 5.00;
    final total = subtotal +
        (cartItems.isEmpty ? 0 : deliveryFee);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 72,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Delivery Information',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().length < 2) {
                        return 'Enter your full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      hintText: 'Enter your phone number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    validator: (value) {
                      final phone = value?.trim() ?? '';
                      if (phone.length < 7 ||
                          !RegExp(r'^[0-9+()\-\s]+$')
                              .hasMatch(phone)) {
                        return 'Enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _addressController,
                    minLines: 2,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Delivery Address',
                      hintText: 'House, road, area, city',
                      alignLabelWithHint: true,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 38),
                        child: Icon(Icons.location_on_outlined),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().length < 8) {
                        return 'Enter your complete address';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 28),

                  Text(
                    'Delivery Method',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  RadioGroup<String>(
                    groupValue: _deliveryMethod,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _deliveryMethod = value;
                      });
                    },
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          value: 'Standard Delivery',
                          title: const Text('Standard Delivery'),
                          subtitle: const Text('3–5 business days'),
                          secondary: const Icon(
                            Icons.local_shipping_outlined,
                          ),
                        ),
                        RadioListTile<String>(
                          value: 'Express Delivery',
                          title: const Text('Express Delivery'),
                          subtitle: const Text('1–2 business days'),
                          secondary: const Icon(
                            Icons.bolt_outlined,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Order Summary',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        _summaryRow(
                          'Total Items',
                          '${cartController.totalQuantity}',
                        ),
                        const SizedBox(height: 12),
                        _summaryRow(
                          'Subtotal',
                          '\$${subtotal.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 12),
                        _summaryRow(
                          'Delivery Fee',
                          cartItems.isEmpty
                              ? '\$0.00'
                              : '\$${deliveryFee.toStringAsFixed(2)}',
                        ),
                        const Divider(height: 28),
                        _summaryRow(
                          'Total',
                          '\$${total.toStringAsFixed(2)}',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isPlacingOrder ? null : _placeOrder,


                      icon: const Icon(Icons.check_circle_outline),
                      label: Text( _isPlacingOrder ? 'Placing Order...' : 'Place Order',
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 17,
                        ),
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool isTotal = false,
  }) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 17 : 14,
              fontWeight:
                  isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 15,
            fontWeight: FontWeight.bold,
            color: isTotal ? theme.colorScheme.primary : null,
          ),
        ),
      ],
    );
  }
}
