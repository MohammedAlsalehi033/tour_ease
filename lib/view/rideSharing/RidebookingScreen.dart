import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:tour_ease/controller/rideSharing/RideBooking/ride_booking_bloc.dart';
import 'package:tour_ease/controller/rideSharing/RideBooking/ride_booking_event.dart';
import 'package:tour_ease/controller/rideSharing/RideBooking/ride_booking_state.dart';
import 'package:tour_ease/model/userManagment/user.dart';
import 'package:tour_ease/view/mapscreen/trackingMap.dart';
import 'package:tour_ease/view/rideSharing/RideSharingPage.dart';

class RidebookingscreenTraveler extends StatefulWidget {
  const RidebookingscreenTraveler({super.key});

  @override
  State<RidebookingscreenTraveler> createState() => _RidebookingscreenTravelerState();
}

class _RidebookingscreenTravelerState extends State<RidebookingscreenTraveler> {
  @override
  void initState() {
    super.initState();
    // Load traveler bookings
    context.read<BookingBloc>().add(FetchTravelerBookingsRequested(travelerId: UserModel().id));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingLoadFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error fetching bookings: ${state.error}'),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        print(state);
        if (state is BookingLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ),
          );
        } else if (state is TravelerBookingLoadSuccess) {
          final bool hasBookings = state.travelerBookings.isNotEmpty;

          if (hasBookings) {
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView.builder(
                itemCount: state.travelerBookings.length,
                itemBuilder: (context, index) {
                  final booking = state.travelerBookings[index];

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
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor: theme.colorScheme.onPrimary,
                                  ),
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => LocationTrackingMap(otherUserId: booking.getProviderId(),),));
                                  },
                                  child: const Text('Check Location'),
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
          } else {
            return RideFilterPage();
          }
        } else if (state is BookingLoadFailure) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load bookings',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please try again later',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<BookingBloc>().add(
                          FetchTravelerBookingsRequested(travelerId: UserModel().id)
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        } else if (state is BookingInitial) {
          return Center(
            child: Text(
              "Looking for your bookings...",
              style: theme.textTheme.bodyLarge,
            ),
          );
        } else {
          return Center(
            child: Text(
              "Please check your bookings",
              style: theme.textTheme.bodyLarge,
            ),
          );
        }
      },
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
}