import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tour_ease/controller/tripPlanner/tripPlannerBloc.dart';
import 'package:tour_ease/model/tripPlanner/tripPlannerModels.dart';
import 'package:tour_ease/utils/currency_formatter.dart';
import 'package:intl/intl.dart';
import 'package:tour_ease/view/tripPlanner/confirm_trip_page.dart';

class TripResultsPage extends StatefulWidget {
  const TripResultsPage({Key? key}) : super(key: key);

  @override
  _TripResultsPageState createState() => _TripResultsPageState();

}

class _TripResultsPageState extends State<TripResultsPage> {
  TransportationOption? selectedOutbound;
  TransportationOption? selectedReturn;
  AccommodationOption? selectedAccommodation;
  bool showBestOption = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: BlocBuilder<TripPlannerBloc, TripPlannerState>(
        builder: (context, state) {

          // Error state
          if (state.error != null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(32.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 80.sp,
                      color: colorScheme.error,
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Oops! Something went wrong',
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      state.error!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32.h),
                    FilledButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to Search'),
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                      ),
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
                    size: 80.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'No trip plan available',
                    style: theme.textTheme.headlineSmall,
                  ),
                  SizedBox(height: 32.h),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Create New Trip'),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                    ),
                  ),
                ],
              ),
            );
          }

          final tripPlan = state.tripPlan!;

          // Quick select best option button
          return CustomScrollView(
            slivers: [
              // Modern App Bar
              SliverAppBar.large(
                expandedHeight: 180.h,
                pinned: true,
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                flexibleSpace: FlexibleSpaceBar(
                  title: null,
                  collapseMode: CollapseMode.parallax,
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primaryContainer,
                          colorScheme.surfaceVariant.withOpacity(0.9),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.all(14.w),
                        child: Column(
                          children: [
                            // Top row: back + title + actions
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onPrimaryContainer),
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    'Your Trip Options',
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      color: colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _showTopBarActionMessage(context, 'Map view not implemented yet'),
                                  icon: Icon(Icons.map_rounded, color: colorScheme.onPrimaryContainer),
                                ),
                              ],
                            ),

                            // Spacer pushes the summary to the bottom of the expanded area
                            const Spacer(),

                            // Compact trip header: days/nights and cost
                            if (tripPlan.tripSummary != null) ...[
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${tripPlan.tripSummary!.totalDays} Days • ${tripPlan.tripSummary!.totalNights} Nights',
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              color: colorScheme.onPrimaryContainer.withOpacity(0.95),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            'Est. ${CurrencyFormatter.formatPKR(tripPlan.tripSummary!.estimatedTotalCost.total)} • Remaining ${CurrencyFormatter.formatPKR(tripPlan.tripSummary!.remainingBudget)}',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: colorScheme.onPrimaryContainer.withOpacity(0.9),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(width: 8.w),
                                    OutlinedButton(
                                      onPressed: () => _showTopBarActionMessage(context, 'View cost breakdown'),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: colorScheme.onPrimaryContainer.withOpacity(0.12)),
                                        foregroundColor: colorScheme.onPrimaryContainer,
                                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                      ),
                                      child: Text('Cost'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Best Option Quick Select
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: _buildBestOptionCard(tripPlan, theme),
                ),
              ),

              // Section: Transportation
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 32.h, 20.w, 16.h),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.flight_takeoff_rounded,
                          color: colorScheme.onPrimaryContainer,
                          size: 28.sp,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Text(
                        'Select Transportation',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Outbound Transportation Horizontal Scroll
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        children: [
                          Text(
                            'Outbound Journey',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 20.sp,
                            color: colorScheme.primary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Swipe',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      height: 300.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        itemCount: tripPlan.outboundTransportation.length,
                        itemBuilder: (context, index) {
                          final transport = tripPlan.outboundTransportation[index];
                          final isSelected = selectedOutbound?.id == transport.id;
                          return _buildModernTransportCard(
                            transport,
                            theme,
                            isSelected,
                            () => setState(() => selectedOutbound = transport),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.h).toSliver(),

              // Return Transportation Horizontal Scroll
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        children: [
                          Text(
                            'Return Journey',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 20.sp,
                            color: colorScheme.primary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Swipe',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      height: 300.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        itemCount: tripPlan.returnTransportation.length,
                        itemBuilder: (context, index) {
                          final transport = tripPlan.returnTransportation[index];
                          final isSelected = selectedReturn?.id == transport.id;
                          return _buildModernTransportCard(
                            transport,
                            theme,
                            isSelected,
                            () => setState(() => selectedReturn = transport),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 48.h).toSliver(),

              // Section: Accommodation
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.hotel_rounded,
                          color: colorScheme.onSecondaryContainer,
                          size: 28.sp,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Text(
                        'Select Accommodation',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 20.sp,
                        color: colorScheme.primary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Swipe',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Accommodations Horizontal Scroll
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 520.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: tripPlan.accommodations.length,
                    itemBuilder: (context, index) {
                      final accommodation = tripPlan.accommodations[index];
                      final isSelected = selectedAccommodation?.id == accommodation.id;
                      return _buildModernAccommodationCard(
                        accommodation,
                        theme,
                        isSelected,
                        () => setState(() => selectedAccommodation = accommodation),
                      );
                    },
                  ),
                ),
              ),

              SizedBox(height: 48.h).toSliver(),

              // Section: Daily Activities & Itinerary
              if (tripPlan.itinerary.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.event_note_rounded,
                            color: colorScheme.onTertiaryContainer,
                            size: 28.sp,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Daily Itinerary',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Swipe to explore each day →',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Daily Activities Horizontal Scroll
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 520.h,
                    child: Stack(
                      children: [
                        ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          itemCount: tripPlan.itinerary.length,
                          itemBuilder: (context, index) {
                            final day = tripPlan.itinerary[index];
                            return _buildDayItineraryCard(day, theme);
                          },
                        ),
                        
                        // Scroll indicator - Right arrow
                        if (tripPlan.itinerary.length > 1)
                          Positioned(
                            right: 8.w,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.primary.withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: Offset(0, 4.h),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: colorScheme.onPrimary,
                                  size: 20.sp,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],

              SizedBox(height: 120.h).toSliver(),
            ],
          );
        },
      ),
      
      // Floating Confirm Button
      floatingActionButton: BlocBuilder<TripPlannerBloc, TripPlannerState>(
        builder: (context, state) {
          if (state.tripPlan == null) return const SizedBox();
          
          final canConfirm = selectedOutbound != null && 
                            selectedReturn != null && 
                            selectedAccommodation != null;
          
          if (!canConfirm) return const SizedBox();

          final totalCost = (selectedOutbound?.totalCost ?? 0) +
                           (selectedReturn?.totalCost ?? 0) +
                           (selectedAccommodation?.totalCost ?? 0);

          return Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            child: FilledButton.icon(
              onPressed: () {
                // Navigate to the confirmation page where user can save or book
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => ConfirmTripPage(
                      tripPlan: state.tripPlan!,
                      outbound: selectedOutbound,
                      returnTransport: selectedReturn,
                      accommodation: selectedAccommodation,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.check_circle_rounded),
              label: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Confirm Selection'),
                  Text(
                    CurrencyFormatter.formatPKR(totalCost),
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBestOptionCard(TripPlanResponse tripPlan, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    if (tripPlan.optimalPlan == null) return const SizedBox();
    
    final plan = tripPlan.optimalPlan!;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
            child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Auto-select best options
            setState(() {
              selectedOutbound = plan.outboundTransport;
              selectedReturn = plan.returnTransport;
              selectedAccommodation = plan.accommodation;
            });
                  
                  // Scroll to confirm button and navigate to confirm page
                  Future.delayed(const Duration(milliseconds: 300), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => ConfirmTripPage(
                          tripPlan: tripPlan,
                          outbound: plan.outboundTransport,
                          returnTransport: plan.returnTransport,
                          accommodation: plan.accommodation,
                        ),
                      ),
                    );
                  });
          },
          borderRadius: BorderRadius.circular(24.r),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.stars_rounded, color: Colors.white, size: 20.sp),
                          SizedBox(width: 6.w),
                          Text(
                            'BEST MATCH',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_rounded, size: 28.sp, color: colorScheme.onPrimaryContainer),
                  ],
                ),
                
                SizedBox(height: 20.h),
                
                Text(
                  plan.planName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                
                if (plan.description != null) ...[
                  SizedBox(height: 8.h),
                  Text(
                    plan.description!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                SizedBox(height: 24.h),
                
                Row(
                  children: [
                    _buildQuickInfo(
                      Icons.flight_rounded,
                      plan.outboundTransport?.providerName ?? 'N/A',
                      theme,
                    ),
                    SizedBox(width: 24.w),
                    _buildQuickInfo(
                      Icons.hotel_rounded,
                      plan.accommodation?.name ?? 'N/A',
                      theme,
                    ),
                  ],
                ),
                
                SizedBox(height: 20.h),
                
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Cost',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatPKR(plan.costs.total),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 16.h),
                
                Center(
                  child: Text(
                    'Tap to select this option',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickInfo(IconData icon, String text, ThemeData theme) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: theme.colorScheme.onPrimaryContainer),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTransportCard(
    TransportationOption transport,
    ThemeData theme,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final colorScheme = theme.colorScheme;
    
    return GestureDetector(
      onTap: () {
        onTap();
        _showTransportDetails(transport, theme);
      },
      child: AnimatedScale(
        scale: isSelected ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 360.w,
          // allow the card to adapt a little on different screen sizes
          // increase maxHeight slightly to avoid tiny overflow on some devices
          constraints: BoxConstraints(minHeight: 240.h, maxHeight: 340.h),
          margin: EdgeInsets.only(right: 16.w),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? colorScheme.primary.withOpacity(0.2)
                  : Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: Offset(0, 8.h),
            ),
          ],
          ),
          child: Column(
          children: [
            // Header section
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: isSelected 
                    ? colorScheme.primaryContainer.withOpacity(0.3)
                    : colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.directions_bus_rounded,
                      color: Colors.white,
                      size: 26.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transport.providerName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          transport.vehicleType,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        // show departure date for quick context
                        Text(
                          DateFormat('EEE, MMM dd').format(transport.departureTime),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                ],
              ),
            ),
            
            // Content section
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Departure time section
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 18.sp,
                              color: colorScheme.primary,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Departure Time',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          _formatTime(transport.departureTime.toIso8601String()),
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    
                    // Divider
                    Divider(color: colorScheme.outlineVariant.withOpacity(0.5)),
                    
                    // Info row (rating and seats) - use IntrinsicHeight + VerticalDivider
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          if (transport.avgRating != null)
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.star, size: 18.sp, color: Colors.amber),
                                  SizedBox(width: 6.w),
                                  Flexible(
                                    child: Text(
                                      '${transport.avgRating!.toStringAsFixed(1)}',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Flexible(
                                    child: Text(
                                      '(${transport.totalReviews})',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Divider between rating and seats
                          if (transport.avgRating != null)
                            VerticalDivider(
                              width: 28.w,
                              thickness: 1,
                              color: colorScheme.outlineVariant.withOpacity(0.9),
                            ),

                          // Seats info
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.event_seat_rounded,
                                  size: 18.sp,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                SizedBox(width: 6.w),
                                Flexible(
                                  child: Text(
                                    '${transport.seatsAvailable} seats',
                                    style: theme.textTheme.titleMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
              ),
            ),
            
            // Price footer (tooltip added for clarity)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 18.h),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24.r),
                  bottomRight: Radius.circular(24.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Cost',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Tooltip(
                    message: CurrencyFormatter.formatPKR(transport.totalCost),
                    child: Text(
                      CurrencyFormatter.formatPKR(transport.totalCost),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildModernAccommodationCard(
    AccommodationOption accommodation,
    ThemeData theme,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final colorScheme = theme.colorScheme;
    
    return GestureDetector(
      onTap: () {
        onTap();
        _showAccommodationDetails(accommodation, theme);
      },
      child: Container(
        width: 380.w,
        height: 490.h,
        margin: EdgeInsets.only(right: 16.w),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? colorScheme.primary.withOpacity(0.2)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: Offset(0, 10.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with overlay badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.r),
                    topRight: Radius.circular(24.r),
                  ),
                  child: SizedBox(
                    height: 220.h,
                    width: double.infinity,
                    child: accommodation.mediaUrls.isNotEmpty
                        ? PageView.builder(
                            itemCount: accommodation.mediaUrls.length.clamp(0, 5),
                            itemBuilder: (context, index) => Image.network(
                              accommodation.mediaUrls[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.hotel_rounded,
                                  size: 70.sp,
                                  color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.hotel_rounded,
                              size: 70.sp,
                              color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                            ),
                          ),
                  ),
                ),
                
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.r),
                        topRight: Radius.circular(24.r),
                      ),
                    ),
                  ),
                ),
                
                // Rating badge
                Positioned(
                  top: 16.h,
                  right: 16.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade700,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.white, size: 14.sp),
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
                ),
                
                // Selection checkmark
                if (isSelected)
                  Positioned(
                    top: 12.h,
                    left: 12.w,
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.5),
                            blurRadius: 8,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ),
                  ),
              ],
            ),
            
            // Content section
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hotel name
                    Text(
                      accommodation.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: 10.h),
                    
                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 18.sp,
                          color: colorScheme.primary,
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            accommodation.location,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    // Show check-in / check-out dates compactly
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 16.sp, color: colorScheme.onSurfaceVariant),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            '${DateFormat('MMM dd').format(accommodation.checkInDate)} — ${DateFormat('MMM dd').format(accommodation.checkOutDate)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Details row
                    Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildHotelDetail(
                            Icons.king_bed_rounded,
                            '${accommodation.numberOfNights} nights',
                            theme,
                          ),
                          Container(
                            height: 35.h,
                            width: 1,
                            color: colorScheme.outlineVariant,
                          ),
                          _buildHotelDetail(
                            Icons.people_rounded,
                            '${accommodation.totalGuests} guests',
                            theme,
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Amenities preview
                    if (accommodation.amenities.isNotEmpty) ...[
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: accommodation.amenities.take(3).map((amenity) =>
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: colorScheme.secondary.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getAmenityIcon(amenity),
                                  size: 12.sp,
                                  color: colorScheme.onSecondaryContainer,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  amenity,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).toList(),
                      ),
                      SizedBox(height: 4.h),
                    ],
                    
                    const Spacer(),
                    
                    // Reviews count
                    Text(
                      '${accommodation.totalReviews} reviews',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Price footer
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24.r),
                  bottomRight: Radius.circular(24.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total Cost',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatPKR(accommodation.totalCost),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelDetail(IconData icon, String text, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: theme.colorScheme.primary),
        SizedBox(width: 6.w),
        Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label, ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: theme.colorScheme.onSurfaceVariant),
          SizedBox(width: 4.w),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, TripPlanResponse tripPlan) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final totalCost = (selectedOutbound?.totalCost ?? 0) +
                     (selectedReturn?.totalCost ?? 0) +
                     (selectedAccommodation?.totalCost ?? 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32.r),
            topRight: Radius.circular(32.r),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                      size: 32.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Text(
                    'Confirm Booking',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24.h),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Transportation Details
                    _buildConfirmSection(
                      'Outbound Transportation',
                      Icons.flight_takeoff_rounded,
                      [
                        _buildDetailRow('Provider', selectedOutbound!.providerName),
                        _buildDetailRow('Vehicle', selectedOutbound!.vehicleType),
                        _buildDetailRow('Departure', _formatDateTime(selectedOutbound!.departureTime.toIso8601String())),
                        _buildDetailRow('Cost', CurrencyFormatter.formatPKR(selectedOutbound!.totalCost)),
                      ],
                      theme,
                    ),
                    
                    SizedBox(height: 20.h),
                    
                    _buildConfirmSection(
                      'Return Transportation',
                      Icons.flight_land_rounded,
                      [
                        _buildDetailRow('Provider', selectedReturn!.providerName),
                        _buildDetailRow('Vehicle', selectedReturn!.vehicleType),
                        _buildDetailRow('Departure', _formatDateTime(selectedReturn!.departureTime.toIso8601String())),
                        _buildDetailRow('Cost', CurrencyFormatter.formatPKR(selectedReturn!.totalCost)),
                      ],
                      theme,
                    ),
                    
                    SizedBox(height: 20.h),
                    
                    _buildConfirmSection(
                      'Accommodation',
                      Icons.hotel_rounded,
                      [
                        _buildDetailRow('Hotel', selectedAccommodation!.name),
                        _buildDetailRow('Location', selectedAccommodation!.location),
                        _buildDetailRow('Nights', '${selectedAccommodation!.numberOfNights}'),
                        _buildDetailRow('Guests', '${selectedAccommodation!.totalGuests}'),
                        _buildDetailRow('Cost', CurrencyFormatter.formatPKR(selectedAccommodation!.totalCost)),
                      ],
                      theme,
                    ),
                    
                    SizedBox(height: 32.h),
                    
                    // Total Cost
                    Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colorScheme.primaryContainer, colorScheme.secondaryContainer],
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Cost',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.formatPKR(totalCost),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
            
            // Action Buttons
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        side: BorderSide(color: colorScheme.outline),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: () {
                        // TODO: Implement booking logic
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Booking confirmed!'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Confirm Booking'),
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        backgroundColor: Colors.green,
                      ),
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

  Widget _buildConfirmSection(String title, IconData icon, List<Widget> children, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colorScheme.primary, size: 24.sp),
              SizedBox(width: 12.w),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 15.sp,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15.sp,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String? dateTimeStr) {
    if (dateTimeStr == null) return '';
    try {
      final dt = DateTime.parse(dateTimeStr);
      return DateFormat('h:mm a').format(dt);
    } catch (e) {
      return '';
    }
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return '';
    try {
      final dt = DateTime.parse(dateTimeStr);
      return DateFormat('MMM dd, h:mm a').format(dt);
    } catch (e) {
      return '';
    }
  }

  void _showTopBarActionMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Show detailed transport information
  void _showTransportDetails(TransportationOption transport, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32.r),
            topRight: Radius.circular(32.r),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Icon(
                            Icons.directions_bus_rounded,
                            color: colorScheme.onPrimaryContainer,
                            size: 32.sp,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                transport.providerName,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                transport.vehicleType,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 24.h),
                    
                    _buildInfoSection(
                      'Journey Details',
                      [
                        _buildDetailRow('Departure', _formatDateTime(transport.departureTime.toIso8601String())),
                        _buildDetailRow('Arrival', _formatDateTime(transport.arrivalTime.toIso8601String())),
                        _buildDetailRow('Available Seats', '${transport.seatsAvailable}'),
                        _buildDetailRow('Price per Seat', CurrencyFormatter.formatPKR(transport.pricePerSeat)),
                        _buildDetailRow('Total Cost', CurrencyFormatter.formatPKR(transport.totalCost)),
                      ],
                      theme,
                    ),
                    
                    if (transport.avgRating != null) ...[
                      SizedBox(height: 20.h),
                      _buildInfoSection(
                        'Ratings & Reviews',
                        [
                          Row(
                            children: [
                              Icon(Icons.star_rounded, color: Colors.amber, size: 32.sp),
                              SizedBox(width: 12.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    transport.avgRating!.toStringAsFixed(1),
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${transport.totalReviews} reviews',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                        theme,
                      ),
                    ],
                    
                    if (transport.amenities.isNotEmpty) ...[
                      SizedBox(height: 20.h),
                      Text(
                        'Amenities',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Wrap(
                        spacing: 12.w,
                        runSpacing: 12.h,
                        children: transport.amenities.map((amenity) => 
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getAmenityIcon(amenity),
                                  size: 20.sp,
                                  color: colorScheme.onSecondaryContainer,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  amenity,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSecondaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show detailed accommodation information
  void _showAccommodationDetails(AccommodationOption accommodation, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32.r),
            topRight: Radius.circular(32.r),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Images
                    if (accommodation.mediaUrls.isNotEmpty)
                      SizedBox(
                        height: 300.h,
                        child: PageView.builder(
                          itemCount: accommodation.mediaUrls.length,
                          itemBuilder: (context, index) => Image.network(
                            accommodation.mediaUrls[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.hotel_rounded,
                                size: 80.sp,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                    Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  accommodation.name,
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.star_rounded, color: Colors.white, size: 16.sp),
                                    SizedBox(width: 4.w),
                                    Text(
                                      accommodation.avgRating.toStringAsFixed(1),
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 8.h),
                          
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 20.sp, color: colorScheme.onSurfaceVariant),
                              SizedBox(width: 4.w),
                              Text(
                                accommodation.location,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          
                          if (accommodation.description != null) ...[
                            SizedBox(height: 16.h),
                            Text(
                              accommodation.description!,
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                          
                          SizedBox(height: 24.h),
                          
                          _buildInfoSection(
                            'Booking Details',
                            [
                              _buildDetailRow('Check-in', DateFormat('MMM dd, yyyy').format(accommodation.checkInDate)),
                              _buildDetailRow('Check-out', DateFormat('MMM dd, yyyy').format(accommodation.checkOutDate)),
                              _buildDetailRow('Nights', '${accommodation.numberOfNights}'),
                              _buildDetailRow('Guests', '${accommodation.totalGuests}'),
                              _buildDetailRow('Total Cost', CurrencyFormatter.formatPKR(accommodation.totalCost)),
                            ],
                            theme,
                          ),
                          
                          SizedBox(height: 20.h),
                          
                          Text(
                            'Room Allocations',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          ...accommodation.roomAllocations.map((room) => Container(
                            margin: EdgeInsets.only(bottom: 12.h),
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  room.roomType,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                _buildDetailRow('Number of Rooms', '${room.numberOfRooms}'),
                                _buildDetailRow('Capacity', '${room.capacity} guests'),
                                _buildDetailRow('Price/Night', CurrencyFormatter.formatPKR(room.pricePerNight)),
                                _buildDetailRow('Total', CurrencyFormatter.formatPKR(room.totalCost)),
                                if (room.amenities.isNotEmpty) ...[
                                  SizedBox(height: 8.h),
                                  Wrap(
                                    spacing: 6.w,
                                    runSpacing: 6.h,
                                    children: room.amenities.map((amenity) => 
                                      Text('• $amenity', style: theme.textTheme.bodySmall)
                                    ).toList(),
                                  ),
                                ],
                              ],
                            ),
                          )),
                          
                          if (accommodation.amenities.isNotEmpty) ...[
                            SizedBox(height: 20.h),
                            Text(
                              'Hotel Amenities',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Wrap(
                              spacing: 12.w,
                              runSpacing: 12.h,
                              children: accommodation.amenities.map((amenity) => 
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                                  decoration: BoxDecoration(
                                    color: colorScheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getAmenityIcon(amenity),
                                        size: 20.sp,
                                        color: colorScheme.onSecondaryContainer,
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        amenity,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onSecondaryContainer,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  IconData _getAmenityIcon(String amenity) {
    final lower = amenity.toLowerCase();
    if (lower.contains('wifi') || lower.contains('wi-fi')) return Icons.wifi_rounded;
    if (lower.contains('ac') || lower.contains('air')) return Icons.ac_unit_rounded;
    if (lower.contains('tv')) return Icons.tv_rounded;
    if (lower.contains('pool')) return Icons.pool_rounded;
    if (lower.contains('gym')) return Icons.fitness_center_rounded;
    if (lower.contains('parking')) return Icons.local_parking_rounded;
    if (lower.contains('restaurant')) return Icons.restaurant_rounded;
    if (lower.contains('bar')) return Icons.local_bar_rounded;
    if (lower.contains('seat') || lower.contains('reclin')) return Icons.airline_seat_recline_normal_rounded;
    return Icons.check_circle_outline_rounded;
  }

  // Build day itinerary card
  Widget _buildDayItineraryCard(DayItinerary day, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return Container(
      width: 360.w,
      margin: EdgeInsets.only(right: 16.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header with gradient
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.secondaryContainer,
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'Day ${day.day}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      day.dayOfWeek,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  day.theme,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 16.sp, color: colorScheme.onSurfaceVariant),
                    SizedBox(width: 4.w),
                    Text(
                      '${day.totalDuration ~/ 60}h ${day.totalDuration % 60}m',
                      style: theme.textTheme.bodyMedium,
                    ),
                    SizedBox(width: 16.w),
                    Icon(Icons.payments_rounded, size: 16.sp, color: colorScheme.onSurfaceVariant),
                    SizedBox(width: 4.w),
                    Text(
                      CurrencyFormatter.formatPKR(day.totalEstimatedCost),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Timeline-style vertical activities preview (compact, scannable)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            child: Column(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 420.h),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: day.activities.length.clamp(0, 3),
                    separatorBuilder: (context, index) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final activity = day.activities[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left time rail with dot and connector
                          Column(
                            children: [
                              Text(
                                activity.time,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Container(
                                width: 10.w,
                                height: 10.w,
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(activity.category),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              if (index != day.activities.length - 1)
                                Container(
                                  width: 2.w,
                                  height: 56.h,
                                  color: colorScheme.outline.withOpacity(0.3),
                                ),
                            ],
                          ),
                          SizedBox(width: 12.w),

                          // Activity brief card
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _showActivityDetail(activity, theme),
                              child: Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: colorScheme.outline.withOpacity(0.08)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8.w),
                                      decoration: BoxDecoration(
                                        color: _getCategoryColor(activity.category).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                      child: Icon(_getCategoryIcon(activity.category), color: _getCategoryColor(activity.category), size: 18.sp),
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(activity.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                                          SizedBox(height: 6.h),
                                          Row(
                                            children: [
                                              Icon(Icons.location_on_outlined, size: 14.sp, color: colorScheme.onSurfaceVariant),
                                              SizedBox(width: 6.w),
                                              Expanded(child: Text(activity.location.name, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                              SizedBox(width: 8.w),
                                              Text(CurrencyFormatter.formatPKR(activity.estimatedCost), style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // If there are more activities, show a small badge that opens full day details
                if (day.activities.length > 3)
                  Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => _showDayDetails(day, theme),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text('+${day.activities.length - 3} more', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Footer: totals + view details
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 16.sp, color: colorScheme.onSurfaceVariant),
                      SizedBox(width: 6.w),
                      Text('${day.totalDuration ~/ 60}h ${day.totalDuration % 60}m', style: theme.textTheme.bodyMedium),
                      SizedBox(width: 12.w),
                      Icon(Icons.payments_rounded, size: 16.sp, color: colorScheme.onSurfaceVariant),
                      SizedBox(width: 6.w),
                      Text(CurrencyFormatter.formatPKR(day.totalEstimatedCost), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                OutlinedButton(
                  onPressed: () => _showDayDetails(day, theme),
                  style: OutlinedButton.styleFrom(side: BorderSide(color: colorScheme.primary)),
                  child: Row(
                    children: [
                      Text('View details'),
                      SizedBox(width: 6.w),
                      Icon(Icons.arrow_forward_rounded, size: 16.sp),
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

  // keep helper for backward compatibility with older UI variants
  // ignore: unused_element
  Widget _buildActivityPreview(ItineraryActivity activity, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: _getCategoryColor(activity.category).withOpacity(0.2),
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
                    Text(
                      activity.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (activity.location.name.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 14.sp, color: colorScheme.onSurfaceVariant),
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
                Text(
                  CurrencyFormatter.formatPKR(activity.estimatedCost),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildActivityTile(ItineraryActivity activity, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return GestureDetector(
      onTap: () => _showActivityDetail(activity, theme),
      child: Container(
        width: 260.w,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.35),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: colorScheme.outline.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(activity.category).withOpacity(0.18),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(_getCategoryIcon(activity.category), color: _getCategoryColor(activity.category), size: 18.sp),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(activity.time, style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4.h),
                      Text(activity.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
            if (activity.placeDetails != null && activity.placeDetails!.photos != null && activity.placeDetails!.photos!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Image.network(
                  activity.placeDetails!.photos!.first,
                  height: 80.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 80.h,
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(Icons.image, color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
            ],
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 14.sp, color: colorScheme.onSurfaceVariant),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(activity.location.name, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                SizedBox(width: 8.w),
                Text(CurrencyFormatter.formatPKR(activity.estimatedCost), style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showActivityDetail(ItineraryActivity activity, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24.r), topRight: Radius.circular(24.r)),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(activity.category).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(_getCategoryIcon(activity.category), color: _getCategoryColor(activity.category), size: 22.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(activity.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                          SizedBox(height: 4.h),
                          Text(activity.time, style: theme.textTheme.labelLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close_rounded)),
                  ],
                ),
                SizedBox(height: 12.h),
                if (activity.description.isNotEmpty) ...[
                  Text(activity.description, style: theme.textTheme.bodyMedium),
                  SizedBox(height: 12.h),
                ],
                Row(
                  children: [
                    _buildInfoChip(Icons.access_time_rounded, '${activity.duration} min', theme),
                    SizedBox(width: 8.w),
                    _buildInfoChip(Icons.payments_rounded, CurrencyFormatter.formatPKR(activity.estimatedCost), theme),
                  ],
                ),
                if (activity.placeDetails != null && activity.placeDetails!.photos != null && activity.placeDetails!.photos!.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 140.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: activity.placeDetails!.photos!.length.clamp(0, 5),
                      separatorBuilder: (context, index) => SizedBox(width: 8.w),
                      itemBuilder: (context, index) => ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.network(
                          activity.placeDetails!.photos![index],
                          width: 220.w,
                          height: 140.h,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 220.w,
                            color: colorScheme.surfaceContainerHighest,
                            child: Icon(Icons.image, color: colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 12.h),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDayDetails(DayItinerary day, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32.r),
            topRight: Radius.circular(32.r),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            
            // Header
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          'Day ${day.day}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        '${day.dayOfWeek}, ${day.date}',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    day.theme,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                itemCount: day.activities.length,
                separatorBuilder: (context, index) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    children: [
                      SizedBox(width: 32.w),
                      Container(width: 2.w, height: 24.h, color: colorScheme.outline.withOpacity(0.3)),
                    ],
                  ),
                ),
                itemBuilder: (context, index) {
                  final activity = day.activities[index];
                  return _buildActivityDetailCard(activity, theme);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityDetailCard(ItineraryActivity activity, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prominent activity image if available
          if (activity.placeDetails != null && activity.placeDetails!.photos != null && activity.placeDetails!.photos!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                activity.placeDetails!.photos!.first,
                height: 160.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 160.h,
                  color: colorScheme.surfaceContainerHighest,
                  child: Icon(Icons.image, color: colorScheme.onSurfaceVariant),
                ),
              ),
            ),
            SizedBox(height: 12.h),
          ],
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: _getCategoryColor(activity.category).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  _getCategoryIcon(activity.category),
                  color: _getCategoryColor(activity.category),
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.time,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      activity.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (activity.description.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              activity.description,
              style: theme.textTheme.bodyMedium,
            ),
          ],
          
          SizedBox(height: 12.h),
          
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16.sp, color: colorScheme.onSurfaceVariant),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  activity.location.name,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12.h),
          
          Row(
            children: [
              _buildInfoChip(Icons.access_time_rounded, '${activity.duration} min', theme),
              SizedBox(width: 8.w),
              _buildInfoChip(Icons.payments_rounded, CurrencyFormatter.formatPKR(activity.estimatedCost), theme),
            ],
          ),
          
          if (activity.placeDetails != null && activity.placeDetails!.photos != null && activity.placeDetails!.photos!.isNotEmpty) ...[
            SizedBox(height: 16.h),
            SizedBox(
              height: 120.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: activity.placeDetails!.photos!.length.clamp(0, 5),
                separatorBuilder: (context, index) => SizedBox(width: 8.w),
                itemBuilder: (context, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    activity.placeDetails!.photos![index],
                    width: 160.w,
                    height: 120.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 160.w,
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.image, color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
              ),
            ),
          ],
          
          if (activity.tips != null && activity.tips!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline_rounded, size: 20.sp, color: Colors.blue),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      activity.tips!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
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
        return Icons.restaurant_rounded;
      case 'attraction':
        return Icons.attractions_rounded;
      case 'rest':
        return Icons.hotel_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      default:
        return Icons.place_rounded;
    }
  }
}

// Extension to convert SizedBox to Sliver
extension SizedBoxSliver on SizedBox {
  Widget toSliver() => SliverToBoxAdapter(child: this);
}
