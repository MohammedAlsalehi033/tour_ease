import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class TripPlannerPage extends StatefulWidget {
  const TripPlannerPage({Key? key}) : super(key: key);

  @override
  _TripPlannerPageState createState() => _TripPlannerPageState();
}

class _TripPlannerPageState extends State<TripPlannerPage> {
  // Form controllers
  final _destinationController = TextEditingController();
  final _pickupController = TextEditingController();
  final _budgetController = TextEditingController();
  final _specialRequirementsController = TextEditingController();

  // Selected date range
  DateTimeRange? _selectedDateRange;

  // Activities selection
  final Map<String, bool> _activities = {
    'Sightseeing': false,
    'Outdoor Adventures': false,
    'Museums & Culture': false,
    'Food & Dining': false,
    'Shopping': false,
    'Nightlife': false,
    'Relaxation': false,
    'Beach': false,
  };

  // Travel preferences
  String _travelMode = 'Any';
  final List<String> _travelModes = ['Any', 'Air', 'Train', 'Car', 'Public Transport'];

  int _travelersCount = 1;

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
                            title: _selectedDateRange != null
                                ? '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}'
                                : 'Select dates',
                            onTap: () {
                              // Date selection would go here in real implementation
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
                            suffixText: 'USD',
                            theme: theme,
                          ),
                          SizedBox(height: 32.h),

                          // Travelers counter
                          _buildSectionTitle('How many travelers?', theme),
                          _buildCounterTile(
                            title: 'Travelers',
                            value: _travelersCount,
                            onDecrease: () {
                              // Decrease logic would go here
                            },
                            onIncrease: () {
                              // Increase logic would go here
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
                              // Travel mode selection would go here
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
                          TextField(
                            controller: _specialRequirementsController,
                            decoration: InputDecoration(
                              hintText: 'E.g., accessibility needs, dietary restrictions, etc.',
                              hintStyle: textTheme.bodyMedium,
                              contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(color: colorScheme.outline),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: colorScheme.outline),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: colorScheme.primary),
                              ),
                            ),
                            maxLines: 3,
                            cursorColor: colorScheme.primary,
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
                      onPressed: () {
                        // Reset form would go here
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
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
                    child: ElevatedButton(
                      onPressed: () {
                        // Generate trip plan would go here
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        textStyle: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      child: const Text('Generate My Trip Plan'),
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
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: theme.textTheme.bodyMedium,
        prefixIcon: Icon(prefixIcon, color: theme.colorScheme.onSurface.withOpacity(0.7)),
        suffixText: suffixText,
        contentPadding: EdgeInsets.symmetric(vertical: 16.h),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
      ),
      cursorColor: theme.colorScheme.primary,
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
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: theme.colorScheme.outline),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20.sp,
              color: theme.colorScheme.onSurface,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: title.contains('Select')
                      ? theme.colorScheme.onSurface.withOpacity(0.6)
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20.sp,
              color: theme.colorScheme.outline,
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
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outline),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
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
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
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
      child: Container(
        width: 32.w,
        height: 32.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color:
            enabled ? theme.colorScheme.primary : theme.colorScheme.outline,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 16.sp,
          color:
          enabled ? theme.colorScheme.primary : theme.colorScheme.outline,
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
            // Selection logic would go here
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