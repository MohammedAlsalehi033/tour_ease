import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tour_ease/model/tripPlanner/tripPlannerModels.dart';
import 'package:tour_ease/controller/tripPlanner/tripPlannerBloc.dart';
import 'package:tour_ease/utils/currency_formatter.dart';

class ConfirmTripPage extends StatefulWidget {
  final TripPlanResponse tripPlan;
  final TransportationOption? outbound;
  final TransportationOption? returnTransport;
  final AccommodationOption? accommodation;

  const ConfirmTripPage({
    Key? key,
    required this.tripPlan,
    this.outbound,
    this.returnTransport,
    this.accommodation,
  }) : super(key: key);

  @override
  State<ConfirmTripPage> createState() => _ConfirmTripPageState();
}

class _ConfirmTripPageState extends State<ConfirmTripPage> {
  void _savePlan() {
    // Get the original request from the BLoC state
    final originalRequest = context.read<TripPlannerBloc>().state.originalRequest;
    
    // Calculate total cost
    final outboundCost = widget.outbound?.totalCost ?? 0;
    final returnCost = widget.returnTransport?.totalCost ?? 0;
    final accommodationCost = widget.accommodation?.totalCost ?? 0;
    final totalCost = outboundCost + returnCost + accommodationCost;

    // Build plan data from the trip plan
    final planData = _buildPlanData();

    context.read<TripPlannerBloc>().add(
      SaveTripPlan(
        planName: widget.tripPlan.optimalPlan?.planName ?? 'My Trip Plan',
        startLocation: originalRequest?.startLocation ?? widget.outbound?.startLocationText ?? 'Unknown',
        endLocation: originalRequest?.endLocation ?? widget.outbound?.endLocationText ?? 'Unknown',
        startTime: originalRequest?.startTime.toIso8601String() ?? widget.outbound?.departureTime.toIso8601String() ?? DateTime.now().toIso8601String(),
        endTime: originalRequest?.endTime.toIso8601String() ?? widget.returnTransport?.arrivalTime.toIso8601String() ?? DateTime.now().add(const Duration(days: 3)).toIso8601String(),
        numberOfTravelers: originalRequest?.numberOfTravelers ?? 2,
        budget: originalRequest?.budget ?? totalCost,
        interests: originalRequest?.interests,
        needsReturnTransport: originalRequest?.needsReturnTransport ?? widget.returnTransport != null,
        selectedOutboundTransportId: widget.outbound?.id != null ? int.tryParse(widget.outbound!.id) : null,
        selectedReturnTransportId: widget.returnTransport?.id != null ? int.tryParse(widget.returnTransport!.id) : null,
        selectedAccommodationId: widget.accommodation?.id != null ? int.tryParse(widget.accommodation!.id) : null,
        selectedRoomAllocations: null, // TODO: get from accommodation selection
        seatsNeeded: originalRequest?.numberOfTravelers ?? 2,
        planData: planData,
        notes: widget.tripPlan.optimalPlan?.description,
        tags: [originalRequest?.endLocation ?? widget.outbound?.endLocationText ?? 'Unknown'],
      ),
    );
  }

  Map<String, dynamic> _buildPlanData() {
    return {
      'tripPlan': {
        'optimalPlan': widget.tripPlan.optimalPlan != null ? {
          'planName': widget.tripPlan.optimalPlan!.planName,
          'description': widget.tripPlan.optimalPlan!.description,
        } : null,
        'itinerary': widget.tripPlan.itinerary.map((day) => {
          'day': day.day,
          'date': day.date,
          'dayOfWeek': day.dayOfWeek,
          'theme': day.theme,
          'totalDuration': day.totalDuration,
          'totalEstimatedCost': day.totalEstimatedCost,
          'activities': day.activities.map((activity) => {
            'time': activity.time,
            'title': activity.title,
            'description': activity.description,
            'location': {
              'name': activity.location.name,
              'coordinates': {
                'lat': activity.location.coordinates.lat,
                'lng': activity.location.coordinates.lng,
              }
            },
            'duration': activity.duration,
            'estimatedCost': activity.estimatedCost,
            'category': activity.category,
          }).toList(),
        }).toList(),
      },
      'selectedOptions': {
        'outbound': widget.outbound?.id,
        'return': widget.returnTransport?.id,
        'accommodation': widget.accommodation?.id,
      },
      'totalCost': (widget.outbound?.totalCost ?? 0) + (widget.returnTransport?.totalCost ?? 0) + (widget.accommodation?.totalCost ?? 0),
    };
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
                        if ((widget.tripPlan.optimalPlan?.description ?? '').isNotEmpty) Text(widget.tripPlan.optimalPlan!.description!, style: theme.textTheme.bodyMedium),
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
                            onPressed: () {
                              // Placeholder: booking logic to be implemented later
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking started (placeholder)')));
                            },
                            child: const Text('Book All'),
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
