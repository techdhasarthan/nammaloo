import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearby_toilet_finder/mockdata/mock_toilet_data.dart';
import 'package:nearby_toilet_finder/features/near_me_page.dart';
import 'package:nearby_toilet_finder/features/open_now_page.dart';
import 'package:nearby_toilet_finder/features/top_rated_page.dart';
import 'package:nearby_toilet_finder/screens/toilet_detail_page.dart';
import 'package:nearby_toilet_finder/services/location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListingTab extends StatefulWidget {
  const ListingTab({super.key});

  @override
  State<ListingTab> createState() => _ListingTabState();
}

class _ListingTabState extends State<ListingTab> {
  String _searchQuery = '';
  String _selectedSort = 'rating';
  Set<String> _filters = {};
  List<Map<String, dynamic>> _filteredToilets = [];
  late TextEditingController _searchController;

  final List<String> sortOptions = ['rating', 'distance'];

  String _currentAddress = 'Detecting location...';
  bool _manualOverride = false;
  static bool _locationDetectedOnceGlobal = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredToilets = List.from(mockToilets);
    _loadFilters();
    _loadStoredLocation();
    if (!_locationDetectedOnceGlobal) {
      _detectLocation();
      _locationDetectedOnceGlobal = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStoredLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final storedAddress = prefs.getString('lastDetectedAddress');
    if (storedAddress != null && mounted) {
      setState(() {
        _currentAddress = storedAddress;
      });
    }
  }

  Future<void> _detectLocation() async {
    // Check and request permission
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Still denied? Notify and return
    if (permission == LocationPermission.denied) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permission denied. Using default location.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Denied forever? Open settings
    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Location permission permanently denied.'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () {
              Geolocator.openAppSettings();
            },
          ),
        ),
      );
      return;
    }

    // Permission granted -> fetch location
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    final address = await LocationService.getAddressFromPosition(position);

    if (!mounted) return;
    setState(() {
      _currentAddress = address;
      _manualOverride = false;
    });
    // Store detected location in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastDetectedAddress', address);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Location updated: $_currentAddress'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _enterManualLocation() async {
    final controller = TextEditingController();
    final input = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Enter Location'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'City or Area'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (input != null && input.trim().isNotEmpty) {
      setState(() {
        _currentAddress = input.trim();
        _manualOverride = true;
      });
      // Store manual location in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastDetectedAddress', input.trim());
    }
  }

  Future<void> _loadFilters() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchQuery = prefs.getString('searchQuery') ?? '';
      _searchController.text = _searchQuery;
      _selectedSort = prefs.getString('selectedSort') ?? 'rating';
      _filters = (prefs.getStringList('filters') ?? []).toSet();
    });
  }

  Future<void> _saveFilters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('searchQuery', _searchQuery);
    await prefs.setString('selectedSort', _selectedSort);
    await prefs.setStringList('filters', _filters.toList());
  }

  void _applyFilters() {
    List<Map<String, dynamic>> list = List.from(mockToilets);

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      list = list.where((toilet) {
        final name = toilet['name']?.toString().toLowerCase() ?? '';
        final address = toilet['address']?.toString().toLowerCase() ?? '';
        return name.contains(query) || address.contains(query);
      }).toList();
    }

    if (_filters.isNotEmpty) {
      if (_filters.contains('Free')) {
        list = list.where((toilet) => toilet['is_paid'] == 'No').toList();
      }
      if (_filters.contains('Paid')) {
        list = list.where((toilet) => toilet['is_paid'] == 'Yes').toList();
      }
      if (_filters.contains('Accessible')) {
        list = list.where((toilet) => toilet['wheelchair'] == 'Yes').toList();
      }
    }

    if (_selectedSort != 'rating') {
      list.sort((a, b) {
        final aDistance =
            double.tryParse(a['distance']?.toString().split(' ')[0] ?? '0') ??
            0;
        final bDistance =
            double.tryParse(b['distance']?.toString().split(' ')[0] ?? '0') ??
            0;
        return aDistance.compareTo(bDistance);
      });
    } else {
      list.sort((a, b) {
        final aRating = a['rating'] as num? ?? 0;
        final bRating = b['rating'] as num? ?? 0;
        return bRating.compareTo(aRating);
      });
    }

    setState(() {
      _filteredToilets = list;
    });
    _saveFilters();
  }

  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _selectedSort = 'rating';
      _filters.clear();
      _filteredToilets = List.from(mockToilets);
    });
    _saveFilters();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await _detectLocation();
        _applyFilters();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          // Location Display
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: GestureDetector(
              onTap: () async {
                final result = await showModalBottomSheet<String>(
                  context: context,
                  builder: (_) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.my_location),
                        title: const Text('Use current location'),
                        onTap: () => Navigator.pop(context, 'gps'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.edit_location),
                        title: const Text('Enter location manually'),
                        onTap: () => Navigator.pop(context, 'manual'),
                      ),
                    ],
                  ),
                );

                if (result == 'gps') {
                  await _detectLocation();
                } else if (result == 'manual') {
                  await _enterManualLocation();
                }
              },
              onLongPress: _enterManualLocation,
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _currentAddress,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.edit_location_alt,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search toilets...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _applyFilters();
              },
            ),
          ),

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Free', 'Paid', 'Accessible'].map((filter) {
                  final isSelected = _filters.contains(filter);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _filters.add(filter);
                          } else {
                            _filters.remove(filter);
                          }
                        });
                        _applyFilters();
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Sort and Reset
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: _selectedSort,
                  items: sortOptions
                      .map(
                        (opt) => DropdownMenuItem(
                          value: opt,
                          child: Text(
                            'Sort by ${opt[0].toUpperCase()}${opt.substring(1)}',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSort = value!;
                    });
                    _applyFilters();
                  },
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _resetFilters,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
              ],
            ),
          ),

          // Quick Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickAction(
                    context,
                    icon: Icons.navigation,
                    label: 'Near Me',
                    color: Colors.blue,
                    page: const NearMePage(),
                  ),
                  _buildQuickAction(
                    context,
                    icon: Icons.access_time,
                    label: 'Open Now',
                    color: Colors.green,
                    page: const OpenNowPage(),
                  ),
                  _buildQuickAction(
                    context,
                    icon: Icons.star,
                    label: 'Top Rated',
                    color: Colors.amber,
                    page: const TopRatedPage(),
                  ),
                ],
              ),
            ),
          ),

          // Toilet cards or empty message
          if (_filteredToilets.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No toilets found.'),
              ),
            )
          else
            ..._filteredToilets.map(
              (toilet) => GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ToiletDetailPage(toilet: toilet),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
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
                                  '${toilet['rating']} (${toilet['reviews']} reviews)',
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
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required Widget page,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
