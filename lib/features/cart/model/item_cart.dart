class ItemCart {
  final String restaurantId;
  final String itemName;
  final num price;
  final num qty;
  final String imageUrl;
  ItemCart({
    required this.restaurantId,
    required this.itemName,
    required this.price,
    required this.imageUrl,
    required this.qty,
  });
}
