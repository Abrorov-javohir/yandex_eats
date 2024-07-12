import 'package:dars75_yandexmap_restaurant/controller/restaurant_controller.dart';
import 'package:dars75_yandexmap_restaurant/models/restaurants.dart';
import 'package:dars75_yandexmap_restaurant/services/yandex_map_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  final Restaurant? restaurant;

  const MapScreen({super.key, this.restaurant});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final searchContoller = TextEditingController();
  late YandexMapController mapController;
  List<SuggestItem> suggestions = [];
  Point? selectedLocation;
  List<MapObject> mapObjects = [];
  PolylineMapObject? routePolyline;
  final Location location = Location();

  @override
  void initState() {
    super.initState();
    if (widget.restaurant != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        addMarker(widget.restaurant!);
        goToLocation(Point(
          latitude: double.parse(widget.restaurant!.address.split(', ')[0]),
          longitude: double.parse(widget.restaurant!.address.split(', ')[1]),
        ));
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<RestaurantController>(context).addListener(_updateMarkers);
  }

  @override
  void dispose() {
    Provider.of<RestaurantController>(context, listen: false)
        .removeListener(_updateMarkers);
    super.dispose();
  }

  void _updateMarkers() {
    setState(() {
      final controller =
          Provider.of<RestaurantController>(context, listen: false);
      final restaurantIds = controller.list.map((e) => e.id).toSet();
      mapObjects
          .removeWhere((marker) => !restaurantIds.contains(marker.mapId.value));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          YandexMap(
            onMapCreated: onMapCreated,
            onCameraPositionChanged: onCameraPositionChanged,
            mapObjects: mapObjects,
          ),
          if (selectedLocation != null)
            Align(
              child: Image.asset(
                "assets/location_icon.png",
                width: 50,
              ),
            ),
          Align(
            alignment: const Alignment(0, -0.8),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  TextField(
                    controller: searchContoller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: getSearchSuggestions,
                  ),
                  Container(
                    constraints: BoxConstraints(
                      maxHeight:
                          (70 * suggestions.length).clamp(0, 300).toDouble(),
                    ),
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: ListView.builder(
                      itemCount: suggestions.length,
                      itemExtent: 60,
                      itemBuilder: (ctx, index) {
                        final suggestion = suggestions[index];
                        return ListTile(
                          onTap: () {
                            goToLocation(suggestion.center);
                          },
                          title: Text(suggestion.displayText),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _showAddRestaurantDialog,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          if (widget.restaurant != null)
            FloatingActionButton(
              onPressed: showRouteToRestaurant,
              child: const Icon(Icons.directions),
            ),
        ],
      ),
    );
  }

  void onMapCreated(YandexMapController controller) async {
    mapController = controller;
    await mapController.toggleUserLayer(
      visible: true,
      headingEnabled: true,
      autoZoomEnabled: true,
    );
    setState(() {});
  }

  void onCameraPositionChanged(
    CameraPosition position,
    CameraUpdateReason reason,
    bool finished,
  ) {
    if (reason == CameraUpdateReason.gestures) {
      setState(() {
        selectedLocation = position.target;
      });
    }
  }

  void getSearchSuggestions(String address) async {
    suggestions = await YandexMapService.getSearchSuggestions(address);
    setState(() {});
  }

  void goToLocation(Point? location) async {
    if (location != null) {
      setState(() {
        selectedLocation = location;
        suggestions = [];
      });
      await mapController.moveCamera(
        animation: const MapAnimation(
          type: MapAnimationType.smooth,
        ),
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: location,
            zoom: 15,
          ),
        ),
      );
    }
  }

  void addMarker(Restaurant restaurant) {
    try {
      final point = Point(
        latitude: double.parse(restaurant.address.split(', ')[0]),
        longitude: double.parse(restaurant.address.split(', ')[1]),
      );
      final placemark = PlacemarkMapObject(
        mapId: MapObjectId(restaurant.id),
        point: point,
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: BitmapDescriptor.fromAssetImage("assets/location_icon.png"),
            scale: 0.5,
          ),
        ),
        opacity: 0.9,
      );
      setState(() {
        mapObjects.add(placemark);
      });
    } catch (e) {
      print('Error adding marker: $e');
    }
  }

  void _showAddRestaurantDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final titleController = TextEditingController();
        final imageUrlController = TextEditingController();
        final phoneController = TextEditingController();
        final ratingController = TextEditingController();
        final addressController = TextEditingController();

        return AlertDialog(
          title: Text('Add Restaurant'),
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
              ),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
                readOnly: true,
                onTap: () {
                  if (selectedLocation != null) {
                    addressController.text =
                        "${selectedLocation!.latitude}, ${selectedLocation!.longitude}";
                  }
                },
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
                final restaurant = Restaurant(
                  id: UniqueKey().toString(),
                  title: titleController.text,
                  imageUrl: imageUrlController.text,
                  phone: phoneController.text,
                  rating: double.tryParse(ratingController.text) ?? 0,
                  address: addressController.text,
                );
                Provider.of<RestaurantController>(context, listen: false)
                    .addRestaurant(restaurant);
                addMarker(restaurant);
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showRouteToRestaurant() async {
    if (widget.restaurant != null) {
      final currentLocation = await location.getLocation();
      final startLocation = Point(
        latitude: currentLocation.latitude!,
        longitude: currentLocation.longitude!,
      );
      final endLocation = Point(
        latitude: double.parse(widget.restaurant!.address.split(', ')[0]),
        longitude: double.parse(widget.restaurant!.address.split(', ')[1]),
      );

      final routes = await YandexMapService.getDirection(
        startLocation,
        endLocation,
      );

      setState(() {
        if (routePolyline != null) {
          mapObjects.remove(routePolyline!);
        }
        if (routes.isNotEmpty) {
          routePolyline = routes.first;
          mapObjects.add(routePolyline!);
        }
      });

      await mapController.moveCamera(
        animation: const MapAnimation(
          type: MapAnimationType.smooth,
        ),
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: startLocation,
            zoom: 14,
          ),
        ),
      );
    }
  }
}