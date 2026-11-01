// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ShopMate';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get bangla => 'Bangla';

  @override
  String get appearance => 'Appearance';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get systemTheme => 'System Default';

  @override
  String get accountInformation => 'Account Information';

  @override
  String get logout => 'Logout';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get myProfile => 'My Profile';

  @override
  String get shopMateUser => 'ShopMate User';

  @override
  String get noEmailAvailable => 'No email available';

  @override
  String get shopMateMember => 'ShopMate Member';

  @override
  String get myShopping => 'MY SHOPPING';

  @override
  String get myWishlist => 'My Wishlist';

  @override
  String get wishlistSubtitle => 'View your favorite products';

  @override
  String get orderHistory => 'Order History';

  @override
  String get orderHistorySubtitle => 'Track and view your orders';

  @override
  String get myCart => 'My Cart';

  @override
  String get cartSubtitle => 'View products in your cart';

  @override
  String get account => 'ACCOUNT';

  @override
  String get accountInfoSubtitle => 'View and edit your personal information';

  @override
  String get appearanceSettings => 'Appearance Settings';

  @override
  String get changeThemeSubtitle => 'Change light or dark mode';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get changeLanguageSubtitle => 'Change app language';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get done => 'Done';

  @override
  String get logOutQuestion => 'Log Out?';

  @override
  String get logoutConfirmation =>
      'Are you sure you want to log out of your account?';

  @override
  String get no => 'No';

  @override
  String get yesLogout => 'Yes, Log Out';

  @override
  String get name => 'Name';

  @override
  String get email => 'Email';

  @override
  String get permanentAddress => 'Permanent Address';

  @override
  String get noAddress => 'No permanent address found.';

  @override
  String get mobile => 'Mobile';

  @override
  String get address => 'Address';

  @override
  String get close => 'Close';

  @override
  String get editAddress => 'Edit Address';

  @override
  String get notAvailable => 'Not available';

  @override
  String get editPermanentAddress => 'Edit Permanent Address';

  @override
  String get fullName => 'Full Name';

  @override
  String get mobileNumber => 'Mobile Number';

  @override
  String get division => 'Division';

  @override
  String get city => 'City';

  @override
  String get areaName => 'Area Name';

  @override
  String get houseNumber => 'House No. / House Name';

  @override
  String pleaseEnter(Object field) {
    return 'Please enter $field';
  }

  @override
  String get validMobile => 'Enter a valid mobile number';

  @override
  String couldNotLoadAddress(Object error) {
    return 'Could not load address: $error';
  }

  @override
  String failedUpdateAddress(Object error) {
    return 'Failed to update address: $error';
  }

  @override
  String get userNotLoggedIn => 'User is not logged in.';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get profileFooter => 'ShopMate • Your shopping companion';
}
