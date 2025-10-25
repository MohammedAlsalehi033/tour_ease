import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tour_ease/Services/ApiService.dart';
import 'package:tour_ease/controller/rideSharing/RideBooking/traveler/booking_for_traveler_bloc.dart';
import 'package:tour_ease/model/reviews/reviews_repo.dart';
import 'package:tour_ease/model/userManagment/user.dart';

class RideHistory extends StatefulWidget {
  const RideHistory({super.key});

  @override
  State<RideHistory> createState() => _RideHistoryState();
}

class _RideHistoryState extends State<RideHistory> {
  Set<int> reviewedBookingIds = {}; // Simple set to track reviewed booking IDs
  bool loadingReviews = true;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<BookingForTravelerBloc>(context)
        .add(FetchTravelerBookingsRequested(UserModel().id));
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final api = context.read<APIService>();
      final repo = ReviewsRepositoryApi(api);
      
      final reviews = await repo.getExtendedReviewsByReviewer(
        reviewerId: UserModel().id,
      );

      // Extract booking IDs from reviews
      setState(() {
        reviewedBookingIds = reviews
            .where((review) => review.transportationBooking != null)
            .map((review) => review.transportationBooking!.id)
            .toSet();
        loadingReviews = false;
      });
    } catch (e) {
      print('Failed to load reviews: $e');
      setState(() {
        loadingReviews = false;
      });
    }
  }

  void _showReviewDialog(BuildContext context, int bookingId) {
    int rating = 0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Review This Ride'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Rate your experience:'),
                const SizedBox(height: 16),
                // Star rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          rating = index + 1;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                // Comment field
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Comment (optional)',
                    border: OutlineInputBorder(),
                    hintText: 'Share your experience...',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (rating == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a rating')),
                    );
                    return;
                  }

                  try {
                    final api = context.read<APIService>();
                    final repo = ReviewsRepositoryApi(api);
                    
                    await repo.createTransportationBookingReview(
                      bookingId: bookingId,
                      rating: rating,
                      comment: commentController.text,
                    );

                    // Update the reviewed bookings set
                    setState(() {
                      reviewedBookingIds.add(bookingId);
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Review submitted successfully!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to submit review: $e')),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Completed Rides'),
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
            // Filter only completed rides
            final completedBookings = state.bookings
                .where((booking) => booking.status.toUpperCase() == 'COMPLETE')
                .toList();

            if (completedBookings.isEmpty) {
              return Center(
                child: Text(
                  'You have no completed rides yet.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              );
            }

            // Sort bookings from newest to oldest
            completedBookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView.builder(
                itemCount: completedBookings.length,
                itemBuilder: (context, index) {
                  final booking = completedBookings[index];
                  final isReviewed = reviewedBookingIds.contains(booking.id);

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with booking number
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Booking #${booking.id.toString().padLeft(6, '0')}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  if (isReviewed)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.secondary,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            size: 14,
                                            color: theme.colorScheme.onSecondary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Reviewed',
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: theme.colorScheme.onSecondary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  Chip(
                                    label: Text(
                                      'COMPLETED',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(height: 24),

                          // Journey details
                          if (booking.listing != null) ...[
                            _buildInfoRow(
                              Icons.location_on,
                              'From',
                              booking.listing!.startLocationText,
                              theme,
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              Icons.flag,
                              'To',
                              booking.listing!.endLocationText,
                              theme,
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              Icons.calendar_today,
                              'Date',
                              DateFormat('MMM d, yyyy - hh:mm a')
                                  .format(booking.listing!.departureTime.toLocal()),
                              theme,
                            ),
                          ],

                          const SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.airline_seat_recline_normal,
                            'Seats',
                            booking.seatsBooked.toString(),
                            theme,
                          ),
                          
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.attach_money,
                            'Total Price',
                            '${booking.totalPrice.toStringAsFixed(2)} USD',
                            theme,
                          ),

                          // Review button for unreviewed bookings
                          if (!isReviewed) ...[
                            const SizedBox(height: 16),
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: () => _showReviewDialog(context, booking.id),
                                icon: const Icon(Icons.rate_review),
                                label: const Text('Review'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return const Center(child: Text("Loading your ride history..."));
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
}