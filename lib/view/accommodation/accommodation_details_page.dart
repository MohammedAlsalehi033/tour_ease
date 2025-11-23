import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../Services/ApiService.dart';
import '../../Services/accommodation/accommodation_service.dart';
import '../../model/accommodation/accommodation_model.dart';
import '../../model/userManagment/user.dart';
import '../../controller/userManagment/JWTController.dart' as jwt_controller;
import 'room_booking_page.dart';

class AccommodationDetailsPage extends StatefulWidget {
  final int accommodationId;

  const AccommodationDetailsPage({
    Key? key,
    required this.accommodationId,
  }) : super(key: key);

  @override
  _AccommodationDetailsPageState createState() =>
      _AccommodationDetailsPageState();
}

class _AccommodationDetailsPageState extends State<AccommodationDetailsPage> {
  late AccommodationService _accommodationService;
  Accommodation? _accommodation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  void _initializeService() async {
    final user = UserModel();
    // ACCOMMODATION FEATURE: Using localhost for development
    // Using deployed backend
    _accommodationService = AccommodationService(
      APIServiceNodeJS('https://api.tourease.me/api', user.id),
    );
    await _loadAccommodationDetails();
  }

  Future<void> _loadAccommodationDetails() async {
    setState(() => _isLoading = true);
    try {
      final accommodation = await _accommodationService.getAccommodationById(
        widget.accommodationId,
      );
      setState(() {
        _accommodation = accommodation;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load accommodation details: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accommodation Details'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _accommodation == null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageCarousel(),
          _buildBasicInfo(),
          _buildDescription(),
          _buildReviewsButton(),
          // Amenities section removed - not in backend schema
          _buildRoomsList(),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    final images = _accommodation!.mediaUrls.isNotEmpty
        ? _accommodation!.mediaUrls
        : ['https://via.placeholder.com/800x400?text=No+Image'];

    return CarouselSlider(
      options: CarouselOptions(
        height: 300.h,
        viewportFraction: 1.0,
        enableInfiniteScroll: images.length > 1,
        autoPlay: images.length > 1,
        autoPlayInterval: Duration(seconds: 5),
      ),
      items: images.map((imageUrl) {
        return CachedNetworkImage(
          imageUrl: imageUrl,
          width: double.infinity,
          height: 300.h,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Icon(Icons.image_not_supported, size: 48.w),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBasicInfo() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and Rating
          Row(
            children: [
              Expanded(
                child: Text(
                  _accommodation!.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              if (_accommodation!.averageRating != null) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, size: 20.w, color: Colors.white),
                      SizedBox(width: 4.w),
                      Text(
                        _accommodation!.averageRating!.toStringAsFixed(1),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                      if (_accommodation!.reviewCount != null &&
                          _accommodation!.reviewCount! > 0) ...[
                        Text(
                          ' (${_accommodation!.reviewCount})',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 12.h),

          // Location
          Row(
            children: [
              Icon(Icons.location_on,
                  size: 20.w, color: Theme.of(context).colorScheme.primary),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  _accommodation!.location,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 8.h),
          Text(
            _accommodation!.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildReviewsButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: ElevatedButton.icon(
        onPressed: () {
          _showReviewsDialog();
        },
        icon: Icon(Icons.rate_review),
        label: Text('View Reviews'),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 48.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  Future<void> _showReviewsDialog() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccommodationReviewsDialog(
          accommodationId: widget.accommodationId,
          accommodationName: _accommodation!.name,
        ),
      ),
    );
  }

  // Amenities section removed - not available in backend Prisma schema

  Widget _buildRoomsList() {
    if (_accommodation!.rooms == null || _accommodation!.rooms!.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16.w),
        child: Center(
          child: Text(
            'No rooms available',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Rooms',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 12.h),
          ..._accommodation!.rooms!
              .map((room) => _buildRoomCard(room))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildRoomCard(Room room) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room Image
          if (room.mediaUrls.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: CachedNetworkImage(
                imageUrl: room.mediaUrls.first,
                height: 180.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  height: 180.h,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Icon(Icons.bed, size: 48.w),
                ),
              ),
            ),

          // Room Details
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        room.roomType,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Capacity and Price
                Row(
                  children: [
                    Icon(Icons.people, size: 18.w),
                    SizedBox(width: 4.w),
                    Text(
                      '${room.capacity} ${room.capacity == 1 ? "guest" : "guests"}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Spacer(),
                    Text(
                      'PKR ${room.pricePerNight.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '/night',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Book Now Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RoomBookingPage(
                            accommodation: _accommodation!,
                            room: room,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text('Book Now'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80.w,
            color: Colors.red,
          ),
          SizedBox(height: 16.h),
          Text(
            'Failed to load accommodation',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: _loadAccommodationDetails,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// Dialog to show accommodation reviews
class AccommodationReviewsDialog extends StatefulWidget {
  final int accommodationId;
  final String accommodationName;

  const AccommodationReviewsDialog({
    Key? key,
    required this.accommodationId,
    required this.accommodationName,
  }) : super(key: key);

  @override
  _AccommodationReviewsDialogState createState() =>
      _AccommodationReviewsDialogState();
}

class _AccommodationReviewsDialogState
    extends State<AccommodationReviewsDialog> {
  List<dynamic> _reviews = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Get Firebase JWT token for authentication
      final token = await jwt_controller.getFirebaseIdToken();
      final apiService = APIServiceNodeJS('https://api.tourease.me/api', token ?? '');

      print('[Reviews] Fetching reviews for accommodation ${widget.accommodationId}');

      // Get reviews for this accommodation (requires JWT authentication)
      final response = await apiService.get<dynamic>(
        path: '/reviews/item/ACCOMMODATION/${widget.accommodationId}',
        queryParams: {'page': '1', 'limit': '50'},
        fromJson: (json) => json,
      );

      print('[Reviews] Response received: $response');

      // Handle different response formats
      if (response is Map<String, dynamic>) {
        // Backend returns {reviews: [...], stats: {...}}
        if (response.containsKey('reviews')) {
          final reviewsList = response['reviews'];
          setState(() {
            _reviews = (reviewsList is List) ? reviewsList : [];
            _isLoading = false;
          });
          print('[Reviews] Loaded ${_reviews.length} reviews');
        } else if (response['success'] == true) {
          // Fallback for success/data format
          final data = response['data'];
          setState(() {
            _reviews = (data is List) ? data : [];
            _isLoading = false;
          });
          print('[Reviews] Loaded ${_reviews.length} reviews');
        } else {
          throw Exception(response['message'] ?? 'Failed to load reviews');
        }
      } else if (response is List) {
        // Direct list response
        setState(() {
          _reviews = response;
          _isLoading = false;
        });
        print('[Reviews] Loaded ${_reviews.length} reviews (direct list)');
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      print('[Reviews] Error loading reviews: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reviews',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.accommodationName,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14.sp,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64.w, color: Colors.red),
                      SizedBox(height: 16.h),
                      Text(
                        'Error loading reviews',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _error,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton.icon(
                        onPressed: _loadReviews,
                        icon: Icon(Icons.refresh),
                        label: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _reviews.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.rate_review_outlined,
                            size: 80.w,
                            color: Colors.grey[300],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No reviews yet',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Be the first to review this place!',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.all(16.w),
                      itemCount: _reviews.length,
                      separatorBuilder: (context, index) => Divider(height: 32.h),
                      itemBuilder: (context, index) {
                        final review = _reviews[index];
                        return _buildReviewCard(review);
                      },
                    ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final rating = review['rating'] ?? 0;
    final comment = review['comment'] ?? '';
    final reviewerName = review['reviewer']?['username'] ?? 'Anonymous';
    final createdAt = review['createdAt'] != null
        ? DateTime.parse(review['createdAt'])
        : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: CircleAvatar(
                  radius: 24.w,
                  backgroundColor: Colors.transparent,
                  child: Text(
                    reviewerName.isNotEmpty
                        ? reviewerName[0].toUpperCase()
                        : 'A',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reviewerName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: Colors.black87,
                      ),
                    ),
                    if (createdAt != null)
                      Text(
                        '${createdAt.day}/${createdAt.month}/${createdAt.year}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13.sp,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _getRatingColor(rating),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.white, size: 16.w),
                    SizedBox(width: 4.w),
                    Text(
                      rating.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                comment,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getRatingColor(int rating) {
    if (rating >= 4) return Colors.green;
    if (rating >= 3) return Colors.orange;
    return Colors.red;
  }
}
