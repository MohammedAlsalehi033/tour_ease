import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tour_ease/model/tripPlanner/tripPlannerModels.dart';
import 'package:tour_ease/model/tripPlanner/saved_plan_models.dart';
import 'package:tour_ease/Services/tripPlanner/saved_plans_service.dart';
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
  bool _isSaving = false;

  Future<void> _savePlan() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Extract location from transport or accommodation if available
      final startLoc = widget.outbound?.startLocationText ?? widget.accommodation?.location ?? 'Unknown';
      final endLoc = widget.outbound?.endLocationText ?? widget.accommodation?.location ?? 'Unknown';
      
      final request = SavePlanRequest(
        planName: widget.tripPlan.optimalPlan?.planName ?? 'My Trip Plan',
        startLocation: startLoc,
        endLocation: endLoc,
        startTime: widget.outbound?.departureTime.toIso8601String() ?? DateTime.now().toIso8601String(),
        endTime: widget.returnTransport?.arrivalTime.toIso8601String() ?? DateTime.now().add(const Duration(days: 3)).toIso8601String(),
        numberOfTravelers: 2, // TODO: get from trip request
        budget: widget.tripPlan.metadata.requestedBudget,
        selectedOutboundTransportId: widget.outbound?.id != null ? int.tryParse(widget.outbound!.id) : null,
        selectedReturnTransportId: widget.returnTransport?.id != null ? int.tryParse(widget.returnTransport!.id) : null,
        selectedAccommodationId: widget.accommodation?.id != null ? int.tryParse(widget.accommodation!.id) : null,
        seatsNeeded: 2, // TODO: get from trip request
        planData: _buildPlanData(),
        notes: '',
        tags: [endLoc],
      );

      final response = await SavedPlansService.savePlan(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Plan saved successfully! ID: ${response.data.id}'),
            backgroundColor: Colors.green,
          ),
        );
        // Optional: Navigate back or to saved plans page
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save plan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Map<String, dynamic> _buildPlanData() {
    return {
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
      'tripSummary': {
        'totalDays': widget.tripPlan.itinerary.length,
        'estimatedTotalCost': {
          'transportation': (widget.outbound?.totalCost ?? 0) + (widget.returnTransport?.totalCost ?? 0),
          'accommodation': widget.accommodation?.totalCost ?? 0,
          'total': (widget.outbound?.totalCost ?? 0) + (widget.returnTransport?.totalCost ?? 0) + (widget.accommodation?.totalCost ?? 0),
        }
      }
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

    return Scaffold(
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
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : _savePlan,
                      child: _isSaving
                          ? SizedBox(
                              height: 20.h,
                              width: 20.w,
                              child: CircularProgressIndicator(strokeWidth: 2),
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
              ),
            ],
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
