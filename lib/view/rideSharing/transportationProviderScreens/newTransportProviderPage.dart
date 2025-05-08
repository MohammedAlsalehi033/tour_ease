import 'dart:io';

import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tab_container/tab_container.dart';
import 'package:tour_ease/controller/rideSharing/RideBooking/ride_booking_bloc.dart';
import 'package:tour_ease/controller/rideSharing/RideBooking/ride_booking_event.dart';
import 'package:tour_ease/controller/rideSharing/RideBooking/ride_booking_state.dart';
import 'package:tour_ease/controller/rideSharing/RideRequests/ride_request_bloc.dart';
import 'package:tour_ease/controller/rideSharing/transportationProvider/transporation_provider_bloc.dart';
import 'package:tour_ease/model/rideSharing/RideFilterData.dart';
import 'package:tour_ease/model/rideSharing/rideRequest/rideRequestModel.dart';
import 'package:tour_ease/model/userManagment/UserModelTempForNow.dart';
import 'package:tour_ease/model/userManagment/transportationProvider.dart';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tour_ease/model/userManagment/user.dart';
import 'package:tour_ease/view/mapscreen/trackingMap.dart';
import 'package:tour_ease/view/rideSharing/transportationProviderScreens/TravelBookingForm.dart';
import 'package:tour_ease/view/rideSharing/transportationProviderScreens/providerProfile.dart';
import 'package:tour_ease/view/rideSharing/transportationProviderScreens/viewRequestDetails.dart';

class NewTransportationProviderPage extends StatefulWidget {
  const NewTransportationProviderPage({super.key});

  @override
  State<NewTransportationProviderPage> createState() =>
      _NewTransportationProviderPageState();
}

class _NewTransportationProviderPageState
    extends State<NewTransportationProviderPage> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    context
        .read<TransporationProviderBloc>()
        .add(FetchCurrentTransportationProviderData());

    context.read<BookingBloc>().add(FetchProviderBookingsRequested(providerId: UserModel().id));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transportation Provider Details'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16.r),
          ),
        ),
      ),
      body: BlocBuilder<TransporationProviderBloc, TransporationProviderState>(
        builder: (context, state) {


          if (state is TransportationProviderdataLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: colorScheme.primary,
              ),
            );
          }

          if (state is TransportationProviderdataError) {
            return _buildErrorState1(context, state, textTheme, colorScheme);
          }

          if (state is TransportationProviderdataLoaded) {

            final provider = state.transportationProviderModel;

            if (provider.accountStatus.toLowerCase() == 'active') {
              return BlocBuilder<BookingBloc, BookingState>(
                builder: (context, stateForBooking) {
                  if(stateForBooking is BookingLoading){
                    return Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    );
                  }
                  else if (stateForBooking is BookingLoadFailure){
                    return Text(stateForBooking.error);

                  }

                  else if(stateForBooking is ProviderBookingLoadSuccess){
                    final bookings = stateForBooking.providerBookings.where((element) => element.status.toLowerCase() == "pending" || element.status.toLowerCase() == "accepted" ).toList();
                    print(stateForBooking.providerBookings[1].toJson());
                    if (bookings.length < 1){
                      return TabContainer(
                      color: colorScheme.surface,
                      selectedTextStyle: textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      unselectedTextStyle: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      borderRadius: BorderRadius.circular(16.w),
                      tabEdge: TabEdge.left,
                      tabCurve: Curves.fastEaseInToSlowEaseOut,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          ),
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.95, end: 1.0)
                                .animate(animation),
                            child: child,
                          ),
                        );
                      },
                      tabs: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.directions_car,
                                size: 20.sp, color: colorScheme.primary),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add,
                                size: 20.sp,
                                weight: 2,
                                color: colorScheme.primary),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person,
                                size: 20.sp, color: colorScheme.primary),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history,
                                size: 20.sp, color: colorScheme.primary),
                          ],
                        ),
                      ],
                      children: [
                        _buildRideRequestsTab(textTheme, colorScheme),
                        TravelBookingForm(travelerId: "12345"),
                        TransportationProviderProfile(
                            transportationProviderModel: provider),
                        TransportationProviderProfile(
                            transportationProviderModel: provider),
                      ],
                    );
                    }


                    else {
                      return  Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ListView.builder(
                          itemCount: bookings.length,
                          itemBuilder: (context, index) {
                            final booking = bookings[index];

                            // Format date for better readability
                            final formattedDate = DateFormat('MMM d, yyyy - HH:mm').format(booking.createdAt.toLocal());
                            // Format status with proper capitalization
                            final status = booking.status.toUpperCase();

                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: _getStatusColor(booking.status, theme),
                                  width: 1.5,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header with status badge
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Booking #${booking.id}',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        _buildStatusChip(status, theme),
                                      ],
                                    ),
                                    const Divider(height: 24),

                                    // Journey details
                                    if (booking.listing != null) ...[
                                      _buildInfoRow(
                                        Icons.location_on_outlined,
                                        'From',
                                        booking.listing!.startLocationText,
                                        theme,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildInfoRow(
                                        Icons.flag_outlined,
                                        'To',
                                        booking.listing!.endLocationText,
                                        theme,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildInfoRow(
                                        Icons.access_time,
                                        'Departure',
                                        DateFormat('MMM d, yyyy - HH:mm').format(booking.listing!.departureTime.toLocal()),
                                        theme,
                                      ),
                                    ],

                                    // Booking details
                                    const SizedBox(height: 12),
                                    _buildInfoRow(
                                      Icons.event_note,
                                      'Booked on',
                                      formattedDate,
                                      theme,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildInfoRow(
                                      Icons.airline_seat_recline_normal,
                                      'Seats',
                                      booking.seatsBooked.toString(),
                                      theme,
                                    ),
                                    if (booking.luggage != null && booking.luggage!.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      _buildInfoRow(
                                        Icons.luggage,
                                        'Luggage',
                                        booking.luggage!,
                                        theme,
                                      ),
                                    ],
                                    const SizedBox(height: 12),
                                    _buildInfoRow(
                                      Icons.attach_money,
                                      'Total Price',
                                      '${booking.totalPrice.toStringAsFixed(2)} USD',
                                      theme,
                                    ),

                                    const SizedBox(height: 24),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [Expanded(
                                        child: ElevatedButton(onPressed: () {
context.read<BookingBloc>().add(MarkBookingAsComplete(bookingId: booking.id.toString()));
                                        }, child: Text("Mark as complete")),
                                      ),
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: theme.colorScheme.primary,
                                              foregroundColor: theme.colorScheme.onPrimary,
                                            ),
                                            onPressed: () {
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => LocationTrackingMap(otherUserId: booking.travelerId,),));
                                            },
                                            child: const Text('Check Location'),
                                          ),
                                        ),
                                      ],
                                    ),

                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );

                    }
                  }
                  else {
                    return Text("something went south");
                  }
            return Text(stateForBooking.toString());

                },
              );
            } else {
              return Text("wating for admin apporvel");
            }
          }

          return const Center(
              child: Text('Loading Transportation Provider Data...'));
        },
      ),
    );
  }

  Widget _buildErrorState1(
      BuildContext context,
      TransportationProviderdataError state,
      TextTheme textTheme,
      ColorScheme colorScheme) {
    return state.error == "Exception: Transportation provider not found"
        ? TransportationProviderForm()
        : Center(
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
                  state.error,
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: () {
                    context
                        .read<TransporationProviderBloc>()
                        .add(FetchCurrentTransportationProviderData());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
  }

  // Helper method to build status chip
  Widget _buildStatusChip(String status, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status, theme).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: theme.textTheme.bodySmall?.copyWith(
          color: _getStatusColor(status, theme),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Helper method to build info rows
  Widget _buildInfoRow(IconData icon, String label, String value, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method to get color based on status
  Color _getStatusColor(String status, ThemeData theme) {
    final statusLower = status.toLowerCase();

    if (statusLower == 'confirmed' || statusLower == 'completed') {
      return Colors.green;
    } else if (statusLower == 'pending' || statusLower == 'waiting') {
      return theme.colorScheme.primary;
    } else if (statusLower == 'cancelled' || statusLower == 'canceled') {
      return theme.colorScheme.error;
    } else {
      return theme.colorScheme.secondary;
    }
  }


  Widget _buildProviderDetailsTab(TransportationProviderModel provider,
      TextTheme textTheme, DateFormat dateFormat, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProviderDetailsContent(provider, textTheme, dateFormat),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildProviderDetailsContent(TransportationProviderModel provider,
      TextTheme textTheme, DateFormat dateFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Provider ID: ${provider.providerId}',
            style: textTheme.titleLarge),
        SizedBox(height: 16.h),
        Text('Vehicle Type: ${provider.vehicleType}',
            style: textTheme.titleMedium),
        SizedBox(height: 8.h),
        Text('Seats Available: ${provider.seatsAvailable}',
            style: textTheme.titleMedium),
        SizedBox(height: 8.h),
        Text('Account Status: ${provider.accountStatus}',
            style: textTheme.titleMedium),
        SizedBox(height: 8.h),
        Text('Created At: ${dateFormat.format(provider.createdAt)}',
            style: textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildRideRequestsTab(TextTheme textTheme, ColorScheme colorScheme) {
    final RideFilterModel filter = RideFilterModel(
      selectedDate: DateTime(2025, 4, 29),
      endTime: Time(hour: 17, minute: 30, second: 0),
      startTime: Time(hour: 9, minute: 0, second: 0),
      numberOfTravelers: 10,
      luggageCapacity: 10,
      pickupLocation: 'Islamabad International Airport (ISB)',
      destination: 'Centaurus Mall, Islamabad',
      priceRange: const RangeValues(50.0, 150.0),
      pickupLocationCoordinates:
          const LatLng(33.65055521987961, 73.15607607364655),
      destinationCoordinates:
          const LatLng(33.75313193883657, 72.83092696219683),
    );
    context.read<RideRequestBloc>().add(FetchRideRequests(filter: filter));

    return BlocBuilder<RideRequestBloc, RideRequestState>(
      builder: (context, state) {
        if (state is RideRequestLoading || state is RideRequestInitial) {
          return Center(
              child: CircularProgressIndicator(color: colorScheme.primary));
        } else if (state is RideRequestError) {
          return _buildErrorState(
              context, state, filter, textTheme, colorScheme);
        } else if (state is RideRequestLoaded) {
          if (state.rideRequests.isEmpty) {
            return _buildEmptyState(textTheme, colorScheme);
          }
          return _buildRideRequestsList(
              state.rideRequests, filter, textTheme, colorScheme);
        } else {
          return Center(child: Text('Waiting for data...'));
        }
      },
    );
  }

  Widget _buildErrorState(BuildContext context, RideRequestError state,
      RideFilterModel filter, TextTheme textTheme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded,
                color: colorScheme.error, size: 36.sp),
            SizedBox(height: 12.h),
            Text(
              'Error fetching ride requests:\n${state.error}',
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            ElevatedButton.icon(
              icon: Icon(Icons.refresh, size: 18.sp),
              label: Text("Retry"),
              onPressed: () {
                context
                    .read<RideRequestBloc>()
                    .add(FetchRideRequests(filter: filter));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.errorContainer,
                foregroundColor: colorScheme.onErrorContainer,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(TextTheme textTheme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 44.sp,
                color: colorScheme.onSurfaceVariant.withOpacity(0.6)),
            SizedBox(height: 12.h),
            Text(
              'No ride requests found matching your criteria nearby.',
              style: textTheme.titleMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideRequestsList(List<TravelerRideRequestModel> requests,
      RideFilterModel filter, TextTheme textTheme, ColorScheme colorScheme) {
    return AnimationLimiter(
      child: RefreshIndicator(
        onRefresh: () async {
          context
              .read<RideRequestBloc>()
              .add(FetchRideRequests(filter: filter));
        },
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 350),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildRequestCard(request, textTheme, colorScheme),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRequestCard(TravelerRideRequestModel request,
      TextTheme textTheme, ColorScheme colorScheme) {
    final dateFormat = DateFormat('MMM dd, hh:mm a');

    return Card(
      margin: EdgeInsets.symmetric(vertical: 5.h, horizontal: 2.w),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Handle tap to view details
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with ID and Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ID: ${request.id}',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11.sp,
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      dateFormat.format(request.departureTime),
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),

              // Route information
              _buildRouteInfoSection(request, colorScheme, textTheme),

              SizedBox(height: 8.h),
              Divider(
                  height: 1,
                  thickness: 1,
                  color: colorScheme.outlineVariant.withOpacity(0.3)),
              SizedBox(height: 8.h),

              // Trip details row
              _buildTripDetailsRow(request, colorScheme, textTheme),

              SizedBox(height: 10.h),

              // Action buttons
              _buildActionButtons(colorScheme, request),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteInfoSection(TravelerRideRequestModel request,
      ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Route icons column
        Column(
          children: [
            Icon(Icons.trip_origin, color: colorScheme.primary, size: 16.sp),
            Container(
              height: 16.h,
              width: 1.w,
              color: colorScheme.outline.withOpacity(0.5),
            ),
            Icon(Icons.location_on, color: colorScheme.secondary, size: 16.sp),
          ],
        ),
        SizedBox(width: 8.w),

        // Location details column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // From location
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 10.sp,
                    ),
                  ),
                  Text(
                    request.startLocationText,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              SizedBox(height: 6.h),

              // To location
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'To',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 10.sp,
                    ),
                  ),
                  Text(
                    request.endLocationText,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTripDetailsRow(TravelerRideRequestModel request,
      ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Passengers count
        _buildDetailChip(
          icon: Icons.people_outline,
          label: request.seatsNeeded.toString(),
          sublabel: 'Seats',
          color: colorScheme.primaryContainer,
          textColor: colorScheme.onPrimaryContainer,
          textTheme: textTheme,
        ),

        // Budget amount
        _buildDetailChip(
          icon: Icons.attach_money,
          label: '\$${request.budget.toStringAsFixed(0)}',
          sublabel: 'Budget',
          color: Colors.green.shade50,
          textColor: Colors.green.shade700,
          textTheme: textTheme,
        ),

        // Distance if available
        if (request.distanceKm != null && request.distanceKm! > 0)
          _buildDetailChip(
            icon: Icons.route_outlined,
            label: '${request.distanceKm!.toStringAsFixed(1)} km',
            sublabel: 'Distance',
            color: colorScheme.secondaryContainer,
            textColor: colorScheme.onSecondaryContainer,
            textTheme: textTheme,
          ),
      ],
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
    required Color textColor,
    required TextTheme textTheme,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: textColor),
          SizedBox(width: 4.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              Text(
                sublabel,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 9.sp,
                  color: textColor.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      ColorScheme colorScheme, TravelerRideRequestModel request) {
    return Row(
      children: [
        // Make Offer - primary button
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TravelerRideRequestDetailsPage(
                        travelerRideRequestModel: request),
                  ));
            },
            child: Text('View Details'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(vertical: 4.h),
              minimumSize: Size(0, 32.h),
              elevation: 0,
              textStyle:
                  TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }
}

class TransportationProviderForm extends StatefulWidget {
  @override
  _TransportationProviderFormState createState() =>
      _TransportationProviderFormState();
}

class _TransportationProviderFormState
    extends State<TransportationProviderForm> {
  final TextEditingController _vehicleTypeController = TextEditingController();
  int _seatsAvailable = 1;
  List<XFile>? _licenseMedia;
  List<XFile>? _vehicleMedia;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(bool isLicense, ImageSource source) async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        var limitedImages = images.length > 4 ? images.sublist(0, 4) : images;
        if (isLicense) {
          _licenseMedia = limitedImages;
        } else {
          _vehicleMedia = limitedImages;
        }
      });
    }
  }

  Widget _buildFileSelector({
    required String title,
    required List<XFile>? files,
    required VoidCallback onTapGallery,
    required VoidCallback onTapCamera,
    required ThemeData theme,
  }) {
    bool hasFiles = files != null && files.isNotEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            alignment: WrapAlignment.start, // Align buttons below title
            children: [
              OutlinedButton.icon(
                onPressed: onTapGallery,
                icon: Icon(Icons.photo_library_outlined),
                label: Text("Gallery"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  side: BorderSide(color: theme.colorScheme.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onTapCamera,
                icon: Icon(Icons.camera_alt_outlined),
                label: Text("Camera"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  side: BorderSide(color: theme.colorScheme.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          hasFiles
              ? SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      final file = files[index];
                      return Container(
                        width: 60,
                        height: 60,
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: theme.colorScheme.outline
                                    .withOpacity(0.2))),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(file.path),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                  color: theme.colorScheme.surface,
                                  child: Center(
                                      child: Icon(Icons.error_outline,
                                          color: theme.colorScheme.error,
                                          size: 24)));
                            },
                          ),
                        ),
                      );
                    },
                  ),
                )
              : Container(
                  height: 60,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.2))),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("No media selected",
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant))),
                ),
        ],
      ),
    );
  }

  Widget _buildCounterTile(
      {required String title,
      required int value,
      required VoidCallback onDecrease,
      required VoidCallback onIncrease,
      required ThemeData theme}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
      ),
      child: Row(
        // Main row
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Wrap title in Flexible to allow text wrapping and prevent pushing controls
          Flexible(
            child: Text(title, style: theme.textTheme.titleMedium),
          ),
          SizedBox(width: 8), // Add some space between title and controls
          // Counter controls row
          Row(
            mainAxisSize: MainAxisSize.min, // Take only needed space
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle_outline,
                    color: theme.colorScheme.primary),
                onPressed:
                    value > 1 ? onDecrease : null, // Disable if value is 1
                visualDensity: VisualDensity.compact, // Reduce padding slightly
                padding: EdgeInsets.zero, // Remove default padding if needed
              ),
              SizedBox(width: 4), // Reduced space
              Text('$value', style: theme.textTheme.headlineSmall),
              SizedBox(width: 4), // Reduced space
              IconButton(
                icon: Icon(Icons.add_circle_outline,
                    color: theme.colorScheme.primary),
                onPressed: onIncrease,
                visualDensity: VisualDensity.compact, // Reduce padding slightly
                padding: EdgeInsets.zero, // Remove default padding if needed
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _vehicleTypeController,
              decoration: InputDecoration(
                labelText: "Vehicle Type",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.5))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: theme.colorScheme.primary)),
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            SizedBox(height: 24),
            _buildCounterTile(
              title: "Seats Available",
              value: _seatsAvailable,
              onDecrease: () => setState(() => _seatsAvailable =
                  (_seatsAvailable > 1) ? _seatsAvailable - 1 : 1),
              onIncrease: () => setState(() => _seatsAvailable++),
              theme: theme,
            ),
            _buildFileSelector(
              title: "License Media (Max 4)",
              files: _licenseMedia,
              onTapGallery: () => _pickImage(true, ImageSource.gallery),
              onTapCamera: () => _pickImage(true, ImageSource.camera),
              theme: theme,
            ),
            _buildFileSelector(
              title: "Vehicle Media (Max 4)",
              files: _vehicleMedia,
              onTapGallery: () => _pickImage(false, ImageSource.gallery),
              onTapCamera: () => _pickImage(false, ImageSource.camera),
              theme: theme,
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<TransporationProviderBloc>().add(
                      CreateTransportationProvider(
                          TransportationProviderModel(
                              providerId: UserModel().id,
                              accountStatus: "",
                              createdAt: DateTime.now(),
                              licenseMmediaUrls: [],
                              vehicleMediaUrls: [],
                              seatsAvailable: _seatsAvailable,
                              user: UserModelTempForNow(
                                  id: UserModel().id,
                                  email: UserModel().email,
                                  username: "",
                                  mediaUrls: [],
                                  accountStatus: "",
                                  createdAt: DateTime.now()),
                              vehicleType: _vehicleTypeController.text),
                          _licenseMedia!,
                          _vehicleMedia!));
                },
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: Text("Submit"),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _vehicleTypeController.dispose();
    super.dispose();
  }
}
