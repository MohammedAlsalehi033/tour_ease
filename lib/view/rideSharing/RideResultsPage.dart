import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:tour_ease/bloc/rideResultsBloc.dart';
import 'package:tour_ease/components/PulsatingActionButton/PulsatingActionButton.dart';
import 'package:tour_ease/model/rideSharing/rideListing/rideListingModel.dart';
import 'package:tour_ease/model/rideSharing/rideModel.dart';
import 'package:tour_ease/view/rideSharing/RideRequestPage.dart';
import 'package:tour_ease/view/rideSharing/RideSharingPage.dart';
import 'package:tour_ease/view/rideSharing/rideBookingSheetUp.dart';

class RideResultsPage extends StatefulWidget {
  const RideResultsPage({super.key});

  @override
  State<RideResultsPage> createState() => _RideResultsPageState();
}

class _RideResultsPageState extends State<RideResultsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Available Rides', style: textTheme.headlineMedium),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: PulsatingActionButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => RideRequestPage(),));}),
      
      body: BlocBuilder<RideResultBloc, RideResultState>(
        builder: (context, state) {
          print(state.rides);

          if (state.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: colorScheme.primary,
              ),
            );
          }

          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.sp,
                    color: colorScheme.error,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Something went wrong',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    state.error!,
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () {
                      // Option to retry or go back
                      Navigator.pop(context);
                    },
                    child: Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          if (state.rides.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_car_outlined,
                    size: 64.sp,
                    color: colorScheme.primary.withOpacity(0.7),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No rides available',
                    style: textTheme.titleLarge,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Try adjusting your filters or check back later',
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Back to Filters'),
                  ),
                ],
              ),
            );
          }

          return AnimationLimiter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: ListView.builder(
                itemCount: state.rides.length,
                itemBuilder: (context, index) {
                  final ride = state.rides[index];

                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: _buildRideCard(ride, theme),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRideCard(RideListingModel ride, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final dateFormat = DateFormat('MMM dd, hh:mm a');

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: InkWell(
        onTap: () {
          // Navigate to ride details page
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ride header
              Row(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                      image: ride.mediaUrls.isNotEmpty
                          ? DecorationImage(
                        image: NetworkImage(ride.mediaUrls[0]),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: ride.mediaUrls.isEmpty
                        ? Icon(
                      Icons.person,
                      color: colorScheme.primary,
                      size: 24.sp,
                    )
                        : null,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ride.provider!.user.username,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              "4.2",
                              style: textTheme.bodyMedium,
                            ),
                            SizedBox(width: 12.w),
                            Icon(
                              Icons.directions_car,
                              color: colorScheme.onSurfaceVariant,
                              size: 16.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              ride.provider!.vehicleType,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '\$${ride.pricePerSeat.toStringAsFixed(0)}',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              // Divider
              Divider(height: 32.h),

              // Ride details
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildLocationInfo(
                          icon: Icons.location_on_outlined,
                          title: 'Pick-up',
                          location: ride.startLocationText,
                          theme: theme,
                        ),
                        SizedBox(height: 24.h),
                        _buildLocationInfo(
                          icon: Icons.location_on,
                          title: 'Destination',
                          location: ride.endLocationText,
                          theme: theme,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 80.h,
                    width: 1.w,
                    color: colorScheme.outlineVariant,
                  ),
                  SizedBox(width: 16.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetail(
                        icon: Icons.access_time,
                        label: 'Departure',
                        value: dateFormat.format(ride.departureTime),
                        theme: theme,
                      ),
                      SizedBox(height: 12.h),
                      _buildDetail(
                        icon: Icons.people_outline,
                        label: 'Seats',
                        value: ride.seatsAvailable.toString(),
                        theme: theme,
                      ),
                      SizedBox(height: 12.h),
                      _buildDetail(
                        icon: Icons.work_outline,
                        label: 'Luggage',
                        value: "3",
                        theme: theme,
                      ),
                    ],
                  ),
                ],
              ),

              // Action button
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () {


                  Navigator.push(context, MaterialPageRoute(builder: (context) => RideDetailsSheet(ride: ride,),)) ;               },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48.h),
                ),
                child: Text('Book Ride'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationInfo({
    required IconData icon,
    required String title,
    required String location,
    required ThemeData theme,
  }) {
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          color: title == 'Pick-up' ? colorScheme.secondary : colorScheme.primary,
          size: 24.sp,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                location,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetail({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: colorScheme.primary.withOpacity(0.7),
          size: 18.sp,
        ),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}