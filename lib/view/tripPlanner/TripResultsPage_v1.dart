import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tour_ease/controller/tripPlanner/tripPlannerBloc.dart';
import 'package:tour_ease/model/tripPlanner/tripPlannerModels.dart';
import 'package:tour_ease/utils/currency_formatter.dart';
import 'package:intl/intl.dart';

class TripResultsPage extends StatelessWidget {
  const TripResultsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Your Trip Plans'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: BlocBuilder<TripPlannerBloc, TripPlannerState>(
        builder: (context, state) {
          // Loading state
          if (state.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: colorScheme.primary),
                  SizedBox(height: 24.h),
                  Text(
                    'Creating your perfect trip...',
                    style: theme.textTheme.titleLarge,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Analyzing best options for you',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          // Error state
          if (state.error != null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64.sp,
                      color: colorScheme.error,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Oops! Something went wrong',
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      state.error!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to Search'),
                    ),
                  ],
                ),
              ),
            );
          }

          // No trip plan yet
          if (state.tripPlan == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 64.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No trip plan available',
                    style: theme.textTheme.titleLarge,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Create New Trip'),
                  ),
                ],
              ),
            );
          }

          // Success state - show comprehensive trip details
          final tripPlan = state.tripPlan!;

          return DefaultTabController(
            length: tripPlan.itinerary.isNotEmpty ? 4 : 3,
            child: Column(
              children: [
                // Tab Bar
                Container(
                  color: colorScheme.surface,
                  child: TabBar(
                    labelColor: colorScheme.primary,
                    unselectedLabelColor: colorScheme.onSurfaceVariant,
                    indicatorColor: colorScheme.primary,
                    tabs: [
                      if (tripPlan.itinerary.isNotEmpty)
                        const Tab(icon: Icon(Icons.event_note), text: 'Itinerary'),
                      const Tab(icon: Icon(Icons.flight), text: 'Transport'),
                      const Tab(icon: Icon(Icons.hotel), text: 'Hotels'),
                      const Tab(icon: Icon(Icons.recommend), text: 'Plans'),
                    ],
                  ),
                ),
                
                // Tab Views
                Expanded(
                  child: TabBarView(
                    children: [
                      if (tripPlan.itinerary.isNotEmpty)
                        _buildItineraryTab(tripPlan, theme),
                      _buildTransportationTab(tripPlan, theme),
                      _buildAccommodationsTab(tripPlan, theme),
                      _buildPlansTab(tripPlan, theme),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ITINERARY TAB - Complete day-by-day itinerary
  Widget _buildItineraryTab(TripPlanResponse tripPlan, ThemeData theme) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        if (tripPlan.tripSummary != null) ...[
          _buildTripSummaryCard(tripPlan.tripSummary!, theme),
          SizedBox(height: 16.h),
        ],
        ...tripPlan.itinerary.map((day) => _buildDayItineraryCard(day, theme)),
      ],
    );
  }

  Widget _buildTripSummaryCard(TripSummary summary, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.summarize_rounded, color: colorScheme.primary),
                SizedBox(width: 8.w),
                Text(
                  'Trip Summary',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  Icons.calendar_month,
                  '${summary.totalDays} Days',
                  '${summary.totalNights} Nights',
                  theme,
                ),
                _buildSummaryItem(
                  Icons.payments_rounded,
                  CurrencyFormatter.formatPKR(summary.estimatedTotalCost.total),
                  'Total Cost',
                  theme,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Divider(),
            SizedBox(height: 8.h),
            _buildCostBreakdown(summary.estimatedTotalCost, theme),
            if (summary.budgetStatus.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: _getBudgetStatusColor(summary.budgetStatus, colorScheme).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(_getBudgetStatusIcon(summary.budgetStatus), 
                      color: _getBudgetStatusColor(summary.budgetStatus, colorScheme),
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      summary.budgetStatus == 'within_budget'
                          ? 'Within Budget • ${CurrencyFormatter.formatPKR(summary.remainingBudget)} remaining'
                          : summary.budgetStatus == 'tight'
                              ? 'Tight Budget • ${CurrencyFormatter.formatPKR(summary.remainingBudget)} remaining'
                              : 'Over Budget • ${CurrencyFormatter.formatPKR(summary.remainingBudget.abs())} over',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _getBudgetStatusColor(summary.budgetStatus, colorScheme),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String value, String label, ThemeData theme) {
    return Column(
      children: [
        Icon(icon, size: 32.sp, color: theme.colorScheme.primary),
        SizedBox(height: 8.h),
        Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }

  Widget _buildCostBreakdown(TripCostBreakdown costs, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cost Breakdown:', style: theme.textTheme.titleSmall),
        SizedBox(height: 8.h),
        _buildCostRow('Transportation', costs.transportation, theme),
        _buildCostRow('Accommodation', costs.accommodation, theme),
        _buildCostRow('Activities', costs.activities, theme),
        _buildCostRow('Meals', costs.meals, theme),
      ],
    );
  }

  Widget _buildCostRow(String label, double amount, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(CurrencyFormatter.formatPKR(amount), style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Color _getBudgetStatusColor(String status, ColorScheme colorScheme) {
    switch (status) {
      case 'within_budget':
        return Colors.green;
      case 'tight':
        return Colors.orange;
      case 'over_budget':
        return Colors.red;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  IconData _getBudgetStatusIcon(String status) {
    switch (status) {
      case 'within_budget':
        return Icons.check_circle;
      case 'tight':
        return Icons.warning;
      case 'over_budget':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  Widget _buildDayItineraryCard(DayItinerary day, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: ExpansionTile(
        initiallyExpanded: day.day == 1,
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Day ${day.day}',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(day.theme, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Text('${day.dayOfWeek}, ${day.date}', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 8.h),
          child: Row(
            children: [
              Icon(Icons.access_time, size: 14.sp, color: colorScheme.onSurfaceVariant),
              SizedBox(width: 4.w),
              Text('${day.totalDuration} min'),
              SizedBox(width: 16.w),
              Icon(Icons.payments, size: 14.sp, color: colorScheme.onSurfaceVariant),
              SizedBox(width: 4.w),
              Text(CurrencyFormatter.formatPKR(day.totalEstimatedCost)),
            ],
          ),
        ),
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            itemCount: day.activities.length,
            separatorBuilder: (context, index) => Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                children: [
                  SizedBox(width: 20.w),
                  Container(width: 2.w, height: 24.h, color: colorScheme.outline),
                  SizedBox(width: 12.w),
                  Icon(Icons.arrow_downward, size: 16.sp, color: colorScheme.outline),
                ],
              ),
            ),
            itemBuilder: (context, index) => _buildActivityCard(day.activities[index], theme),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(ItineraryActivity activity, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: () {}, // Could navigate to activity details
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(activity.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      _getCategoryIcon(activity.category),
                      color: _getCategoryColor(activity.category),
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.time,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          activity.title,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (activity.description.isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Text(
                            activity.description,
                            style: theme.textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 8.h),
              
              Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14.sp, color: colorScheme.onSurfaceVariant),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        activity.location.name,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              
              SizedBox(height: 8.h),
              
              Row(
                children: [
                  if (activity.duration > 0) ...[
                    Icon(Icons.schedule, size: 14.sp, color: colorScheme.onSurfaceVariant),
                    SizedBox(width: 4.w),
                    Text('${activity.duration} min', style: theme.textTheme.bodySmall),
                    SizedBox(width: 12.w),
                  ],
                  Icon(Icons.payments, size: 14.sp, color: colorScheme.onSurfaceVariant),
                  SizedBox(width: 4.w),
                  Text(CurrencyFormatter.formatPKR(activity.estimatedCost), style: theme.textTheme.bodySmall),
                  
                  if (activity.placeDetails != null && activity.placeDetails!.rating != null) ...[
                    SizedBox(width: 12.w),
                    Icon(Icons.star, size: 14.sp, color: Colors.amber),
                    SizedBox(width: 4.w),
                    Text(
                      activity.placeDetails!.rating!.toStringAsFixed(1),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
              
              if (activity.placeDetails != null && activity.placeDetails!.photos != null && activity.placeDetails!.photos!.isNotEmpty) ...[
                SizedBox(height: 12.h),
                SizedBox(
                  height: 100.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: activity.placeDetails!.photos!.length,
                    separatorBuilder: (context, index) => SizedBox(width: 8.w),
                    itemBuilder: (context, index) => ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.network(
                        activity.placeDetails!.photos![index],
                        width: 120.w,
                        height: 100.h,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 120.w,
                          color: colorScheme.surfaceVariant,
                          child: Icon(Icons.image, color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              
              if (activity.tips != null && activity.tips!.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_outline, size: 16.sp, color: Colors.blue),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          activity.tips!,
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.blue[900]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'breakfast':
      case 'lunch':
      case 'dinner':
        return Colors.orange;
      case 'attraction':
        return Colors.purple;
      case 'rest':
        return Colors.blue;
      case 'shopping':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'breakfast':
      case 'lunch':
      case 'dinner':
        return Icons.restaurant;
      case 'attraction':
        return Icons.attractions;
      case 'rest':
        return Icons.hotel;
      case 'shopping':
        return Icons.shopping_bag;
      default:
        return Icons.place;
    }
  }

  // TRANSPORTATION TAB - All available transportation options
  Widget _buildTransportationTab(TripPlanResponse tripPlan, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        // Outbound Transportation
        Text(
          'Outbound Transportation (${tripPlan.outboundTransportation.length} options)',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        ...tripPlan.outboundTransportation.map((transport) => 
          _buildTransportCard(transport, theme, colorScheme, isReturn: false)
        ),
        
        SizedBox(height: 24.h),
        
        // Return Transportation
        Text(
          'Return Transportation (${tripPlan.returnTransportation.length} options)',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        ...tripPlan.returnTransportation.map((transport) => 
          _buildTransportCard(transport, theme, colorScheme, isReturn: true)
        ),
      ],
    );
  }

  Widget _buildTransportCard(TransportationOption transport, ThemeData theme, ColorScheme colorScheme, {required bool isReturn}) {
    final departureTime = transport.departureTime;
    final arrivalTime = transport.arrivalTime;
    
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: () {}, // Will add details dialog
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      isReturn ? Icons.flight_land : Icons.flight_takeoff,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transport.providerName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          transport.vehicleType,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.formatPKR(transport.pricePerSeat),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'per seat',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              
              SizedBox(height: 12.h),
              
              // Time and Location
              Row(
                children: [
                  Icon(Icons.schedule, size: 16.sp, color: colorScheme.onSurfaceVariant),
                  SizedBox(width: 4.w),
                  Text(
                    '${_formatTime(departureTime.toIso8601String())} - ${_formatTime(arrivalTime.toIso8601String())}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Spacer(),
                  Icon(Icons.event_seat, size: 16.sp, color: colorScheme.onSurfaceVariant),
                  SizedBox(width: 4.w),
                  Text(
                    '${transport.seatsAvailable} seats',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              
              if (transport.startLocationText != null || transport.endLocationText != null) ...[
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16.sp, color: colorScheme.onSurfaceVariant),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        '${transport.startLocationText ?? ''} → ${transport.endLocationText ?? ''}',
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              
              if (transport.avgRating != null) ...[
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.star, size: 16.sp, color: Colors.amber),
                    SizedBox(width: 4.w),
                    Text(
                      '${transport.avgRating!.toStringAsFixed(1)} (${transport.totalReviews} reviews)',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
              
              if (transport.amenities.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 4.w,
                  children: transport.amenities.take(3).map((amenity) => 
                    Chip(
                      label: Text(amenity, style: theme.textTheme.labelSmall),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    )
                  ).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ACCOMMODATIONS TAB - All available hotels
  Widget _buildAccommodationsTab(TripPlanResponse tripPlan, ThemeData theme) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        Text(
          'Available Accommodations (${tripPlan.accommodations.length})',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        ...tripPlan.accommodations.map((acc) => _buildAccommodationCard(acc, theme)),
      ],
    );
  }

  Widget _buildAccommodationCard(AccommodationOption accommodation, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Images Carousel
          if (accommodation.mediaUrls.isNotEmpty)
            SizedBox(
              height: 200.h,
              child: PageView.builder(
                itemCount: accommodation.mediaUrls.length,
                itemBuilder: (context, index) => Image.network(
                  accommodation.mediaUrls[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: colorScheme.surfaceVariant,
                    child: Icon(Icons.hotel, size: 64.sp, color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
            ),
          
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        accommodation.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, size: 14.sp, color: Colors.white),
                          SizedBox(width: 4.w),
                          Text(
                            accommodation.avgRating.toStringAsFixed(1),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 4.h),
                
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16.sp, color: colorScheme.onSurfaceVariant),
                    SizedBox(width: 4.w),
                    Text(
                      accommodation.location,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                
                if (accommodation.description != null) ...[
                  SizedBox(height: 8.h),
                  Text(
                    accommodation.description!,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                SizedBox(height: 12.h),
                
                // Room Info
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${accommodation.numberOfNights} nights',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            '${accommodation.totalGuests} guests',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            '${accommodation.roomAllocations.length} room(s)',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Cost',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.formatPKR(accommodation.totalCost),
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                if (accommodation.amenities.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: accommodation.amenities.take(5).map((amenity) => 
                      Chip(
                        label: Text(amenity, style: theme.textTheme.labelSmall),
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )
                    ).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // PLANS TAB - Recommended trip plans
  Widget _buildPlansTab(TripPlanResponse tripPlan, ThemeData theme) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        // Optimal Plan Card
        if (tripPlan.optimalPlan != null) ...[
          Text(
            'Best Match',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          _buildPlanCard(tripPlan.optimalPlan!, theme, isOptimal: true),
          SizedBox(height: 24.h),
        ],

        // Recommended Plans Section
        if (tripPlan.recommendedPlans.isNotEmpty) ...[
          Text(
            'Alternative Plans',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          ...tripPlan.recommendedPlans.map((plan) => 
            _buildPlanCard(plan, theme, isOptimal: false),
          ),
        ],
      ],
    );
  }

  Widget _buildPlanCard(TripPlan plan, ThemeData theme, {required bool isOptimal}) {
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: isOptimal ? 4 : 2,
      margin: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isOptimal)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.workspace_premium_rounded, color: colorScheme.onPrimaryContainer, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'BEST MATCH',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.planName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (plan.description != null && plan.description!.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Text(
                    plan.description!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
                SizedBox(height: 16.h),
                
                // Transportation Info
                if (plan.outboundTransportation != null) ...[
                  _buildPlanDetailSection('Outbound', plan.outboundTransportation!, theme),
                  SizedBox(height: 12.h),
                ],
                if (plan.returnTransportation != null) ...[
                  _buildPlanDetailSection('Return', plan.returnTransportation!, theme),
                  SizedBox(height: 12.h),
                ],
                
                // Accommodation Info
                if (plan.accommodation != null) ...[
                  _buildAccommodationSection(plan.accommodation!, theme),
                  SizedBox(height: 16.h),
                ],
                
                // Total Cost
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Cost',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatPKR(plan.costs.total),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanDetailSection(String label, TransportationOption transport, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label Transportation',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Text('${transport.providerName} - ${transport.vehicleType}'),
          Text(CurrencyFormatter.formatPKR(transport.totalCost)),
        ],
      ),
    );
  }

  Widget _buildAccommodationSection(AccommodationOption accommodation, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accommodation',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Text('${accommodation.name} - ${accommodation.location}'),
          Text('${accommodation.numberOfNights} nights'),
          Text(CurrencyFormatter.formatPKR(accommodation.totalCost)),
        ],
      ),
    );
  }

  // Helper methods
  String _formatTime(String? dateTimeStr) {
    if (dateTimeStr == null) return '';
    try {
      final dt = DateTime.parse(dateTimeStr);
      return DateFormat('h:mm a').format(dt);
    } catch (e) {
      return '';
    }
  }
}
