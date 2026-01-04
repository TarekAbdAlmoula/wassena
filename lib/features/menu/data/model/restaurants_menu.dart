class RestaurantsMenu {
  final String restaurantId;
  final List<Meal> meal;

  RestaurantsMenu({required this.meal, required this.restaurantId});
  factory RestaurantsMenu.fromJson(Map<String, dynamic> json) {
    return RestaurantsMenu(
      restaurantId: json["restaurant_id"],
      meal: (json['menu'] as List).map((menu) => Meal.fromJson(menu)).toList(),
    );
  }
}

class Meal {
  final String itemName;
  final String description;
  final num price;
  final String imageUrl;
  final bool availabilityStatus;

  Meal({
    required this.itemName,
    required this.description,
    required this.imageUrl,
    required this.availabilityStatus,
    required this.price,
  });
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      itemName: json['item_name'],
      description: json['description'],
      imageUrl: json['image_url'],
      availabilityStatus: json['availability_status'],
      price: json['price'],
    );
  }
}
