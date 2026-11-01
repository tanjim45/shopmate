
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

class AddressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Box<Map> get _addressBox =>
      Hive.box<Map>('shopmate_addresses');

  Future<void> savePermanentAddress({
    required String name,
    required String email,
    required String division,
    required String city,
    required String areaName,
    required String house,
    required String phone,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final addressData = {
      'name': name,
      'email': email,
      'division': division,
      'city': city,
      'areaName': areaName,
      'house': house,
      'phone': phone,
    };

    await _firestore.collection('users').doc(user.uid).set({
      'name': name,
      'email': email,
      'permanentAddress': addressData,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _addressBox.put(
      user.uid,
      Map<String, dynamic>.from(addressData),
    );
  }

  Future<Map<String, dynamic>?> getPermanentAddress() async {
    final user = _auth.currentUser;

    if (user == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        final address = data?['permanentAddress'];

        if (address is Map) {
          final addressMap = Map<String, dynamic>.from(address);

          await _addressBox.put(user.uid, addressMap);

          return addressMap;
        }

        // Support addresses saved by the previous version.
        final oldAddress = data?['deliveryAddress'];

        if (oldAddress is Map) {
          final addressMap =
              Map<String, dynamic>.from(oldAddress);

          await savePermanentAddress(
            name: addressMap['name'] ?? '',
            email: addressMap['email'] ?? user.email ?? '',
            division: addressMap['division'] ?? '',
            city: addressMap['city'] ?? '',
            areaName: addressMap['areaName'] ?? '',
            house: addressMap['house'] ?? '',
            phone: addressMap['phone'] ?? '',
          );

          return addressMap;
        }
      }

      return null;
    } catch (e) {
      final cachedAddress = _addressBox.get(user.uid);

      if (cachedAddress != null) {
        return Map<String, dynamic>.from(cachedAddress);
      }

      rethrow;
    }
  }
}
