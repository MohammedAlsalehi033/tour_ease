import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:tour_ease/bloc/rideFilterBloc.dart';
import 'package:tour_ease/model/rideSharing/RideFilterData.dart';
import 'package:tour_ease/view/mapscreen/mappage.dart';

class RideRequestSearchWidget extends StatefulWidget {
  final Function(RideFilterModel) onSearch;

  const RideRequestSearchWidget({
    Key? key,
    required this.onSearch,
  }) : super(key: key);

  @override
  State<RideRequestSearchWidget> createState() => _RideRequestSearchWidgetState();
}

class _RideRequestSearchWidgetState extends State<RideRequestSearchWidget> {
  // Basic search fields
  String _pickupLocation = '';
  String _destination = '';
  DateTime? _selectedDate; // Nullable - if null, don't filter by date
  LatLng? _pickupCoordinates;
  LatLng? _destinationCoordinates;

  // Advanced search fields with defaults
  bool _showAdvancedOptions = false;
  Time _startTime = Time(hour: 0, minute: 0, second: 0);
  Time _endTime = Time(hour: 23, minute: 59, second: 59);
  int _numberOfTravelers = 0; // 0 means no filter
  int _luggageCapacity = 0; // 0 means no filter
  RangeValues _priceRange = const RangeValues(0.0, 0.0); // 0 means no filter

  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _performSearch() {
    // Use Islamabad as default if no pickup coordinates are selected
    final pickupCoords = _pickupCoordinates ?? const LatLng(33.6844, 73.0479); // Islamabad
    
    print('🔍 Search initiated:');
    print('  Pickup: $_pickupLocation at $pickupCoords');
    print('  Destination: $_destination at $_destinationCoordinates');
    print('  Date: $_selectedDate');
    print('  Travelers: $_numberOfTravelers');
    print('  Luggage: $_luggageCapacity');
    print('  Budget: ${_priceRange.start} - ${_priceRange.end}');

    final filter = RideFilterModel(
      selectedDate: _selectedDate, // Can be null
      startTime: _startTime,
      endTime: _endTime,
      numberOfTravelers: _numberOfTravelers,
      luggageCapacity: _luggageCapacity,
      pickupLocation: _pickupLocation.isEmpty ? 'Islamabad (Default)' : _pickupLocation,
      destination: _destination.isEmpty ? 'Any Destination' : _destination,
      priceRange: _priceRange,
      pickupLocationCoordinates: pickupCoords,
      destinationCoordinates: _destinationCoordinates ?? const LatLng(10, 10), // Use default if not set
    );

    widget.onSearch(filter);
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showLocationSearch({required bool isPickup}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LocationSearchSheet(
        isPickup: isPickup,
        onLocationSelected: (locationName, coordinates) {
          setState(() {
            if (isPickup) {
              _pickupLocation = locationName;
              _pickupController.text = locationName;
              _pickupCoordinates = coordinates;
            } else {
              _destination = locationName;
              _destinationController.text = locationName;
              _destinationCoordinates = coordinates;
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.search, color: colorScheme.primary, size: 24.sp),
                SizedBox(width: 8.w),
                Text(
                  'Search Ride Requests',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Pickup Location
            _buildLocationField(
              controller: _pickupController,
              label: 'Pickup Location *',  // Added asterisk to show it's required
              icon: Icons.my_location,
              hint: 'Tap to select pickup location',
              onTap: () => _showLocationSearch(isPickup: true),
              onClear: () {
                setState(() {
                  _pickupLocation = '';
                  _pickupController.clear();
                  _pickupCoordinates = null;
                });
              },
              colorScheme: colorScheme,
            ),
            SizedBox(height: 12.h),

            // Destination
            _buildLocationField(
              controller: _destinationController,
              label: 'Destination (Optional)',
              icon: Icons.location_on,
              hint: 'Tap to select destination',
              onTap: () => _showLocationSearch(isPickup: false),
              onClear: () {
                setState(() {
                  _destination = '';
                  _destinationController.clear();
                  _destinationCoordinates = null;
                });
              },
              colorScheme: colorScheme,
            ),
            SizedBox(height: 16.h),

            // Map Selection Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  // Navigate to map screen
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MapScreen()),
                  );
                  
                  // Update locations from map selection if available
                  if (mounted) {
                    final state = context.read<RideFilterBloc>().state;
                    setState(() {
                      if (state.filterModel.pickupLocation.isNotEmpty &&
                          state.filterModel.pickupLocationCoordinates.latitude != 10) {
                        _pickupLocation = state.filterModel.pickupLocation;
                        _pickupController.text = state.filterModel.pickupLocation;
                        _pickupCoordinates = state.filterModel.pickupLocationCoordinates;
                      }
                      if (state.filterModel.destination.isNotEmpty &&
                          state.filterModel.destinationCoordinates.latitude != 10) {
                        _destination = state.filterModel.destination;
                        _destinationController.text = state.filterModel.destination;
                        _destinationCoordinates = state.filterModel.destinationCoordinates;
                      }
                    });
                  }
                },
                icon: Icon(Icons.map, size: 20.sp),
                label: Text(
                  'Select Locations on Map',
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(color: colorScheme.primary, width: 1.5),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // Date Selection
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: colorScheme.primary, size: 20.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date (Optional)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            _selectedDate != null
                                ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                                : 'Any Date',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _selectedDate == null
                                  ? colorScheme.onSurfaceVariant.withOpacity(0.5)
                                  : colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_selectedDate != null)
                          IconButton(
                            icon: Icon(Icons.clear, size: 20.sp),
                            onPressed: () {
                              setState(() {
                                _selectedDate = null;
                              });
                            },
                            color: colorScheme.onSurfaceVariant,
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Advanced Options Toggle
            InkWell(
              onTap: () {
                setState(() {
                  _showAdvancedOptions = !_showAdvancedOptions;
                });
              },
              child: Row(
                children: [
                  Icon(
                    _showAdvancedOptions ? Icons.expand_less : Icons.expand_more,
                    color: colorScheme.primary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Advanced Options',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Advanced Options Content
            if (_showAdvancedOptions) ...[
              SizedBox(height: 16.h),
              _buildAdvancedOptions(theme, colorScheme),
            ],

            SizedBox(height: 20.h),

            // Search Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _performSearch,
                icon: Icon(Icons.search, size: 20.sp),
                label: Text(
                  'Search Requests',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    required VoidCallback onTap,
    required VoidCallback onClear,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: IgnorePointer(
        ignoring: true, // Make the container non-interactive to prevent text selection
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: colorScheme.primary, size: 20.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      controller.text.isEmpty ? hint : controller.text,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: controller.text.isEmpty
                                ? colorScheme.onSurfaceVariant.withOpacity(0.5)
                                : colorScheme.onSurface,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IgnorePointer(
                ignoring: false, // Allow the clear button to be interactive
                child: controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: 20.sp),
                        onPressed: onClear,
                        color: colorScheme.onSurfaceVariant,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      )
                    : SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedOptions(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time Range
          Text(
            'Time Range',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildTimeSelector(
                  label: 'Start Time',
                  time: _startTime,
                  onChanged: (Time newTime) {
                    setState(() {
                      _startTime = newTime;
                    });
                  },
                  colorScheme: colorScheme,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildTimeSelector(
                  label: 'End Time',
                  time: _endTime,
                  onChanged: (Time newTime) {
                    setState(() {
                      _endTime = newTime;
                    });
                  },
                  colorScheme: colorScheme,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Number of Travelers
          Text(
            'Max Seats Needed: ${_numberOfTravelers == 0 ? 'Any' : _numberOfTravelers}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 4.h),
          Slider(
            value: _numberOfTravelers.toDouble(),
            min: 0,
            max: 20,
            divisions: 20,
            label: _numberOfTravelers == 0 ? 'Any' : _numberOfTravelers.toString(),
            activeColor: colorScheme.primary,
            onChanged: (value) {
              setState(() {
                _numberOfTravelers = value.toInt();
              });
            },
          ),
          SizedBox(height: 16.h),

          // Luggage Capacity
          Text(
            'Luggage: ${_luggageCapacity == 0 ? 'Any' : _luggageCapacity}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 4.h),
          Slider(
            value: _luggageCapacity.toDouble(),
            min: 0,
            max: 50,
            divisions: 50,
            label: _luggageCapacity == 0 ? 'Any' : _luggageCapacity.toString(),
            activeColor: colorScheme.primary,
            onChanged: (value) {
              setState(() {
                _luggageCapacity = value.toInt();
              });
            },
          ),
          SizedBox(height: 16.h),

          // Price Range
          Text(
            'Budget Range: ${_priceRange.start.toInt() == 0 && _priceRange.end.toInt() == 0 ? 'Any' : 'PKR ${_priceRange.start.toInt()} - ${_priceRange.end.toInt()}'}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 4.h),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 10000,
            divisions: 100,
            labels: RangeLabels(
              _priceRange.start.toInt().toString(),
              _priceRange.end.toInt().toString(),
            ),
            activeColor: colorScheme.primary,
            onChanged: (RangeValues values) {
              setState(() {
                _priceRange = values;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector({
    required String label,
    required Time time,
    required Function(Time) onChanged,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          showPicker(
            context: context,
            value: time,
            onChange: onChanged,
            is24HrFormat: false,
          ),
        );
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Icon(Icons.access_time, color: colorScheme.primary, size: 18.sp),
                SizedBox(width: 8.w),
                Text(
                  time.format(context),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Location Search Bottom Sheet
class _LocationSearchSheet extends StatefulWidget {
  final bool isPickup;
  final Function(String, LatLng) onLocationSelected;

  const _LocationSearchSheet({
    required this.isPickup,
    required this.onLocationSelected,
  });

  @override
  State<_LocationSearchSheet> createState() => _LocationSearchSheetState();
}

class _LocationSearchSheetState extends State<_LocationSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _suggestions = [];

  // Predefined popular locations in Pakistan
  final List<Map<String, dynamic>> _popularLocations = [
    {'name': 'Islamabad', 'coords': LatLng(33.6844, 73.0479)},
    {'name': 'Rawalpindi', 'coords': LatLng(33.5651, 73.0169)},
    {'name': 'Lahore', 'coords': LatLng(31.5497, 74.3436)},
    {'name': 'Karachi', 'coords': LatLng(24.8607, 67.0011)},
    {'name': 'Faisalabad', 'coords': LatLng(31.4504, 73.1350)},
    {'name': 'Multan', 'coords': LatLng(30.1575, 71.5249)},
    {'name': 'Peshawar', 'coords': LatLng(34.0151, 71.5249)},
    {'name': 'Quetta', 'coords': LatLng(30.1798, 66.9750)},
  ];

  @override
  void initState() {
    super.initState();
    _suggestions = _popularLocations;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchLocation(String query) {
    if (query.isEmpty) {
      setState(() {
        _suggestions = _popularLocations;
      });
      return;
    }

    setState(() {
      _suggestions = _popularLocations
          .where((location) =>
              location['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 16.h),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Icon(
                  widget.isPickup ? Icons.my_location : Icons.location_on,
                  color: colorScheme.primary,
                ),
                SizedBox(width: 12.w),
                Text(
                  widget.isPickup ? 'Select Pickup Location' : 'Select Destination',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Search field
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: TextField(
              controller: _searchController,
              onChanged: _searchLocation,
              decoration: InputDecoration(
                hintText: 'Search location...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchLocation('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                filled: true,
                fillColor: colorScheme.surfaceVariant,
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Results list
          Expanded(
            child: _suggestions.isEmpty
                ? Center(
                    child: Text(
                      'No locations found',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _suggestions.length,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemBuilder: (context, index) {
                      final location = _suggestions[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colorScheme.primaryContainer,
                          child: Icon(
                            Icons.location_on,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        title: Text(location['name']),
                        onTap: () {
                          widget.onLocationSelected(
                            location['name'],
                            location['coords'],
                          );
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
