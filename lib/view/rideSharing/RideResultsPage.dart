import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:tour_ease/bloc/rideResultsBloc.dart';
import 'package:tour_ease/components/PulsatingActionButton/PulsatingActionButton.dart';
import 'package:tour_ease/model/rideSharing/rideListing/rideListingModel.dart';
import 'package:tour_ease/view/rideSharing/RideRequestPage.dart';
import 'package:tour_ease/view/rideSharing/rideBookingSheetUp.dart';
import 'package:tour_ease/Services/ApiService.dart';
import 'package:tour_ease/model/reviews/reviews_repo.dart';
import 'package:tour_ease/components/profileAvatar.dart';
import 'package:tour_ease/model/userManagment/user.dart';

class RideResultsPage extends StatefulWidget {
  const RideResultsPage({super.key});

  @override
  State<RideResultsPage> createState() => _RideResultsPageState();
}

class _RideListingRatingBadge extends StatefulWidget {
  final String driverID;
  const _RideListingRatingBadge({required this.driverID});

  @override
  State<_RideListingRatingBadge> createState() => _RideListingRatingBadgeState();
}

class _RideListingRatingBadgeState extends State<_RideListingRatingBadge>
    with SingleTickerProviderStateMixin {
  double? _average;
  int? _count;
  bool _loading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _fetch();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    try {
      final api = context.read<APIService>();
      final repo = ReviewsRepositoryApi(api);
      
      final stats = await repo.getDriverStats(driverId: widget.driverID);
      if (!mounted) return;
      setState(() {
        _average = stats.stats['averageRating'] is num
            ? (stats.stats['averageRating'] as num).toDouble()
            : double.tryParse(stats.stats['averageRating']?.toString() ?? '0') ?? 0;
        _count = stats.stats['totalReviews'] is int
            ? (stats.stats['totalReviews'] as int)
            : int.tryParse(stats.stats['totalReviews']?.toString() ?? '0') ?? 0;
        _loading = false;
      });
      _animationController.forward();
    } catch (e) {
      print("Error fetching driver stats: $e");
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
        width: 60.w,
        height: 24.h,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: const Center(
            child: SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          ),
        ),
      );
    }
    
    if (_average == null) {
      return const SizedBox.shrink();
    }
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber.shade400, Colors.orange.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rounded, color: Colors.white, size: 16.sp),
            SizedBox(width: 4.w),
            Text(
              _average!.toStringAsFixed(1),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
            if (_count != null && _count! > 0) ...[
              SizedBox(width: 4.w),
              Text(
                '($_count)',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 11.sp,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RideResultsPageState extends State<RideResultsPage>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    ));
    
    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeInOut,
    ));
    
    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.h),
        child: SlideTransition(
          position: _headerSlideAnimation,
          child: FadeTransition(
            opacity: _headerFadeAnimation,
            child: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary.withOpacity(0.1),
                      colorScheme.secondary.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Available Rides',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  BlocBuilder<RideResultBloc, RideResultState>(
                    builder: (context, state) {
                      if (!state.isLoading && state.error == null) {
                        // Filter out current user's rides for the count
                        final currentUserId = UserModel().id;
                        final filteredCount = state.rides
                            .where((ride) => ride.providerId != currentUserId)
                            .length;
                        
                        return Text(
                          '$filteredCount ride${filteredCount != 1 ? 's' : ''} found',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
              leading: Container(
                margin: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Navigator.pop(context),
                  iconSize: 20.sp,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _headerFadeAnimation,
        child: PulsatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => RideRequestPage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
              ),
            );
          },
        ),
      ),
      body: BlocBuilder<RideResultBloc, RideResultState>(
        builder: (context, state) {
          if (state.isLoading) {
            return _buildLoadingState(colorScheme);
          }

          if (state.error != null) {
            return _buildErrorState(state.error!, colorScheme, textTheme);
          }

          // Filter out the current user's own rides
          final currentUserId = UserModel().id;
          final filteredRides = state.rides
              .where((ride) => ride.providerId != currentUserId)
              .toList();

          if (filteredRides.isEmpty) {
            return _buildEmptyState(colorScheme, textTheme);
          }

          return _buildRidesList(filteredRides, theme);
        },
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return AnimationLimiter(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: List.generate(
            3,
            (index) => AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildSkeletonCard(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Container(
        height: 180.h,
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120.w,
                        height: 16.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: 80.w,
                        height: 14.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 80.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 60.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Container(
                    height: 60.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: AnimationConfiguration.synchronized(
        duration: const Duration(milliseconds: 600),
        child: FadeInAnimation(
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: Padding(
              padding: EdgeInsets.all(32.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 64.sp,
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Oops! Something went wrong',
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    error,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32.h),
                  FilledButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_rounded),
                    label: Text('Go Back'),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: AnimationConfiguration.synchronized(
        duration: const Duration(milliseconds: 600),
        child: FadeInAnimation(
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: Padding(
              padding: EdgeInsets.all(32.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.directions_car_outlined,
                      size: 64.sp,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'No rides available',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Try adjusting your filters or check back later for more options',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32.h),
                  FilledButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.tune_rounded),
                    label: Text('Adjust Filters'),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRidesList(List<RideListingModel> rides, ThemeData theme) {
    return AnimationLimiter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: rides.length,
          itemBuilder: (context, index) {
            final ride = rides[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 500),
              delay: Duration(milliseconds: index * 100),
              child: SlideAnimation(
                curve: Curves.easeOutCubic,
                verticalOffset: 80.0,
                child: FadeInAnimation(
                  curve: Curves.easeIn,
                  child: _buildRideCard(ride, theme, index),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRideCard(RideListingModel ride, ThemeData theme, int index) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final dateFormat = DateFormat('MMM dd');
    final timeFormat = DateFormat('hh:mm a');

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      child: Material(
        elevation: 2,
        shadowColor: colorScheme.shadow.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24.r),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    RideDetailsSheet(ride: ride),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 1.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  );
                },
              ),
            );
          },
          borderRadius: BorderRadius.circular(24.r),
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              color: colorScheme.surface,
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price and Rating Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price - Make it prominent
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PKR ${ride.pricePerSeat.toStringAsFixed(0)}',
                          style: textTheme.headlineSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'per seat',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    
                    _RideListingRatingBadge(driverID: ride.providerId),
                  ],
                ),

                SizedBox(height: 20.h),

                // Route - Integrated design
                _buildIntegratedRoute(
                  ride.startLocationText,
                  ride.endLocationText,
                  colorScheme,
                  textTheme,
                ),

                SizedBox(height: 20.h),

                // Time and Seats - Inline, minimal
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 18.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${dateFormat.format(ride.departureTime)} at ${timeFormat.format(ride.departureTime)}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Container(
                      width: 4.w,
                      height: 4.w,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Icon(
                      Icons.event_seat_rounded,
                      size: 18.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${ride.seatsAvailable} left',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // Divider
                Divider(
                  height: 1,
                  thickness: 1,
                  color: colorScheme.outlineVariant.withOpacity(0.5),
                ),

                SizedBox(height: 16.h),

                // Driver info - Bottom section
                Row(
                  children: [
                    Hero(
                      tag: 'avatar_${ride.id}',
                      child: ProfileAvatar(
                        imageURL: (ride.provider != null && 
                            ride.provider!.user.mediaUrls.isNotEmpty)
                            ? ride.provider!.user.mediaUrls.first
                            : null,
                        userName: ride.provider != null 
                            ? ride.provider!.user.username 
                            : 'Driver',
                        radius: 22.r,
                        userId: ride.provider != null 
                            ? ride.provider!.user.id 
                            : '',
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ride.provider!.user.username,
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Icon(
                                Icons.directions_car_rounded,
                                color: colorScheme.onSurfaceVariant,
                                size: 14.sp,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                ride.provider!.vehicleType,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Book button - Compact
                    FilledButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                RideDetailsSheet(ride: ride),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.0, 1.0),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                )),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text('Book'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntegratedRoute(
    String startLocation,
    String endLocation,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Route line indicator
        Column(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.3),
                  width: 3,
                ),
              ),
            ),
            Container(
              width: 2.w,
              height: 40.h,
              margin: EdgeInsets.symmetric(vertical: 4.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.3),
                  ],
                ),
              ),
            ),
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.primary,
                  width: 2.5,
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: 16.w),
        // Locations
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                startLocation,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 32.h),
              Text(
                endLocation,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  height: 1.3,
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
}