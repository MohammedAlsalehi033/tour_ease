import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart'; // NEW: Import the animation package
import 'package:intl/intl.dart';
import 'package:tour_ease/controller/rideSharing/offers/offers_bloc.dart';
import 'package:tour_ease/controller/rideSharing/offers/offers_state.dart';
import 'package:tour_ease/controller/rideSharing/offers/offers_event.dart';
import 'package:tour_ease/model/rideSharing/offer/offerModel.dart';
import 'package:tour_ease/model/userManagment/user.dart';
import 'package:tour_ease/components/profileAvatar.dart';

class NotifiactionScreen extends StatefulWidget {
  const NotifiactionScreen({super.key});

  @override
  State<NotifiactionScreen> createState() => _NotifiactionScreenState();
}

class _NotifiactionScreenState extends State<NotifiactionScreen> {
  @override
  void initState() {
    super.initState();
    // Use a post-frame callback to ensure context is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OfferBloc>().add(GetReceivedOffersEvent(userId: UserModel().id));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OfferBloc, OfferState>(
      listener: (context, state) {
        if (state is OfferAccepted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Offer accepted successfully'),
                ],
              ),
              backgroundColor: Colors.green, // This is acceptable for universal success feedback
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)), // CHANGED: Added border radius
              ),
              margin: EdgeInsets.all(16),
              duration: Duration(seconds: 3),
            ),
          );
          context.read<OfferBloc>().add(GetReceivedOffersEvent(userId: UserModel().id));
        } else if (state is OfferRejected) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.cancel, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Offer rejected successfully'),
                ],
              ),
              backgroundColor: Colors.red, // This is acceptable for universal error feedback
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)), // CHANGED: Added border radius
              ),
              margin: EdgeInsets.all(16),
              duration: Duration(seconds: 3),
            ),
          );
          context.read<OfferBloc>().add(GetReceivedOffersEvent(userId: UserModel().id));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Notifications"),
            centerTitle: true,
            elevation: 0,
          ),
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(OfferState state) {
    if (state is OfferLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is OfferError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.message}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<OfferBloc>().add(GetReceivedOffersEvent(userId: UserModel().id)),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    } else if (state is OffersLoaded) {
      final List<OfferModel> offers = state.offers;
      if (offers.isEmpty) {
        // NEW: Added animation to the empty state
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_off_outlined, size: 64, color: Theme.of(context).textTheme.bodySmall?.color),
              const SizedBox(height: 16),
              Text(
                'No notifications available',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final offer = offers[index];

          final senderName = offer.sender?['username'] ?? 'Unknown User';
          final formattedDate = DateFormat('MMM d').format(offer.createdAt);
          final formattedTime = DateFormat('h:mm a').format(offer.createdAt);

          String routeInfo = 'Trip details unavailable';
          if (offer.listing != null) {
            final startLoc = offer.listing!['startLocationText'] ?? '';
            final endLoc = offer.listing!['endLocationText'] ?? '';
            if (startLoc.isNotEmpty && endLoc.isNotEmpty) {
              routeInfo = '$startLoc → $endLoc';
            }
          }

          Color statusColor;
          switch (offer.status.toLowerCase()) {
            case 'pending':
              statusColor = Colors.orange;
              break;
            case 'accepted':
              statusColor = Colors.green;
              break;
            case 'rejected':
              statusColor = Theme.of(context).colorScheme.error; // CHANGED: Use theme color
              break;
            default:
              statusColor = Colors.grey;
          }

          final mediaUrls = offer.sender?['mediaUrls'];
          final hasImage = mediaUrls != null && mediaUrls is List && mediaUrls.isNotEmpty;

          final departureTimeStr = offer.listing?["departureTime"];
          final bool hasDepartureTime = departureTimeStr != null;
          final departureTime = hasDepartureTime ? DateTime.tryParse(departureTimeStr) : null;
          final isOutDated = departureTime != null ? DateTime.now().isAfter(departureTime) : false;

          // NEW: Added animation to each card
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.5), width: 0.5),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                _showOfferDetailsBottomSheet(context, offer);
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileAvatar(
                          imageURL: hasImage ? mediaUrls[0] : null,
                          userName: senderName,
                          radius: 22,
                          userId: offer.sender?['id'] ?? '',
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    senderName,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '$formattedDate at $formattedTime',
                                    style: Theme.of(context).textTheme.bodySmall, // CHANGED: Use theme text style
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                routeInfo,
                                style: Theme.of(context).textTheme.bodyMedium, // CHANGED: Use theme text style
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.airline_seat_recline_normal, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${offer.seatsRequested} seat(s)',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color), // CHANGED
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(Icons.attach_money, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                                      const SizedBox(width: 4),
                                      Text(
                                        '\$${offer.pricePerSeat.toStringAsFixed(2)}',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color, fontWeight: FontWeight.bold), //CHANGED
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      offer.status.toUpperCase(),
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (offer.status.toLowerCase() == 'pending')
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: isOutDated
                            ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text("This offer has expired", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.error)),
                          ),
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => _handleOfferResponse(context, offer, 'rejected'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Theme.of(context).colorScheme.error, // CHANGED
                                side: BorderSide(color: Theme.of(context).colorScheme.error), // CHANGED
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              child: const Text('Decline'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () => _handleOfferResponse(context, offer, 'accepted'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green, // CHANGED
                                foregroundColor: Colors.white, // CHANGED
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              child: const Text('Accept'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: (100 * index).ms).slideY(begin: 0.2, curve: Curves.easeInOut);
        },
      );
    }
    return const Center(child: Text('No notifications'));
  }

  void _showOfferDetailsBottomSheet(BuildContext context, OfferModel offer) {
    // ... (rest of the data parsing logic is the same)
    final senderName = offer.sender?['username'] ?? 'Unknown User';
    final formattedFullDate = DateFormat('EEEE, MMM d, yyyy').format(offer.createdAt);
    final formattedTime = DateFormat('h:mm a').format(offer.createdAt);
    String startLocation = 'N/A', endLocation = 'N/A', tripDate = "N/A", tripTime = "N/A";

    if (offer.listing != null) {
      startLocation = offer.listing!['startLocationText'] ?? 'N/A';
      endLocation = offer.listing!['endLocationText'] ?? 'N/A';
      if (offer.listing!['departureTime'] != null) {
        DateTime? departureDateTime = DateTime.tryParse(offer.listing!['departureTime']);
        if (departureDateTime != null) {
          tripDate = DateFormat('EEEE, MMM d').format(departureDateTime);
          tripTime = DateFormat('h:mm a').format(departureDateTime);
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // CHANGED: Use theme color for the background, making it dark-mode compatible.
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    // CHANGED: Use a theme-aware color for the drag handle
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Expanded(
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Offer Details',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith( // CHANGED
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Received on $formattedFullDate at $formattedTime',
                                style: Theme.of(context).textTheme.bodySmall, // CHANGED
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _buildStatusIndicator(offer.status),
                                  const SizedBox(width: 16),
                                  if (offer.status.toLowerCase() == 'pending')
                                    Expanded(
                                      child: Text(
                                        'This offer requires your response',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith( // CHANGED
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const Divider(height: 32),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildSectionTitle(context, 'From'),
                            _buildDetailRow(context, icon: Icons.person, title: senderName, subtitle: 'Sender'),
                            const SizedBox(height: 24),
                            _buildSectionTitle(context, 'Trip Information'),
                            _buildDetailRow(context, icon: Icons.location_on_outlined, title: 'From: $startLocation'),
                            const SizedBox(height: 8),
                            _buildDetailRow(context, icon: Icons.location_on, title: 'To: $endLocation'),
                            const SizedBox(height: 8),
                            _buildDetailRow(context, icon: Icons.calendar_today, title: tripDate, subtitle: tripTime),
                            const SizedBox(height: 24),
                            _buildSectionTitle(context, 'Offer Details'),
                            _buildDetailRow(context, icon: Icons.airline_seat_recline_normal, title: '${offer.seatsRequested} seat(s) requested'),
                            const SizedBox(height: 8),
                            _buildDetailRow(context, icon: Icons.attach_money, title: '\$${offer.pricePerSeat.toStringAsFixed(2)} per seat', subtitle: 'Total: \$${(offer.pricePerSeat * offer.seatsRequested).toStringAsFixed(2)}'),
                            if (offer.message != null && offer.message!.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              _buildSectionTitle(context, 'Message'),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  // CHANGED: Use theme colors for the message box
                                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Theme.of(context).dividerColor),
                                ),
                                child: Text(offer.message!, style: Theme.of(context).textTheme.bodyLarge), // CHANGED
                              ),
                            ],
                            const SizedBox(height: 24),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
                if (offer.status.toLowerCase() == 'pending')
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor, // CHANGED
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _handleOfferResponse(context, offer, 'rejected');
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.error, // CHANGED
                              side: BorderSide(color: Theme.of(context).colorScheme.error), // CHANGED
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Decline Offer'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _handleOfferResponse(context, offer, 'accepted');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Accept Offer'),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  // The helper widgets below are now theme-aware.

  Widget _buildStatusIndicator(String status) {
    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case 'accepted':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Theme.of(context).colorScheme.error; // CHANGED
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 18, color: statusColor),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary, // CHANGED
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, {required IconData icon, required String title, String? subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1), // CHANGED
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary), // CHANGED
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500), // CHANGED
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium, // CHANGED
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _handleOfferResponse(BuildContext context, OfferModel offer, String status) {
    if (status == "accepted") {
      context.read<OfferBloc>().add(AcceptOfferEvent(offer.id));
    } else if (status == "rejected") {
      context.read<OfferBloc>().add(RejectOfferEvent(offer.id));
    }
  }
}