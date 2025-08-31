import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tour_ease/controller/rideSharing/RideBooking/ride_booking_bloc.dart';
import 'package:tour_ease/controller/rideSharing/RideBooking/ride_booking_state.dart';
import 'package:tour_ease/controller/rideSharing/RideBooking/traveler/booking_for_traveler_bloc.dart';
import 'package:tour_ease/model/userManagment/user.dart';

// --- Placeholder Models (Replace with your actual models) ---
class ListingModel {
  final String startLocationText;
  final String endLocationText;
  final DateTime departureTime;
  final String providerId;

  ListingModel({
    required this.startLocationText,
    required this.endLocationText,
    required this.departureTime,
    required this.providerId,
  });
}

class TravelerBookingModel {
  final String id;
  final DateTime createdAt;
  final String status;
  final ListingModel? listing;
  final int seatsBooked;
  final String? luggage;
  final double totalPrice;

  TravelerBookingModel({
    required this.id,
    required this.createdAt,
    required this.status,
    this.listing,
    required this.seatsBooked,
    this.luggage,
    required this.totalPrice,
  });

  // Example method to get providerId from the listing
  String getProviderId() {
    return listing?.providerId ?? '';
  }
}
// --- End of Placeholder Models ---


// --- Placeholder for Navigation (Replace with your actual page) ---
class LocationTrackingMap extends StatelessWidget {
  final String otherUserId;
  const LocationTrackingMap({super.key, required this.otherUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location Tracking')),
      body: Center(
        child: Text('Tracking user: $otherUserId'),
      ),
    );
  }
}
// --- End of Placeholder ---

class RideHistory extends StatefulWidget {
  const RideHistory({super.key});

  @override
  State<RideHistory> createState() => _RideHistoryState();
}

class _RideHistoryState extends State<RideHistory> {
  @override
  void initState() {
    super.initState();
    // TODO: Replace UserModel().id with the actual ID of the logged-in user.
    // For example: context.read<AuthBloc>().state.user.id
    BlocProvider.of<BookingForTravelerBloc>(context)
        .add(FetchTravelerBookingsRequested(UserModel().id));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Ride History'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 1,
      ),
      body: BlocBuilder<BookingForTravelerBloc, BookingForTravelerState>(
        builder: (context, state) {
          if (state is BookingForTravelerLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BookingForTravelerLoadFailure) {
            return Center(
              child: Text(
                'Failed to load bookings: ${state.error}',
                textAlign: TextAlign.center,
              ),
            );
          }
          if (state is BookingForTravelerLoadSuccess) {
            if (state.bookings.isEmpty) {
              return const Center(
                child: Text(
                  'You have no ride history yet.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView.builder(
                itemCount: state.bookings.length,
                itemBuilder: (context, index) {
                  final booking = state.bookings[index];
                  final formattedDate =
                  DateFormat('MMM d, yyyy - hh:mm a').format(booking.createdAt.toLocal());
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
                              Flexible(
                                child: Text(
                                  'Booking #${booking.id}...', // Shorten ID for display
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
                              DateFormat('MMM d, yyyy - hh:mm a').format(
                                  booking.listing!.departureTime.toLocal()),
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
                          if (booking.luggage != null &&
                              booking.luggage!.isNotEmpty) ...[
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


                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
          // Default case or initial state
          return const Center(child: Text("Welcome to your ride history!"));
        },
      ),
    );
  }

  // Helper widget for displaying information rows
  Widget _buildInfoRow(
      IconData icon, String label, String value, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
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

  // Helper widget for the status chip
  Widget _buildStatusChip(String status, ThemeData theme) {
    return Chip(
      label: Text(
        status,
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: _getStatusColor(status, theme),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      visualDensity: VisualDensity.compact,
    );
  }

  // Helper function to determine color based on status
  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return Colors.green.shade600;
      case 'PENDING':
        return Colors.orange.shade600;
      case 'CANCELLED':
        return Colors.red.shade600;
      case 'CONFIRMED':
        return theme.colorScheme.primary;
      default:
        return Colors.grey.shade600;
    }
  }
}