import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:wassena/features/cart/model/item_cart.dart';
import 'package:wassena/features/cart/model/orders.dart';

class CartController extends ChangeNotifier {
  final List<ItemCart> items = [];
  String orderId = '';
  Orders? orders;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  void addToCart(ItemCart itemCart) async {
    items.add(itemCart);
  }

  void createOrdersTable() async {
    final user = FirebaseAuth.instance.currentUser;
    orders = Orders(
      userId: user!.uid,
      restaurantId: items[0].restaurantId,
      orderStatus: 'pending',
      totalAmount: items.fold(0, (sum, item) => sum + item.price * item.qty),
      createdAt: FieldValue.serverTimestamp(),
    );
    DocumentReference orderRef = await _firebaseFirestore
        .collection('orders')
        .add({
          'userId': orders!.userId,
          'restaurantId': orders!.restaurantId,
          'orderStatus': orders!.orderStatus,
          'totalAmount': orders!.totalAmount,
          'createdAt': orders!.createdAt,
        });
    orderId = orderRef.id;
    createOrderItemsTable(orderId: orderId);
  }

  void createOrderItemsTable({required String orderId}) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('menu')
          .where('data.restaurant_id', isEqualTo: items[0].restaurantId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return;
      }
      String menuId = snapshot.docs.first.id;

      List<Map<String, dynamic>> orderItemsData = items.map((item) {
        return {
          'itemName': item.itemName,
          'price': item.price,
          'qty': item.qty,
          'menuId': menuId,
          'restaurantId': item.restaurantId,
          'orderId': orderId,
        };
      }).toList();
      await _firebaseFirestore.collection('order_items').add({
        "orderItems": orderItemsData,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void makePayment({required String paymentMethod}) async {
    final uuid = Uuid();
    String id = uuid.v4();
    await _firebaseFirestore.collection('payments').add({
      'order_id ': orderId,
      'payment_method': paymentMethod,
      'transaction_id': paymentMethod == 'الدفع كاش' ? '' : id,
      'totalAmount': orders!.totalAmount,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  String getOrderId() {
    return orderId;
  }
}
