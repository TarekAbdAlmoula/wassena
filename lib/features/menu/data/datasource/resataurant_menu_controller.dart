import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wassena/features/menu/data/model/restaurants_menu.dart';

abstract class ResataurantMenuController {
  static Future<List<RestaurantsMenu>> getRestaurantMenu(
    String restaurantId,
  ) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('menu')
        .get();
    List<RestaurantsMenu> restaurantsMenu = [];
    for (var doc in snapshot.docs) {
      if (doc["data"]["restaurant_id"] == restaurantId) {
        restaurantsMenu.add(RestaurantsMenu.fromJson(doc['data']));
      }
    }
    return restaurantsMenu;
  }
}
