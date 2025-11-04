import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tour_ease/model/tripPlanner/tripPlannerModels.dart';
import 'package:tour_ease/utils/currency_formatter.dart';

class ConfirmTripPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
  final theme = Theme.of(context);

    final outboundCost = outbound?.totalCost ?? 0;
    final returnCost = returnTransport?.totalCost ?? 0;
    final accommodationCost = accommodation?.totalCost ?? 0;
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
                      Text(tripPlan.optimalPlan?.planName ?? 'Trip Plan', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8.h),
                      if ((tripPlan.optimalPlan?.description ?? '').isNotEmpty) Text(tripPlan.optimalPlan!.description!, style: theme.textTheme.bodyMedium),
                      SizedBox(height: 16.h),

                      sectionTitle('Outbound'),
                      if (outbound != null)
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(outbound!.vehicleType, style: theme.textTheme.titleMedium),
                                SizedBox(height: 6.h),
                                Text(fmtDate(outbound!.departureTime)),
                                SizedBox(height: 6.h),
                                // Detailed origin/destination fields depend on model shape; show available info only
                                Text('Cost: ${CurrencyFormatter.formatPKR(outboundCost)}', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),

                      sectionTitle('Return'),
                      if (returnTransport != null)
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(returnTransport!.vehicleType, style: theme.textTheme.titleMedium),
                                SizedBox(height: 6.h),
                                Text(fmtDate(returnTransport!.departureTime)),
                                SizedBox(height: 6.h),
                                Text('Cost: ${CurrencyFormatter.formatPKR(returnCost)}', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),

                      sectionTitle('Accommodation'),
                      if (accommodation != null)
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(accommodation!.name, style: theme.textTheme.titleMedium),
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
                      onPressed: () {
                        // Placeholder: save logic will be implemented later
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plan saved (placeholder)')));
                      },
                      child: const Text('Save Plan'),
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
