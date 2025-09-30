import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tour_ease/controller/rideSharing/offers/offers_bloc.dart';
import 'package:tour_ease/controller/rideSharing/offers/offers_bloc.dart';
import 'package:tour_ease/controller/rideSharing/offers/offers_event.dart';
import 'package:tour_ease/controller/rideSharing/offers/offers_state.dart';
import 'package:tour_ease/model/rideSharing/rideRequest/rideRequestModel.dart';
import 'package:tour_ease/model/userManagment/user.dart';

class TravelerRideRequestDetailsPage extends StatefulWidget {
  final TravelerRideRequestModel travelerRideRequestModel;
  const TravelerRideRequestDetailsPage({super.key, required this.travelerRideRequestModel});
  @override
  State<TravelerRideRequestDetailsPage> createState() => _TravelerRideRequestDetailsPageState();
}

class _TravelerRideRequestDetailsPageState extends State<TravelerRideRequestDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final dateFormat = DateFormat('MMM dd, yyyy • h:mm a');
    final currencyFormat = NumberFormat.currency(symbol: 'PKR ');

    return BlocBuilder<OfferBloc, OfferState>(
  builder: (context, state) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride Request Details', style: textTheme.titleLarge),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRequestOverview(context),
            const SizedBox(height: 24),
            _buildLocationSection(context),
            const SizedBox(height: 24),
            _buildTripDetailsSection(context),
            const SizedBox(height: 24),
            _buildActionButtons(context, widget.travelerRideRequestModel),
          ],
        ),
      ),
    );
  },
);
  }

  Widget _buildRequestOverview(BuildContext context) {
    final theme = Theme.of(context);
    final model = widget.travelerRideRequestModel;
    final dateFormat = DateFormat('MMM dd, yyyy • h:mm a');


    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                  child: Icon(Icons.person, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Request #${model.id}',
                        style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold
                        )),
                    Container(width: 200.w,
                      child: Text('Traveler ID: ${model.travelerId}',overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.access_time, size: 18, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  'Created on ${dateFormat.format(model.createdAt)}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    final theme = Theme.of(context);
    final model = widget.travelerRideRequestModel;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Journey Details',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Icon(Icons.circle, size: 16, color: theme.colorScheme.primary),
                    Container(
                      height: 40,
                      width: 2,
                      color: theme.colorScheme.primary.withOpacity(0.5),
                    ),
                    Icon(Icons.location_pin, size: 24, color: theme.colorScheme.error),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('From', style: theme.textTheme.bodySmall),
                      Text(model.startLocationText, style: theme.textTheme.titleSmall),
                      if (model.startLocationLat != null && model.startLocationLng != null)
                        Text('(${model.startLocationLat!.toStringAsFixed(6)}, ${model.startLocationLng!.toStringAsFixed(6)})',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary)),
                      const SizedBox(height: 24),
                      Text('To', style: theme.textTheme.bodySmall),
                      Text(model.endLocationText, style: theme.textTheme.titleSmall),
                      if (model.endLocationLat != null && model.endLocationLng != null)
                        Text('(${model.endLocationLat!.toStringAsFixed(6)}, ${model.endLocationLng!.toStringAsFixed(6)})',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary)),
                    ],
                  ),
                ),
              ],
            ),
            if (model.distanceKm != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    Icon(Icons.straight, size: 18, color: theme.colorScheme.secondary),
                    const SizedBox(width: 8),
                    Text(
                      'Distance: ${model.distanceKm!} km',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripDetailsSection(BuildContext context) {
    final theme = Theme.of(context);
    final model = widget.travelerRideRequestModel;
    final dateFormat = DateFormat('MMM dd, yyyy • h:mm a');
    final currencyFormat = NumberFormat.currency(symbol: 'PKR ');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trip Requirements',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildDetailRow(
              context,
              Icons.event,
              'Departure Time',
              dateFormat.format(model.departureTime),
            ),
            const Divider(height: 24),
            _buildDetailRow(
              context,
              Icons.person_add,
              'Seats Needed',
              '${model.seatsNeeded}',
            ),
            const Divider(height: 24),
            _buildDetailRow(
              context,
              Icons.attach_money,
              'Budget',
              currencyFormat.format(model.budget),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.secondary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.bodySmall),
            Text(value, style: theme.textTheme.titleSmall),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, TravelerRideRequestModel model) {
    final theme = Theme.of(context);

    return BlocConsumer<OfferBloc, OfferState>(
      listener: (context, state) {
        if (state is OfferError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Failed to submit offer: ${state.message}',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        } else if (state is SingleOfferLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Offer submitted successfully! You will be notified when the traveler responds.',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          // Navigate back after successful submission
          Future.delayed(Duration(seconds: 1), () {
            Navigator.pop(context);
          });
        }
      },
      builder: (context, state) {
        final isLoading = state is OfferLoading;
        
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: isLoading 
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(Icons.check),
                    label: Text(isLoading ? 'Submitting...' : 'Accept & Make Offer'),
                    onPressed: isLoading 
                        ? null 
                        : () => _submitOffer(context, model),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      disabledBackgroundColor: theme.colorScheme.primary.withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            OutlinedButton.icon(
              icon: Icon(Icons.close),
              label: Text('Decline Request'),
              onPressed: isLoading 
                  ? null 
                  : () => _showDeclineDialog(context),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _submitOffer(BuildContext context, TravelerRideRequestModel model) {
    // Validate that we can make an offer
    if (model.budget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid budget amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (model.seatsNeeded <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid seat requirement'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Submit the offer
    context.read<OfferBloc>().add(
      CreateOfferEvent(
        senderId: UserModel().id,
        recipientId: model.travelerId,
        pricePerSeat: model.budget,
        seatsRequested: model.seatsNeeded,
        message: "I can provide this service. Let's connect to discuss details.",
        transportationRequestId: model.id,
      ),
    );
  }

  void _showDeclineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Decline Request'),
          content: Text(
            'Are you sure you want to decline this ride request? You can always view other requests from the main tab.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close dialog
                Navigator.pop(context); // Go back to previous screen
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Request declined'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text('Decline'),
            ),
          ],
        );
      },
    );
  }
}