import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopmate/features/auth/app_theme.dart';
import 'package:shopmate/features/auth/auth_gate.dart';
import 'package:shopmate/l10n/app_localizations.dart';
import '../../auth/theme_provider.dart';
import '../../auth/language_provider.dart';
import 'cart_screen.dart';
import 'order_history_screen.dart';
import 'wishlist_screen.dart';
import '../services/address_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

Future<void> _logout(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;

  final shouldLogout = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        icon: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.logout_rounded,
            size: 30,
            color: AppColors.danger,
          ),
        ),
        title: Text(l10n.logOutQuestion),
        content: Text(
          l10n.logoutConfirmation,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textMuted,
            height: 1.5,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.no),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              minimumSize: const Size(130, 46),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.yesLogout),
          ),
        ],
      );
    },
  );

  if (shouldLogout != true || !context.mounted) return;

  try {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const AuthGate(),
      ),
      (route) => false,
    );
  } catch (e) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logout failed: $e'),
        backgroundColor: AppColors.danger,
      ),
    );
  }
}


  Future<void> _showAppearanceSettings(
    BuildContext context,
    WidgetRef ref,
  ) async {
    

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Consumer(
          builder: (context, ref, child) {
            final selectedTheme = ref.watch(themeProvider);
            final currentL10n = AppLocalizations.of(context)!;

            return AlertDialog(
              title: Text(currentL10n.appearanceSettings),
              content: RadioGroup<ThemeMode>(
                groupValue: selectedTheme,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(themeProvider.notifier).changeTheme(value);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.light,
                      title: Text(currentL10n.lightMode),
                      secondary: const Icon(Icons.light_mode),
                    ),
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.dark,
                      title: Text(currentL10n.darkMode),
                      secondary: const Icon(Icons.dark_mode),
                    ),
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.system,
                      title: Text(currentL10n.systemTheme),
                      secondary: const Icon(Icons.settings_brightness),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(currentL10n.done),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showLanguageSettings(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Consumer(
          builder: (context, ref, child) {
            final selectedLanguage = ref.watch(languageProvider);
            final l10n = AppLocalizations.of(context)!;

            return AlertDialog(
              title: Text(l10n.language),
              content: RadioGroup<String>(
                groupValue: selectedLanguage.languageCode,
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(languageProvider.notifier)
                        .changeLanguage(value);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<String>(
                      value: 'en',
                      title: Text(l10n.english),
                      secondary: const Icon(Icons.language),
                    ),
                    RadioListTile<String>(
                      value: 'bn',
                      title: Text(l10n.bangla),
                      secondary: const Icon(Icons.translate),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(l10n.done),
                ),
              ],
            );
          },
        );
      },
    );
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
            final l10n = AppLocalizations.of(context)!;

            return AlertDialog(
              title: Text(l10n.accountInformation),
              content: FutureBuilder<Map<String, dynamic>?>(
                future: addressService.getPermanentAddress(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final address = snapshot.data;

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _infoRow(
                          Icons.person_outline,
                          l10n.name,
                          name,
                          l10n.notAvailable,
                        ),
                        const SizedBox(height: 14),
                        _infoRow(
                          Icons.email_outlined,
                          l10n.email,
                          email,
                          l10n.notAvailable,
                        ),
                        const SizedBox(height: 18),
                        const Divider(),
                        const SizedBox(height: 14),
                        Text(
                          l10n.permanentAddress,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (address == null)
                          Text(
                            l10n.noAddress,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                            ),
                          )
                        else ...[
                          _infoRow(
                            Icons.phone_outlined,
                            l10n.mobile,
                            address['phone']?.toString() ?? '',
                            l10n.notAvailable,
                          ),
                          const SizedBox(height: 14),
                          _infoRow(
                            Icons.home_outlined,
                            l10n.address,
                            _formatAddress(address),
                            l10n.notAvailable,
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
                  child: Text(l10n.close),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(140, 44),
                  ),
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
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(l10n.editAddress),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
    String notAvailable,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? notAvailable : value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.3,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName?.trim();

    final name = displayName != null && displayName.isNotEmpty
        ? displayName
        : l10n.shopMateUser;

    final email = user?.email ?? l10n.noEmailAvailable;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myProfile),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 26),
            decoration: BoxDecoration(
              gradient: AppColors.gradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.6),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.white,
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? const Icon(
                            Icons.person_rounded,
                            size: 48,
                            color: AppColors.primary,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  email,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.workspace_premium_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.shopMateMember,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          _sectionLabel(l10n.myShopping),
          _ProfileMenuTile(
            icon: Icons.favorite_rounded,
            title: l10n.myWishlist,
            subtitle: l10n.wishlistSubtitle,
            color: const Color(0xFFE91E63),
            onTap: () => _openPage(context, const WishlistScreen()),
          ),
          _ProfileMenuTile(
            icon: Icons.receipt_long_rounded,
            title: l10n.orderHistory,
            subtitle: l10n.orderHistorySubtitle,
            color: AppColors.primary,
            onTap: () => _openPage(context, const OrderHistoryScreen()),
          ),
          _ProfileMenuTile(
            icon: Icons.shopping_cart_rounded,
            title: l10n.myCart,
            subtitle: l10n.cartSubtitle,
            color: AppColors.accent,
            onTap: () => _openPage(context, const CartScreen()),
          ),
          const SizedBox(height: 22),

          _sectionLabel(l10n.account),
          _ProfileMenuTile(
            icon: Icons.manage_accounts_rounded,
            title: l10n.accountInformation,
            subtitle: l10n.accountInfoSubtitle,
            color: const Color(0xFF2F80ED),
            onTap: () => _showAccountInformation(context, name, email),
          ),
          _ProfileMenuTile(
            icon: Icons.palette_outlined,
            title: l10n.appearanceSettings,
            subtitle: l10n.changeThemeSubtitle,
            color: const Color(0xFF8E44AD),
            onTap: () => _showAppearanceSettings(context, ref),
          ),
          _ProfileMenuTile(
            icon: Icons.language_rounded,
            title: l10n.languageSettings,
            subtitle: l10n.changeLanguageSubtitle,
            color: const Color(0xFF16A085),
            onTap: () => _showLanguageSettings(context, ref),
          ),
          const SizedBox(height: 22),

          OutlinedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_rounded),
            label: Text(
              l10n.logout,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              backgroundColor: AppColors.danger.withValues(alpha: 0.05),
              side: BorderSide(
                color: AppColors.danger.withValues(alpha: 0.5),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              l10n.profileFooter,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textMuted,
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
    final l10n = AppLocalizations.of(context)!;

    try {
      final address = await widget.addressService.getPermanentAddress();

      if (!mounted) return;

      if (address != null) {
        _nameController.text = address['name']?.toString() ?? '';
        _phoneController.text = address['phone']?.toString() ?? '';
        _divisionController.text = address['division']?.toString() ?? '';
        _cityController.text = address['city']?.toString() ?? '';
        _areaController.text = address['areaName']?.toString() ?? '';
        _houseController.text = address['house']?.toString() ?? '';
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.couldNotLoadAddress(e.toString())),
        ),
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
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return l10n.pleaseEnter(label);
          }

          if (label == l10n.mobileNumber &&
              !RegExp(r'^[0-9+\-\s]{10,15}$').hasMatch(value.trim())) {
            return l10n.validMobile;
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
        throw Exception(
          AppLocalizations.of(context)!.userNotLoggedIn,
        );
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

      final l10n = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.failedUpdateAddress(e.toString())),
          backgroundColor: AppColors.danger,
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
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.editPermanentAddress),
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
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _field(
                        l10n.fullName,
                        _nameController,
                        Icons.person_outline,
                      ),
                      _field(
                        l10n.mobileNumber,
                        _phoneController,
                        Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      _field(
                        l10n.division,
                        _divisionController,
                        Icons.map_outlined,
                      ),
                      _field(
                        l10n.city,
                        _cityController,
                        Icons.location_city_outlined,
                      ),
                      _field(
                        l10n.areaName,
                        _areaController,
                        Icons.location_on_outlined,
                      ),
                      _field(
                        l10n.houseNumber,
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
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size(130, 46),
          ),
          onPressed: _isSaving || _isLoading ? null : _saveAddress,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(l10n.saveChanges),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.5,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
