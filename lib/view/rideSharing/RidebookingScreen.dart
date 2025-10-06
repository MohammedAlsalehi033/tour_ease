import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:tour_ease/controller/rideSharing/RideBooking/traveler/booking_for_traveler_bloc.dart';
import 'package:tour_ease/model/rideSharing/RideBooking/RideBooking.dart';
import 'package:tour_ease/model/userManagment/user.dart';
import 'package:tour_ease/view/mapscreen/trackingMap.dart';
import 'package:tour_ease/view/rideSharing/RideSharingPage.dart';
import 'package:tour_ease/components/simple_cancel_button.dart';
import 'package:tour_ease/view/chat/chatDetailsPage.dart';
import 'package:tour_ease/components/profileAvatar.dart';

class RidebookingscreenTraveler extends StatefulWidget {
  const RidebookingscreenTraveler({super.key});

  @override
  State<RidebookingscreenTraveler> createState() =>
      _RidebookingscreenTravelerState();
}

class _RidebookingscreenTravelerState extends State<RidebookingscreenTraveler> {
  @override
  void initState() {
    super.initState();
    // Load traveler bookings
    context
        .read<BookingForTravelerBloc>()
        .add(FetchTravelerBookingsRequested(UserModel().id));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<BookingForTravelerBloc, BookingForTravelerState>(
      listener: (context, state) {
        // if (state is BookingLoadFailure) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: Text('Error fetching bookings: ${state.error}'),
        //       backgroundColor: theme.colorScheme.error,
        //     ),
        //   );
        // }
      },
      builder: (context, state) {
        if (state is BookingForTravelerLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ),
          );
        } else if (state is BookingForTravelerLoadSuccess) {
          final bookings = state.bookings
              .where((e) =>
                  e.status != "complete" &&
                  e.status != "cancelled" &&
                  e.status != "canceled")
              .toList();
          final bool hasBookings = bookings.isNotEmpty;
          print("Filtered bookings: ${bookings.toString()}");
          if (hasBookings) {
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final TravelerBookingModel booking = bookings[index];

                  // Format date for better readability
                  final formattedDate = DateFormat('MMM d, yyyy - HH:mm')
                      .format(booking.createdAt.toLocal());
                  final status = booking.status.toUpperCase();
                  print(booking.toString());
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
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Booking #${booking.id}',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Source Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: booking.listing != null
                                            ? Colors.blue.withOpacity(0.15)
                                            : booking.request != null
                                                ? Colors.purple.withOpacity(0.15)
                                                : Colors.orange.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            booking.listing != null
                                                ? Icons.list_alt
                                                : booking.request != null
                                                    ? Icons.request_page
                                                    : Icons.local_offer,
                                            size: 12,
                                            color: booking.listing != null
                                                ? Colors.blue
                                                : booking.request != null
                                                    ? Colors.purple
                                                    : Colors.orange,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            booking.listing != null
                                                ? 'From Ride Listing'
                                                : booking.request != null
                                                    ? 'From Ride Request'
                                                    : 'Via Offer',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: booking.listing != null
                                                  ? Colors.blue
                                                  : booking.request != null
                                                      ? Colors.purple
                                                      : Colors.orange,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _buildStatusChip(status, theme),
                            ],
                          ),
                          const Divider(height: 24),

                          // Provider Information (if available from listing)
                          if (booking.listing?.provider != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  ProfileAvatar(
                                    imageURL: booking.listing!.provider!.user.mediaUrls.isNotEmpty
                                        ? booking.listing!.provider!.user.mediaUrls[0]
                                        : null,
                                    userName: booking.listing!.provider!.user.username,
                                    userId: booking.listing!.provider!.providerId,
                                    radius: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Driver: ',
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                                              ),
                                            ),
                                            Text(
                                              booking.listing!.provider!.user.username,
                                              style: theme.textTheme.titleSmall?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.directions_car,
                                              size: 16,
                                              color: theme.colorScheme.primary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              booking.listing!.provider!.vehicleType,
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Icon(
                                              Icons.event_seat,
                                              size: 16,
                                              color: theme.colorScheme.primary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${booking.listing!.provider!.seatsAvailable} seats',
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Journey details - Handle both listings and requests
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
                              DateFormat('MMM d, yyyy - HH:mm').format(
                                  booking.listing!.departureTime.toLocal()),
                              theme,
                            ),
                            if (booking.listing!.distanceKm != null) ...[
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.straighten,
                                'Distance',
                                '${booking.listing!.distanceKm!.toStringAsFixed(1)} km',
                                theme,
                              ),
                            ],
                          ] else if (booking.request != null) ...[
                            _buildInfoRow(
                              Icons.location_on_outlined,
                              'From',
                              booking.request!.startLocationText,
                              theme,
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              Icons.flag_outlined,
                              'To',
                              booking.request!.endLocationText,
                              theme,
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              Icons.access_time,
                              'Departure',
                              DateFormat('MMM d, yyyy - HH:mm').format(
                                  booking.request!.departureTime.toLocal()),
                              theme,
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              Icons.attach_money,
                              'Budget',
                              'PKR ${booking.request!.budget.toStringAsFixed(2)}',
                              theme,
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              Icons.airline_seat_recline_normal,
                              'Seats Needed',
                              booking.request!.seatsNeeded.toString(),
                              theme,
                            ),
                            if (booking.request!.distanceKm != null) ...[
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.straighten,
                                'Distance',
                                '${booking.request!.distanceKm!.toStringAsFixed(1)} km',
                                theme,
                              ),
                            ],
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
                            booking.request != null ? 'Seats Booked' : 'Seats',
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
                            'PKR ${booking.totalPrice.toStringAsFixed(2)}',
                            theme,
                          ),
                          
                          // Show offer message if booking is via offer
                          if (booking.offer?.message != null && 
                              booking.offer!.message!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.orange.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.message,
                                    size: 18,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Offer Message',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          booking.offer!.message!,
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),
                          
                          // Action buttons row 1: Track Location & Chat
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor:
                                        theme.colorScheme.onPrimary,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              LocationTrackingMap(
                                            otherUserId:
                                                booking.getProviderId(),
                                          ),
                                        ));
                                  },
                                  icon: const Icon(Icons.location_on, size: 18),
                                  label: const Text('Track'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: theme.colorScheme.primary,
                                    side: BorderSide(
                                      color: theme.colorScheme.primary,
                                      width: 1.5,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  onPressed: () {
                                    final providerId = booking.getProviderId();
                                    if (providerId.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Unable to identify driver'),
                                        ),
                                      );
                                      return;
                                    }
                                    
                                    // Get provider info for chat
                                    String driverName = 'Driver';
                                    String driverAvatar = '';
                                    
                                    if (booking.listing?.provider != null) {
                                      driverName = booking.listing!.provider!.user.username;
                                      driverAvatar = booking.listing!.provider!.user.mediaUrls.isNotEmpty
                                          ? booking.listing!.provider!.user.mediaUrls[0]
                                          : '';
                                    } else if (booking.offer?.sender != null) {
                                      final senderData = booking.offer!.sender!;
                                      driverName = senderData['username'] ?? 'Driver';
                                      if (senderData['mediaUrls'] != null && 
                                          (senderData['mediaUrls'] as List).isNotEmpty) {
                                        driverAvatar = senderData['mediaUrls'][0];
                                      }
                                    }
                                    
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatPage(
                                          currentUserId: UserModel().id,
                                          otherUserId: providerId,
                                          apiBaseUrl: 'http://10.0.2.2:3000/api',
                                          otherUserName: driverName,
                                          otherUserAvatar: driverAvatar,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                                  label: const Text('Chat'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Action buttons row 2: Cancel
                          Row(
                            children: [
                              Expanded(
                                child: SimpleCancelButton(
                                  bookingId: booking.id.toString(),
                                  onCancelled: () {
                                    // Refresh the bookings after cancellation
                                    context.read<BookingForTravelerBloc>().add(
                                        FetchTravelerBookingsRequested(
                                            UserModel().id));
                                  },
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
          } else {
            return RideFilterPage();
          }
        } else if (state is BookingForTravelerLoadFailure) {
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
                    state.error,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<BookingForTravelerBloc>()
                          .add(FetchTravelerBookingsRequested(UserModel().id));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Center(
            child: Text(
              "Looking for your bookings...",
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
