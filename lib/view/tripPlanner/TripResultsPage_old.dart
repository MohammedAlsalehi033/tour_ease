import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tour_ease/controller/tripPlanner/tripPlannerBloc.dart';
import 'package:tour_ease/model/tripPlanner/tripPlannerModels.dart';
import 'package:tour_ease/utils/currency_formatter.dart';

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
          // Debug logging
          print('TripResultsPage - isLoading: ${state.isLoading}');
          print('TripResultsPage - error: ${state.error}');
          print('TripResultsPage - tripPlan: ${state.tripPlan}');
          
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
                    SizedBox(height: 24.h),
                    Text(
                      'Oops! Something went wrong',
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Text(
                          state.error!,
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Empty state
          if (state.tripPlan == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.travel_explore_rounded,
                    size: 64.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'No trips found',
                    style: theme.textTheme.titleLarge,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Try adjusting your search criteria',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.search_rounded),
                    label: const Text('Search Again'),
                  ),
                ],
              ),
            );
          }

          // Success state - show trip plans
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
                        Tab(icon: Icon(Icons.event_note), text: 'Itinerary'),
                      Tab(icon: Icon(Icons.flight), text: 'Transport'),
                      Tab(icon: Icon(Icons.hotel), text: 'Hotels'),
                      Tab(icon: Icon(Icons.recommend), text: 'Plans'),
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

  // ITINERARY TAB
  Widget _buildItineraryTab(TripPlanResponse tripPlan, ThemeData theme) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        if (tripPlan.tripSummary != null) ...[
          _buildTripSummaryCard(context, tripPlan.tripSummary!, theme),
          SizedBox(height: 16.h),
        ],
        ...tripPlan.itinerary.map((day) => _buildDayItineraryCard(context, day, theme)),
      ],
    );
  }

  // TRANSPORTATION TAB
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
        onTap: () => _showTransportDetails(context, transport),
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
                    '${_formatTime(departureTime)} - ${_formatTime(arrivalTime)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Spacer(),
                  Icon(Icons.airline_seats_rounded, size: 16.sp, color: colorScheme.onSurfaceVariant),
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

  void _showTransportDetails(BuildContext context, TransportationOption transport) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(16.w),
          child: ListView(
            controller: scrollController,
            children: [
              Text(
                transport.providerName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                transport.vehicleType,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 16.h),
              _buildDetailRow(Icons.payments, 'Price per Seat', CurrencyFormatter.formatPKR(transport.pricePerSeat), Theme.of(context)),
              _buildDetailRow(Icons.payments, 'Total Cost', CurrencyFormatter.formatPKR(transport.totalCost), Theme.of(context)),
              _buildDetailRow(Icons.schedule, 'Departure', _formatDateTime(transport.departureTime), Theme.of(context)),
              _buildDetailRow(Icons.schedule, 'Arrival', _formatDateTime(transport.arrivalTime), Theme.of(context)),
              _buildDetailRow(Icons.airline_seats, 'Available Seats', '${transport.seatsAvailable}', Theme.of(context)),
              if (transport.avgRating != null)
                _buildDetailRow(Icons.star, 'Rating', '${transport.avgRating!.toStringAsFixed(1)} (${transport.totalReviews} reviews)', Theme.of(context)),
              if (transport.amenities.isNotEmpty) ...[
                SizedBox(height: 16.h),
                Text('Amenities:', style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: transport.amenities.map((amenity) => 
                    Chip(label: Text(amenity))
                  ).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ACCOMMODATIONS TAB
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
      child: InkWell(
        onTap: () => _showAccommodationDetails(context, accommodation),
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
      ),
    );
  }

  void _showAccommodationDetails(BuildContext context, AccommodationOption accommodation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(16.w),
          child: ListView(
            controller: scrollController,
            children: [
              Text(
                accommodation.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber),
                  SizedBox(width: 4.w),
                  Text(
                    '${accommodation.avgRating.toStringAsFixed(1)} (${accommodation.totalReviews} reviews)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              
              if (accommodation.description != null) ...[
                SizedBox(height: 16.h),
                Text(accommodation.description!, style: Theme.of(context).textTheme.bodyLarge),
              ],
              
              SizedBox(height: 16.h),
              _buildDetailRow(Icons.location_on, 'Location', accommodation.location, Theme.of(context)),
              _buildDetailRow(Icons.calendar_today, 'Check-in', _formatDate(accommodation.checkInDate), Theme.of(context)),
              _buildDetailRow(Icons.calendar_today, 'Check-out', _formatDate(accommodation.checkOutDate), Theme.of(context)),
              _buildDetailRow(Icons.nights_stay, 'Nights', '${accommodation.numberOfNights}', Theme.of(context)),
              _buildDetailRow(Icons.people, 'Guests', '${accommodation.totalGuests}', Theme.of(context)),
              _buildDetailRow(Icons.payments, 'Total Cost', CurrencyFormatter.formatPKR(accommodation.totalCost), Theme.of(context)),
              
              SizedBox(height: 16.h),
              Text('Room Allocations:', style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 8.h),
              ...accommodation.roomAllocations.map((room) => Card(
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(room.roomType, style: Theme.of(context).textTheme.titleSmall),
                      SizedBox(height: 4.h),
                      Text('${room.numberOfRooms} room(s) × ${room.capacity} guests'),
                      Text(CurrencyFormatter.formatPKR(room.pricePerNight) + ' per night'),
                      Text('Total: ' + CurrencyFormatter.formatPKR(room.totalCost), 
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )),
              
              if (accommodation.amenities.isNotEmpty) ...[
                SizedBox(height: 16.h),
                Text('Amenities:', style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: accommodation.amenities.map((amenity) => 
                    Chip(label: Text(amenity))
                  ).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // PLANS TAB
  Widget _buildPlansTab(TripPlanResponse tripPlan, ThemeData theme) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
              // Optimal Plan Card
              if (tripPlan.optimalPlan != null) ...[
                _buildPlanCard(context, tripPlan.optimalPlan!, theme, isOptimal: true),
                SizedBox(height: 24.h),
              ],

              // Recommended Plans Section
              if (tripPlan.recommendedPlans.isNotEmpty) ...[
                Text(
                  'Alternative Plans',
                  style: theme.textTheme.headlineSmall,
                ),
                SizedBox(height: 12.h),
                ...tripPlan.recommendedPlans.map((plan) => 
                  _buildPlanCard(context, plan, theme, isOptimal: false),
                ),
                SizedBox(height: 24.h),
              ],

              // Available Options Summary
              Text(
                'Available Options',
                style: theme.textTheme.headlineSmall,
              ),
              SizedBox(height: 12.h),
              _buildOptionsCard(
                icon: Icons.flight_rounded,
                title: 'Transportation',
                count: tripPlan.outboundTransportation.length + tripPlan.returnTransportation.length,
                theme: theme,
              ),
              SizedBox(height: 12.h),
              _buildOptionsCard(
                icon: Icons.hotel_rounded,
                title: 'Accommodations',
                count: tripPlan.accommodations.length,
                theme: theme,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, TripPlan plan, ThemeData theme, {required bool isOptimal}) {
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        plan.planName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '${(plan.optimizationScore).toStringAsFixed(1)}%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (plan.description != null) ...[
                  SizedBox(height: 8.h),
                  Text(
                    plan.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                SizedBox(height: 16.h),
                
                // Transportation
                if (plan.outboundTransport != null)
                  _buildPlanDetailRow(
                    Icons.flight_takeoff_rounded,
                    'Outbound',
                    '${plan.outboundTransport!.vehicleType} - ${plan.outboundTransport!.providerName}',
                    theme,
                  ),
                if (plan.returnTransport != null)
                  _buildPlanDetailRow(
                    Icons.flight_land_rounded,
                    'Return',
                    '${plan.returnTransport!.vehicleType} - ${plan.returnTransport!.providerName}',
                    theme,
                  ),
                
                // Accommodation
                if (plan.accommodation != null)
                  _buildPlanDetailRow(
                    Icons.hotel_rounded,
                    'Accommodation',
                    '${plan.accommodation!.name} (${plan.accommodation!.numberOfNights} nights)',
                    theme,
                  ),
                
                SizedBox(height: 16.h),
                
                // Total Cost
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
                      CurrencyFormatter.formatPKR(plan.costs.total),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                // Warnings
                if (plan.warnings.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  ...plan.warnings.map((warning) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 16.sp, color: colorScheme.error),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            warning,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
                
                SizedBox(height: 16.h),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showPlanDetailsDialog(context, plan),
                        child: const Text('View Details'),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showBookingConfirmation(context, plan),
                        child: Text(isOptimal ? 'Book Now' : 'Select'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanDetailRow(IconData icon, String label, String value, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: theme.colorScheme.onSurfaceVariant),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
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
      ),
    );
  }

  void _showPlanDetailsDialog(BuildContext context, TripPlan plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(plan.planName),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (plan.description != null) ...[
                Text(plan.description!),
                SizedBox(height: 16.h),
              ],
              Text('Cost Breakdown:', style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 8.h),
              _buildCostRow('Transportation', plan.costs.transportation, context),
              _buildCostRow('Accommodation', plan.costs.accommodation, context),
              if (plan.costs.activities != null)
                _buildCostRow('Activities', plan.costs.activities!, context),
              Divider(height: 16.h),
              _buildCostRow('Total', plan.costs.total, context, bold: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(String label, double amount, BuildContext context, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: bold ? FontWeight.bold : null,
            ),
          ),
          Text(
            CurrencyFormatter.formatPKR(amount),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: bold ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingConfirmation(BuildContext context, TripPlan plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Do you want to book this trip plan?'),
            SizedBox(height: 16.h),
            Text(
              plan.planName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              CurrencyFormatter.formatPKR(plan.costs.total),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking confirmed!')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Widget _buildTripSummaryCard(BuildContext context, TripSummary summary, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights_rounded, color: colorScheme.primary, size: 24.sp),
                SizedBox(width: 12.w),
                Text(
                  'Trip Summary',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            
            // Duration
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    icon: Icons.calendar_today_rounded,
                    label: 'Duration',
                    value: '${summary.totalDays} days / ${summary.totalNights} nights',
                    theme: theme,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            
            // Cost Breakdown
            _buildCostBreakdownItem('Transportation', summary.estimatedTotalCost.transportation, theme),
            _buildCostBreakdownItem('Accommodation', summary.estimatedTotalCost.accommodation, theme),
            _buildCostBreakdownItem('Activities', summary.estimatedTotalCost.activities, theme),
            _buildCostBreakdownItem('Meals', summary.estimatedTotalCost.meals, theme),
            
            Divider(height: 24.h),
            
            // Total Cost
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
                  CurrencyFormatter.formatPKR(summary.estimatedTotalCost.total),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12.h),
            
            // Budget Status
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: _getBudgetStatusColor(summary.budgetStatus, colorScheme).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: _getBudgetStatusColor(summary.budgetStatus, colorScheme),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getBudgetStatusIcon(summary.budgetStatus),
                    color: _getBudgetStatusColor(summary.budgetStatus, colorScheme),
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getBudgetStatusText(summary.budgetStatus),
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Remaining: ${CurrencyFormatter.formatPKR(summary.remainingBudget)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayItineraryCard(BuildContext context, DayItinerary day, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ExpansionTile(
        tilePadding: EdgeInsets.all(16.w),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Day ${day.day} - ${day.dayOfWeek}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              day.theme,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
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
              Text(
                '${day.totalDuration} min',
                style: theme.textTheme.bodySmall,
              ),
              SizedBox(width: 16.w),
              Icon(Icons.payments_rounded, size: 14.sp, color: colorScheme.onSurfaceVariant),
              SizedBox(width: 4.w),
              Text(
                CurrencyFormatter.formatPKR(day.totalEstimatedCost),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Column(
              children: day.activities.map((activity) => 
                _buildActivityItem(context, activity, theme)
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, ItineraryActivity activity, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: () => _showActivityDetails(context, activity),
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  _getActivityCategoryIcon(activity.category),
                  size: 20.sp,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          activity.time,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        if (activity.bookingRequired)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'BOOKING REQUIRED',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 9.sp,
                                color: colorScheme.onErrorContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      activity.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      activity.description,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 12.sp, color: colorScheme.onSurfaceVariant),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            activity.location.name,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (activity.estimatedCost > 0) ...[
                          SizedBox(width: 8.w),
                          Text(
                            CurrencyFormatter.formatPKR(activity.estimatedCost),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (activity.placeDetails != null && activity.placeDetails!.rating != null) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.star, size: 12.sp, color: Colors.amber),
                          SizedBox(width: 4.w),
                          Text(
                            '${activity.placeDetails!.rating} (${activity.placeDetails!.userRatingsTotal} reviews)',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 20.sp, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: theme.colorScheme.onSurfaceVariant),
        SizedBox(width: 8.w),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCostBreakdownItem(String label, double amount, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(
            CurrencyFormatter.formatPKR(amount),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBudgetStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'within_budget':
        return Colors.green;
      case 'tight':
        return Colors.orange;
      case 'over_budget':
        return colorScheme.error;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  IconData _getBudgetStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'within_budget':
        return Icons.check_circle_rounded;
      case 'tight':
        return Icons.warning_rounded;
      case 'over_budget':
        return Icons.error_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String _getBudgetStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'within_budget':
        return 'Within Budget';
      case 'tight':
        return 'Tight Budget';
      case 'over_budget':
        return 'Over Budget';
      default:
        return 'Unknown Status';
    }
  }

  IconData _getActivityCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'attraction':
        return Icons.attractions_rounded;
      case 'activity':
        return Icons.local_activity_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'lunch':
      case 'dinner':
      case 'breakfast':
        return Icons.restaurant_rounded;
      case 'rest':
        return Icons.hotel_rounded;
      case 'travel':
        return Icons.commute_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  void _showActivityDetails(BuildContext context, ItineraryActivity activity) {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Column(
          children: [
            // Handle
            Container(
              margin: EdgeInsets.symmetric(vertical: 8.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            // Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.all(16.w),
                children: [
                  Text(
                    activity.title,
                    style: theme.textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          activity.category.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  
                  // Description
                  Text(
                    activity.description,
                    style: theme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 16.h),
                  
                  // Details
                  _buildDetailRow(Icons.access_time, 'Time', activity.time, theme),
                  _buildDetailRow(Icons.timer_outlined, 'Duration', '${activity.duration} minutes', theme),
                  _buildDetailRow(Icons.location_on_outlined, 'Location', activity.location.name, theme),
                  if (activity.location.address != null)
                    _buildDetailRow(Icons.place, 'Address', activity.location.address!, theme),
                  if (activity.estimatedCost > 0)
                    _buildDetailRow(Icons.payments_rounded, 'Cost', CurrencyFormatter.formatPKR(activity.estimatedCost), theme),
                  
                  // Google Places Details
                  if (activity.placeDetails != null) ...[
                    SizedBox(height: 16.h),
                    Divider(),
                    SizedBox(height: 16.h),
                    if (activity.placeDetails!.rating != null)
                      _buildDetailRow(Icons.star, 'Rating', '${activity.placeDetails!.rating} (${activity.placeDetails!.userRatingsTotal} reviews)', theme),
                    if (activity.placeDetails!.website != null)
                      _buildDetailRow(Icons.language, 'Website', activity.placeDetails!.website!, theme),
                    if (activity.placeDetails!.phoneNumber != null)
                      _buildDetailRow(Icons.phone, 'Phone', activity.placeDetails!.phoneNumber!, theme),
                  ],
                  
                  // Tips
                  if (activity.tips != null) ...[
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_outline, color: theme.colorScheme.onTertiaryContainer),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tip',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onTertiaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  activity.tips!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onTertiaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  SizedBox(height: 16.h),
                  
                  // Map Button
                  ElevatedButton.icon(
                    onPressed: () {
                      // Open map URL
                      // You can use url_launcher package here
                    },
                    icon: const Icon(Icons.map_rounded),
                    label: const Text('View on Map'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20.sp, color: theme.colorScheme.onSurfaceVariant),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsCard({
    required IconData icon,
    required String title,
    required int count,
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;
    
    return Card(
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: colorScheme.onPrimaryContainer),
        ),
        title: Text(title, style: theme.textTheme.titleMedium),
        trailing: Text(
          '$count option${count != 1 ? 's' : ''}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
