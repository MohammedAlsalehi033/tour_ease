import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tour_ease/components/profileAvatar.dart';
import 'package:tour_ease/controller/rideSharing/offers/offers_bloc.dart';
import 'package:tour_ease/controller/rideSharing/offers/offers_event.dart';
import 'package:tour_ease/controller/rideSharing/offers/offers_state.dart';
import 'package:tour_ease/model/rideSharing/rideListing/rideListingModel.dart';
import 'package:intl/intl.dart';
import 'package:tour_ease/model/userManagment/user.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import 'package:tour_ease/Services/ApiService.dart';
import 'package:tour_ease/model/reviews/reviews_repo.dart';

import 'package:tour_ease/view/chat/chatDetailsPage.dart';

class RideDetailsSheet extends StatefulWidget {
  final RideListingModel ride;
  const RideDetailsSheet({super.key, required this.ride});

  @override
  State<RideDetailsSheet> createState() => _RideDetailsSheetState();
}

class _RideDetailsSheetState extends State<RideDetailsSheet>
    with TickerProviderStateMixin {
  double counterOffer = 0;
  bool isCountering = false;

  late AnimationController _slideController;
  late AnimationController _expandController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  int _seatsRequested = 1;
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Reviews state
  double? _averageRating;
  int? _totalReviews;
  List<Map<String, dynamic>> _reviews = [];
  bool _loadingReviews = true;

  @override
  void initState() {
    super.initState();
    counterOffer = widget.ride.pricePerSeat;
    _priceController.text = widget.ride.pricePerSeat.toStringAsFixed(0);

    _initializeAnimations();
    _fetchReviews();

    // Start entrance animation
    _slideController.forward();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _expandController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    ));
  }

  Future<void> _fetchReviews() async {
    try {
      final api = context.read<APIService>();
      final repo = ReviewsRepositoryApi(api);
      
      final stats = await repo.getDriverStats(driverId: widget.ride.providerId);
      
      if (!mounted) return;
      
      setState(() {
        _averageRating = stats.stats['averageRating'] is num
            ? (stats.stats['averageRating'] as num).toDouble()
            : double.tryParse(stats.stats['averageRating']?.toString() ?? '0') ?? 0;
        _totalReviews = stats.stats['totalReviews'] is int
            ? (stats.stats['totalReviews'] as int)
            : int.tryParse(stats.stats['totalReviews']?.toString() ?? '0') ?? 0;
        _reviews = stats.reviews
                .map((e) => e as Map<String, dynamic>)
                .toList();
        _loadingReviews = false;
      });
    } catch (e) {
      print("Error fetching reviews: $e");
      if (!mounted) return;
      setState(() {
        _loadingReviews = false;
      });
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _expandController.dispose();
    _priceController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleCountering() {
    setState(() {
      isCountering = !isCountering;
    });

    if (isCountering) {
      // Auto scroll to bottom to show offer form
      Future.delayed(const Duration(milliseconds: 200), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _sendOffer() {
    // Validate price
    final priceText = _priceController.text.trim();
    if (priceText.isEmpty) {
      _showSnackBar('Please enter a price', isError: true);
      return;
    }

    final parsedPrice = double.tryParse(priceText);
    if (parsedPrice == null) {
      _showSnackBar('Please enter a valid price', isError: true);
      return;
    }

    if (parsedPrice <= 0) {
      _showSnackBar('Price must be greater than 0', isError: true);
      return;
    }

    // Validate seats
    if (_seatsRequested < 1) {
      _showSnackBar('Please select at least 1 seat', isError: true);
      return;
    }

    if (_seatsRequested > widget.ride.seatsAvailable) {
      _showSnackBar('Only ${widget.ride.seatsAvailable} seats available', isError: true);
      return;
    }

    // Send the offer
    context.read<OfferBloc>().add(
      CreateOfferEvent(
        transportationListingId: widget.ride.id,
        message: _messageController.text.trim(),
        senderId: UserModel().id,
        recipientId: widget.ride.providerId,
        pricePerSeat: parsedPrice,
        seatsRequested: _seatsRequested,
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent, // Make scaffold bg transparent for the sheet effect
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: BlocListener<OfferBloc, OfferState>(
          listener: (context, state) {
            if (state is OfferCreated) {
              _showSnackBar('Offer sent successfully! 🎉');
              // Close the sheet and go back after successful offer
              Future.delayed(const Duration(milliseconds: 1500), () {
                if (mounted) {
                  Navigator.pop(context);
                }
              });
            } else if (state is OfferError) {
              _showSnackBar('Failed to send offer: ${state.message}', isError: true);
            }
          },
          child: SlideTransition(
            position: _slideAnimation,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.9,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -8),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildHeader(theme),
                    Expanded(
                      child: _buildContent(theme),
                    ),
                    _buildActionButtons(theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 0),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 24.h),

          FadeTransition(
            opacity: _fadeAnimation,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trip Details',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        DateFormat('EEEE, MMM d • h:mm a').format(widget.ride.departureTime),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Duration badge
               

                SizedBox(width: 12.w),

                // Close button
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(24.w),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRouteCard(theme),
            SizedBox(height: 20.h),
            _buildDriverCard(theme),
            SizedBox(height: 20.h),
            _buildReviewsCard(theme),
            SizedBox(height: 20.h),
            _buildVehicleCard(theme),
            SizedBox(height: 20.h),
            _buildPriceCard(theme),
            SizedBox(height: 20.h), // Extra space for bottom
          ],
        ),
      ),
    );
  }

  BoxDecoration _getCardDecoration(ThemeData theme, {bool hasGradient = false, bool accentBorder = false}) {
    return BoxDecoration(
      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      gradient: hasGradient
          ? LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.colorScheme.primary.withOpacity(0.05),
          theme.colorScheme.secondary.withOpacity(0.05),
        ],
      )
          : null,
      borderRadius: BorderRadius.circular(24.r),
      border: Border.all(
        color: accentBorder
            ? theme.colorScheme.primary.withOpacity(0.5)
            : theme.colorScheme.outline.withOpacity(0.1),
        width: accentBorder ? 1.5 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildRouteCard(ThemeData theme) {
    return Container(
      decoration: _getCardDecoration(theme),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Route',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell(
                onTap: () => _openDirections(),
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.directions_rounded,
                        size: 16.sp,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Directions',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Route line indicator
              Column(
                children: [
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.3),
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
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 2.5,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16.w),
              // Locations - Clickable
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Start location - clickable
                    InkWell(
                      onTap: () => _openDirections(),
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16.sp,
                              color: theme.colorScheme.primary,
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                widget.ride.startLocationText,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.directions_rounded,
                              size: 14.sp,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),
                    // End location - clickable
                    InkWell(
                      onTap: () => _openDirections(),
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16.sp,
                              color: theme.colorScheme.secondary,
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                widget.ride.endLocationText,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.directions_rounded,
                              size: 14.sp,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Open directions from start to end location
  Future<void> _openDirections() async {
    final startLat = widget.ride.startLocationLat!;
    final startLng = widget.ride.startLocationLng!;
    final endLat = widget.ride.endLocationLat!;
    final endLng = widget.ride.endLocationLng!;
    
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=$startLat,$startLng&destination=$endLat,$endLng&travelmode=driving'
    );
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        _showSnackBar('Could not open directions', isError: true);
      }
    }
  }

  Widget _buildDriverCard(ThemeData theme) {
    return Container(
      decoration: _getCardDecoration(theme),
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          // Driver avatar
          CircleAvatar(
            radius: 28.r,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              widget.ride.provider!.user.username.substring(0, 1).toUpperCase(),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          SizedBox(width: 16.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.ride.provider!.user.username,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.verified_rounded,
                      size: 16.sp,
                      color: Colors.green,
                    ),
                  ],
                ),

                SizedBox(height: 6.h),

                // Rating - Compact
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.amber, size: 16.sp),
                    SizedBox(width: 4.w),
                    _loadingReviews
                        ? SizedBox(
                            width: 30.w,
                            height: 16.h,
                            child: const Center(
                              child: SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          )
                        : Text(
                            _averageRating?.toStringAsFixed(1) ?? 'N/A',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                    SizedBox(width: 4.w),
                    if (!_loadingReviews && _totalReviews != null && _totalReviews! > 0)
                      Text(
                        '($_totalReviews)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    SizedBox(width: 16.w),
                    Icon(
                      Icons.local_taxi_rounded,
                      size: 16.sp,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${widget.ride.provider!.vehicleType}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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

  Widget _buildReviewsCard(ThemeData theme) {
    if (_loadingReviews) {
      return Container(
        decoration: _getCardDecoration(theme),
        padding: EdgeInsets.all(20.w),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_reviews.isEmpty) {
      return Container(
        decoration: _getCardDecoration(theme),
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 48.sp,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            SizedBox(height: 12.h),
            Text(
              'No reviews yet',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: _getCardDecoration(theme),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Reviews',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (_averageRating != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber.shade400, Colors.orange.shade400],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star_rounded, color: Colors.white, size: 16.sp),
                      SizedBox(width: 4.w),
                      Text(
                        _averageRating!.toStringAsFixed(1),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          
          // Reviews list
          ...List.generate(
            _reviews.length > 3 ? 3 : _reviews.length,
            (index) {
              final review = _reviews[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: _buildReviewItem(review, theme),
              );
            },
          ),
          
          if (_reviews.length > 3)
            Center(
              child: TextButton(
                onPressed: () {
                  _showAllReviewsDialog(context, theme);
                },
                child: Text('See all ${_reviews.length > 10 ? '10' : _reviews.length} reviews'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review, ThemeData theme) {
    final rating = review['rating'] is num
        ? (review['rating'] as num).toDouble()
        : double.tryParse(review['rating']?.toString() ?? '0') ?? 0.0;
    final comment = review['comment']?.toString() ?? '';
    final reviewerName = review['reviewer']["username"]?.toString() ?? 'Anonymous';
    final createdAt = review['createdAt']?.toString();
    
    String timeAgo = '';
    if (createdAt != null) {
      try {
        final date = DateTime.parse(createdAt);
        final now = DateTime.now();
        final difference = now.difference(date);
        
        if (difference.inDays > 30) {
          timeAgo = '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
        } else if (difference.inDays > 0) {
          timeAgo = '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
        } else if (difference.inHours > 0) {
          timeAgo = '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
        } else {
          timeAgo = 'Just now';
        }
      } catch (e) {
        timeAgo = '';
      }
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileAvatar(
                          imageURL: review['reviewer']["mediaUrls"][0] ?? '',
                          radius: 16.r,
                          userId: review['reviewer']["id"] ?? '',
                          userName: reviewerName,

                      ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reviewerName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (timeAgo.isNotEmpty)
                      Text(
                        timeAgo,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11.sp,
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.star_rounded, color: Colors.amber, size: 14.sp),
                  SizedBox(width: 2.w),
                  Text(
                    rating.toStringAsFixed(1),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              comment,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  void _showAllReviewsDialog(BuildContext context, ThemeData theme) {
    final reviewsToShow = _reviews.take(10).toList();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: 500.w,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'All Reviews',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_averageRating != null)
                              Text(
                                '${_averageRating!.toStringAsFixed(1)} average rating',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.surface.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Reviews list
                Flexible(
                  child: ListView.separated(
                    padding: EdgeInsets.all(20.w),
                    shrinkWrap: true,
                    itemCount: reviewsToShow.length,
                    separatorBuilder: (context, index) => SizedBox(height: 16.h),
                    itemBuilder: (context, index) {
                      return _buildReviewItem(reviewsToShow[index], theme);
                    },
                  ),
                ),
                
                // Footer note if there are more than 10 reviews
                if (_reviews.length > 10)
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Text(
                      'Showing 10 of ${_reviews.length} reviews',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVehicleCard(ThemeData theme) {
    return Container(
      decoration: _getCardDecoration(theme),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trip Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),

          // Trip info in a grid
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.event_seat_rounded,
                  'Seats',
                  '${widget.ride.seatsAvailable} available',
                  theme,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildInfoItem(
                  Icons.access_time_rounded,
                  'Departure',
                  DateFormat('h:mm a').format(widget.ride.departureTime),
                  theme,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.luggage_rounded,
                  'Luggage',
                  widget.ride.luggage != null ? '${widget.ride.luggage} bags' : 'Not specified',
                  theme,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildInfoItem(
                  Icons.smoke_free_rounded,
                  'Smoking',
                  'Not allowed',
                  theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
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

  Widget _buildPriceCard(ThemeData theme) {
    return Container(
      decoration: _getCardDecoration(theme, hasGradient: true),
      padding: EdgeInsets.all(20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Price per seat',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'PKR ${widget.ride.pricePerSeat.toStringAsFixed(0)}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 18.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  'Details',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
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

  Widget _buildActionButtons(ThemeData theme) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Show offer form when countering
          if (isCountering) ...[
            _buildOfferForm(theme),
            SizedBox(height: 16.h),
          ],
          
          // Action buttons
          Row(
            children: [
              // Message Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          currentUserId: UserModel().id,
                          otherUserId: widget.ride.providerId,
                          apiBaseUrl: "apiBaseUrl",
                          otherUserName: widget.ride.provider?.user.username ?? "N/A",
                          otherUserAvatar: "otherUserAvatar",
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.message_rounded, size: 18.sp),
                  label: Text('Message'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(
                      color: theme.colorScheme.primary.withOpacity(0.5),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // Make Offer / Send Offer Button
              Expanded(
                flex: 2,
                child: BlocBuilder<OfferBloc, OfferState>(
                  builder: (context, state) {
                    final isLoading = state is OfferLoading;
                    
                    return ElevatedButton.icon(
                      onPressed: isLoading ? null : (isCountering ? _sendOffer : _toggleCountering),
                      icon: isLoading 
                          ? SizedBox(
                              width: 18.sp,
                              height: 18.sp,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.onPrimary,
                              ),
                            )
                          : Icon(
                              isCountering ? Icons.send_rounded : Icons.local_offer_rounded,
                              size: 18.sp,
                            ),
                      label: Text(
                        isCountering ? 'Send Offer' : 'Make an Offer',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 4,
                        shadowColor: theme.colorScheme.primary.withOpacity(0.3),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfferForm(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.handshake_rounded,
                color: theme.colorScheme.primary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Your Offer',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: _toggleCountering,
                child: Text('Cancel'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          // Price and Seats Row
          Row(
            children: [
              // Price Input
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price per seat',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        prefixText: 'PKR ',
                        prefixStyle: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              
              // Seats Counter
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seats',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: _seatsRequested > 1
                                ? () => setState(() => _seatsRequested--)
                                : null,
                            icon: Icon(Icons.remove_rounded, size: 20.sp),
                            style: IconButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            '$_seatsRequested',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: _seatsRequested < widget.ride.seatsAvailable
                                ? () => setState(() => _seatsRequested++)
                                : null,
                            icon: Icon(Icons.add_rounded, size: 20.sp),
                            style: IconButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
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
          
          SizedBox(height: 12.h),
          
          // Optional Message
          TextField(
            controller: _messageController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Message (optional)',
              hintText: 'Add a message to the driver...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
          ),
          
          SizedBox(height: 12.h),
          
          // Total Preview
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total offer',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'PKR ${(double.tryParse(_priceController.text) ?? 0) * _seatsRequested}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
