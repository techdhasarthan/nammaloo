import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nearby_toilet_finder/constants/colors.dart';
import 'package:nearby_toilet_finder/widgets/login.dart';
import 'package:nearby_toilet_finder/widgets/review_feedback_section.dart';
import 'package:url_launcher/url_launcher.dart';

class ToiletDetailPage extends StatelessWidget {
  final Map<String, dynamic> toilet;

  const ToiletDetailPage({super.key, required this.toilet});

  @override
  Widget build(BuildContext context) {
    final additionalFeatures = [
      {'label': 'Free WiFi', 'icon': Icons.wifi, 'available': true},
      {'label': 'Parking', 'icon': Icons.local_parking, 'available': true},
      {'label': 'Emergency Call', 'icon': Icons.call, 'available': false},
    ];

    bool isUserLoggedIn() {
      return FirebaseAuth.instance.currentUser != null;
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with image
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    toilet['image_url'] ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  // Gradient overlay
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black87),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    color: Colors.black87,
                  ),
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share, color: Colors.black87),
                ),
                onPressed: () {},
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              toilet['name'] ?? 'Unnamed Location',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              toilet['address'] ?? 'No address provided',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: toilet['status'] == 'open'
                              ? AppColors.green
                              : AppColors.red,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          toilet['status'] == 'open' ? 'OPEN NOW' : 'CLOSED',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Rating and distance
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppColors.yellow,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${toilet['rating'] ?? '0.0'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ' (${toilet['reviews'] ?? '0'} reviews)',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.blue[600],
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              toilet['distance'] ?? 'Unknown',
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final lat = toilet['latitude'];
                            final lng = toilet['longitude'];
                            final uri = Uri.parse(
                              'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
                            );
                            launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          },

                          icon: const Icon(Icons.directions, size: 20),
                          label: const Text("Get Directions"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.navyBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            try {
                              final phone =
                                  toilet['phone'] ??
                                  toilet['contact_information'];
                              if (phone == null || phone.toString().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Phone number not available'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }

                              String cleanPhone = phone.toString().replaceAll(
                                RegExp(r'\s+'),
                                '',
                              );
                              if (!cleanPhone.startsWith('+') &&
                                  !cleanPhone.startsWith('0')) {
                                cleanPhone = '+$cleanPhone';
                              }

                              await _launchPhoneDialer(cleanPhone);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString().replaceFirst(
                                      'Exception: ',
                                      '',
                                    ), // clean up error text
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.call, size: 20),
                          label: const Text("Call"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.navyBlue,
                            side: const BorderSide(color: AppColors.navyBlue),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Features section
                  const Text(
                    "Features & Amenities",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (toilet['features'] as List<dynamic>? ?? [])
                        .map(
                          (f) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              f.toString(),
                              style: TextStyle(color: Colors.grey[800]),
                            ),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 32),

                  // Location Details
                  const Text(
                    "Location Details",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey[200]!, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            'Division',
                            toilet['division'] ?? 'Not Available',
                          ),
                          _buildInfoRow(
                            'Zone',
                            toilet['zone'] ?? 'Not Available',
                          ),
                          _buildInfoRow(
                            'Landmark',
                            toilet['landmark'] ?? 'Not Available',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Operational Information
                  const Text(
                    "Operational Information",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey[200]!, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            'Operational Hours',
                            toilet['operational_hours'] ?? 'Not Available',
                          ),
                          _buildInfoRow(
                            'Cleanliness Status',
                            toilet['cleanliness_status'] ?? 'Not Available',
                          ),
                          _buildInfoRow(
                            'Maintenance Schedule',
                            toilet['maintenance_schedule'] ?? 'Not Available',
                          ),
                          _buildInfoRow(
                            'Contact Information',
                            toilet['contact_information'] ?? 'Not Available',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Additional services
                  const Text(
                    "Additional Services",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey[200]!, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: additionalFeatures.map((feature) {
                          return ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: feature['available'] as bool
                                    ? const Color.fromARGB(255, 169, 236, 172)
                                    : const Color.fromARGB(255, 240, 177, 176),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                feature['icon'] as IconData?,
                                color: feature['available'] as bool
                                    ? Colors.green
                                    : Colors.red,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              feature['label'].toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: feature['available'] as bool
                                    ? Colors.green[50]
                                    : Colors.red[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                feature['available'] as bool
                                    ? 'Available'
                                    : 'Unavailable',
                                style: TextStyle(
                                  color: feature['available'] as bool
                                      ? Colors.green[800]
                                      : Colors.red[800],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Working hours
                  const Text(
                    "Working Hours",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey[200]!, width: 1),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.access_time,
                        color: AppColors.navyBlue,
                      ),
                      title: Text(
                        toilet['operational_hours'] ?? "Open 24 Hours",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        toilet['operational_hours'] != null
                            ? "Check operational hours above"
                            : "Available all day, every day",
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ReviewFeedbackSection(
                    isUserLoggedIn: isUserLoggedIn(),
                    onRequireLogin: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LoginScreen()),
                      );
                    },
                    onSubmit: (rating, reviewText) {
                      // You can send this to your backend
                      print('User rated: $rating');
                      print('Review: $reviewText');
                    },
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchPhoneDialer(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch phone dialer';
    }
  }
}
