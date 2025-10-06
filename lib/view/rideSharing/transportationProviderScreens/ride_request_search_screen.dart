import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:tour_ease/controller/rideSharing/RideRequests/ride_request_bloc.dart';
import 'package:tour_ease/model/rideSharing/RideFilterData.dart';
import 'package:tour_ease/model/rideSharing/rideRequest/rideRequestModel.dart';
import 'package:tour_ease/view/rideSharing/transportationProviderScreens/ride_request_search_widget.dart';
import 'package:tour_ease/view/rideSharing/transportationProviderScreens/viewRequestDetails.dart';
import 'package:tour_ease/model/userManagment/user.dart';

class RideRequestSearchScreen extends StatefulWidget {
  const RideRequestSearchScreen({Key? key}) : super(key: key);

  @override
  State<RideRequestSearchScreen> createState() => _RideRequestSearchScreenState();
}

class _RideRequestSearchScreenState extends State<RideRequestSearchScreen> with SingleTickerProviderStateMixin {
  RideFilterModel? _lastFilter;
  bool _isSearchCollapsed = false;
  late AnimationController _animationController;
  late Animation<double> _searchHeightAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _searchHeightAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleSearch(RideFilterModel filter) {

    print('Search initiated with filter: ${filter.luggageCapacity}');
    setState(() {
      _lastFilter = filter;
      _isSearchCollapsed = true;
    });
    _animationController.forward();
    context.read<RideRequestBloc>().add(FetchRideRequests(filter: filter));
  }

  void _expandSearch() {
    setState(() {
      _isSearchCollapsed = false;
    });
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Ride Requests'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Animated Search Widget Section
          AnimatedBuilder(
            animation: _searchHeightAnimation,
            builder: (context, child) {
              return SizeTransition(
                sizeFactor: _searchHeightAnimation,
                axisAlignment: -1.0,
                child: child,
              );
            },
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: SingleChildScrollView(
                child: RideRequestSearchWidget(
                  onSearch: _handleSearch,
                ),
              ),
            ),
          ),
          
          // Collapsed search summary (shows when search is active)
          if (_isSearchCollapsed) _buildCollapsedSearchBar(colorScheme, textTheme),
          
          Divider(height: 1, thickness: 1),
          
          // Results Section - Expands when search is collapsed
          Expanded(
            child: BlocBuilder<RideRequestBloc, RideRequestState>(
              builder: (context, state) {
                if (state is RideRequestLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: colorScheme.primary),
                        SizedBox(height: 16.h),
                        Text(
                          'Searching for requests...',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is RideRequestError) {
                  return _buildErrorState(context, state, textTheme, colorScheme);
                } else if (state is RideRequestLoaded) {
                  // Filter out current user's own requests
                  final currentUserId = UserModel().id;
                  final filteredRequests = state.rideRequests
                      .where((request) => request.travelerId != currentUserId)
                      .toList();
                  
                  if (filteredRequests.isEmpty) {
                    return _buildEmptyState(textTheme, colorScheme);
                  }
                  return _buildRideRequestsList(
                    filteredRequests,
                    textTheme,
                    colorScheme,
                  );
                } else {
                  return _buildInitialState(textTheme, colorScheme);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedSearchBar(ColorScheme colorScheme, TextTheme textTheme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
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
                  'Active Search',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                if (_lastFilter != null)
                  Text(
                    '${_lastFilter!.pickupLocation} → ${_lastFilter!.destination}',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: _expandSearch,
            icon: Icon(Icons.edit_outlined, size: 20.sp),
            tooltip: 'Modify Search',
            color: colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState(TextTheme textTheme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80.sp,
              color: colorScheme.primary.withOpacity(0.3),
            ),
            SizedBox(height: 24.h),
            Text(
              'Ready to Search',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Fill in your search criteria above and tap "Search Requests" to find available ride requests',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    RideRequestError state,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: colorScheme.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'Error',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              state.error,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              icon: Icon(Icons.refresh, size: 20.sp),
              label: Text('Retry'),
              onPressed: () {
                if (_lastFilter != null) {
                  context.read<RideRequestBloc>().add(
                        FetchRideRequests(filter: _lastFilter!),
                      );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(TextTheme textTheme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80.sp,
              color: colorScheme.onSurfaceVariant.withOpacity(0.4),
            ),
            SizedBox(height: 24.h),
            Text(
              'No Requests Found',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'No ride requests match your search criteria. Try adjusting your filters.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideRequestsList(
    List<TravelerRideRequestModel> requests,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        // Results header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          color: colorScheme.primaryContainer.withOpacity(0.3),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: colorScheme.primary, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                '${requests.length} request${requests.length == 1 ? '' : 's'} found',
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        // Results list
        Expanded(
          child: AnimationLimiter(
            child: RefreshIndicator(
              onRefresh: () async {
                if (_lastFilter != null) {
                  context.read<RideRequestBloc>().add(
                        FetchRideRequests(filter: _lastFilter!),
                      );
                }
              },
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: _buildRequestCard(request, textTheme, colorScheme),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestCard(
    TravelerRideRequestModel request,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    final dateFormat = DateFormat('MMM dd, hh:mm a');

    return Card(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TravelerRideRequestDetailsPage(
                travelerRideRequestModel: request,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with ID and Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Request #${request.id}',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14.sp,
                          color: colorScheme.onPrimaryContainer,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          dateFormat.format(request.departureTime),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Route information
              _buildRouteInfo(request, colorScheme, textTheme),

              SizedBox(height: 16.h),
              Divider(height: 1),
              SizedBox(height: 16.h),

              // Trip details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoChip(
                    icon: Icons.people_outline,
                    label: '${request.seatsNeeded} Seats',
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  _buildInfoChip(
                    icon: Icons.attach_money,
                    label: 'PKR ${request.budget.toStringAsFixed(0)}',
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  if (request.luggage != null && request.luggage! > 0)
                    _buildInfoChip(
                      icon: Icons.luggage,
                      label: '${request.luggage} bags',
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                  if (request.distanceKm != null && request.distanceKm! > 0)
                    _buildInfoChip(
                      icon: Icons.route,
                      label: '${request.distanceKm!.toStringAsFixed(1)} km',
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                ],
              ),

              SizedBox(height: 16.h),

              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TravelerRideRequestDetailsPage(
                          travelerRideRequestModel: request,
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.visibility, size: 18.sp),
                  label: Text('View Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteInfo(
    TravelerRideRequestModel request,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(Icons.trip_origin, color: colorScheme.primary, size: 20.sp),
            Container(
              height: 30.h,
              width: 2.w,
              margin: EdgeInsets.symmetric(vertical: 4.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.primary,
                    colorScheme.secondary,
                  ],
                ),
              ),
            ),
            Icon(Icons.location_on, color: colorScheme.secondary, size: 20.sp),
          ],
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pickup',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                request.startLocationText,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12.h),
              Text(
                'Destination',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                request.endLocationText,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: colorScheme.primary),
          SizedBox(width: 6.w),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
