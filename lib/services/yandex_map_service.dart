import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class YandexMapService {
  static Future<List<SuggestItem>> getSearchSuggestions(String address) async {
    final result = await YandexSuggest.getSuggestions(
      text: address,
      boundingBox: const BoundingBox(
        northEast: Point(
          latitude: 0,
          longitude: 0,
        ),
        southWest: Point(
          latitude: 0,
          longitude: 0,
        ),
      ),
      suggestOptions: const SuggestOptions(
        suggestType: SuggestType.geo,
      ),
    );

    final suggestionResult = await result.$2;

    if (suggestionResult.error != null) {
      print("Manzil topilmadi");
      return [];
    }

    return suggestionResult.items ?? [];
  }

  static Future<List<PolylineMapObject>> getDirection(Point from, Point to) async {
    final result = await YandexPedestrian.requestRoutes(
      points: [
        RequestPoint(point: from, requestPointType: RequestPointType.wayPoint),
        RequestPoint(point: to, requestPointType: RequestPointType.wayPoint),
      ],
      avoidSteep: true,
      timeOptions: TimeOptions(),
    );

    final drivingResults = await result.$2;

    if (drivingResults.error != null) {
      print("Yo'lni ololmadi");
      return [];
    }

    return drivingResults.routes!.map((route) {
      return PolylineMapObject(
        mapId: MapObjectId(UniqueKey().toString()),
        polyline: route.geometry,
        strokeColor: Colors.orange,
        strokeWidth: 5,
      );
    }).toList();
  }
}
