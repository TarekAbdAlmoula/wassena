import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wassena/features/home/data/model/restaurant.dart';

abstract class RestaurantRemoteSource {
  static Future<List<Restaurant>> getRestaurants() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('restaurants')
        .get();
    List<Restaurant> restaurants = [];
    for (var doc in snapshot.docs) {
      restaurants.add(Restaurant.fromJson(json: doc['data'], id: doc.id));
    }
    return restaurants;
  }
}
