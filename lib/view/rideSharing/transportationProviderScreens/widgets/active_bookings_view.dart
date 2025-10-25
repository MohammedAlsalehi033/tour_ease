import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tour_ease/controller/rideSharing/RideBooking/provider/booking_for_provider_bloc.dart';
import 'package:tour_ease/controller/rideSharing/RideBooking/ride_booking_bloc.dart';
import 'package:tour_ease/controller/rideSharing/RideBooking/ride_booking_event.dart';
import 'package:tour_ease/controller/rideSharing/RideBooking/ride_booking_state.dart';
import 'package:tour_ease/model/userManagment/user.dart';
import 'package:tour_ease/view/mapscreen/trackingMap.dart';
import 'package:tour_ease/components/profileAvatar.dart';
import 'package:tour_ease/components/simple_cancel_button.dart';
import 'package:tour_ease/view/chat/chatDetailsPage.dart';

class ActiveBookingsView extends StatelessWidget {
  final Function() onRefresh;

  const ActiveBookingsView({
    Key? key,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<BookingBloc, BookingState>(
      listener: (context, bookingState) {
        // Refresh the provider bookings list when a booking is marked as complete
        if (bookingState is BookingMarkedComplete) {
          context.read<BookingForProviderBloc>().add(
                FetchProviderBookingsRequested(UserModel().id),
              );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Booking marked as complete!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: BlocBuilder<BookingForProviderBloc, BookingForProviderState>(
        builder: (context, state) {
          if (state is BookingForProviderLoading) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          } else if (state is BookingForProviderLoadFailure) {
            return Center(child: Text(state.error));
          } else if (state is BookingForProviderLoadSuccess) {
            final bookings = state.bookings
                .where((element) =>
                    element.status.toLowerCase() == "pending" ||
                    element.status.toLowerCase() == "accepted")
                .toList();

          print('Active Bookings: ${bookings[0].toJson()}');
          return RefreshIndicator(
            onRefresh: () async {
              onRefresh();
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  final formattedDate = DateFormat('MMM d, yyyy - HH:mm')
                      .format(booking.createdAt.toLocal());
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

                          // Booking Source Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: booking.bookingSource == 'request'
                                  ? Colors.purple.withOpacity(0.15)
                                  : Colors.blue.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  booking.bookingSource == 'request'
                                      ? Icons.request_quote
                                      : Icons.list_alt,
                                  size: 14,
                                  color: booking.bookingSource == 'request'
                                      ? Colors.purple
                                      : Colors.blue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'From ${booking.bookingSource == 'request' ? 'Request' : 'Listing'}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: booking.bookingSource == 'request'
                                        ? Colors.purple
                                        : Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Traveler info
                          Row(
                            children: [
                              ProfileAvatar(
                                imageURL: (booking.traveler != null &&
                                        booking.traveler!.mediaUrls.isNotEmpty)
                                    ? booking.traveler!.mediaUrls.first
                                    : null,
                                userName: booking.traveler?.username ?? 'Traveler',
                                radius: 18,
                                userId: booking.traveler?.id ?? '',
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  booking.traveler?.username ?? 'Traveler',
                                  style: theme.textTheme.titleSmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Journey details - Check both listing and request
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
                          ] else if (booking.request != null) ...[
                            // Show request details when booking is from request
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
                              Icons.monetization_on,
                              'Budget',
                              'PKR ${booking.request!.budget.toStringAsFixed(2)}',
                              theme,
                            ),
                            if (booking.offer?.message != null && 
                                booking.offer!.message!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.message,
                                      size: 18,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Your Offer Message',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            booking.offer!.message!,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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
                            'PKR ${booking.totalPrice.toStringAsFixed(2)}',
                            theme,
                          ),

                          const SizedBox(height: 24),
                          Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        context.read<BookingBloc>().add(
                                              MarkBookingAsComplete(
                                                  bookingId: booking.id.toString()),
                                            );
                                      },
                                      icon: const Icon(Icons.check_circle, size: 18),
                                      label: const Text("Mark as complete"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            theme.colorScheme.primary,
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
                                              otherUserId: booking.travelerId,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.location_on,
                                          size: 18),
                                      label: const Text('Track Location'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
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
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatPage(
                                              currentUserId: UserModel().id,
                                              otherUserId: booking.travelerId,
                                              apiBaseUrl: 'http://10.0.2.2:300/api',
                                              otherUserName: booking.traveler?.username ?? 'Traveler',
                                              otherUserAvatar: (booking.traveler != null &&
                                                      booking.traveler!.mediaUrls.isNotEmpty)
                                                  ? booking.traveler!.mediaUrls.first
                                                  : '',
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.chat_bubble_outline,
                                          size: 18),
                                      label: const Text('Chat with Traveler'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SimpleCancelButton(
                                bookingId: booking.id.toString(),
                                onCancelled: () {
                                  context.read<BookingForProviderBloc>().add(
                                        FetchProviderBookingsRequested(
                                            UserModel().id),
                                      );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        } else {
          return Center(child: Text(state.toString()));
        }
      },
      ),
    );
  }

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

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme,
  ) {
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
