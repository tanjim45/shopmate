import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopmate/features/products/screens/order_success_screen.dart';
import 'package:shopmate/features/products/services/address_service.dart';
import 'package:shopmate/features/products/services/order_service.dart';

import '../models/order_model.dart';
import '../providers/cart_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  // New delivery address controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _divisionController = TextEditingController();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  final _houseController = TextEditingController();

  final AddressService _addressService = AddressService();

  Map<String, dynamic>? _permanentAddress;

  bool _isPlacingOrder = false;
  bool _isLoadingAddress = true;
  bool _usePermanentAddress = false;

  String _deliveryMethod = 'Standard Delivery';

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }

  Future<void> _loadSavedAddress() async {
    try {
      final address = await _addressService.getPermanentAddress();

      if (!mounted) return;

      setState(() {
        _permanentAddress = address;

        // Permanent address থাকলে checkbox default checked থাকবে
        _usePermanentAddress = address != null;

        _isLoadingAddress = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _permanentAddress = null;
        _usePermanentAddress = false;
        _isLoadingAddress = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not load permanent address: $e'),
        ),
      );
    }
  }

  String _formatAddress(Map<String, dynamic> address) {
    return [
      address['house']?.toString() ?? '',
      address['areaName']?.toString() ?? '',
      address['city']?.toString() ?? '',
      address['division']?.toString() ?? '',
    ].where((part) => part.trim().isNotEmpty).join(', ');
  }

  String get _formattedDeliveryAddress {
    return [
      _houseController.text.trim(),
      _areaController.text.trim(),
      _cityController.text.trim(),
      _divisionController.text.trim(),
    ].where((part) => part.isNotEmpty).join(', ');
  }

  Future<void> _placeOrder() async {
    // নতুন address ব্যবহার করলে form validation হবে
    if (!_usePermanentAddress) {
      if (!_formKey.currentState!.validate()) return;
    }

    final cartItems = ref.read(cartProvider);

    if (cartItems.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login before placing an order.'),
        ),
      );
      return;
    }

    // Permanent address অথবা নতুন delivery address নির্বাচন
    final String customerName;
    final String phone;
    final String deliveryAddress;

    if (_usePermanentAddress) {
      if (_permanentAddress == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permanent address not found.'),
          ),
        );
        return;
      }

      customerName = _permanentAddress!['name']?.toString() ?? '';
      phone = _permanentAddress!['phone']?.toString() ?? '';
      deliveryAddress = _formatAddress(_permanentAddress!);
    } else {
      customerName = _nameController.text.trim();
      phone = _phoneController.text.trim();
      deliveryAddress = _formattedDeliveryAddress;
    }

    setState(() => _isPlacingOrder = true);

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
        customerName: customerName,
        phone: phone,
        address: deliveryAddress,
        deliveryMethod: _deliveryMethod,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        total: subtotal + deliveryFee,
        status: 'Placed',
        createdAt: DateTime.now(),
        items: orderItems,
      );

      // শুধু order save হবে; permanent address পরিবর্তন হবে না।
      await OrderService().saveOrder(order);

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
        setState(() => _isPlacingOrder = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _divisionController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _houseController.dispose();
    super.dispose();
  }

  Widget _addressField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        validator: validator ??
            (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter $label';
              }
              return null;
            },
      ),
    );
  }

  Widget _buildPermanentAddressCard() {
    final theme = Theme.of(context);
    final address = _permanentAddress!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.home_outlined,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Permanent Address',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const Icon(
                Icons.verified,
                color: Colors.green,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            address['name']?.toString() ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(_formatAddress(address)),
          const SizedBox(height: 5),
          Text('Mobile: ${address['phone'] ?? ''}'),
        ],
      ),
    );
  }

  Widget _buildAddressForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _addressField(
          label: 'Full Name',
          icon: Icons.person_outline,
          controller: _nameController,
          validator: (value) {
            if (value == null || value.trim().length < 2) {
              return 'Enter your full name';
            }
            return null;
          },
        ),
        _addressField(
          label: 'Mobile Number',
          icon: Icons.phone_outlined,
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          validator: (value) {
            final phone = value?.trim() ?? '';

            if (!RegExp(r'^[0-9+\-\s]{10,15}$').hasMatch(phone)) {
              return 'Enter a valid mobile number';
            }
            return null;
          },
        ),
        _addressField(
          label: 'Division',
          icon: Icons.map_outlined,
          controller: _divisionController,
        ),
        _addressField(
          label: 'City',
          icon: Icons.location_city_outlined,
          controller: _cityController,
        ),
        _addressField(
          label: 'Area Name',
          icon: Icons.location_on_outlined,
          controller: _areaController,
        ),
        _addressField(
          label: 'House No. / House Name',
          icon: Icons.home_outlined,
          controller: _houseController,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final cartController = ref.read(cartProvider.notifier);
    final theme = Theme.of(context);

    final subtotal = cartController.totalPrice;
    const deliveryFee = 5.00;
    final total = subtotal + (cartItems.isEmpty ? 0 : deliveryFee);

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
          : _isLoadingAddress
              ? const Center(child: CircularProgressIndicator())
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

                      // Same as Permanent Address checkbox
                      if (_permanentAddress != null) ...[
                        CheckboxListTile(
                          value: _usePermanentAddress,
                          onChanged: (value) {
                            setState(() {
                              _usePermanentAddress = value ?? false;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: const Text(
                            'Same as Permanent Address',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: const Text(
                            'Use your saved permanent address for delivery',
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      if (_usePermanentAddress &&
                          _permanentAddress != null)
                        _buildPermanentAddressCard()
                      else ...[
                        Text(
                          'Delivery Address',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildAddressForm(),
                      ],

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
                          onPressed:
                              _isPlacingOrder ? null : _placeOrder,
                          icon: const Icon(Icons.check_circle_outline),
                          label: Text(
                            _isPlacingOrder
                                ? 'Placing Order...'
                                : 'Place Order',
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