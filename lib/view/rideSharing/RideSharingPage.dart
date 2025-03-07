import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

class RideFilterPage extends StatefulWidget {
  @override
  _RideFilterPageState createState() => _RideFilterPageState();
}

class _RideFilterPageState extends State<RideFilterPage> {
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  int _numberOfTravelers = 1;
  int _luggageCapacity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Filter Rides',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () {
              // Clear all filters
              setState(() {
                _selectedDate = null;
                _startTime = null;
                _endTime = null;
                _numberOfTravelers = 1;
                _luggageCapacity = 1;
              });
            },
            child: Text(
              'Clear',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: AnimationLimiter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: Duration(milliseconds: 500),
                childAnimationBuilder: (widget) => SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(
                    child: widget,
                  ),
                ),
                children: [
                  // Pickup Location
                  _buildFilterCard(
                    context,
                    child: _buildFilterSection(
                      context,
                      title: 'Pickup Location',
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter pickup location',
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            TablerIcons.map_pin,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Destination
                  _buildFilterCard(
                    context,
                    child: _buildFilterSection(
                      context,
                      title: 'Destination',
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter destination',
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            TablerIcons.map_pin,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Date Picker
                  _buildFilterCard(
                    context,
                    child: _buildFilterSection(
                      context,
                      title: 'Date',
                      child: InkWell(
                        onTap: () async {
                          final selectedDate = await showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              child: Container(
                                height: 400.h,
                                child: SfDateRangePicker(
                                  selectionMode: DateRangePickerSelectionMode.single,
                                  initialSelectedDate: _selectedDate,
                                  onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                                    setState(() {
                                      _selectedDate = args.value;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          child: Row(
                            children: [
                              Icon(
                                TablerIcons.calendar,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              SizedBox(width: 16.w),
                              Text(
                                _selectedDate == null
                                    ? 'Select Date'
                                    : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                style: TextStyle(
                                  color: _selectedDate == null
                                      ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Time Range
                  _buildFilterCard(
                    context,
                    child: _buildFilterSection(
                      context,
                      title: 'Time Range',
                      child: Column(
                        children: [
                          SfRangeSlider(
                            min: 0,
                            max: 24,
                            values: SfRangeValues(
                              _startTime?.hour.toDouble() ?? 0,
                              _endTime?.hour.toDouble() ?? 24,
                            ),
                            interval: 4,
                            showTicks: true,
                            showLabels: true,
                            onChanged: (SfRangeValues values) {
                              setState(() {
                                _startTime = TimeOfDay(hour: values.start.toInt(), minute: 0);
                                _endTime = TimeOfDay(hour: values.end.toInt(), minute: 0);
                              });
                            },
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Start: ${_startTime?.format(context) ?? 'Not set'}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'End: ${_endTime?.format(context) ?? 'Not set'}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Number of Travelers
                  _buildFilterCard(
                    context,
                    child: _buildFilterSection(
                      context,
                      title: 'Number of Travelers',
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(TablerIcons.minus),
                            onPressed: () {
                              setState(() {
                                if (_numberOfTravelers > 1) _numberOfTravelers--;
                              });
                            },
                          ),
                          Text(
                            '$_numberOfTravelers',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(TablerIcons.plus),
                            onPressed: () {
                              setState(() {
                                _numberOfTravelers++;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Luggage Capacity
                  _buildFilterCard(
                    context,
                    child: _buildFilterSection(
                      context,
                      title: 'Luggage Capacity',
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(TablerIcons.minus),
                            onPressed: () {
                              setState(() {
                                if (_luggageCapacity > 1) _luggageCapacity--;
                              });
                            },
                          ),
                          Text(
                            '$_luggageCapacity',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(TablerIcons.plus),
                            onPressed: () {
                              setState(() {
                                _luggageCapacity++;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  // Apply Filters Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Apply filters and navigate back
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        elevation: 4,
                        textStyle: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Reusable Filter Section Widget
  Widget _buildFilterSection(BuildContext context, {required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        child,
      ],
    );
  }

  // Reusable Filter Card Widget
  Widget _buildFilterCard(BuildContext context, {required Widget child}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: child,
      ),
    );
  }
}