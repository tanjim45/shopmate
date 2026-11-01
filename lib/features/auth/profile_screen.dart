
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../products/screens/cart_screen.dart';
import '../products/screens/order_history_screen.dart';
import '../products/screens/wishlist_screen.dart';
import '../products/services/address_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.logout_rounded,
            size: 36,
            color: Colors.red,
          ),
          title: const Text('Log Out?'),
          content: const Text(
            'Are you sure you want to log out of your account?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('No'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Yes, Log Out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !context.mounted) return;

    await FirebaseAuth.instance.signOut();
  }

  void _openPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  String _formatAddress(Map<String, dynamic> address) {
    return [
      address['house']?.toString() ?? '',
      address['areaName']?.toString() ?? '',
      address['city']?.toString() ?? '',
      address['division']?.toString() ?? '',
    ].where((part) => part.trim().isNotEmpty).join(', ');
  }

  Future<void> _showAccountInformation(
    BuildContext context,
    String name,
    String email,
  ) async {
    final addressService = AddressService();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Account Information'),
              content: FutureBuilder<Map<String, dynamic>?>(
                future: addressService.getPermanentAddress(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const SizedBox(
                      height: 100,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final address = snapshot.data;

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _infoRow('Name', name),
                        const SizedBox(height: 12),
                        _infoRow('Email', email),
                        const SizedBox(height: 18),
                        const Divider(),
                        const SizedBox(height: 10),
                        const Text(
                          'Permanent Address',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (address == null)
                          const Text('No permanent address found.')
                        else ...[
                          _infoRow(
                            'Mobile',
                            address['phone']?.toString() ?? '',
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatAddress(address),
                            style: const TextStyle(height: 1.5),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Close'),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final updated = await showDialog<bool>(
                      context: dialogContext,
                      builder: (_) => _EditPermanentAddressDialog(
                        addressService: addressService,
                      ),
                    );

                    if (updated == true && dialogContext.mounted) {
                      setDialogState(() {});
                    }
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Address'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value.isEmpty ? 'Not available' : value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    final displayName = user?.displayName?.trim();

    final name = displayName != null && displayName.isNotEmpty
        ? displayName
        : 'ShopMate User';

    final email = user?.email ?? 'No email available';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF6750A4),
                  Color(0xFF9580D8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.white,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? const Icon(
                          Icons.person_rounded,
                          size: 48,
                          color: Color(0xFF6750A4),
                        )
                      : null,
                ),
                const SizedBox(height: 14),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'ShopMate Member',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'MY SHOPPING',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          _ProfileMenuTile(
            icon: Icons.favorite_rounded,
            title: 'My Wishlist',
            subtitle: 'View your favorite products',
            color: Colors.pink,
            onTap: () {
              _openPage(context, const WishlistScreen());
            },
          ),
          _ProfileMenuTile(
            icon: Icons.receipt_long_rounded,
            title: 'Order History',
            subtitle: 'Track and view your orders',
            color: Colors.deepPurple,
            onTap: () {
              _openPage(context, const OrderHistoryScreen());
            },
          ),
          _ProfileMenuTile(
            icon: Icons.shopping_cart_rounded,
            title: 'My Cart',
            subtitle: 'View products in your cart',
            color: Colors.teal,
            onTap: () {
              _openPage(context, const CartScreen());
            },
          ),
          const SizedBox(height: 24),
          Text(
            'ACCOUNT',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          _ProfileMenuTile(
            icon: Icons.info_outline_rounded,
            title: 'Account Information',
            subtitle: 'View and edit your personal information',
            color: Colors.blue,
            onTap: () {
              _showAccountInformation(context, name, email);
            },
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Log Out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'ShopMate • Your shopping companion',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditPermanentAddressDialog extends StatefulWidget {
  final AddressService addressService;

  const _EditPermanentAddressDialog({
    required this.addressService,
  });

  @override
  State<_EditPermanentAddressDialog> createState() =>
      _EditPermanentAddressDialogState();
}

class _EditPermanentAddressDialogState
    extends State<_EditPermanentAddressDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _divisionController = TextEditingController();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  final _houseController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    try {
      final address = await widget.addressService.getPermanentAddress();

      if (!mounted) return;

      if (address != null) {
        _nameController.text = address['name']?.toString() ?? '';
        _phoneController.text = address['phone']?.toString() ?? '';
        _divisionController.text =
            address['division']?.toString() ?? '';
        _cityController.text = address['city']?.toString() ?? '';
        _areaController.text = address['areaName']?.toString() ?? '';
        _houseController.text = address['house']?.toString() ?? '';
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load address: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _field(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
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
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter $label';
          }

          if (label == 'Mobile Number' &&
              !RegExp(r'^[0-9+\-\s]{10,15}$')
                  .hasMatch(value.trim())) {
            return 'Enter a valid mobile number';
          }

          return null;
        },
      ),
    );
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User is not logged in.');
      }

      await widget.addressService.savePermanentAddress(
        name: _nameController.text.trim(),
        email: user.email ?? '',
        phone: _phoneController.text.trim(),
        division: _divisionController.text.trim(),
        city: _cityController.text.trim(),
        areaName: _areaController.text.trim(),
        house: _houseController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update address: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Permanent Address'),
      content: _isLoading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : SizedBox(
              width: 400,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _field(
                        'Full Name',
                        _nameController,
                        Icons.person_outline,
                      ),
                      _field(
                        'Mobile Number',
                        _phoneController,
                        Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      _field(
                        'Division',
                        _divisionController,
                        Icons.map_outlined,
                      ),
                      _field(
                        'City',
                        _cityController,
                        Icons.location_city_outlined,
                      ),
                      _field(
                        'Area Name',
                        _areaController,
                        Icons.location_on_outlined,
                      ),
                      _field(
                        'House No. / House Name',
                        _houseController,
                        Icons.home_outlined,
                      ),
                    ],
                  ),
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: _isSaving || _isLoading
              ? null
              : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving || _isLoading ? null : _saveAddress,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save Changes'),
        ),
      ],
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 7,
        ),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
