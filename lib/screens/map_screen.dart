import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/toilet.dart';

class MapScreen extends StatelessWidget {
  final List<Toilet> toilets = [
    Toilet(
      name: "Public Toilet A",
      latitude: 37.7749,
      longitude: -122.4194,
      rating: 4.0,
      accessibility: "Wheelchair accessible",
      reviews: "Clean and spacious.",
    ),
    Toilet(
      name: "Public Toilet B",
      latitude: 37.7849,
      longitude: -122.4094,
      rating: 3.5,
      accessibility: "Not accessible",
      reviews: "Could be cleaner.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(37.7749, -122.4194),
          zoom: 14,
        ),
        markers: toilets.map((toilet) {
          return Marker(
            markerId: MarkerId(toilet.name),
            position: LatLng(toilet.latitude, toilet.longitude),
            infoWindow: InfoWindow(
              title: toilet.name,
              snippet: "${toilet.rating} stars",
            ),
          );
        }).toSet(),
      ),
    );
  }
}
