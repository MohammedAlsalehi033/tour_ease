import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tour_ease/Services/ApiService.dart';
import 'package:tour_ease/controller/rideSharing/RideBooking/traveler/booking_for_traveler_bloc.dart';
import 'package:tour_ease/model/reviews/reviews_repo.dart';
import 'package:tour_ease/model/reviews/review_model.dart';
import 'package:tour_ease/model/rideSharing/RideBooking/RideBooking.dart';
import 'package:tour_ease/model/userManagment/user.dart';
import 'package:tour_ease/view/profile/user_reviews.dart';

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
  final TextEditingController reviewController = TextEditingController();
  double rating = 0;
  Map<int, List<ReviewModel>> bookingReviews = {};
  Map<int, bool> loadingReviews = {};

  @override
  void initState() {
    super.initState();
    // TODO: Replace UserModel().id with the actual ID of the logged-in user.
    BlocProvider.of<BookingForTravelerBloc>(context)
        .add(FetchTravelerBookingsRequested(UserModel().id));
    
  }

  Future<void> _loadAllReviews(List<TravelerBookingModel> bookings, ReviewsRepositoryApi repo) async {
    for (final booking in bookings) {
      if (!loadingReviews.containsKey(booking.id) && !bookingReviews.containsKey(booking.id)) {
        _loadReviewsForBooking(booking.id, repo);
      }
    }
  }

  Future<void> _loadReviewsForBooking(int bookingId, ReviewsRepositoryApi repo) async {
    if (loadingReviews[bookingId] == true || bookingReviews.containsKey(bookingId)) {
      return; // Already loading or loaded
    }

    setState(() {
      loadingReviews[bookingId] = true;
    });

    try {
      await repo.getReviewsByReviewer(reviewerId: UserModel().id);
      setState(() {
        loadingReviews[bookingId] = false;
      });
    } catch (e) {
      setState(() {
        print("Failed to load reviews for booking $bookingId: $e");
        loadingReviews[bookingId] = false;
        bookingReviews[bookingId] = [];
      });
    }
  }

  bool _hasUserReviewed(int bookingId) {
    final reviews = bookingReviews[bookingId] ?? [];
    final currentUserId = UserModel().id;
    return reviews.any((review) => review.reviewerId == currentUserId);
  }

  ReviewModel? _getUserReview(int bookingId) {
    final reviews = bookingReviews[bookingId] ?? [];
    final currentUserId = UserModel().id;
    try {
      return reviews.firstWhere((review) => review.reviewerId == currentUserId);
    } catch (e) {
      return null;
    }
  }

  void _showReviewDialog(BuildContext context, TravelerBookingModel booking, ReviewsRepositoryApi repo) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Write a Review",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // Simple star rating row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Theme.of(context).colorScheme.tertiary, // Use theme color for stars
                        ),
                        onPressed: () {
                          setModalState(() {
                            rating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  TextField(
                    controller: reviewController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Your review",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (rating == 0 || reviewController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please provide a rating and review.")),
                        );
                        return;
                      }
                      try {
                        // Call the API to submit the review
                        await repo.createTransportationBookingReview(
                          bookingId: booking.id,
                          rating: rating.toInt(),
                          comment: reviewController.text,
                        );
                        
                        // Clear the form
                        reviewController.clear();
                        rating = 0;
                        
                        // Refresh reviews for this booking
                        setState(() {
                          bookingReviews.remove(booking.id);
                          loadingReviews.remove(booking.id);
                        });
                        
                        Navigator.pop(context); // Close the bottom sheet
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Review submitted successfully.")),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Failed to submit review: $e")),
                        );
                      }
                    },
                    child: const Text("Submit"),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    

  final api = context.read<APIService>();
  final repo = ReviewsRepositoryApi(api);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Ride History'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.rate_review),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserReviewsScreen(),
                ),
              );
            },
            tooltip: 'View All Reviews',
          ),
        ],
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
              return Center(
                child: Text(
                  'You have no ride history yet.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              );
            }

            // Sort bookings from newest to oldest
            final sortedBookings = [...state.bookings];
            sortedBookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            // Load reviews for all bookings after build is complete
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadAllReviews(sortedBookings, repo);
            });

            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView.builder(
                itemCount: sortedBookings.length,
                itemBuilder: (context, index) {
                  final booking = sortedBookings[index];
                  final formattedDate = DateFormat('MMM d, yyyy - hh:mm a').format(booking.createdAt.toLocal());
                  final status = booking.status.toUpperCase();

                  final hasReviewed = _hasUserReviewed(booking.id);
                  final userReview = _getUserReview(booking.id);

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: hasReviewed 
                            ? _getStatusColor(booking.status, theme) 
                            : theme.colorScheme.secondary,
                        width: hasReviewed ? 1.5 : 2.0,
                      ),
                    ),
                    child: Container(
                      decoration: hasReviewed ? null : BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.secondaryContainer.withOpacity(0.3),
                            theme.colorScheme.tertiaryContainer.withOpacity(0.3),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with status badge and review indicator
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    'Booking #${booking.id.toString().padLeft(6, '0')}',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Row(
                                  children: [
                                    if (!hasReviewed)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.secondary,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.rate_review, 
                                              size: 12, 
                                              color: theme.colorScheme.onSecondary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Review Needed',
                                              style: theme.textTheme.labelSmall?.copyWith(
                                                color: theme.colorScheme.onSecondary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    _buildStatusChip(status, theme),
                                  ],
                                ),
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

                            const SizedBox(height: 20),

                            // Review Section
                            if (hasReviewed && userReview != null) ...[
                              // Show existing review
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.rate_review, size: 20, color: theme.colorScheme.primary),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Your Review',
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                        const Spacer(),
                                        Row(
                                          children: List.generate(5, (starIndex) {
                                            return Icon(
                                              starIndex < userReview.rating ? Icons.star : Icons.star_border,
                                              color: theme.colorScheme.tertiary, // Use theme color for stars
                                              size: 16,
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      userReview.comment.isNotEmpty ? userReview.comment : 'No comment provided',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Reviewed on ${DateFormat('MMM d, yyyy').format(userReview.createdAt)}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              // Show review button for unreviewed bookings
                              Center(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.rate_review),
                                  style: theme.elevatedButtonTheme.style?.copyWith(
                                    backgroundColor: WidgetStateProperty.all(theme.colorScheme.primary),
                                  ),
                                  onPressed: () => _showReviewDialog(context, booking, repo),
                                  label: const Text("Review this ride"),
                                ),
                              ),
                            ],
                          ],
                        ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserReviewsScreen(),
            ),
          );
        },
        icon: const Icon(Icons.rate_review),
        label: const Text('My Reviews'),
        tooltip: 'View all my reviews',
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
          color: theme.colorScheme.onPrimary, // Use theme color for text
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
      case 'COMPLETE':
        return theme.colorScheme.primary; // Use theme color for completed status
      case 'PENDING':
        return theme.colorScheme.primary; // Use theme color for pending status
      case 'CANCELLED':
        return theme.colorScheme.error; // Use theme color for error/cancelled status
      case 'CONFIRMED':
        return theme.colorScheme.primary;
      default:
        return theme.colorScheme.outline; // Use theme color for default status
    }
  }
}