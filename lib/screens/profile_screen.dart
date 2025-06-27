import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nearby_toilet_finder/constants/colors.dart';
import 'package:nearby_toilet_finder/google_sign_in_service.dart';
import 'package:nearby_toilet_finder/screens/edit_profile_screen.dart';
import 'package:nearby_toilet_finder/widgets/login.dart';
import 'package:nearby_toilet_finder/services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }
    final data = await ApiService.fetchUserProfile(user.uid);
    setState(() {
      _userData = data;
      _loading = false;
    });
  }

  void _handleLogout(BuildContext context) async {
    await GoogleSignInService().signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final bool isGuest = user == null;
    final String displayName = isGuest
        ? 'Guest'
        : (_userData?['name'] ?? user.displayName ?? 'No Name');
    final String email = isGuest
        ? 'Not available'
        : (_userData?['email'] ?? user.email ?? 'No Email');
    final String preferences =
        _userData?['preferences'] ?? 'Accessibility, Cleanliness';
    final String bio = _userData?['bio'] ?? '';
    final ImageProvider avatar = isGuest
        ? const AssetImage('assets/avatar.png')
        : (_userData?['photoUrl'] != null && _userData?['photoUrl'] != ''
              ? NetworkImage(_userData!['photoUrl'])
              : (user.photoURL != null
                    ? NetworkImage(user.photoURL!)
                    : const AssetImage('assets/avatar.png') as ImageProvider));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header with profile background
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      color: AppColors.navyBlue,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Profile Avatar with shadow
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 46,
                                backgroundImage: avatar,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Profile Details Card
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      shadowColor: AppColors.yellow.withOpacity(0.2),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildProfileDetailItem(
                              icon: Icons.person_outline,
                              title: 'Account Type',
                              value: isGuest ? 'Guest' : 'Registered User',
                            ),
                            const Divider(height: 30),
                            _buildProfileDetailItem(
                              icon: Icons.settings_outlined,
                              title: 'Preferences',
                              value: preferences,
                            ),
                            const Divider(height: 30),
                            _buildProfileDetailItem(
                              icon: Icons.info_outline,
                              title: 'Bio',
                              value: bio.isNotEmpty ? bio : 'No bio provided',
                            ),
                            const Divider(height: 30),
                            _buildProfileDetailItem(
                              icon: Icons.star_outline,
                              title: 'Favorite Locations',
                              value: '3 saved',
                              showBadge: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        if (!isGuest)
                          _buildActionButton(
                            context,
                            icon: Icons.edit,
                            label: 'Edit Profile',
                            color: AppColors.skyBlue,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditProfileScreen(firebaseUser: user!),
                                ),
                              ).then((_) => _fetchUserData());
                            },
                          ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          context,
                          icon: Icons.settings,
                          label: 'Settings',
                          color: AppColors.magenta,
                          onPressed: () {},
                        ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          context,
                          icon: isGuest ? Icons.login : Icons.logout,
                          label: isGuest ? 'Sign In' : 'Sign Out',
                          color: isGuest ? AppColors.green : AppColors.red,
                          onPressed: () {
                            if (!isGuest) {
                              _handleLogout(context);
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  // App Version Info
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Nammaloo v1.0.0',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileDetailItem({
    required IconData icon,
    required String title,
    required String value,
    bool showBadge = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.deepPurple),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (showBadge)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'New',
                        style: TextStyle(
                          color: Colors.amber[800],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: Colors.grey[400]),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: color,
          backgroundColor: color.withOpacity(0.1),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
