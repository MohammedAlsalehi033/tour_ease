import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:tour_ease/bloc/rideFilterBloc.dart';
import 'package:tour_ease/bloc/rideResultsBloc.dart';
import 'package:tour_ease/model/rideSharing/rideRepository.dart';
import 'package:tour_ease/view/rideSharing/RideResultsPage.dart';
import 'package:tour_ease/view/rideSharing/newTransportProviderPage.dart';

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
        return Scaffold(appBar: AppBar(title: Text("join as a driver"),actions: [IconButton(onPressed: () {
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
                              _buildMinimalTextField(
                                controller: context
                                    .read<RideFilterBloc>()
                                    .pickupController,
                                hintText: 'Add pickup location',
                                theme: theme,
                              ),
                              SizedBox(height: 24.h),

                              // Destination
                              _buildSectionTitle('Where to?', theme),
                              _buildMinimalTextField(
                                controller: context
                                    .read<RideFilterBloc>()
                                    .destinationController,
                                hintText: 'Add destination',
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
                                  // When showing the dialog, pass your existing bloc instance directly
                                  await showDialog(
                                    context: context,
                                    builder: (dialogContext) {
                                      // Capture the bloc from the original context
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
                              _buildSectionTitle('Price range', theme),
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '\$${state.filterModel.priceRange.start.round()}',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    '\$${state.filterModel.priceRange.end.round()}',
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
                                  min: 0,
                                  max: 200,
                                  divisions: 20,
                                  labels: RangeLabels(
                                    '\$${state.filterModel.priceRange.start.round()}',
                                    '\$${state.filterModel.priceRange.end.round()}',
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
                                      100.h), // Extra space for bottom button
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
                        child: ElevatedButton(
                          onPressed: state.isLoading
                              ? null
                              : () {
                                  context.read<RideResultBloc>().add(
                                      FetchRideResults(
                                          filterModel: state.filterModel));


                                  context
                                      .read<RideFilterBloc>()
                                      .add(ApplyFilters());


                                  Navigator.push(context  , MaterialPageRoute(builder: (context) => RideResultsPage(),));
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
                            disabledBackgroundColor:
                                colorScheme.primary.withOpacity(0.8),
                          ),
                          child: state.isLoading
                              ? SizedBox(
                                  height: 20.h,
                                  width: 20.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        colorScheme.onPrimary),
                                  ),
                                )
                              : const Text('Show results'),
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
                  color: title.contains('Any') ||
                          title.contains('time') && !title.contains(':')
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
}
