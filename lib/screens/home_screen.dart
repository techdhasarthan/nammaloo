import 'package:flutter/material.dart';
import 'package:geolocator_platform_interface/src/models/position.dart';
import 'package:nearby_toilet_finder/constants/colors.dart';
import 'package:nearby_toilet_finder/tabs/listing_tab.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import '../widgets/login.dart';
import '../google_sign_in_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required Position position});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [const ListingTab(), MapScreen(), ProfileScreen()];

  void _handleLogout(BuildContext context) async {
    await GoogleSignInService().signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Nammaloo',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.navyBlue,
        elevation: 10,
        shadowColor: AppColors.navyBlue.withOpacity(0.5),
        // Fixed the missing parenthesis here
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () => _handleLogout(context),
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.navyBlue.withOpacity(0.03),
              AppColors.navyBlue.withOpacity(0.1),
            ],
          ),
        ),
        child: _tabs[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: AppColors.navyBlue.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onTabTapped,
            selectedItemColor: AppColors.navyBlue,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            elevation: 10,
            backgroundColor: Colors.white,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: _selectedIndex == 0
                        ? AppColors.navyBlue.withOpacity(0.2)
                        : Colors.transparent,
                  ),
                  child: const Icon(Icons.list_alt_rounded),
                ),
                label: 'Listing',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: _selectedIndex == 1
                        ? AppColors.navyBlue.withOpacity(0.2)
                        : Colors.transparent,
                  ),
                  child: const Icon(Icons.map_rounded),
                ),
                label: 'Map',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: _selectedIndex == 2
                        ? AppColors.navyBlue.withOpacity(0.2)
                        : Colors.transparent,
                  ),
                  child: const Icon(Icons.person_rounded),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
