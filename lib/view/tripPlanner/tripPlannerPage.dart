import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tour_ease/controller/tripPlanner/tripPlannerBloc.dart';
import 'package:tour_ease/model/tripPlanner/tripPlannerModels.dart';
import 'package:tour_ease/view/tripPlanner/TripResultsPage.dart';

class TripPlannerPage extends StatefulWidget {
  const TripPlannerPage({Key? key}) : super(key: key);

  @override
  _TripPlannerPageState createState() => _TripPlannerPageState();
}

class _TripPlannerPageState extends State<TripPlannerPage> {
  // Form controllers with default values (PKR currency) - Working test values
  final _destinationController = TextEditingController(text: "Lahore, Pakistan");
  final _pickupController = TextEditingController(text: "Islamabad, Pakistan");
  final _budgetController = TextEditingController(text: "500000");
  final _specialRequirementsController = TextEditingController(text: "");

  // Selected date range with default values
  late DateTimeRange _selectedDateRange;

  // Activities selection with some defaults selected
  final Map<String, bool> _activities = {
    'Sightseeing': true,
    'Outdoor Adventures': false,
    'Museums & Culture': true,
    'Food & Dining': true,
    'Shopping': false,
    'Nightlife': false,
    'Relaxation': false,
    'Beach': false,
  };

  // Travel preferences with default
  String _travelMode = 'Any';
  final List<String> _travelModes = ['Any', 'Air', 'Train', 'Car', 'Public Transport'];

  int _travelersCount = 2;

  @override
  void initState() {
    super.initState();
    // Set default date range to match test data: Dec 1-5, 2025
    _selectedDateRange = DateTimeRange(
      start: DateTime(2025, 12, 1, 8, 0),
      end: DateTime(2025, 12, 5, 18, 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: AnimationLimiter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: AnimationConfiguration.toStaggeredList(
                        duration: const Duration(milliseconds: 400),
                        childAnimationBuilder: (widget) => SlideAnimation(
                          horizontalOffset: 20.0,
                          child: FadeInAnimation(
                            child: widget,
                          ),
                        ),
                        children: [
                          SizedBox(height: 16.h),

                          // Title section
                          Text(
                            "AI Trip Planner",
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "Tell us what you're looking for and we'll create a personalized itinerary for you.",
                            style: textTheme.bodyLarge,
                          ),
                          SizedBox(height: 32.h),

                          // Destination field
                          _buildSectionTitle('Where would you like to go?', theme),
                          _buildMinimalTextField(
                            controller: _destinationController,
                            hintText: 'City, Country, or Region',
                            prefixIcon: Icons.location_on_outlined,
                            theme: theme,
                          ),
                          SizedBox(height: 24.h),

                          // Starting point field
                          _buildSectionTitle('Where are you starting from?', theme),
                          _buildMinimalTextField(
                            controller: _pickupController,
                            hintText: 'Your current location',
                            prefixIcon: Icons.home_outlined,
                            theme: theme,
                          ),
                          SizedBox(height: 32.h),

                          // Date range selection
                          _buildSectionTitle('When do you want to travel?', theme),
                          _buildSelectionTile(
                            icon: Icons.calendar_today_outlined,
                            title: '${_selectedDateRange.start.day}/${_selectedDateRange.start.month} - ${_selectedDateRange.end.day}/${_selectedDateRange.end.month}',
                            onTap: () async {
                              final DateTimeRange? picked = await showDateRangePicker(
                                context: context,
                                initialDateRange: _selectedDateRange,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                                builder: (context, child) {
                                  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
                                  
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: isDarkMode 
                                        ? ColorScheme.dark(
                                            primary: colorScheme.primary,
                                            onPrimary: colorScheme.onPrimary,
                                            surface: colorScheme.surface,
                                            onSurface: colorScheme.onSurface,
                                            background: colorScheme.background,
                                            onBackground: colorScheme.onSurface,
                                          )
                                        : ColorScheme.light(
                                            primary: colorScheme.primary,
                                            onPrimary: colorScheme.onPrimary,
                                            surface: colorScheme.surface,
                                            onSurface: colorScheme.onSurface,
                                          ),
                                      textTheme: Theme.of(context).textTheme.copyWith(
                                        titleMedium: TextStyle(
                                          color: colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        labelLarge: TextStyle(
                                          color: colorScheme.onSurface,
                                        ),
                                        bodyMedium: TextStyle(
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      dialogBackgroundColor: colorScheme.surface,
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setState(() {
                                  _selectedDateRange = picked;
                                });
                              }
                            },
                            theme: theme,
                          ),
                          SizedBox(height: 32.h),

                          // Budget field
                          _buildSectionTitle('What\'s your budget?', theme),
                          _buildMinimalTextField(
                            controller: _budgetController,
                            hintText: 'Enter amount',
                            prefixIcon: Icons.attach_money_outlined,
                            suffixText: 'PKR',
                            theme: theme,
                          ),
                          SizedBox(height: 32.h),

                          // Travelers counter
                          _buildSectionTitle('How many travelers?', theme),
                          _buildCounterTile(
                            title: 'Travelers',
                            value: _travelersCount,
                            onDecrease: () {
                              if (_travelersCount > 1) {
                                setState(() {
                                  _travelersCount--;
                                });
                              }
                            },
                            onIncrease: () {
                              setState(() {
                                _travelersCount++;
                              });
                            },
                            theme: theme,
                          ),
                          SizedBox(height: 32.h),

                          // Travel mode selection
                          _buildSectionTitle('Preferred mode of transport', theme),
                          _buildSelectionTile(
                            icon: _getTravelModeIcon(_travelMode),
                            title: _travelMode,
                            onTap: () {
                              _showTravelModeSelector(context, theme);
                            },
                            theme: theme,
                          ),
                          SizedBox(height: 32.h),

                          // Activities section
                          _buildSectionTitle('What activities are you interested in?', theme),
                          SizedBox(height: 16.h),
                          _buildActivitiesGrid(theme),
                          SizedBox(height: 32.h),

                          // Special requirements field
                          _buildSectionTitle('Any special requirements?', theme),
                          Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: theme.colorScheme.outline.withOpacity(0.3),
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
                            child: TextField(
                              controller: _specialRequirementsController,
                              decoration: InputDecoration(
                                hintText: 'E.g., accessibility needs, dietary restrictions, etc.',
                                hintStyle: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.5),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 14.h,
                                ),
                                border: InputBorder.none,
                              ),
                              maxLines: 3,
                              cursorColor: colorScheme.primary,
                            ),
                          ),
                          SizedBox(height: 100.h), // Extra space for bottom button
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom fixed button container
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.onSurface.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _resetForm,
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        textStyle: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      child: const Text('Reset'),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _generateTripPlan,
                      icon: Icon(Icons.auto_awesome, size: 20.sp),
                      label: Text(
                        'Generate My Trip Plan',
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 2,
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _destinationController.text = "Lahore, Pakistan";
      _pickupController.text = "Islamabad, Pakistan";
      _budgetController.text = "900000";
      _specialRequirementsController.text = "Need hotel with gym access";

      // Reset date range
      final now = DateTime.now();
      _selectedDateRange = DateTimeRange(
        start: DateTime(now.year, now.month, now.day + 14),
        end: DateTime(now.year, now.month, now.day + 21),
      );

      // Reset activities
      for (var key in _activities.keys) {
        _activities[key] = key == 'Sightseeing' || key == 'Museums & Culture' || key == 'Food & Dining';
      }

      // Reset travel mode and travelers
      _travelMode = 'Air';
      _travelersCount = 2;
    });
  }

  void _generateTripPlan() {
    // Get selected activities
    final selectedActivities = _activities.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key.toLowerCase())
        .toList();

    // Parse budget
    final budget = double.tryParse(_budgetController.text) ?? 0.0;

    if (budget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid budget')),
      );
      return;
    }

    // Create trip plan request
    final request = TripPlanRequest(
      startLocation: _pickupController.text,
      endLocation: _destinationController.text,
      startTime: _selectedDateRange.start,
      endTime: _selectedDateRange.end,
      interests: selectedActivities,
      budget: budget,
      numberOfTravelers: _travelersCount,
      needsReturnTransport: true,
      specialRequirements: _specialRequirementsController.text.isNotEmpty
          ? _specialRequirementsController.text
          : null,
    );

    // Dispatch event to BLoC
    context.read<TripPlannerBloc>().add(GenerateTripPlan(request: request));

    // Navigate to trip results page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TripResultsPage(),
      ),
    );
  }

  void _showTravelModeSelector(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose transport mode',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            ...List.generate(
              _travelModes.length,
                  (index) => ListTile(
                leading: Icon(
                  _getTravelModeIcon(_travelModes[index]),
                  color: _travelMode == _travelModes[index]
                      ? theme.colorScheme.primary
                      : null,
                ),
                title: Text(_travelModes[index]),
                onTap: () {
                  setState(() {
                    _travelMode = _travelModes[index];
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildMinimalTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    String? suffixText,
    required ThemeData theme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
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
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: theme.colorScheme.primary,
            size: 20.sp,
          ),
          suffixText: suffixText,
          suffixStyle: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          border: InputBorder.none,
        ),
        cursorColor: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildSelectionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.3),
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
            Icon(
              icon,
              size: 20.sp,
              color: theme.colorScheme.primary,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18.sp,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterTile({
    required String title,
    required int value,
    required VoidCallback onDecrease,
    required VoidCallback onIncrease,
    required ThemeData theme,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Row(
            children: [
              _buildCircleButton(
                icon: Icons.remove,
                onTap: onDecrease,
                enabled: value > 1,
                theme: theme,
              ),
              SizedBox(width: 24.w),
              Text(
                '$value',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(width: 24.w),
              _buildCircleButton(
                icon: Icons.add,
                onTap: onIncrease,
                enabled: true,
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        width: 36.w,
        height: 36.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.colorScheme.surfaceVariant,
          border: Border.all(
            color: enabled
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          size: 18.sp,
          color: enabled
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
        ),
      ),
    );
  }

  Widget _buildActivitiesGrid(ThemeData theme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
      ),
      itemCount: _activities.length,
      itemBuilder: (context, index) {
        final activity = _activities.keys.elementAt(index);
        final isSelected = _activities[activity]!;

        return InkWell(
          onTap: () {
            setState(() {
              _activities[activity] = !isSelected;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: isSelected
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : theme.colorScheme.surface,
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Row(
              children: [
                Icon(
                  _getActivityIcon(activity),
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.7),
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    activity,
                    style: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getActivityIcon(String activity) {
    switch (activity) {
      case 'Sightseeing':
        return Icons.photo_camera_outlined;
      case 'Outdoor Adventures':
        return Icons.terrain_outlined;
      case 'Museums & Culture':
        return Icons.museum_outlined;
      case 'Food & Dining':
        return Icons.restaurant_outlined;
      case 'Shopping':
        return Icons.shopping_bag_outlined;
      case 'Nightlife':
        return Icons.nightlife_outlined;
      case 'Relaxation':
        return Icons.spa_outlined;
      case 'Beach':
        return Icons.beach_access_outlined;
      default:
        return Icons.star_outline;
    }
  }

  IconData _getTravelModeIcon(String mode) {
    switch (mode) {
      case 'Air':
        return Icons.flight_outlined;
      case 'Train':
        return Icons.train_outlined;
      case 'Car':
        return Icons.directions_car_outlined;
      case 'Public Transport':
        return Icons.directions_bus_outlined;
      default:
        return Icons.commute_outlined;
    }
  }
}