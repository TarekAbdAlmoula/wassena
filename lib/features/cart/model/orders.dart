import 'package:cloud_firestore/cloud_firestore.dart';

class Orders {
  final String userId;
  final String restaurantId;
  final String orderStatus;
  final num totalAmount;
  final FieldValue createdAt;
  Orders({
    required this.userId,
    required this.restaurantId,
    required this.orderStatus,
    required this.totalAmount,
    required this.createdAt,
  });
}
