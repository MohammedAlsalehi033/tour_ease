import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tour_ease/model/tripPlanner/tripPlannerModels.dart';
import 'package:tour_ease/controller/tripPlanner/tripPlannerBloc.dart';
import 'package:tour_ease/utils/currency_formatter.dart';
import 'package:tour_ease/Services/stripe_service.dart';
import 'package:tour_ease/model/userManagment/user.dart';
import 'package:tour_ease/utils/trip_plan_formatter.dart';

class ConfirmTripPage extends StatefulWidget {
  final TripPlannerResponse tripPlan;
  final TransportOption? outbound;
  final TransportOption? returnTransport;
  final AccommodationOption? accommodation;
  final List<RoomSelection>? selectedRoomAllocations;

  const ConfirmTripPage({
    Key? key,
    required this.tripPlan,
    this.outbound,
    this.returnTransport,
    this.accommodation,
    this.selectedRoomAllocations,
  }) : super(key: key);

  @override
  State<ConfirmTripPage> createState() => _ConfirmTripPageState();
}

class _ConfirmTripPageState extends State<ConfirmTripPage> {
  bool _isProcessingPayment = false;

  void _savePlan() {
    // Validate required selections
    if (widget.outbound == null || widget.accommodation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both transport and accommodation'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Get the original request from the BLoC state
    final originalRequest = context.read<TripPlannerBloc>().state.originalRequest;
    
    if (originalRequest == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Original search parameters not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Use TripPlanFormatter to create properly formatted SavePlanRequest
    final saveRequest = TripPlanFormatter.createSavePlanRequest(
      planName: widget.tripPlan.optimalPlan?.planName ?? 'My Trip Plan',
      description: widget.tripPlan.optimalPlan?.description,
      selectedOutbound: widget.outbound!,
      selectedReturn: widget.returnTransport ?? widget.outbound!, // Fallback if no return
      selectedAccommodation: widget.accommodation!,
      selectedRoomAllocations: widget.selectedRoomAllocations,
      selectedActivities: [], // Add activities if needed
      tags: [], // Add tags if needed
      originalSearchParams: originalRequest,
      fullTripResults: widget.tripPlan,
    );

    // Validate the request before saving
    if (!TripPlanFormatter.validateSavePlanRequest(saveRequest)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Invalid plan data'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Dispatch save event to BLoC
    context.read<TripPlannerBloc>().add(
      SaveTripPlan(request: saveRequest),
    );

    // Show loading/success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saving plan...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _bookTrip() async {
    if (widget.outbound == null || widget.accommodation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both transport and accommodation')),
      );
      return;
    }

    // Calculate total cost
    final outboundCost = widget.outbound?.totalCost ?? 0;
    final returnCost = widget.returnTransport?.totalCost ?? 0;
    final accommodationCost = widget.accommodation?.totalCost ?? 0;
    final totalCost = outboundCost + returnCost + accommodationCost;

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      // Get user info
      final user = UserModel();
      if (user.id.isEmpty || user.email.isEmpty) {
        throw Exception('User not logged in');
      }

      // Step 1: Process Stripe payment first
      final paymentResult = await StripeService.instance.makePayment(
        amount: totalCost,
        currency: 'usd',
        bookingId: 0, // Temporary ID for payment tracking
        customerEmail: user.email,
        user: user,
      );

      if (paymentResult['success'] != true) {
        // Payment failed or cancelled
        setState(() {
          _isProcessingPayment = false;
        });

        if (paymentResult['cancelled'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment cancelled')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Payment failed: ${paymentResult['error'] ?? 'Unknown error'}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
        return;
      }

      // Step 2: Payment successful, now create the booking
      final paymentIntentId = paymentResult['paymentIntentId'];
      
      // Get booking details from the trip data
      final originalRequest = context.read<TripPlannerBloc>().state.originalRequest;
      final seatsNeeded = originalRequest?.numberOfTravelers ?? widget.accommodation?.totalGuests ?? 1;
      final checkInDate = widget.accommodation?.checkInDate ?? originalRequest?.startTime ?? DateTime.now();
      final checkOutDate = widget.accommodation?.checkOutDate ?? originalRequest?.endTime ?? DateTime.now().add(const Duration(days: 3));
      
      final bookingRequest = BookingRequest(
        outboundTransportId: widget.outbound!.id,
        returnTransportId: widget.returnTransport?.id,
        seatsNeeded: seatsNeeded,
        accommodationId: widget.accommodation!.id,
        selectedRoomAllocations: widget.selectedRoomAllocations ?? [],
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        paymentMethod: 'stripe',
        stripePaymentIntentId: paymentIntentId,
        specialRequests: null,
      );

      // Create booking via BLoC
      context.read<TripPlannerBloc>().add(
        ConfirmBooking(request: bookingRequest),
      );

      // Wait for booking confirmation
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _isProcessingPayment = false;
      });

      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Booking Confirmed!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60,
                ),
                SizedBox(height: 16.h),
                const Text('Your trip has been successfully booked.'),
                SizedBox(height: 8.h),
                Text('Payment ID: $paymentIntentId'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to results
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessingPayment = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final outboundCost = widget.outbound?.totalCost ?? 0;
    final returnCost = widget.returnTransport?.totalCost ?? 0;
    final accommodationCost = widget.accommodation?.totalCost ?? 0;
    final total = outboundCost + returnCost + accommodationCost;

    String fmtDate(dynamic v) {
      if (v == null) return '';
      try {
        if (v is String) {
          final dt = DateTime.parse(v);
          return DateFormat('EEE, MMM d • h:mm a').format(dt);
        }
        if (v is DateTime) {
          return DateFormat('EEE, MMM d • h:mm a').format(v);
        }
        return v.toString();
      } catch (_) {
        return v.toString();
      }
    }

    Widget sectionTitle(String t) => Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Text(t, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        );

    return BlocListener<TripPlannerBloc, TripPlannerState>(
      listener: (context, state) {
        if (state.savedPlan != null && !state.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Plan saved successfully! ID: ${state.savedPlan!.id}'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state.error != null && !state.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save plan: ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Confirm & Save'),
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.tripPlan.optimalPlan?.planName ?? 'Trip Plan', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8.h),
                        if ((widget.tripPlan.optimalPlan?.description ?? '').isNotEmpty) Text(widget.tripPlan.optimalPlan!.description, style: theme.textTheme.bodyMedium),
                        SizedBox(height: 16.h),

                        sectionTitle('Outbound'),
                        if (widget.outbound != null)
                          Card(
                            child: Padding(
                              padding: EdgeInsets.all(12.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.outbound!.vehicleType, style: theme.textTheme.titleMedium),
                                  SizedBox(height: 6.h),
                                  Text(fmtDate(widget.outbound!.departureTime)),
                                SizedBox(height: 6.h),
                                // Detailed origin/destination fields depend on model shape; show available info only
                                Text('Cost: ${CurrencyFormatter.formatPKR(outboundCost)}', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),

                      sectionTitle('Return'),
                      if (widget.returnTransport != null)
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.returnTransport!.vehicleType, style: theme.textTheme.titleMedium),
                                SizedBox(height: 6.h),
                                Text(fmtDate(widget.returnTransport!.departureTime)),
                                SizedBox(height: 6.h),
                                Text('Cost: ${CurrencyFormatter.formatPKR(returnCost)}', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),

                      sectionTitle('Accommodation'),
                      if (widget.accommodation != null)
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.accommodation!.name, style: theme.textTheme.titleMedium),
                                SizedBox(height: 6.h),
                                Text('Cost: ${CurrencyFormatter.formatPKR(accommodationCost)}', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),

                      SizedBox(height: 20.h),

                      Text('Cost Breakdown', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      SizedBox(height: 12.h),
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(12.w),
                          child: Column(
                            children: [
                              _buildCostRow('Outbound', CurrencyFormatter.formatPKR(outboundCost), theme),
                              Divider(),
                              _buildCostRow('Return', CurrencyFormatter.formatPKR(returnCost), theme),
                              Divider(),
                              _buildCostRow('Accommodation', CurrencyFormatter.formatPKR(accommodationCost), theme),
                              Divider(),
                              _buildCostRow('Total', CurrencyFormatter.formatPKR(total), theme, isTotal: true),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ),

                // Action Row
                SizedBox(height: 12.h),
                BlocBuilder<TripPlannerBloc, TripPlannerState>(
                  builder: (context, state) {
                    final isSaving = state.isLoading;
                    
                    return Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isSaving ? null : _savePlan,
                            child: isSaving
                                ? SizedBox(
                                    height: 20.h,
                                    width: 20.w,
                                    child: const CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Save Plan'),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: (isSaving || _isProcessingPayment) ? null : _bookTrip,
                            child: _isProcessingPayment
                                ? SizedBox(
                                    height: 20.h,
                                    width: 20.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Book All'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCostRow(String label, String value, ThemeData theme, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: isTotal ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold) : theme.textTheme.bodyMedium),
          Text(value, style: isTotal ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold) : theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
