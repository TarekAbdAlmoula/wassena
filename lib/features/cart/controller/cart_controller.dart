import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wassena/features/cart/model/item_cart.dart';
import 'package:wassena/features/cart/model/orders.dart';

class CartController extends ChangeNotifier {
  final List<ItemCart> items = [];
  Orders? orders;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  void addToCart(ItemCart itemCart) async {
    items.add(itemCart);
    print('Item added to cart. Total items: ${items[0].restaurantId}');
  }

  void createOrdersTable() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print(user.uid); // هذا هو User ID
    } // هذا هو User ID

    orders = Orders(
      userId: user!.uid,
      restaurantId: items[0].restaurantId,
      orderStatus: 'pending',
      totalAmount: items.fold(0, (sum, item) => sum + item.price * item.qty),
      createdAt: FieldValue.serverTimestamp(),
    );
    _firebaseFirestore.collection('orders').add({
      'userId': orders!.userId,
      'restaurantId': orders!.restaurantId,
      'orderStatus': orders!.orderStatus,
      'totalAmount': orders!.totalAmount,
      'createdAt': orders!.createdAt,
    });
  }

  void printItems() {
    for (var item in items) {
      print('''restaurantId:${item.restaurantId}
      itemName:${item.itemName}
      price:${item.price}
      imageUrl:${item.imageUrl}
      qty:${item.qty}
      ''');
    }
  }
}
