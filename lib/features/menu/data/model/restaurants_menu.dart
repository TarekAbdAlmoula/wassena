class RestaurantsMenu {
  final String restaurantId;
  final List<Menu> menu;

  RestaurantsMenu({required this.menu, required this.restaurantId});
  factory RestaurantsMenu.fromJson(Map<String, dynamic> json) {
    return RestaurantsMenu(
      restaurantId: json["restaurant_id"],
      menu: (json['menu'] as List).map((menu) => Menu.fromJson(menu)).toList(),
    );
  }
}

class Menu {
  final String itemName;
  final String description;
  final num price;
  final String imageUrl;
  final bool availabilityStatus;
  Menu({
    required this.itemName,
    required this.description,
    required this.imageUrl,
    required this.availabilityStatus,
    required this.price,
  });
  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      itemName: json['item_name'],
      description: json['description'],
      imageUrl: json['image_url'],
      availabilityStatus: json['availability_status'],
      price: json['price'],
    );
  }
}
