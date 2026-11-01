// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'শপমেট';

  @override
  String get settings => 'সেটিংস';

  @override
  String get language => 'ভাষা';

  @override
  String get english => 'ইংরেজি';

  @override
  String get bangla => 'বাংলা';

  @override
  String get appearance => 'অ্যাপের চেহারা';

  @override
  String get lightTheme => 'লাইট';

  @override
  String get darkTheme => 'ডার্ক';

  @override
  String get systemTheme => 'সিস্টেম ডিফল্ট';

  @override
  String get accountInformation => 'অ্যাকাউন্টের তথ্য';

  @override
  String get logout => 'লগআউট';

  @override
  String get cancel => 'বাতিল';

  @override
  String get save => 'সংরক্ষণ';

  @override
  String get myProfile => 'আমার প্রোফাইল';

  @override
  String get shopMateUser => 'শপমেট ব্যবহারকারী';

  @override
  String get noEmailAvailable => 'কোনো ইমেইল পাওয়া যায়নি';

  @override
  String get shopMateMember => 'শপমেট সদস্য';

  @override
  String get myShopping => 'আমার কেনাকাটা';

  @override
  String get myWishlist => 'আমার পছন্দের তালিকা';

  @override
  String get wishlistSubtitle => 'আপনার পছন্দের পণ্যগুলো দেখুন';

  @override
  String get orderHistory => 'অর্ডারের ইতিহাস';

  @override
  String get orderHistorySubtitle => 'আপনার অর্ডার দেখুন ও ট্র্যাক করুন';

  @override
  String get myCart => 'আমার কার্ট';

  @override
  String get cartSubtitle => 'কার্টে থাকা পণ্যগুলো দেখুন';

  @override
  String get account => 'অ্যাকাউন্ট';

  @override
  String get accountInfoSubtitle =>
      'আপনার ব্যক্তিগত তথ্য দেখুন ও পরিবর্তন করুন';

  @override
  String get appearanceSettings => 'অ্যাপের থিম সেটিংস';

  @override
  String get changeThemeSubtitle => 'লাইট বা ডার্ক মোড পরিবর্তন করুন';

  @override
  String get languageSettings => 'ভাষার সেটিংস';

  @override
  String get changeLanguageSubtitle => 'অ্যাপের ভাষা পরিবর্তন করুন';

  @override
  String get lightMode => 'লাইট মোড';

  @override
  String get darkMode => 'ডার্ক মোড';

  @override
  String get done => 'সম্পন্ন';

  @override
  String get logOutQuestion => 'লগআউট করবেন?';

  @override
  String get logoutConfirmation =>
      'আপনি কি নিশ্চিত যে আপনার অ্যাকাউন্ট থেকে লগআউট করতে চান?';

  @override
  String get no => 'না';

  @override
  String get yesLogout => 'হ্যাঁ, লগআউট';

  @override
  String get name => 'নাম';

  @override
  String get email => 'ইমেইল';

  @override
  String get permanentAddress => 'স্থায়ী ঠিকানা';

  @override
  String get noAddress => 'কোনো স্থায়ী ঠিকানা পাওয়া যায়নি।';

  @override
  String get mobile => 'মোবাইল';

  @override
  String get address => 'ঠিকানা';

  @override
  String get close => 'বন্ধ করুন';

  @override
  String get editAddress => 'ঠিকানা পরিবর্তন';

  @override
  String get notAvailable => 'পাওয়া যায়নি';

  @override
  String get editPermanentAddress => 'স্থায়ী ঠিকানা পরিবর্তন';

  @override
  String get fullName => 'সম্পূর্ণ নাম';

  @override
  String get mobileNumber => 'মোবাইল নম্বর';

  @override
  String get division => 'বিভাগ';

  @override
  String get city => 'শহর';

  @override
  String get areaName => 'এলাকার নাম';

  @override
  String get houseNumber => 'বাড়ি নম্বর / বাড়ির নাম';

  @override
  String pleaseEnter(Object field) {
    return '$field লিখুন';
  }

  @override
  String get validMobile => 'সঠিক মোবাইল নম্বর দিন';

  @override
  String couldNotLoadAddress(Object error) {
    return 'ঠিকানা লোড করা যায়নি: $error';
  }

  @override
  String failedUpdateAddress(Object error) {
    return 'ঠিকানা আপডেট করা যায়নি: $error';
  }

  @override
  String get userNotLoggedIn => 'ব্যবহারকারী লগইন করা নেই।';

  @override
  String get saveChanges => 'পরিবর্তন সংরক্ষণ করুন';

  @override
  String get profileFooter => 'শপমেট • আপনার কেনাকাটার সঙ্গী';
}
