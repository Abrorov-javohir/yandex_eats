import 'package:dars75_yandexmap_restaurant/controller/restaurant_controller.dart';
import 'package:dars75_yandexmap_restaurant/models/restaurants.dart';
import 'package:dars75_yandexmap_restaurant/views/screens/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class RestaurantsScreen extends StatefulWidget {
  const RestaurantsScreen({super.key});

  @override
  State<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Consumer<RestaurantController>(
        builder: (context, controller, child) {
          final restaurants = controller.list;

          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (ctx, index) {
              final restaurant = restaurants[index];
              return Slidable(
                startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        controller.removeRestaurant(restaurant.id);
                      },
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                    SlidableAction(
                      onPressed: (context) {
                        _showEditRestaurantDialog(context, restaurant);
                      },
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: 'Edit',
                    ),
                  ],
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      restaurant.imageUrl,
                    ),
                  ),
                  title: Text(restaurant.title),
                  subtitle: Text(restaurant.address),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) {
                          return MapScreen(restaurant: restaurant);
                        },
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) {
                return const MapScreen();
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showEditRestaurantDialog(BuildContext context, Restaurant restaurant) {
    final titleController = TextEditingController(text: restaurant.title);
    final imageUrlController = TextEditingController(text: restaurant.imageUrl);
    final phoneController = TextEditingController(text: restaurant.phone);
    final ratingController = TextEditingController(text: restaurant.rating.toString());
    final addressController = TextEditingController(text: restaurant.address);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Restaurant'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: imageUrlController,
                decoration: InputDecoration(labelText: 'Image URL'),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                controller: ratingController,
                decoration: InputDecoration(labelText: 'Rating'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final updatedTitle = titleController.text;
                final updatedImageUrl = imageUrlController.text;
                final updatedPhone = phoneController.text;
                final updatedRating = double.tryParse(ratingController.text) ?? 0;
                final updatedAddress = addressController.text;

                setState(() {
                  restaurant.update(
                    title: updatedTitle,
                    imageUrl: updatedImageUrl,
                    phone: updatedPhone,
                    rating: updatedRating,
                    address: updatedAddress,
                  );
                });

                Provider.of<RestaurantController>(context, listen: false).updateRestaurant(restaurant);

                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}