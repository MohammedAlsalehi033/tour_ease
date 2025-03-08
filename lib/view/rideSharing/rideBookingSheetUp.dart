import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tour_ease/view/chat/chatDetailsPage.dart';
import '../../model/rideSharing/rideModel.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

class RideDetailsSheet extends StatefulWidget {
  final Ride ride;
  const RideDetailsSheet({super.key, required this.ride});

  @override
  State<RideDetailsSheet> createState() => _RideDetailsSheetState();
}

class _RideDetailsSheetState extends State<RideDetailsSheet> with SingleTickerProviderStateMixin {
  double counterOffer = 0;
  bool isCountering = false;
  bool isFavorite = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    counterOffer = widget.ride.price;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleCountering() {
    setState(() {
      isCountering = !isCountering;
      if (isCountering) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    final accentColor = HSLColor.fromColor(primaryColor).withLightness(
        isDark ? 0.6 : 0.4
    ).toColor();

    final cardGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
        theme.colorScheme.surface,
        theme.colorScheme.surface.withOpacity(0.8),
      ]
          : [
        Colors.white,
        Colors.white.withOpacity(0.9),
      ],
    );

    final cardDecoration = BoxDecoration(
      gradient: cardGradient,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withOpacity(0.2)
              : Colors.grey.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ],
      border: Border.all(
        color: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.black.withOpacity(0.05),
        width: 1,
      ),
    );

    return Scaffold(appBar: AppBar(),
      body: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // Header section with trip overview
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trip Overview',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('EEEE, MMM d · h:mm a').format(widget.ride.departureTime),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
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
                ],
              ),
            ),
      
            // Flexible content with scrolling
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Route Card
                    Container(
                      height: 140,
                      decoration: cardDecoration,
                      padding: const EdgeInsets.all(20),
                      child: Stack(
                        children: [
                          // Route Line
                          Positioned.fill(
                            child: CustomPaint(
                              painter: ModernRoutePainter(accentColor),
                            ),
                          ),
      
                          // Origin
                          Positioned(
                            left: 0,
                            top: 20,
                            child: Row(
                              children: [
                                Container(
                                  height: 16,
                                  width: 16,
                                  decoration: BoxDecoration(
                                    color: accentColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: theme.scaffoldBackgroundColor,
                                      width: 3,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.4),
                                  child: Text(
                                    widget.ride.pickupLocation,
                                    style: theme.textTheme.titleSmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
      
                          // Destination
                          Positioned(
                            right: 0,
                            bottom: 20,
                            child: Row(
                              children: [
                                Container(
                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.4),
                                  child: Text(
                                    widget.ride.destination,
                                    style: theme.textTheme.titleSmall,
                                    textAlign: TextAlign.right,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  height: 16,
                                  width: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: accentColor,
                                      width: 3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
      
                    // Driver Card
                    Container(
                      decoration: cardDecoration,
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 32,
                              backgroundImage: NetworkImage(widget.ride.imageUrl),
                              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      widget.ride.driverName,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isFavorite ? Icons.favorite : Icons.favorite_border,
                                        color: isFavorite ? Colors.red : theme.colorScheme.onBackground.withOpacity(0.5),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isFavorite = !isFavorite;
                                        });
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Row(
                                      children: List.generate(5, (index) {
                                        return Icon(
                                          index < widget.ride.rating.floor()
                                              ? Icons.star
                                              : (index < widget.ride.rating
                                              ? Icons.star_half
                                              : Icons.star_border),
                                          color: Colors.amber,
                                          size: 16,
                                        );
                                      }),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.ride.rating.toString(),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: accentColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.verified,
                                        size: 14,
                                        color: accentColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Verified Driver',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: accentColor,
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
                    ),
                    const SizedBox(height: 20),
      
                    // Vehicle and details card
                    Container(
                      decoration: cardDecoration,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.directions_car,
                                    color: accentColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.ride.vehicleType,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'Comfort',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
      
                          // Vehicle details grid
                          Row(
                            children: [
                              Expanded(
                                child: _buildDetailItem(
                                    context,
                                    Icons.event_seat_outlined,
                                    '${widget.ride.availableSeats} seats',
                                    'Available',
                                    accentColor
                                ),
                              ),
                              SizedBox(width: 20.w,),
                              Expanded(
                                child: _buildDetailItem(
                                    context,
                                    Icons.luggage_outlined,
                                    '${widget.ride.luggageCapacity} kg',
                                    'Luggage',
                                    accentColor
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
      
                    // Price details card
                    Container(
                      decoration: cardDecoration,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Price Details',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Base fare',
                                style: theme.textTheme.bodyMedium,
                              ),
                              Text(
                                '\$${(widget.ride.price * 0.85).toStringAsFixed(2)}',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Mohammed fee',
                                style: theme.textTheme.bodyMedium,
                              ),
                              Text(
                                '\$${(widget.ride.price * 0.15).toStringAsFixed(2)}',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Divider(
                              color: theme.dividerColor.withOpacity(0.3),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${widget.ride.price.toStringAsFixed(2)}',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: accentColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
      
                    // Counter offer section (animated)
                    SizeTransition(
                      sizeFactor: _animation,
                      axis: Axis.vertical,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: cardDecoration.copyWith(
                          border: Border.all(
                            color: accentColor.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
      
                            const SizedBox(height: 20),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      
            // Action buttons
            Container(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Counter offer button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _toggleCountering,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: isCountering ? theme.colorScheme.error.withOpacity(0.1) : accentColor.withOpacity(0.1),
                        foregroundColor: isCountering ? theme.colorScheme.error : accentColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isCountering ? theme.colorScheme.error.withOpacity(0.5) : accentColor.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isCountering ? Icons.close : Icons.handshake_outlined,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isCountering ? 'Cancel' : 'Make Offer',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
      
                  // Primary action button (Chat or Send Offer)
                  Expanded(
                    flex: 3,
                    child: ElevatedButton(
                      onPressed: () {
                        if (isCountering) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Offer of \$${counterOffer.toStringAsFixed(2)} sent'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: accentColor,
                            ),
                          );
                          setState(() {
                            isCountering = false;
                            _animationController.reverse();
                          });
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(userName: widget.ride.driverName, avatarUrl: widget.ride.imageUrl,),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isCountering ? Icons.send : Icons.chat_bubble_outline,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isCountering ? 'Send Offer' : 'Chat with Driver',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
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
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, IconData icon, String value, String label, Color accentColor) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: accentColor,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// Modern route painter
class ModernRoutePainter extends CustomPainter {
  final Color routeColor;

  ModernRoutePainter(this.routeColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = routeColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dashPaint = Paint()
      ..color = routeColor.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw dashed curved path
    final path = Path();
    path.moveTo(8, size.height / 2);
    path.cubicTo(
        size.width * 0.2,
        size.height * 0.2,
        size.width * 0.6,
        size.height * 0.8,
        size.width - 8,
        size.height / 2
    );

    // Draw dashed line
    const dashWidth = 6;
    const dashSpace = 4;

    final pathMetrics = path.computeMetrics().first;
    final dashPath = Path();

    var distance = 0.0;
    final length = pathMetrics.length;

    while (distance < length) {
      final extractPath = pathMetrics.extractPath(
        distance,
        distance + dashWidth,
      );
      dashPath.addPath(extractPath, Offset.zero);
      distance += dashWidth + dashSpace;
    }

    canvas.drawPath(dashPath, dashPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

