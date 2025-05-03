import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:intl/intl.dart';
import 'package:tour_ease/bloc/rideFilterBloc.dart';
import 'package:tour_ease/controller/rideSharing/RideRequests/ride_request_bloc.dart';
import 'package:tour_ease/view/mapscreen/mappage.dart';

class RideRequestPage extends StatefulWidget {
  const RideRequestPage({Key? key}) : super(key: key);

  @override
  _RideRequestPageState createState() => _RideRequestPageState();
}


class _RideRequestPageState extends State<RideRequestPage> {
  final _budgetController = TextEditingController();
  bool isStartLocationValid = true;
  bool isEndLocationValid = true;
  bool isBudgetValid = true;
  bool isSeatsValid = true;
  bool isSubmitting = false;
  bool isSubmitSuccess = false;

  String startLocationText = '';
  String endLocationText = '';
  int seatsNeeded = 1;
  double budget = 50.0;

  @override
  void initState() {
    super.initState();
    final filterState = context.read<RideFilterBloc>().state;
    final initialBudget = (filterState.filterModel.priceRange.start +
            filterState.filterModel.priceRange.end) /
        2;
    budget = initialBudget;
    _budgetController.text = budget.toString();

    if (filterState.filterModel.pickupLocation.isNotEmpty) {
      startLocationText = filterState.filterModel.pickupLocation;
    }
    if (filterState.filterModel.destination.isNotEmpty) {
      endLocationText = filterState.filterModel.destination;
    }

    // Use filter travelers count if available
    if (filterState.filterModel.numberOfTravelers > 0) {
      seatsNeeded = filterState.filterModel.numberOfTravelers;
    }
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  void _onBudgetChanged() {
    if (_budgetController.text.isNotEmpty) {
      try {
        budget = double.parse(_budgetController.text);
        setState(() {
          isBudgetValid = budget > 0;
        });
      } catch (e) {
        setState(() {
          isBudgetValid = false;
        });
      }
    }
  }

  void _updateStartLocation(String value) {
    setState(() {
      startLocationText = value;
      isStartLocationValid = value.isNotEmpty;
    });
  }

  void _updateEndLocation(String value) {
    setState(() {
      endLocationText = value;
      isEndLocationValid = value.isNotEmpty;
    });
  }

  void _incrementSeats() {
    setState(() {
      seatsNeeded++;
      isSeatsValid = seatsNeeded > 0;
    });
  }

  void _decrementSeats() {
    if (seatsNeeded > 1) {
      setState(() {
        seatsNeeded--;
        isSeatsValid = seatsNeeded > 0;
      });
    }
  }

  void _resetForm() {
    setState(() {
      startLocationText = '';
      endLocationText = '';
      seatsNeeded = 1;
      budget = 5000.0;
      _budgetController.text = budget.toString();
      isStartLocationValid = true;
      isEndLocationValid = true;
      isBudgetValid = true;
      isSeatsValid = true;
    });
  }

  void _submitRequest() {
    setState(() {
      RideFilterState rideFilterState = context.read<RideFilterBloc>().state;
      isStartLocationValid =
          rideFilterState.filterModel.pickupLocation.isNotEmpty;
      isEndLocationValid = rideFilterState.filterModel.destination.isNotEmpty;
      isBudgetValid = budget > 0;
      isSeatsValid = seatsNeeded > 0;

      if (isStartLocationValid &&
          isEndLocationValid &&
          isBudgetValid &&
          isSeatsValid) {
        isSubmitting = true;


        context.read<RideRequestBloc>().add(CreateRideRequest(
            startLocationText: rideFilterState.filterModel.pickupLocation,
            endLocationText: rideFilterState.filterModel.destination,
            startLocationLat:
                rideFilterState.filterModel.pickupLocationCoordinates.latitude,
            startLocationLng:
                rideFilterState.filterModel.pickupLocationCoordinates.longitude,
            endLocationLat:
                rideFilterState.filterModel.destinationCoordinates.latitude,
            endLocationLng:
                rideFilterState.filterModel.destinationCoordinates.longitude,
            departureTime: _getDepartureDateTime(),
            seatsNeeded: seatsNeeded,
            budget: budget));
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            isSubmitting = false;
            isSubmitSuccess = true;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ride request submitted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          });
        });
      } else {
      }
    });
  }

  DateTime _getDepartureDateTime() {
    final filterState = context.read<RideFilterBloc>().state;
    DateTime departureDate = filterState.filterModel.selectedDate ??
        DateTime.now().add(Duration(days: 1));

    TimeOfDay departureTime = filterState.filterModel.startTime;

    return DateTime(
      departureDate.year,
      departureDate.month,
      departureDate.day,
      departureTime.hour,
      departureTime.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BlocBuilder<RideFilterBloc, RideFilterState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Create Ride Request"),
            actions: [
              IconButton(onPressed: _resetForm, icon: Icon(Icons.refresh))
            ],
          ),
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

                              // Location Selection
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MapScreen()),
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.w, vertical: 12.h),
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 5,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildSectionTitle('Where from?', theme),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on,
                                              color: theme.primaryColor,
                                              size: 18),
                                          SizedBox(width: 8.w),
                                          Expanded(
                                            child: Text(
                                              state.filterModel.pickupLocation
                                                      .isEmpty
                                                  ? 'Select pickup location'
                                                  : state.filterModel
                                                      .pickupLocation,
                                              style: TextStyle(
                                                color: state.filterModel
                                                        .pickupLocation.isEmpty
                                                    ? theme.hintColor
                                                    : theme.textTheme.bodyMedium
                                                        ?.color,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Divider(height: 24.h, thickness: 1),
                                      _buildSectionTitle('Where to?', theme),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on,
                                              color: theme.primaryColor,
                                              size: 18),
                                          SizedBox(width: 8.w),
                                          Expanded(
                                            child: Text(
                                              state.filterModel.destination
                                                      .isEmpty
                                                  ? 'Select destination'
                                                  : state
                                                      .filterModel.destination,
                                              style: TextStyle(
                                                color: state.filterModel
                                                        .destination.isEmpty
                                                    ? theme.hintColor
                                                    : theme.textTheme.bodyMedium
                                                        ?.color,
                                              ),
                                            ),
                                          ),
                                          Icon(Icons.arrow_forward_ios,
                                              color: theme.primaryColor,
                                              size: 16),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: 32.h),

                              // Date Selection
                              _buildSectionTitle('When?', theme),
                              _buildSelectionTile(
                                icon: Icons.calendar_today_outlined,
                                title: state.filterModel.selectedDate == null
                                    ? 'Any date'
                                    : DateFormat('MMMM d, yyyy').format(
                                        state.filterModel.selectedDate!),
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
                                          initialSelectedDate:
                                              state.filterModel.selectedDate ??
                                                  DateTime.now(),
                                          minDate: DateTime.now(),
                                          maxDate: DateTime.now()
                                              .add(const Duration(days: 90)),
                                          onSelectionChanged:
                                              (DateRangePickerSelectionChangedArgs
                                                  args) {
                                            rideFilterBloc
                                                .add(UpdateDate(args.value));
                                            Navigator.pop(dialogContext);
                                          },
                                          headerStyle:
                                              DateRangePickerHeaderStyle(
                                            textStyle:
                                                textTheme.titleMedium?.copyWith(
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                          monthCellStyle:
                                              DateRangePickerMonthCellStyle(
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
                                      );
                                    },
                                  );
                                },
                                theme: theme,
                              ),
                              SizedBox(height: 16.h),

                              // Time Selection
                              _buildSectionTitle('Departure Time', theme),
                              _buildSelectionTile(
                                icon: Icons.access_time,
                                title:
                                    state.filterModel.startTime.format(context),
                                onTap: () async {
                                  Navigator.of(context).push(
                                    showPicker(
                                      context: context,
                                      value: state.filterModel.startTime,
                                      sunrise: TimeOfDay(hour: 6, minute: 0),
                                      sunset: TimeOfDay(hour: 18, minute: 0),
                                      duskSpanInMinutes: 120,
                                      onChange: (newTime) {
                                        context
                                            .read<RideFilterBloc>()
                                            .add(UpdateStartTime(newTime));
                                      },
                                    ),
                                  );
                                },
                                theme: theme,
                              ),
                              SizedBox(height: 32.h),

                              // Budget
                              _buildSectionTitle('Your Budget (PKR)', theme,
                                  isValid: isBudgetValid),
                              TextField(
                                controller: _budgetController,
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                decoration: InputDecoration(
                                  suffixText: '\PKR ',
                                  hintText: 'Enter your maximum budget',
                                  border: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: colorScheme.outline),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: colorScheme.outline),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: colorScheme.primary),
                                  ),
                                  errorText: !isBudgetValid
                                      ? 'Please enter a valid budget amount'
                                      : null,
                                ),
                                onChanged: (value) {
                                  _onBudgetChanged();
                                },
                              ),
                              SizedBox(height: 32.h),

                              // Seats Needed
                              _buildSectionTitle('Seats Needed', theme,
                                  isValid: isSeatsValid),
                              _buildCounterTile(
                                title: 'Seats',
                                value: seatsNeeded,
                                onDecrease: _decrementSeats,
                                onIncrease: _incrementSeats,
                                theme: theme,
                                errorText: !isSeatsValid
                                    ? 'At least 1 seat is required'
                                    : null,
                              ),



                              SizedBox(height: 100.h),
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
                          onPressed: isSubmitting ? null : _resetForm,
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
                      BlocBuilder<RideRequestBloc, RideRequestState>(
                        builder: (context, state) {

                          if (state is RideRequestError){
                            print(state.error);
                            return Text(state.error);
                          }
                          return Expanded(flex: 2,
                            child: ElevatedButton(
                              onPressed: isSubmitting ? null : _submitRequest,
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
                              child: isSubmitting
                                  ? SizedBox(
                                      height: 20.h,
                                      width: 20.w,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                colorScheme.onPrimary),
                                      ),
                                    )
                                  : const Text('Submit Request'),
                            ),
                          );
                        },
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
  Widget _buildSectionTitle(String title, ThemeData theme,
      {bool isValid = true}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: isValid ? theme.colorScheme.primary : Colors.red,
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
                  color: theme.colorScheme.onSurface,
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
    String? errorText,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outline),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          if (errorText != null)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                errorText,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12.sp,
                ),
              ),
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


