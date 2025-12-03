import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:tour_ease/bloc/rideFilterBloc.dart';
import 'package:tour_ease/bloc/rideResultsBloc.dart';
import 'package:tour_ease/view/mapscreen/mappage.dart';
import 'package:tour_ease/view/rideSharing/RideResultsPage.dart';
import 'package:tour_ease/view/rideSharing/transportationProviderScreens/newTransportProviderPage.dart';

class RideFilterPage extends StatefulWidget {
  const RideFilterPage({Key? key}) : super(key: key);

  @override
  _RideFilterPageState createState() => _RideFilterPageState();
}

class _RideFilterPageState extends State<RideFilterPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BlocBuilder<RideFilterBloc, RideFilterState>(
      builder: (context, state) {
        return Scaffold(appBar: AppBar(title: Text("Driver Tap"),actions: [IconButton(onPressed: ()  async {
           Navigator.push(context, MaterialPageRoute(builder: (context) => NewTransportationProviderPage(),));
        }, icon: Icon(Icons.add))],),
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

                              // Pickup Location
                              _buildSectionTitle('Where from?', theme),
                              _buildSelectionTile(
                                icon: Icons.trip_origin,
                                title: state.filterModel.pickupLocation.isEmpty
                                    ? 'Select pickup location'
                                    : state.filterModel.pickupLocation,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => MapScreen()),
                                ),
                                theme: theme,
                              ),
                              SizedBox(height: 24.h),

                              // Destination
                              _buildSectionTitle('Where to?', theme),
                              _buildSelectionTile(
                                icon: Icons.location_on,
                                title: state.filterModel.destination.isEmpty
                                    ? 'Select destination'
                                    : state.filterModel.destination,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => MapScreen()),
                                ),
                                theme: theme,
                              ),
                              SizedBox(height: 32.h),

                              // Date Selection
                              _buildSectionTitle('When?', theme),
                              _buildSelectionTile(
                                icon: Icons.calendar_today_outlined,
                                title: state.filterModel.selectedDate == null
                                    ? 'Any date'
                                    : '${state.filterModel.selectedDate!.day}/${state.filterModel.selectedDate!.month}/${state.filterModel.selectedDate!.year}',
                                onTap: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (dialogContext) {
                                      final rideFilterBloc =
                                          context.read<RideFilterBloc>();

                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16.r),
                                        ),
                                        child: SfDateRangePicker(
                                          selectionMode:
                                              DateRangePickerSelectionMode
                                                  .single,
                                          initialSelectedDate: state
                                                  .filterModel.selectedDate ??
                                              DateTime.now(),
                                          minDate: DateTime.now(),
                                          maxDate: DateTime.now()
                                              .add(const Duration(days: 90)),
                                          onSelectionChanged:
                                              (DateRangePickerSelectionChangedArgs
                                                  args) {
                                            // Use the captured bloc instance
                                            rideFilterBloc
                                                .add(UpdateDate(args.value));
                                            Navigator.pop(dialogContext);
                                          },
                                          headerStyle:
                                              DateRangePickerHeaderStyle(
                                            textStyle: textTheme.titleMedium
                                                ?.copyWith(
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                          monthCellStyle:
                                              DateRangePickerMonthCellStyle(
                                            todayTextStyle: TextStyle(
                                              color: colorScheme.onSurface,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            todayCellDecoration:
                                                BoxDecoration(
                                              color:
                                                  colorScheme.surfaceVariant,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          selectionColor: colorScheme.primary,
                                        ),
                                      );
                                    },
                                  );
                                },
                                theme: theme,
                              ),
                              SizedBox(height: 32.h),

                              // Time Range
                              _buildSectionTitle('Time', theme),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildSelectionTile(
                                      icon: Icons.access_time,
                                      title: state.filterModel.startTime
                                          .format(context),
                                      onTap: () async {
                                        Navigator.of(context).push(
                                          showPicker(
                                            themeData: Theme.of(context),
                                            context: context,
                                            value:
                                                state.filterModel.startTime,
                                            sunrise:
                                                TimeOfDay(hour: 6, minute: 0),
                                            sunset: TimeOfDay(
                                                hour: 18, minute: 0),
                                            duskSpanInMinutes: 120,
                                            onChange: (newTime) {
                                              context
                                                  .read<RideFilterBloc>()
                                                  .add(UpdateStartTime(
                                                      newTime));
                                            },
                                          ),
                                        );
                                      },
                                      theme: theme,
                                    ),
                                  ),
                                  SizedBox(width: 20.w),
                                  Expanded(
                                    child: _buildSelectionTile(
                                      icon: Icons.access_time,
                                      title: state.filterModel.endTime
                                          .format(context),
                                      onTap: () async {
                                        Navigator.of(context).push(
                                          showPicker(
                                            context: context,
                                            value: state.filterModel.endTime,
                                            sunrise:
                                                TimeOfDay(hour: 6, minute: 0),
                                            sunset: TimeOfDay(
                                                hour: 18, minute: 0),
                                            duskSpanInMinutes: 120,
                                            onChange: (newTime) {
                                              context
                                                  .read<RideFilterBloc>()
                                                  .add(
                                                      UpdateEndTime(newTime));
                                            },
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
                              _buildSectionTitle('Price range (PKR)', theme),
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'PKR ${state.filterModel.priceRange.start.round()}',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    'PKR ${state.filterModel.priceRange.end.round()}',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              SliderTheme(
                                data: SliderThemeData(
                                  activeTrackColor: colorScheme.primary,
                                  inactiveTrackColor:
                                      colorScheme.surfaceVariant,
                                  thumbColor: colorScheme.surface,
                                  thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 12.r,
                                    elevation: 2,
                                  ),
                                  overlayColor:
                                      colorScheme.primary.withOpacity(0.1),
                                ),
                                child: RangeSlider(
                                  values: state.filterModel.priceRange,
                                  min: 500,
                                  max: 20000,
                                  divisions: 39,
                                  labels: RangeLabels(
                                    'PKR ${state.filterModel.priceRange.start.round()}',
                                    'PKR ${state.filterModel.priceRange.end.round()}',
                                  ),
                                  onChanged: (RangeValues values) {
                                    context
                                        .read<RideFilterBloc>()
                                        .add(UpdatePriceRange(values));
                                  },
                                ),
                              ),
                              SizedBox(height: 32.h),

                              // Passengers
                              _buildSectionTitle('Passengers', theme),
                              _buildCounterTile(
                                title: 'Travelers',
                                value: state.filterModel.numberOfTravelers,
                                onDecrease: () {
                                  context
                                      .read<RideFilterBloc>()
                                      .add(DecrementTravelers());
                                },
                                onIncrease: () {
                                  context
                                      .read<RideFilterBloc>()
                                      .add(IncrementTravelers());
                                },
                                theme: theme,
                              ),
                              SizedBox(height: 16.h),

                              // Luggage
                              _buildCounterTile(
                                title: 'Luggage',
                                value: state.filterModel.luggageCapacity,
                                onDecrease: () {
                                  context
                                      .read<RideFilterBloc>()
                                      .add(DecrementLuggage());
                                },
                                onIncrease: () {
                                  context
                                      .read<RideFilterBloc>()
                                      .add(IncrementLuggage());
                                },
                                theme: theme,
                              ),
                              SizedBox(
                                  height:
                                      100.h),
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
                          onPressed: state.isLoading
                              ? null
                              : () {
                                  context
                                      .read<RideFilterBloc>()
                                      .add(ResetFilters());
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
                        child: ElevatedButton.icon(
                          onPressed: state.isLoading
                              ? null
                              : () {
                                  context.read<RideResultBloc>().add(
                                      FetchRideResults(
                                          filterModel: state.filterModel));


                                  context
                                      .read<RideFilterBloc>()
                                      .add(ApplyFilters());


                                  Navigator.push(context  , MaterialPageRoute(builder: (context) => RideResultsPage(),)).then((_){
                                    setState(() {

                                    });
                                  });
                                },
                          icon: state.isLoading
                              ? SizedBox(
                                  height: 20.h,
                                  width: 20.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        colorScheme.onPrimary),
                                  ),
                                )
                              : Icon(Icons.search, size: 20.sp),
                          label: Text(
                            'Show results',
                            style: textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            elevation: 2,
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            disabledBackgroundColor:
                                colorScheme.primary.withOpacity(0.6),
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
      },
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
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: title.contains('Any') ||
                          title.contains('time') && !title.contains(':')
                      ? theme.colorScheme.onSurface.withOpacity(0.5)
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20.sp,
              color: theme.colorScheme.onSurfaceVariant,
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
      margin: EdgeInsets.only(bottom: 12.h),
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
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
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
              SizedBox(width: 16.w),
              Text(
                '$value',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(width: 16.w),
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
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        width: 36.w,
        height: 36.h,
        decoration: BoxDecoration(
          color: enabled 
              ? theme.colorScheme.primary.withOpacity(0.1) 
              : theme.colorScheme.surfaceVariant,
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          size: 18.sp,
          color: enabled ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
        ),
      ),
    );
  }
}
