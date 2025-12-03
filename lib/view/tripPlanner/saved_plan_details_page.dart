import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tour_ease/controller/tripPlanner/tripPlannerBloc.dart';
import 'package:tour_ease/model/tripPlanner/tripPlannerModels.dart';
import 'package:tour_ease/utils/currency_formatter.dart';
import 'package:intl/intl.dart';

class SavedPlanDetailsPage extends StatefulWidget {
  final SavedPlan plan;

  const SavedPlanDetailsPage({Key? key, required this.plan}) : super(key: key);

  @override
  State<SavedPlanDetailsPage> createState() => _SavedPlanDetailsPageState();
}

class _SavedPlanDetailsPageState extends State<SavedPlanDetailsPage> {
  // Use parsed fields directly from the model or fallback to searchResultsData
  TransportOption? get outboundTransport {
    if (widget.plan.outboundTransport != null) {
      return widget.plan.outboundTransport;
    }
    // Fallback: try to get from searchResultsData
    final searchData = widget.plan.searchResultsData;
    if (searchData != null && widget.plan.selectedOutboundTransportId != null) {
      final availableOptions =
          searchData['availableOptions'] as Map<String, dynamic>?;
      final transport = availableOptions?['transport'] as List?;
      if (transport != null) {
        try {
          final selected = transport.firstWhere(
            (t) => t['id'] == widget.plan.selectedOutboundTransportId,
          );
          return TransportOption.fromJson(selected);
        } catch (e) {
          print('Could not find outbound transport in searchResultsData: $e');
        }
      }
    }
    return null;
  }

  TransportOption? get returnTransport {
    if (widget.plan.returnTransport != null) {
      return widget.plan.returnTransport;
    }
    // Fallback: try to get from searchResultsData
    final searchData = widget.plan.searchResultsData;
    if (searchData != null && widget.plan.selectedReturnTransportId != null) {
      final availableOptions =
          searchData['availableOptions'] as Map<String, dynamic>?;
      final transport = availableOptions?['transport'] as List?;
      if (transport != null) {
        try {
          final selected = transport.firstWhere(
            (t) => t['id'] == widget.plan.selectedReturnTransportId,
          );
          return TransportOption.fromJson(selected);
        } catch (e) {
          print('Could not find return transport in searchResultsData: $e');
        }
      }
    }
    return null;
  }

  AccommodationOption? get accommodation {
    if (widget.plan.accommodation != null) {
      return widget.plan.accommodation;
    }
    // Fallback: try to get from searchResultsData
    final searchData = widget.plan.searchResultsData;
    if (searchData != null && widget.plan.selectedAccommodationId != null) {
      final availableOptions =
          searchData['availableOptions'] as Map<String, dynamic>?;
      final accommodations = availableOptions?['accommodation'] as List?;
      if (accommodations != null) {
        try {
          final selected = accommodations.firstWhere(
            (a) =>
                a['accommodationId'] == widget.plan.selectedAccommodationId ||
                a['id'] == widget.plan.selectedAccommodationId,
          );
          return AccommodationOption.fromJson(selected);
        } catch (e) {
          print('Could not find accommodation in searchResultsData: $e');
        }
      }
    }
    return null;
  }

  List<RoomAllocation> get roomAllocations {
    // First try from model
    if (widget.plan.roomAllocations != null &&
        widget.plan.roomAllocations!.isNotEmpty) {
      return widget.plan.roomAllocations!;
    }
    // Try from accommodation
    if (accommodation?.roomAllocations != null &&
        accommodation!.roomAllocations.isNotEmpty) {
      return accommodation!.roomAllocations;
    }
    return [];
  }

  Map<String, dynamic>? get bookingDetails => widget.plan.bookings;
  List<ItineraryDay> get itinerary => _parseItinerary();

  @override
  void initState() {
    super.initState();
    print('=== Saved Plan Details Debug ===');
    print('Plan Name: ${widget.plan.planName}');
    print('Status: ${widget.plan.status}');
    print('Total Cost: ${widget.plan.totalCost}');
    print('\n--- Direct from Model ---');
    print(
        'Model Outbound Transport: ${widget.plan.outboundTransport != null ? 'Available' : 'NULL'}');
    print(
        'Model Return Transport: ${widget.plan.returnTransport != null ? 'Available' : 'NULL'}');
    print(
        'Model Accommodation: ${widget.plan.accommodation != null ? 'Available' : 'NULL'}');
    print(
        'Model Room Allocations: ${widget.plan.roomAllocations?.length ?? 0}');
    print('\n--- Via Getters (with fallback) ---');
    print(
        'Getter Outbound Transport: ${outboundTransport != null ? 'Available (${outboundTransport!.providerName} - ${outboundTransport!.vehicleType})' : 'NULL'}');
    print(
        'Getter Return Transport: ${returnTransport != null ? 'Available (${returnTransport!.providerName} - ${returnTransport!.vehicleType})' : 'NULL'}');
    print(
        'Getter Accommodation: ${accommodation != null ? 'Available (${accommodation!.name})' : 'NULL'}');
    print('Getter Room Allocations: ${roomAllocations.length}');
    print('\n--- Selection IDs ---');
    print('Selected Outbound ID: ${widget.plan.selectedOutboundTransportId}');
    print('Selected Return ID: ${widget.plan.selectedReturnTransportId}');
    print('Selected Accommodation ID: ${widget.plan.selectedAccommodationId}');
    print('\n--- SearchResultsData Available ---');
    print('Has searchResultsData: ${widget.plan.searchResultsData != null}');
    if (widget.plan.searchResultsData != null) {
      final availableOptions = widget
          .plan.searchResultsData!['availableOptions'] as Map<String, dynamic>?;
      if (availableOptions != null) {
        print(
            '  - Transport options: ${(availableOptions['transport'] as List?)?.length ?? 0}');
        print(
            '  - Accommodation options: ${(availableOptions['accommodation'] as List?)?.length ?? 0}');
      }
    }
    print('================================');
  }

  List<ItineraryDay> _parseItinerary() {
    // Try to get itinerary from planData or searchResultsData
    final planData = widget.plan.planData;
    final searchData = widget.plan.searchResultsData;

    final itineraryData = planData?['itinerary'] ?? searchData?['itinerary'];
    if (itineraryData != null && itineraryData is List) {
      return itineraryData.map((day) => ItineraryDay.fromJson(day)).toList();
    }
    return [];
  }

  // Parsing methods removed - now handled by SavedPlan model

  String _formatDateTime(DateTime date) {
    return DateFormat('MMM dd, h:mm a').format(date);
  }

  int _getDaysDifference() {
    return widget.plan.endTime.difference(widget.plan.startTime).inDays + 1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final days = _getDaysDifference();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Minimal App Bar
          SliverAppBar.large(
            expandedHeight: 160.h,
            pinned: true,
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
            actions: [
              IconButton(
                onPressed: () => _showDeleteConfirmation(context),
                icon: Icon(Icons.delete_outline_rounded, color: colorScheme.error),
                tooltip: 'Delete Plan',
              ),
              if (widget.plan.status == 'draft')
                IconButton(
                  onPressed: () => _showBookingOptions(context),
                  icon: Icon(Icons.payment_rounded, color: colorScheme.primary),
                  tooltip: 'Book Plan',
                )
              else
                IconButton(
                  onPressed: () => _showPlanActions(context),
                  icon: Icon(Icons.more_vert_rounded),
                  tooltip: 'More Actions',
                ),
              SizedBox(width: 8.w),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              title: Text(
                widget.plan.planName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              background: Container(color: colorScheme.surface),
            ),
          ),

          // Status & Info Section (Moved from App Bar background)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: _getStatusColor(widget.plan.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: _getStatusColor(widget.plan.status).withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_getStatusIcon(widget.plan.status),
                                color: _getStatusColor(widget.plan.status), size: 14.sp),
                            SizedBox(width: 6.w),
                            Text(
                              widget.plan.status.toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: _getStatusColor(widget.plan.status),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Icon(Icons.calendar_today_rounded,
                          size: 16.sp,
                          color: colorScheme.onSurfaceVariant),
                      SizedBox(width: 6.w),
                      Text(
                        '$days ${days == 1 ? 'Day' : 'Days'}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant),
                      ),
                      SizedBox(width: 12.w),
                      Icon(Icons.people_outline_rounded,
                          size: 16.sp,
                          color: colorScheme.onSurfaceVariant),
                      SizedBox(width: 6.w),
                      Text(
                        '${widget.plan.numberOfTravelers}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Summary Card
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: _buildSummaryCard(theme, colorScheme, days),
            ),
          ),

          // Transportation Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
              child: Row(
                children: [
                  Icon(Icons.directions_bus_outlined,
                      color: colorScheme.primary, size: 24.sp),
                  SizedBox(width: 12.w),
                  Text('Transportation',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),

          // Outbound Transport
          if (outboundTransport != null) ...[
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Text('Outbound',
                        style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant)),
                  ),
                  SizedBox(height: 8.h),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: _buildModernTransportCard(
                        outboundTransport!, theme, true, () {
                      _showTransportDetails(
                          outboundTransport!, theme, 'Outbound Journey');
                    }),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h).toSliver(),
          ],

          // Return Transport
          if (returnTransport != null && widget.plan.needsReturnTransport) ...[
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Text('Return',
                        style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant)),
                  ),
                  SizedBox(height: 8.h),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: _buildModernTransportCard(
                        returnTransport!, theme, true, () {
                      _showTransportDetails(
                          returnTransport!, theme, 'Return Journey');
                    }),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h).toSliver(),
          ],

          // Accommodation Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
              child: Row(
                children: [
                  Icon(Icons.hotel_outlined,
                      color: colorScheme.primary, size: 24.sp),
                  SizedBox(width: 12.w),
                  Text('Accommodation',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),

          // Accommodation Card
          if (accommodation != null)
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: _buildModernAccommodationCard(
                    accommodation!, theme, true, () {
                  _showAccommodationDetails(accommodation!, theme);
                }),
              ),
            ),

          SizedBox(height: 32.h).toSliver(),

          // Daily Itinerary Section
          if (itinerary.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        color: colorScheme.primary, size: 24.sp),
                    SizedBox(width: 12.w),
                    Text('Itinerary',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

            // Itinerary Days
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final day = itinerary[index];
                  return _buildDayCard(day, theme, colorScheme);
                },
                childCount: itinerary.length,
              ),
            ),

            SizedBox(height: 24.h).toSliver(),
          ],

          // Booking Status (if booked)
          if (widget.plan.status == 'booked' && bookingDetails != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: _buildBookingStatusCard(theme, colorScheme),
              ),
            ),

          SizedBox(height: 40.h).toSliver(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme, ColorScheme colorScheme, int days) {
    // Calculate actual total cost from all components
    double calculatedTotalCost = 0.0;

    // Add transport costs
    if (outboundTransport != null) {
      calculatedTotalCost += outboundTransport!.totalCost;
    }
    if (returnTransport != null && widget.plan.needsReturnTransport) {
      calculatedTotalCost += returnTransport!.totalCost;
    }

    // Add accommodation cost
    if (accommodation != null) {
      calculatedTotalCost += accommodation!.totalCost;
    }

    // Add itinerary activity costs
    for (var day in itinerary) {
      calculatedTotalCost += day.totalEstimatedCost;
    }

    // Use calculated cost if it's more accurate than stored totalCost
    final totalCost =
        calculatedTotalCost > 0 ? calculatedTotalCost : widget.plan.totalCost;
    final budgetRemaining = widget.plan.budget - totalCost;
    final budgetPercentage = (totalCost / widget.plan.budget).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.summarize_outlined,
                  color: colorScheme.primary, size: 24.sp),
              SizedBox(width: 12.w),
              Text(
                'Trip Summary',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Route Info
          Row(
            children: [
              Expanded(
                child: _buildLocationInfo(
                  icon: Icons.trip_origin_rounded,
                  label: 'From',
                  location: widget.plan.startLocation,
                  time: _formatDateTime(widget.plan.startTime),
                  color: colorScheme.primary,
                  theme: theme,
                ),
              ),
              Icon(Icons.arrow_forward_rounded,
                  color: colorScheme.onSurfaceVariant, size: 20.sp),
              Expanded(
                child: _buildLocationInfo(
                  icon: Icons.location_on_rounded,
                  label: 'To',
                  location: widget.plan.endLocation,
                  time: _formatDateTime(widget.plan.endTime),
                  color: colorScheme.primary,
                  theme: theme,
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Cost Summary
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Cost',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(color: colorScheme.onSurface)),
                    Flexible(
                      child: Text(
                        CurrencyFormatter.formatPKR(totalCost),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Budget',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7))),
                    Text(
                      CurrencyFormatter.formatPKR(widget.plan.budget),
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: budgetPercentage,
                    minHeight: 6.h,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      budgetPercentage > 0.9
                          ? colorScheme.error
                          : budgetPercentage > 0.7
                              ? Colors.orange
                              : colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      budgetRemaining >= 0 ? 'Remaining' : 'Over Budget',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7)),
                    ),
                    Text(
                      CurrencyFormatter.formatPKR(budgetRemaining.abs()),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: budgetRemaining >= 0 ? colorScheme.primary : colorScheme.error,
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

  Widget _buildLocationInfo({
    required IconData icon,
    required String label,
    required String location,
    required String time,
    required Color color,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16.sp),
            SizedBox(width: 6.w),
            Text(label,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          location,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          time,
          style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildBookingStatusCard(ThemeData theme, ColorScheme colorScheme) {
    final transportBooking = bookingDetails?['transportation']?['outbound'];
    final bookingStatus = transportBooking?['status'] ?? 'unknown';
    final bookingMessage = transportBooking?['message'] ?? 'Booking processed';

    // Additional info from plan
    final offerId = transportBooking?['offerId'];
    final totalPrice = transportBooking?['totalPrice'];

    return Container(
      margin: EdgeInsets.only(top: 24.h),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
            color: _getBookingStatusColor(bookingStatus).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: _getBookingStatusColor(bookingStatus).withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color:
                      _getBookingStatusColor(bookingStatus).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getBookingStatusIcon(bookingStatus),
                  color: _getBookingStatusColor(bookingStatus),
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Status',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      bookingStatus.toUpperCase(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _getBookingStatusColor(bookingStatus),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 20.sp, color: colorScheme.primary),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        bookingMessage,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                if (offerId != null) ...[
                  SizedBox(height: 8.h),
                  Text(
                    'Offer ID: #$offerId',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (totalPrice != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    'Amount: ${CurrencyFormatter.formatPKR(double.tryParse(totalPrice.toString()) ?? 0)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
                if (widget.plan.stripePaymentIntentId != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    'Payment ID: ${widget.plan.stripePaymentIntentId}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Reuse the transport card from TripResultsPage
  Widget _buildModernTransportCard(
    TransportOption transport,
    ThemeData theme,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 320.w,
        constraints: BoxConstraints(minHeight: 200.h, maxHeight: 280.h),
        margin: EdgeInsets.only(right: 16.w),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primaryContainer.withOpacity(0.2)
                    : colorScheme.surfaceContainerHighest.withOpacity(0.3),
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getVehicleIcon(transport.vehicleType),
                    color: colorScheme.primary,
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transport.vehicleType,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          transport.providerName,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        _buildTransportInfoRow(
                          Icons.schedule_rounded,
                          'Departure',
                          _formatDateTime(transport.departureTime),
                          theme,
                        ),
                        SizedBox(height: 12.h),
                        _buildTransportInfoRow(
                          Icons.location_on_outlined,
                          'Route',
                          '${transport.pickupLocation ?? 'Start'} → ${transport.dropoffLocation ?? 'End'}',
                          theme,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Price Footer
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Cost',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatPKR(transport.totalCost),
                    style: theme.textTheme.titleMedium?.copyWith(
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
    );
  }

  Widget _buildTransportInfoRow(
      IconData icon, String label, String value, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20.sp, color: theme.colorScheme.primary),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              Text(value,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  // Reuse accommodation card from TripResultsPage
  Widget _buildModernAccommodationCard(
    AccommodationOption accommodation,
    ThemeData theme,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 320.w,
        margin: EdgeInsets.only(right: 16.w),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                  ),
                  child: accommodation.images?.isNotEmpty ?? false
                      ? Image.network(
                          accommodation.images!.first,
                          height: 160.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 160.h,
                            color: colorScheme.surfaceContainerHighest,
                            child: Icon(Icons.hotel_rounded,
                                size: 48.sp,
                                color: colorScheme.onSurfaceVariant),
                          ),
                        )
                      : Container(
                          height: 160.h,
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(Icons.hotel_rounded,
                              size: 48.sp, color: colorScheme.onSurfaceVariant),
                        ),
                ),

                // Rating Badge
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded,
                            color: Colors.amber, size: 14.sp),
                        SizedBox(width: 4.w),
                        Text(
                          accommodation.avgRating.toStringAsFixed(1),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    accommodation.name,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 4.h),

                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 14.sp, color: colorScheme.onSurfaceVariant),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          accommodation.location,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Room Info
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bed_rounded,
                            size: 16.sp, color: colorScheme.primary),
                        SizedBox(width: 6.w),
                        Text(
                          '${roomAllocations.isNotEmpty ? roomAllocations.length : (accommodation.roomAllocations.isNotEmpty ? accommodation.roomAllocations.length : 1)} room${(roomAllocations.isNotEmpty ? roomAllocations.length : accommodation.roomAllocations.length) != 1 ? 's' : ''}',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Price Footer
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Cost',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant),
                  ),
                  Text(
                    CurrencyFormatter.formatPKR(accommodation.totalCost),
                    style: theme.textTheme.titleMedium?.copyWith(
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
    );
  }

  void _showTransportDetails(
      TransportOption transport, ThemeData theme, String title) {
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
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Icon(
                            _getVehicleIcon(transport.vehicleType),
                            size: 32.sp,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                transport.vehicleType,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 32.h),

                    // Provider Info
                    _buildDetailSection(
                      icon: Icons.person_rounded,
                      title: 'Provider Information',
                      children: [
                        _buildDetailRow('Provider', transport.providerName),
                        _buildDetailRow('Vehicle Type', transport.vehicleType),
                        _buildDetailRow(
                            'Seats Available', '${transport.seatsAvailable}'),
                      ],
                      theme: theme,
                    ),

                    SizedBox(height: 24.h),

                    // Journey Details
                    _buildDetailSection(
                      icon: Icons.route_rounded,
                      title: 'Journey Details',
                      children: [
                        _buildDetailRow('Departure',
                            _formatDateTime(transport.departureTime)),
                        _buildDetailRow(
                            'From', transport.pickupLocation ?? 'N/A'),
                        _buildDetailRow(
                            'To', transport.dropoffLocation ?? 'N/A'),
                      ],
                      theme: theme,
                    ),

                    SizedBox(height: 24.h),

                    // Pricing
                    _buildDetailSection(
                      icon: Icons.payments_rounded,
                      title: 'Pricing',
                      children: [
                        _buildDetailRow(
                            'Price per Seat',
                            CurrencyFormatter.formatPKR(
                                transport.pricePerSeat)),
                        _buildDetailRow('Total Cost',
                            CurrencyFormatter.formatPKR(transport.totalCost)),
                      ],
                      theme: theme,
                    ),

                    SizedBox(height: 32.h),

                    // Close Button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context),
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                        child: const Text('Close'),
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

  void _showAccommodationDetails(
      AccommodationOption accommodation, ThemeData theme) {
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
                    // Image Gallery
                    if (accommodation.images?.isNotEmpty ?? false)
                      SizedBox(
                        height: 250.h,
                        child: PageView.builder(
                          itemCount: accommodation.images!.length,
                          itemBuilder: (context, index) {
                            return Image.network(
                              accommodation.images![index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: colorScheme.surfaceContainerHighest,
                                child: Icon(Icons.hotel_rounded, size: 64.sp),
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Container(
                        height: 250.h,
                        color: colorScheme.surfaceContainerHighest,
                        child: Center(
                          child: Icon(Icons.hotel_rounded,
                              size: 64.sp, color: colorScheme.onSurfaceVariant),
                        ),
                      ),

                    Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      accommodation.name,
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on_outlined,
                                            size: 16.sp,
                                            color:
                                                colorScheme.onSurfaceVariant),
                                        SizedBox(width: 4.w),
                                        Text(
                                          accommodation.location,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                  color: colorScheme
                                                      .onSurfaceVariant),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.star_rounded,
                                        color: Colors.white, size: 16.sp),
                                    SizedBox(width: 4.w),
                                    Text(
                                      accommodation.avgRating
                                          .toStringAsFixed(1),
                                      style:
                                          theme.textTheme.labelMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 20.h),

                          // Description
                          if (accommodation.description?.isNotEmpty ??
                              false) ...[
                            Text(
                              accommodation.description!,
                              style: theme.textTheme.bodyLarge,
                            ),
                            SizedBox(height: 24.h),
                          ],

                          // Stay Details
                          _buildDetailSection(
                            icon: Icons.hotel_rounded,
                            title: 'Stay Details',
                            children: [
                              _buildDetailRow(
                                  'Check-in',
                                  accommodation.checkInDate != null
                                      ? DateFormat('MMM dd, yyyy')
                                          .format(accommodation.checkInDate!)
                                      : 'N/A'),
                              _buildDetailRow(
                                  'Check-out',
                                  accommodation.checkOutDate != null
                                      ? DateFormat('MMM dd, yyyy')
                                          .format(accommodation.checkOutDate!)
                                      : 'N/A'),
                              _buildDetailRow('Number of Nights',
                                  '${accommodation.numberOfNights}'),
                              _buildDetailRow('Guests',
                                  '${accommodation.totalGuests ?? 0}'),
                            ],
                            theme: theme,
                          ),

                          SizedBox(height: 24.h),

                          // Room Allocations
                          Text(
                            'Room Details',
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 12.h),

                          ...(roomAllocations.isNotEmpty
                                  ? roomAllocations
                                  : accommodation.roomAllocations)
                              .map((room) => Container(
                                    margin: EdgeInsets.only(bottom: 12.h),
                                    padding: EdgeInsets.all(16.w),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerHighest
                                          .withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                          color: colorScheme.outline
                                              .withOpacity(0.2)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                room.roomType,
                                                style: theme
                                                    .textTheme.titleMedium
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                            ),
                                            Text(
                                              CurrencyFormatter.formatPKR(
                                                  room.pricePerNight),
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                color: colorScheme.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8.h),
                                        Text('Per night',
                                            style: theme.textTheme.bodySmall),
                                        SizedBox(height: 8.h),
                                        Row(
                                          children: [
                                            Icon(Icons.people_rounded,
                                                size: 16.sp,
                                                color: colorScheme
                                                    .onSurfaceVariant),
                                            SizedBox(width: 4.w),
                                            Text('Capacity: ${room.capacity}',
                                                style:
                                                    theme.textTheme.bodyMedium),
                                            SizedBox(width: 16.w),
                                            Icon(Icons.hotel_rounded,
                                                size: 16.sp,
                                                color: colorScheme
                                                    .onSurfaceVariant),
                                            SizedBox(width: 4.w),
                                            Text('Rooms: ${room.numberOfRooms}',
                                                style:
                                                    theme.textTheme.bodyMedium),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),

                          SizedBox(height: 24.h),

                          // Amenities
                          if (accommodation.amenities?.isNotEmpty ?? false) ...[
                            Text(
                              'Amenities',
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 12.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: accommodation.amenities!
                                  .map((amenity) => Chip(
                                        label: Text(amenity),
                                        avatar: Icon(_getAmenityIcon(amenity),
                                            size: 18.sp),
                                        backgroundColor:
                                            colorScheme.surfaceContainerHighest,
                                      ))
                                  .toList(),
                            ),
                            SizedBox(height: 24.h),
                          ],

                          // Total Cost
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Accommodation Cost',
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  CurrencyFormatter.formatPKR(
                                      accommodation.totalCost),
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 24.h),

                          // Close Button
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () => Navigator.pop(context),
                              style: FilledButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                              ),
                              child: const Text('Close'),
                            ),
                          ),
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

  Widget _buildDetailSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24.sp),
            SizedBox(width: 12.w),
            Text(
              title,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12.r),
            border:
                Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
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

  Widget _buildDayCard(
      ItineraryDay day, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day Header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withOpacity(0.5),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day ${day.day}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${day.date} • ${day.dayOfWeek}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    CurrencyFormatter.formatPKR(day.totalEstimatedCost),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Day Theme
          if (day.theme.isNotEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outlineVariant.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline_rounded,
                      size: 16.sp, color: colorScheme.primary),
                  SizedBox(width: 8.w),
                  Text(
                    day.theme,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

          // Activities
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            itemCount: day.activities.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final activity = day.activities[index];
              return _buildActivityItem(activity, theme, colorScheme);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
      ActivityItem activity, ThemeData theme, ColorScheme colorScheme) {
    return InkWell(
      onTap: () => _showActivityDetails(activity, theme),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16.r),
          border:
              Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Activity photo preview (if available)
            if (activity.placeDetails != null &&
                activity.placeDetails!.photos != null &&
                activity.placeDetails!.photos!.isNotEmpty)
              Container(
                width: 80.w,
                height: 80.w,
                margin: EdgeInsets.only(right: 12.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border:
                      Border.all(color: colorScheme.outline.withOpacity(0.2)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    activity.placeDetails!.photos!.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color:
                            _getCategoryColor(activity.type).withOpacity(0.12),
                        child: Icon(
                          _getCategoryIcon(activity.type),
                          color: _getCategoryColor(activity.type),
                          size: 32.sp,
                        ),
                      );
                    },
                  ),
                ),
              )
            else
              // Time fallback when no photo
              Container(
                width: 70.w,
                margin: EdgeInsets.only(right: 12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.schedule_rounded,
                        size: 16.sp, color: colorScheme.primary),
                    SizedBox(height: 4.h),
                    Text(
                      activity.time,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    if (activity.duration != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        '${activity.duration}m',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            // Activity Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time (when photo is shown)
                  if (activity.placeDetails != null &&
                      activity.placeDetails!.photos != null &&
                      activity.placeDetails!.photos!.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded,
                            size: 14.sp, color: colorScheme.primary),
                        SizedBox(width: 4.w),
                        Text(
                          activity.time,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        if (activity.duration != null) ...[
                          Text(
                            ' • ${activity.duration}m',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 6.h),
                  ],

                  Wrap(
                    spacing: 8.w,
                    runSpacing: 6.h,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color:
                              _getCategoryColor(activity.type).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getCategoryIcon(activity.type),
                              size: 14.sp,
                              color: _getCategoryColor(activity.type),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              activity.type,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: _getCategoryColor(activity.type),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (activity.estimatedCost > 0)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            CurrencyFormatter.formatPKR(activity.estimatedCost),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  Text(
                    activity.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 4.h),

                  Text(
                    activity.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (activity.location != null) ...[
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(Icons.place_rounded,
                            size: 14.sp, color: colorScheme.error),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            activity.location!.name,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (activity.placeDetails?.rating != null) ...[
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.star_rounded,
                            size: 14.sp, color: Colors.amber),
                        SizedBox(width: 4.w),
                        Text(
                          '${activity.placeDetails!.rating!.toStringAsFixed(1)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (activity.placeDetails!.userRatingsTotal !=
                            null) ...[
                          Text(
                            ' (${activity.placeDetails!.userRatingsTotal})',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(width: 8.w),
            Icon(Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant, size: 20.sp),
          ],
        ),
      ),
    );
  }

  void _showActivityDetails(ActivityItem activity, ThemeData theme) {
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
                            color: _getCategoryColor(activity.type)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Icon(
                            _getCategoryIcon(activity.type),
                            size: 32.sp,
                            color: _getCategoryColor(activity.type),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity.type,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: _getCategoryColor(activity.type),
                                ),
                              ),
                              Text(
                                activity.title,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Activity Photos Gallery
                    if (activity.placeDetails != null &&
                        activity.placeDetails!.photos != null &&
                        activity.placeDetails!.photos!.isNotEmpty) ...[
                      SizedBox(height: 20.h),
                      SizedBox(
                        height: 120.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount:
                              activity.placeDetails!.photos!.length.clamp(0, 5),
                          separatorBuilder: (context, index) =>
                              SizedBox(width: 12.w),
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: Image.network(
                                activity.placeDetails!.photos![index],
                                width: 160.w,
                                height: 120.h,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 160.w,
                                    height: 120.h,
                                    color: colorScheme.surfaceContainerHighest,
                                    child: Icon(
                                      _getCategoryIcon(activity.type),
                                      size: 48.sp,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    SizedBox(height: 24.h),
                    _buildDetailSection(
                      icon: Icons.info_outline_rounded,
                      title: 'Description',
                      children: [
                        Text(activity.description,
                            style: theme.textTheme.bodyLarge),
                      ],
                      theme: theme,
                    ),

                    if (activity.location != null) ...[
                      SizedBox(height: 24.h),
                      _buildDetailSection(
                        icon: Icons.place_rounded,
                        title: 'Location',
                        children: [
                          _buildDetailRow('Place', activity.location!.name),
                          if (activity.location!.address != null)
                            _buildDetailRow(
                                'Address', activity.location!.address!),
                          _buildDetailRow(
                            'Coordinates',
                            '${activity.location!.coordinates.lat.toStringAsFixed(6)}, ${activity.location!.coordinates.lng.toStringAsFixed(6)}',
                          ),
                        ],
                        theme: theme,
                      ),
                    ],

                    SizedBox(height: 24.h),

                    _buildDetailSection(
                      icon: Icons.schedule_rounded,
                      title: 'Timing & Cost',
                      children: [
                        _buildDetailRow('Time', activity.time),
                        if (activity.duration != null)
                          _buildDetailRow(
                              'Duration', '${activity.duration} minutes'),
                        _buildDetailRow(
                            'Estimated Cost',
                            CurrencyFormatter.formatPKR(
                                activity.estimatedCost)),
                      ],
                      theme: theme,
                    ),

                    if (activity.placeDetails != null) ...[
                      SizedBox(height: 24.h),
                      _buildDetailSection(
                        icon: Icons.star_rounded,
                        title: 'Reviews & Details',
                        children: [
                          if (activity.placeDetails!.rating != null)
                            _buildDetailRow('Rating',
                                '${activity.placeDetails!.rating!.toStringAsFixed(1)} ⭐'),
                          if (activity.placeDetails!.userRatingsTotal != null)
                            _buildDetailRow('Total Reviews',
                                '${activity.placeDetails!.userRatingsTotal}'),
                          if (activity.placeDetails!.priceLevel != null)
                            _buildDetailRow('Price Level',
                                '${'💰' * activity.placeDetails!.priceLevel!}'),
                          if (activity.placeDetails!.website != null)
                            _buildDetailRow(
                                'Website', activity.placeDetails!.website!),
                          if (activity.placeDetails!.phoneNumber != null)
                            _buildDetailRow(
                                'Phone', activity.placeDetails!.phoneNumber!),
                        ],
                        theme: theme,
                      ),
                    ],

                    if (activity.tips != null) ...[
                      SizedBox(height: 24.h),
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border:
                              Border.all(color: Colors.amber.withOpacity(0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.tips_and_updates_rounded,
                                color: Colors.amber.shade700, size: 24.sp),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tips',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber.shade900,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    activity.tips!,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: 32.h),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context),
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                        child: const Text('Close'),
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

  IconData _getCategoryIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('food') ||
        lower.contains('dining') ||
        lower.contains('restaurant') ||
        lower.contains('meal')) {
      return Icons.restaurant_rounded;
    }
    if (lower.contains('sightseeing') ||
        lower.contains('attraction') ||
        lower.contains('visit')) {
      return Icons.attractions_rounded;
    }
    if (lower.contains('activity') || lower.contains('adventure')) {
      return Icons.local_activity_rounded;
    }
    if (lower.contains('shopping')) {
      return Icons.shopping_bag_rounded;
    }
    if (lower.contains('transport') || lower.contains('travel')) {
      return Icons.directions_car_rounded;
    }
    if (lower.contains('relaxation') || lower.contains('leisure')) {
      return Icons.spa_rounded;
    }
    if (lower.contains('culture') || lower.contains('museum')) {
      return Icons.museum_rounded;
    }
    if (lower.contains('nature') || lower.contains('park')) {
      return Icons.park_rounded;
    }
    return Icons.place_rounded;
  }

  Color _getCategoryColor(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('food') ||
        lower.contains('dining') ||
        lower.contains('restaurant') ||
        lower.contains('meal')) {
      return Colors.orange;
    }
    if (lower.contains('sightseeing') ||
        lower.contains('attraction') ||
        lower.contains('visit')) {
      return Colors.blue;
    }
    if (lower.contains('activity') || lower.contains('adventure')) {
      return Colors.purple;
    }
    if (lower.contains('shopping')) {
      return Colors.pink;
    }
    if (lower.contains('transport') || lower.contains('travel')) {
      return Colors.teal;
    }
    if (lower.contains('relaxation') || lower.contains('leisure')) {
      return Colors.green;
    }
    if (lower.contains('culture') || lower.contains('museum')) {
      return Colors.deepPurple;
    }
    if (lower.contains('nature') || lower.contains('park')) {
      return Colors.lightGreen;
    }
    return Colors.grey;
  }

  IconData _getAmenityIcon(String amenity) {
    final lower = amenity.toLowerCase();
    if (lower.contains('wifi') || lower.contains('wi-fi'))
      return Icons.wifi_rounded;
    if (lower.contains('parking')) return Icons.local_parking_rounded;
    if (lower.contains('restaurant') || lower.contains('dining'))
      return Icons.restaurant_rounded;
    if (lower.contains('pool') || lower.contains('swimming'))
      return Icons.pool_rounded;
    if (lower.contains('gym') || lower.contains('fitness'))
      return Icons.fitness_center_rounded;
    if (lower.contains('spa')) return Icons.spa_rounded;
    if (lower.contains('bar')) return Icons.local_bar_rounded;
    if (lower.contains('room service')) return Icons.room_service_rounded;
    return Icons.check_circle_outline_rounded;
  }

  IconData _getVehicleIcon(String vehicleType) {
    final lower = vehicleType.toLowerCase();
    if (lower.contains('bus') || lower.contains('minibus'))
      return Icons.directions_bus_rounded;
    if (lower.contains('car')) return Icons.directions_car_rounded;
    if (lower.contains('van')) return Icons.airport_shuttle_rounded;
    return Icons.directions_rounded;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'booked':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'draft':
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'booked':
        return Icons.check_circle_rounded;
      case 'completed':
        return Icons.done_all_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      case 'draft':
      default:
        return Icons.edit_note_rounded;
    }
  }

  Color _getBookingStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getBookingStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle_rounded;
      case 'pending':
        return Icons.schedule_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plan?'),
        content: Text(
            'Are you sure you want to delete "${widget.plan.planName}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context
                  .read<TripPlannerBloc>()
                  .add(DeleteSavedPlan(planId: widget.plan.id));
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to list
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Plan deleted successfully')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showBookingOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Book This Plan',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24.h),
            ListTile(
              leading: Icon(Icons.payment_rounded,
                  color: Theme.of(context).colorScheme.primary),
              title: const Text('Proceed to Payment'),
              subtitle:
                  Text(CurrencyFormatter.formatPKR(widget.plan.totalCost)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment feature coming soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPlanActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Plan Actions',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24.h),
            ListTile(
              leading: Icon(Icons.share_rounded,
                  color: Theme.of(context).colorScheme.primary),
              title: const Text('Share Plan'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share feature coming soon')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.edit_rounded,
                  color: Theme.of(context).colorScheme.primary),
              title: const Text('Edit Plan'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit feature coming soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Extension to convert SizedBox to Sliver
extension SizedBoxSliver on SizedBox {
  Widget toSliver() => SliverToBoxAdapter(child: this);
}
