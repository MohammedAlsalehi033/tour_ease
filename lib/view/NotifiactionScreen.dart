import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tour_ease/controller/rideSharing/offers/offers_bloc.dart';
import 'package:tour_ease/controller/rideSharing/offers/offers_state.dart';
import 'package:tour_ease/controller/rideSharing/offers/offers_event.dart';
import 'package:tour_ease/model/rideSharing/offer/offerModel.dart';
import 'package:tour_ease/model/userManagment/user.dart';

class NotifiactionScreen extends StatefulWidget {
  const NotifiactionScreen({super.key});

  @override
  State<NotifiactionScreen> createState() => _NotifiactionScreenState();
}

class _NotifiactionScreenState extends State<NotifiactionScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OfferBloc>().add(GetReceivedOffersEvent(userId: UserModel().id));
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
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
              ),
              margin: EdgeInsets.all(16),
              duration: Duration(seconds: 3),
            ),
          );
          // Refresh the list after a state change
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
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
              ),
              margin: EdgeInsets.all(16),
              duration: Duration(seconds: 3),
            ),
          );
          // Refresh the list after a state change
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
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No notifications available',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final offer = offers[index];

          // Essential data for card
          final senderName = offer.sender != null && offer.sender!['username'] != null
              ? offer.sender!['username']
              : 'Unknown User';

          final formattedDate = DateFormat('MMM d').format(offer.createdAt);
          final formattedTime = DateFormat('h:mm a').format(offer.createdAt);

          // Display trip route (minimal version for card)
          String routeInfo = 'Trip details unavailable';
          if (offer.listing != null) {
            final startLoc = offer.listing!['startLocationText']?? '';
            final endLoc = offer.listing!['endLocationText'] ?? '';

            if (startLoc.isNotEmpty && endLoc.isNotEmpty) {
              routeInfo = '$startLoc → $endLoc';
            }
          }

          // Status color
          Color statusColor;
          switch (offer.status.toLowerCase()) {
            case 'pending':
              statusColor = Colors.orange;
              break;
            case 'accepted':
              statusColor = Colors.green;
              break;
            case 'rejected':
              statusColor = Colors.red;
              break;
            default:
              statusColor = Colors.grey;
          }
          final mediaUrls = offer.sender?['mediaUrls'];

          final hasImage = mediaUrls != null && mediaUrls is List && mediaUrls.isNotEmpty;
      final departureTime = DateTime.parse(offer.listing?["departureTime"]) ;

      final hasDepartureTime = departureTime;
          final isOutDated = DateTime.now().isAfter(departureTime);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 0.5),
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
                        // Avatar for sender
                        CircleAvatar(
                          backgroundImage: hasImage ? NetworkImage(mediaUrls[0]) : null,

                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                          child: hasImage
                              ? null // If there is an image, the child should be null
                              : Text(
                            senderName.isNotEmpty ? senderName[0].toUpperCase() : '?',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Main content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    senderName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '$formattedDate at $formattedTime',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                routeInfo,
                                style: const TextStyle(fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Price and seats
                                  Row(
                                    children: [
                                      Icon(Icons.airline_seat_recline_normal,
                                          size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${offer.seatsRequested} seat(s)',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(Icons.attach_money,
                                          size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(
                                        '\$${offer.pricePerSeat.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Status chip
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
                    // Action buttons for pending offers
                    if (offer.status.toLowerCase() == 'pending')
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child:  isOutDated ?  Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(child: Text("this offer is expired", style:  Theme.of(context).textTheme.titleMedium,)),
                        ): Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(

                              onPressed: () => _handleOfferResponse(context, offer, 'rejected'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
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
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
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
          );
        },
      );
    }

    // Default empty state
    return const Center(child: Text('No notifications'));
  }

  void _showOfferDetailsBottomSheet(BuildContext context, dynamic offer) {
    // Get all data from offer model
    final senderName = offer.sender != null && offer.sender!['username'] != null
        ? offer.sender!['username']
        : 'Unknown User';

    final formattedFullDate = DateFormat('EEEE, MMM d, yyyy').format(offer.createdAt);
    final formattedTime = DateFormat('h:mm a').format(offer.createdAt);

    String routeInfo = 'Trip details unavailable';
    String startLocation = 'N/A';
    String endLocation = 'N/A';
    String tripDate = "Date not specified";
    String tripTime = "Time not specified";

    print(offer.toString());

    // Handle listing data
    if (offer.listing != null) {
      startLocation = offer.listing!['startLocationText'] ?? 'N/A';
      endLocation = offer.listing!['endLocationText'] ?? 'N/A';

      // Format trip details from listing
      if (offer.listing!['departureTime'] != null) {
        DateTime departureDateTime = DateTime.parse(offer.listing!['departureTime']);
        tripDate = DateFormat('EEEE, MMM d').format(departureDateTime);
        tripTime = DateFormat('h:mm a').format(departureDateTime);
      }

      if (startLocation != 'N/A' && endLocation != 'N/A') {
        routeInfo = '$startLocation to $endLocation';
      }
    }

    // Handle request data
    if (offer.request != null) {
      startLocation = offer.request!['startLocationText'] ?? startLocation;
      endLocation = offer.request!['endLocationText'] ?? endLocation;

      // Format trip details from request
      if (offer.request!['departureTime'] != null) {
        DateTime departureDateTime = DateTime.parse(offer.request!['departureTime']);
        tripDate = DateFormat('EEEE, MMM d').format(departureDateTime);
        tripTime = DateFormat('h:mm a').format(departureDateTime);
      }

      if (startLocation != 'N/A' && endLocation != 'N/A') {
        routeInfo = '$startLocation to $endLocation';
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
                // Drag handle
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                // Content
                Expanded(
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      // Header Section
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Offer Details',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Received on $formattedFullDate at $formattedTime',
                                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                              ),
                              const SizedBox(height: 16),

                              // Status Row
                              Row(
                                children: [
                                  _buildStatusIndicator(offer.status),
                                  const SizedBox(width: 24),
                                  if (offer.status.toLowerCase() == 'pending')
                                    Expanded(
                                      child: Text(
                                        'This offer requires your response',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
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

                      // Main Content
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // User Info Section
                            _buildSectionTitle(context, 'From'),
                            _buildDetailRow(
                              context,
                              icon: Icons.person,
                              title: senderName,
                              subtitle: 'Sender',
                            ),
                            const SizedBox(height: 24),

                            // Trip Details Section
                            _buildSectionTitle(context, 'Trip Information'),
                            _buildDetailRow(
                              context,
                              icon: Icons.location_on_outlined,
                              title: 'From: $startLocation',
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              context,
                              icon: Icons.location_on,
                              title: 'To: $endLocation',
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              context,
                              icon: Icons.calendar_today,
                              title: tripDate,
                              subtitle: tripTime,
                            ),
                            const SizedBox(height: 24),

                            // Offer Details Section
                            _buildSectionTitle(context, 'Offer Details'),
                            _buildDetailRow(
                              context,
                              icon: Icons.airline_seat_recline_normal,
                              title: '${offer.seatsRequested} seat(s) requested',
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              context,
                              icon: Icons.attach_money,
                              title: '\$${offer.pricePerSeat.toStringAsFixed(2)} per seat',
                              subtitle: 'Total: \$${(offer.pricePerSeat * offer.seatsRequested).toStringAsFixed(2)}',
                            ),

                            // Message Section (if available)
                            if (offer.message != null && offer.message!.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              _buildSectionTitle(context, 'Message'),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                ),
                                child: Text(
                                  offer.message!,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            ],

                            // Bottom padding for actions
                            const SizedBox(height: 24),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Buttons (if pending)
                if (offer.status.toLowerCase() == 'pending')
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
        statusColor = Colors.red;
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
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context, {
        required IconData icon,
        required String title,
        String? subtitle,
      }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _handleOfferResponse(BuildContext context, dynamic offer, String status) {
    // Dispatch the appropriate event based on the status
    if (status == "accepted") {
      context.read<OfferBloc>().add(AcceptOfferEvent(offer.id));
    } else if (status == "rejected") {
      context.read<OfferBloc>().add(RejectOfferEvent(offer.id));
    }

    // Note: The snackbar feedback is now handled in the BlocConsumer listener
    // and the list refresh is also handled there after state changes
  }
}