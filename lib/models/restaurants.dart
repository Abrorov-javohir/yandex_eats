import 'dart:math';

class Restaurant {
  String id;
  String title;
  String imageUrl;
  String phone;
  double rating;
  String address;

  Restaurant({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.phone,
    required this.rating,
    required this.address,
  });

  void update({
    required String title,
    required String imageUrl,
    required String phone,
    required double rating,
    required String address,
  }) {
    this.title = title;
    this.imageUrl = imageUrl;
    this.phone = phone;
    this.rating = rating;
    this.address = address;
  }
}
