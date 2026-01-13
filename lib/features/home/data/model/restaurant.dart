class Restaurant {
  final String id;
  final String name;
  final String imageUrl;
  final num rating;
  final String cuisineType;
  final String location;
  final int phoneNumber;
  final num latitude;
  final num longitude;

  Restaurant({
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.cuisineType,
    required this.location,
    required this.phoneNumber,
    required this.id,
    required this.latitude,
    required this.longitude,
  });

  factory Restaurant.fromJson({
    required Map<String, dynamic> json,
    required String id,
  }) {
    return Restaurant(
      id: id,
      name: json['name'],
      imageUrl: json['image'],
      rating: json['rating'],
      cuisineType: json['cuisine_type'],
      location: json['address'],
      phoneNumber: json['phone'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}
