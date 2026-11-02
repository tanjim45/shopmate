
import 'package:flutter/material.dart';
import 'package:shopmate/features/auth/app_theme.dart';
import 'login_screen.dart';

class GetStartScreen extends StatelessWidget {
  const GetStartScreen({super.key});

  Widget _circle(double size, double alpha) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
      ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;

          final isTablet = screenWidth >= 600;
          final isDesktop = screenWidth >= 900;

          final logoSize = isDesktop ? 100.0 : isTablet ? 90.0 : 78.0;
          final titleSize = isDesktop ? 52.0 : isTablet ? 46.0 : 40.0;

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.gradient,
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -70,
                  right: -60,
                  child: _circle(240, 0.08),
                ),
                Positioned(
                  top: 140,
                  left: -80,
                  child: _circle(180, 0.06),
                ),
                Positioned(
                  bottom: -90,
                  left: -40,
                  child: _circle(260, 0.08),
                ),

                SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 650 : 550,
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 40 : 28,
                          vertical: 20,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: screenHeight -
                                MediaQuery.of(context).padding.vertical -
                                40,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              children: [
                                const Spacer(flex: 2),

                                // Logo
                                Container(
                                  padding: EdgeInsets.all(
                                    isDesktop ? 34 : 28,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(
                                      alpha: 0.16,
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.shopping_bag_rounded,
                                    size: logoSize,
                                    color: Colors.white,
                                  ),
                                ),

                                const SizedBox(height: 34),

                                // App Name
                                Text(
                                  'ShopMate',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                    color: Colors.white,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Description
                                Text(
                                  'Discover amazing products and enjoy\na smooth shopping experience.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isTablet ? 18 : 16,
                                    height: 1.55,
                                    color: Colors.white.withValues(
                                      alpha: 0.85,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 26),

                                // Feature Chips
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    _chip(
                                      Icons.local_shipping_outlined,
                                      'Fast Delivery',
                                    ),
                                    _chip(
                                      Icons.verified_user_outlined,
                                      'Secure',
                                    ),
                                    _chip(
                                      Icons.favorite_border_rounded,
                                      'Wishlist',
                                    ),
                                  ],
                                ),

                                const Spacer(flex: 3),

                                // Get Started Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 58,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const LoginScreen(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColors.primary,
                                      elevation: 6,
                                      shadowColor: Colors.black38,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Get Started',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 28),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
