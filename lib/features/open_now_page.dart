import 'package:flutter/material.dart';
import 'package:nearby_toilet_finder/mockdata/mock_toilet_data.dart';
import 'package:nearby_toilet_finder/screens/toilet_detail_page.dart';

class OpenNowPage extends StatelessWidget {
  const OpenNowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Open Now')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: openNowToilets.length,
        itemBuilder: (context, index) {
          final toilet = openNowToilets[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ToiletDetailPage(toilet: toilet),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.network(
                      toilet['image_url'] ?? '',
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 160,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 40),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          toilet['name'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          toilet['address'] ?? 'No address',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${toilet['rating'] ?? 0} (${toilet['reviews'] ?? 0} reviews)',
                            ),
                            const Spacer(),
                            Icon(
                              Icons.circle,
                              size: 10,
                              color: toilet['status'] == 'open'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              toilet['status']?.toString().toUpperCase() ??
                                  'UNKNOWN',
                              style: TextStyle(
                                color: toilet['status'] == 'open'
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14),
                            const SizedBox(width: 4),
                            Text(toilet['distance'] ?? 'Unknown'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
