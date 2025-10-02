import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tour_ease/controller/rideSharing/offers/offers_bloc.dart';
import 'package:tour_ease/controller/rideSharing/offers/offers_event.dart';
import 'package:tour_ease/controller/rideSharing/offers/offers_state.dart';
import 'package:tour_ease/model/rideSharing/rideListing/rideListingModel.dart';
import 'package:intl/intl.dart';
import 'package:tour_ease/model/userManagment/user.dart';
import 'dart:ui';

import 'package:tour_ease/view/chat/chatDetailsPage.dart';
import 'package:tour_ease/components/clickable_location_widget.dart';
import 'package:tour_ease/components/simple_cancel_button.dart';

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
  bool isFavorite = false;

  late AnimationController _slideController;
  late AnimationController _counterOfferController;
  late AnimationController _favoriteController;
  late AnimationController _expandController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _counterOfferAnimation;
  late Animation<double> _favoriteAnimation;
  late Animation<double> _expandAnimation;
  late Animation<double> _fadeAnimation;

  int _seatsRequested = 1;
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    counterOffer = widget.ride.pricePerSeat;
    _priceController.text = widget.ride.pricePerSeat.toStringAsFixed(0);

    _initializeAnimations();

    // Start entrance animation
    _slideController.forward();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _counterOfferController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _favoriteController = AnimationController(
      duration: const Duration(milliseconds: 300),
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

    _counterOfferAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _counterOfferController,
      curve: Curves.easeInOutBack,
    ));

    _favoriteAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _favoriteController,
      curve: Curves.elasticOut,
    ));

    _expandAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _counterOfferController.dispose();
    _favoriteController.dispose();
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
      _counterOfferController.forward();
      // Auto scroll to show counter offer section
      Future.delayed(const Duration(milliseconds: 200), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } else {
      _counterOfferController.reverse();
    }
  }

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
    _favoriteController.forward().then((_) {
      _favoriteController.reverse();
    });
  }

  void _sendOffer() {
    final parsedPrice = double.tryParse(_priceController.text.trim());
    final seats = _seatsRequested.clamp(1, widget.ride.seatsAvailable);
    if (parsedPrice == null || parsedPrice <= 0) {
      _showSnackBar('Please enter a valid price', isError: true);
      return;
    }

    context.read<OfferBloc>().add(
      CreateOfferEvent(
        transportationListingId: widget.ride.id,
        message: _messageController.text.trim(),
        senderId: UserModel().id,
        recipientId: widget.ride.providerId,
        pricePerSeat: parsedPrice,
        seatsRequested: seats,
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
              setState(() {
                isCountering = false;
              });
              _counterOfferController.reverse();
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
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.1),
                        theme.colorScheme.secondary.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 18.sp,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '35 min',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

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
            _buildVehicleCard(theme),
            SizedBox(height: 20.h),
            _buildPriceCard(theme),
            SizedBox(height: 20.h),
            _buildCounterOfferSection(theme),
            SizedBox(height: 20.h), // Extra space for FAB
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
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Route',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              // Route indicators
              Column(
                children: [
                  Container(
                    width: 16.w,
                    height: 16.h,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 2.w,
                    height: 40.h,
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(1.r),
                    ),
                  ),
                  Container(
                    width: 16.w,
                    height: 16.h,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.secondary,
                        width: 3,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(width: 20.w),

              // Route display
              Expanded(
                child: RouteDisplay(
                  startLocation: widget.ride.startLocationText,
                  endLocation: widget.ride.endLocationText,
                  enableDirections: true,
                  padding: EdgeInsets.zero,
                  routeTitle: "Trip Route",
                  showDirectionsButton: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(ThemeData theme) {
    return Container(
      decoration: _getCardDecoration(theme),
      padding: EdgeInsets.all(24.w),
      child: Row(
        children: [
          // Driver avatar with glow effect
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 32.r,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                widget.ride.provider!.user.username.substring(0, 1).toUpperCase(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SizedBox(width: 20.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.ride.provider!.user.username,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ScaleTransition(
                      scale: _favoriteAnimation,
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: isFavorite ? Colors.red : theme.colorScheme.onSurfaceVariant,
                          size: 24.sp,
                        ),
                        onPressed: _toggleFavorite,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8.h),

                // Rating
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      return Icon(
                        index < 4 ? Icons.star_rounded : Icons.star_border_rounded,
                        color: Colors.amber,
                        size: 18.sp,
                      );
                    }),
                    SizedBox(width: 8.w),
                    Text(
                      '4.2',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '(124 reviews)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // Verified badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.withOpacity(0.1),
                        Colors.green.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 16.sp,
                        color: Colors.green,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Verified Driver',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.green.shade700,
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

  Widget _buildVehicleCard(ThemeData theme) {
    return Container(
      decoration: _getCardDecoration(theme),
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Icon(
                      Icons.directions_car_rounded,
                      color: theme.colorScheme.primary,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.ride.provider!.vehicleType,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Comfort class',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'AC',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Vehicle features
          Row(
            children: [
              Expanded(
                child: _buildFeatureItem(
                  Icons.event_seat_rounded,
                  '${widget.ride.seatsAvailable}',
                  'Seats available',
                  theme,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildFeatureItem(
                  Icons.luggage_rounded,
                  '2',
                  'Bags allowed',
                  theme,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildFeatureItem(
                  Icons.smoke_free_rounded,
                  'No',
                  'Smoking',
                  theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String value, String label, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 20.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(ThemeData theme) {
    return Container(
      decoration: _getCardDecoration(theme, hasGradient: true),
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Price Breakdown',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.info_outline_rounded,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20.sp,
              ),
            ],
          ),

          SizedBox(height: 20.h),

          _buildPriceRow('Base fare', widget.ride.pricePerSeat * 0.85, theme),
          SizedBox(height: 12.h),
          _buildPriceRow('Service fee', widget.ride.pricePerSeat * 0.15, theme),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Divider(
              color: theme.colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total per seat',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'PKR ${widget.ride.pricePerSeat.toStringAsFixed(0)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          'PKR ${amount.toStringAsFixed(0)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCounterOfferSection(ThemeData theme) {
    return SizeTransition(
      sizeFactor: _counterOfferAnimation,
      axisAlignment: -1.0,
      child: ClipRRect(
        child: Container(
          decoration: _getCardDecoration(theme, accentBorder: true),
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.handshake_rounded,
                    color: theme.colorScheme.primary,
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Make Your Offer',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Price per seat',
                        prefixText: 'PKR ',
                        prefixStyle: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: _seatsRequested > 1
                              ? () => setState(() => _seatsRequested--)
                              : null,
                          icon: Icon(Icons.remove_rounded, size: 20.sp),
                          style: IconButton.styleFrom(minimumSize: Size(32.w, 32.h)),
                        ),
                        Text(
                          '$_seatsRequested',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: _seatsRequested < widget.ride.seatsAvailable
                              ? () => setState(() => _seatsRequested++)
                              : null,
                          icon: Icon(Icons.add_rounded, size: 20.sp),
                          style: IconButton.styleFrom(minimumSize: Size(32.w, 32.h)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _messageController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Optional message to driver',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    // Check if this is an active/confirmed booking that can be cancelled
    final bool canCancel = _isActiveBooking();
    
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
      child: canCancel ? _buildActiveRideActions(theme) : _buildBookingActions(theme),
    );
  }

  Widget _buildBookingActions(ThemeData theme) {
    return Row(
      children: [
        // Secondary Button: Message or Cancel Counter
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              if (isCountering) {
                _toggleCountering(); // Cancel counter offer
              } else {
                // Navigate to chat
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      currentUserId: UserModel().id,
                      otherUserId: widget.ride.providerId,
                      apiBaseUrl: "apiBaseUrl", // Placeholder
                      otherUserName: widget.ride.provider?.user.username ?? "N/A",
                      otherUserAvatar: "otherUserAvatar", // Placeholder
                    ),
                  ),
                );
              }
            },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              foregroundColor: isCountering ? theme.colorScheme.error : theme.colorScheme.primary,
              side: BorderSide(
                color: isCountering ? theme.colorScheme.error.withOpacity(0.5) : theme.colorScheme.primary.withOpacity(0.5),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: Text(isCountering ? 'Cancel' : 'Message'),
          ),
        ),
        SizedBox(width: 16.w),
        // Primary Button: Make Offer or Send Offer
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: isCountering ? _sendOffer : _toggleCountering,
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
            child: Text(
              isCountering ? 'Send Offer' : 'Make an Offer',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveRideActions(ThemeData theme) {
    return Column(
      children: [
        // Regular actions (Message, Complete, etc.)
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
                        apiBaseUrl: "apiBaseUrl", // Placeholder
                        otherUserName: widget.ride.provider?.user.username ?? "N/A",
                        otherUserAvatar: "otherUserAvatar", // Placeholder
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.message, size: 18.sp),
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
            // Complete/Track Button (example)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Handle ride completion or tracking
                  // You can implement ride completion logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ride completion feature coming soon!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: Icon(Icons.check_circle, size: 18.sp),
                label: Text('Complete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        // Cancel Button
        SimpleCancelButton(
          bookingId: widget.ride.id.toString(),
          onCancelled: () {
            Navigator.of(context).pop(); // Close the sheet
          },
        ),
      ],
    );
  }

  bool _isActiveBooking() {
    // Check if this is an active ride that can be cancelled
    // You'll need to adjust these status values based on your actual status values
    final activeStatuses = ['confirmed', 'active', 'in_progress', 'booked'];
    return activeStatuses.contains(widget.ride.status.toLowerCase());
  }
}
