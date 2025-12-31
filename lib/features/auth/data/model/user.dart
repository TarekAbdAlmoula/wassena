import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String name;
  final String email;
  final num phoneNumber;
  final String address;
  final FieldValue createdAt;
  User({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.createdAt,
  });
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'createdAt': createdAt,
    };
  }
}
