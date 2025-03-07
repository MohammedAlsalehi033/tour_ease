import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
class RideFilterPage extends StatefulWidget {
  const RideFilterPage({Key? key}) : super(key: key);

  @override
  _RideFilterPageState createState() => _RideFilterPageState();
}

class _RideFilterPageState extends State<RideFilterPage> {
  DateTime? _selectedDate;
  Time _startTime = Time(hour: 11, minute: 30, second: 20);
  Time _endTime = Time(hour: 11, minute: 30, second: 20);
  int _numberOfTravelers = 1;
  int _luggageCapacity = 1;
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  bool _isLoading = false;

  // Price range filter
  RangeValues _priceRange = const RangeValues(20, 100);

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _applyFilters() {


  }

  void _resetFilters() {
    setState(() {
      _selectedDate = null;
      _numberOfTravelers = 1;
      _luggageCapacity = 1;
      _pickupController.clear();
      _destinationController.clear();
      _priceRange = const RangeValues(20, 100);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    void onTimeChanged(Time newTime) {
      setState(() {
        _startTime = newTime;
      });
    }
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Filters',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        leading: IconButton(
          icon: Icon(Icons.close, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: Text(
              'Clear all',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Main scrolling content
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

                          // Pickup Location
                          _buildSectionTitle('Where from?', theme),
                          _buildMinimalTextField(
                            controller: _pickupController,
                            hintText: 'Add pickup location',
                            theme: theme,
                          ),
                          SizedBox(height: 24.h),

                          // Destination
                          _buildSectionTitle('Where to?', theme),
                          _buildMinimalTextField(
                            controller: _destinationController,
                            hintText: 'Add destination',
                            theme: theme,
                          ),
                          SizedBox(height: 32.h),

                          // Date Selection
                          _buildSectionTitle('When?', theme),
                          _buildSelectionTile(
                            icon: Icons.calendar_today_outlined,
                            title: _selectedDate == null
                                ? 'Any date'
                                : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                            onTap: () async {
                              await showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Container(
                                    height: 380.h,
                                    padding: EdgeInsets.all(16.w),
                                    child: Column(
                                      children: [
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: IconButton(
                                            icon: Icon(Icons.close, color: colorScheme.onSurface),
                                            onPressed: () => Navigator.pop(context),
                                          ),
                                        ),
                                        Expanded(
                                          child: SfDateRangePicker(
                                            selectionMode: DateRangePickerSelectionMode.single,
                                            initialSelectedDate: _selectedDate ?? DateTime.now(),
                                            minDate: DateTime.now(),
                                            maxDate: DateTime.now().add(const Duration(days: 90)),
                                            onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                                              setState(() {
                                                _selectedDate = args.value;
                                              });
                                              Navigator.pop(context);
                                            },
                                            headerStyle: DateRangePickerHeaderStyle(
                                              textStyle: textTheme.titleMedium?.copyWith(
                                                color: colorScheme.onSurface,
                                              ),
                                            ),
                                            monthCellStyle: DateRangePickerMonthCellStyle(
                                              todayTextStyle: TextStyle(
                                                color: colorScheme.onSurface,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              todayCellDecoration: BoxDecoration(
                                                color: colorScheme.surfaceVariant,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            selectionColor: colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            theme: theme,
                          ),
                          SizedBox(height: 32.h),

                          // Time Range
                          _buildSectionTitle('Time', theme),
                          Row(
                            children: [                              Expanded(
                              child: _buildSelectionTile(
                                icon: Icons.access_time,
                                title: _startTime?.format(context) ?? 'Start time',
                                onTap: () async {
                                  Navigator.of(context).push(
                                    showPicker(themeData: Theme.of(context),
                                      context: context,
                                      value: _startTime,
                                      sunrise: TimeOfDay(hour: 6, minute: 0), // optional
                                      sunset: TimeOfDay(hour: 18, minute: 0), // optional
                                      duskSpanInMinutes: 120, // optional
                                      onChange: onTimeChanged,
                                    ),
                                  );
                                },
                                theme: theme,
                              ),
                            ),
                              SizedBox(width: 20.w,),

                              Expanded(
                                child: _buildSelectionTile(
                                  icon: Icons.access_time,
                                  title: _endTime?.format(context) ?? 'End time',
                                  onTap: () async {
                                    Navigator.of(context).push(
                                      showPicker(
                                        context: context,
                                        value: _endTime,
                                        sunrise: TimeOfDay(hour: 6, minute: 0), // optional
                                        sunset: TimeOfDay(hour: 18, minute: 0), // optional
                                        duskSpanInMinutes: 120, // optional
                                        onChange: onTimeChanged,
                                      ),
                                    );
                                  },
                                  theme: theme,
                                ),
                              ),
                              SizedBox(width: 16.w),
                            ],
                          ),
                          SizedBox(height: 32.h),

                          // Price Range
                          _buildSectionTitle('Price range', theme),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${_priceRange.start.round()}',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                '\$${_priceRange.end.round()}',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: colorScheme.primary,
                              inactiveTrackColor: colorScheme.surfaceVariant,
                              thumbColor: colorScheme.surface,
                              thumbShape: RoundSliderThumbShape(
                                enabledThumbRadius: 12.r,
                                elevation: 2,
                              ),
                              overlayColor: colorScheme.primary.withOpacity(0.1),
                            ),
                            child: RangeSlider(
                              values: _priceRange,
                              min: 0,
                              max: 200,
                              divisions: 20,
                              labels: RangeLabels(
                                '\$${_priceRange.start.round()}',
                                '\$${_priceRange.end.round()}',
                              ),
                              onChanged: (RangeValues values) {
                                setState(() {
                                  _priceRange = values;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 32.h),

                          // Passengers
                          _buildSectionTitle('Passengers', theme),
                          _buildCounterTile(
                            title: 'Travelers',
                            value: _numberOfTravelers,
                            onDecrease: () {
                              if (_numberOfTravelers > 1) {
                                setState(() {
                                  _numberOfTravelers--;
                                });
                              }
                            },
                            onIncrease: () {
                              setState(() {
                                _numberOfTravelers++;
                              });
                            },
                            theme: theme,
                          ),
                          SizedBox(height: 16.h),

                          // Luggage
                          _buildCounterTile(
                            title: 'Luggage',
                            value: _luggageCapacity,
                            onDecrease: () {
                              if (_luggageCapacity > 0) {
                                setState(() {
                                  _luggageCapacity--;
                                });
                              }
                            },
                            onIncrease: () {
                              setState(() {
                                _luggageCapacity++;
                              });
                            },
                            theme: theme,
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
              child: ElevatedButton(
                onPressed: _isLoading ? null : _applyFilters,
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
                  disabledBackgroundColor: colorScheme.primary.withOpacity(0.8),
                ),
                child: _isLoading
                    ? SizedBox(
                  height: 20.h,
                  width: 20.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                  ),
                )
                    : const Text('Show results'),
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
        style: theme.textTheme.titleMedium
      ),
    );
  }

  Widget _buildMinimalTextField({
    required TextEditingController controller,
    required String hintText,
    required ThemeData theme,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: theme.textTheme.bodyMedium,
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
                  color: title.contains('Any') || title.contains('time') && !title.contains(':')
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
                enabled: value > (title == 'Luggage' ? 0 : 1),
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
            color: enabled ? theme.colorScheme.primary : theme.colorScheme.outline,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 16.sp,
          color: enabled ? theme.colorScheme.primary : theme.colorScheme.outline,
        ),
      ),
    );
  }
}