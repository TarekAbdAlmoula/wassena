import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wassena/features/delivery/data/model/driver.dart';

abstract class DeliveryController {
  static Future<Driver> getDrivers() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('dirvers')
        .get();

    List<Driver> driver = [];
    for (var doc in snapshot.docs) {
      if (doc['data']['availability_status'] == true) {
        driver.add(Driver.fromJson(doc['data'], doc.id));
      }
    }
    driver.shuffle();
    return driver[0];
  }

  static void addToDelivertTable({
    required String driverId,
    required String orderId,
  }) async {
    FirebaseFirestore.instance.collection('deliveries').add({
      'driver_id': driverId,
      'order_id': orderId,
      'delivery_status': 0,
      'estimated_time': 10,
      'actual_time': 12,
    });
  }
}
