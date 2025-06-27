import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearby_toilet_finder/screens/home_screen.dart';
import 'package:nearby_toilet_finder/widgets/login.dart';
import 'package:nearby_toilet_finder/services/location_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  Position? _position;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final position = await LocationService.getCurrentLocation();
    setState(() {
      _position = position;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = FirebaseAuth.instance.currentUser;
    return user != null
        ? HomeScreen(position: _position!)
        : const LoginScreen();
  }
}
