import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../Services/ApiService.dart';
import '../../Services/accommodation/accommodation_service.dart';
import '../../model/accommodation/accommodation_model.dart';
import '../../model/userManagment/user.dart';
import 'accommodation_details_page.dart';

class AccommodationListPage extends StatefulWidget {
  const AccommodationListPage({Key? key}) : super(key: key);

  @override
  _AccommodationListPageState createState() => _AccommodationListPageState();
}

class _AccommodationListPageState extends State<AccommodationListPage> {
  late AccommodationService _accommodationService;
  List<Accommodation> _accommodations = [];
  List<Accommodation> _filteredAccommodations = [];
  bool _isLoading = true;
  bool _showFilters = false;

  // Filter controllers
  final TextEditingController _locationController = TextEditingController();
  RangeValues _priceRange = RangeValues(0, 10000);
  double _maxKnownPrice = 10000;
  int? _selectedCapacity;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  void _initializeService() async {
    final user = UserModel();
    // ACCOMMODATION FEATURE: Using deployed backend
    _accommodationService = AccommodationService(
      APIServiceNodeJS('https://api.tourease.me/api', user.id),
    );
    await _loadAccommodations();
  }

  Future<void> _loadAccommodations() async {
    setState(() => _isLoading = true);
    try {
      final accommodations = await _accommodationService.getAllAccommodations(
        page: 1,
        pageSize: 100,
      );

      // Calculate max price for filter
      if (accommodations.isNotEmpty) {
        final prices = accommodations
            .where((a) => a.maxPrice != null)
            .map((a) => a.maxPrice!)
            .toList();
        if (prices.isNotEmpty) {
          _maxKnownPrice = prices.reduce((a, b) => a > b ? a : b);
          _priceRange = RangeValues(0, _maxKnownPrice);
        }
      }

      setState(() {
        _accommodations = accommodations;
        _filteredAccommodations = accommodations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load accommodations: $e');
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredAccommodations = _accommodations.where((accommodation) {
        // Location filter
        if (_locationController.text.isNotEmpty) {
          final location = _locationController.text.toLowerCase();
          if (!accommodation.location.toLowerCase().contains(location)) {
            return false;
          }
        }

        // Price filter
        final minPrice = accommodation.minPrice ?? 0;
        final maxPrice = accommodation.maxPrice ?? double.infinity;
        if (maxPrice < _priceRange.start || minPrice > _priceRange.end) {
          return false;
        }

        // Capacity filter
        if (_selectedCapacity != null) {
          final maxCapacity = accommodation.maxCapacity ?? 0;
          if (maxCapacity < _selectedCapacity!) {
            return false;
          }
        }

        return true;
      }).toList();
      _showFilters = false;
    });
  }

  void _clearFilters() {
    setState(() {
      _locationController.clear();
      _priceRange = RangeValues(0, _maxKnownPrice);
      _selectedCapacity = null;
      _filteredAccommodations = _accommodations;
      _showFilters = false;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accommodations'),
        actions: [
          IconButton(
            icon:
                Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() => _showFilters = !_showFilters);
            },
          ),
          if (_locationController.text.isNotEmpty ||
              _priceRange.start != 0 ||
              _priceRange.end != _maxKnownPrice ||
              _selectedCapacity != null)
            IconButton(
              icon: Icon(Icons.clear_all),
              onPressed: _clearFilters,
            ),
        ],
      ),
      body: Column(
        children: [
          if (_showFilters) _buildFilterSection(),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredAccommodations.isEmpty
                    ? _buildEmptyState()
                    : _buildAccommodationList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 16.h),

          // Location Filter
          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'Location (City/Address)',
              prefixIcon: Icon(Icons.location_on),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
          ),
          SizedBox(height: 16.h),

          // Price Range Filter
          Text(
            'Price Range: PKR ${_priceRange.start.toInt()} - PKR ${_priceRange.end.toInt()}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: _maxKnownPrice,
            divisions: 20,
            labels: RangeLabels(
              'PKR ${_priceRange.start.toInt()}',
              'PKR ${_priceRange.end.toInt()}',
            ),
            onChanged: (values) {
              setState(() => _priceRange = values);
            },
          ),
          SizedBox(height: 16.h),

          // Capacity Filter
          DropdownButtonFormField<int>(
            value: _selectedCapacity,
            decoration: InputDecoration(
              labelText: 'Minimum Capacity',
              prefixIcon: Icon(Icons.people),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
            items: [1, 2, 3, 4, 5, 6, 8, 10].map((capacity) {
              return DropdownMenuItem(
                value: capacity,
                child: Text('$capacity ${capacity == 1 ? "person" : "people"}'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedCapacity = value);
            },
          ),
          SizedBox(height: 16.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearFilters,
                  child: Text('Clear'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  child: Text('Apply Filters'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccommodationList() {
    return RefreshIndicator(
      onRefresh: _loadAccommodations,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: _filteredAccommodations.length,
        itemBuilder: (context, index) {
          return _buildAccommodationCard(_filteredAccommodations[index]);
        },
      ),
    );
  }

  Widget _buildAccommodationCard(Accommodation accommodation) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AccommodationDetailsPage(
                accommodationId: accommodation.id,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: CachedNetworkImage(
                imageUrl: accommodation.mediaUrls.isNotEmpty
                    ? accommodation.mediaUrls.first
                    : 'https://via.placeholder.com/400x200?text=No+Image',
                height: 200.h,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Icon(Icons.image_not_supported, size: 48.w),
                ),
              ),
            ),

            // Details
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Rating
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          accommodation.name,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (accommodation.averageRating != null) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star, size: 16.w, color: Colors.white),
                              SizedBox(width: 4.w),
                              Text(
                                accommodation.averageRating!.toStringAsFixed(1),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16.w,
                          color: Theme.of(context).colorScheme.primary),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          accommodation.location,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Description
                  Text(
                    accommodation.description,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12.h),

                  // Price and Capacity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (accommodation.minPrice != null)
                        Text(
                          'From PKR ${accommodation.minPrice!.toStringAsFixed(0)}/night',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      if (accommodation.maxCapacity != null)
                        Row(
                          children: [
                            Icon(Icons.people,
                                size: 16.w,
                                color: Theme.of(context).colorScheme.onSurface),
                            SizedBox(width: 4.w),
                            Text(
                              'Up to ${accommodation.maxCapacity} guests',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hotel_outlined,
            size: 80.w,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            'No accommodations found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8.h),
          Text(
            'Try adjusting your filters',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: _clearFilters,
            child: Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }
}
