import 'package:dars75_yandexmap_restaurant/models/restaurants.dart';
import 'package:flutter/material.dart';

class RestaurantController with ChangeNotifier {
  List<Restaurant> _list = [];

  List<Restaurant> get list {
    return [..._list];
  }

  void addRestaurant(Restaurant restaurant) {
    _list.add(restaurant);
    notifyListeners();
  }

  void removeRestaurant(String id) {
    _list.removeWhere((restaurant) => restaurant.id == id);
    notifyListeners();
  }
    void updateRestaurant(Restaurant updatedRestaurant) {
    final index = _list.indexWhere((restaurant) => restaurant.id == updatedRestaurant.id);
    if (index != -1) {
      _list[index] = updatedRestaurant;
      notifyListeners();
    }
  }
}
