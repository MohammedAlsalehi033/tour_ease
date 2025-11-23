import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../Services/ApiService.dart';
import '../../Services/accommodation/accommodation_service.dart';
import '../../model/accommodation/accommodation_model.dart';
import '../../model/userManagment/user.dart';
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
    final reviewCount = _accommodation!.reviewCount ?? 0;
    final averageRating = _accommodation!.averageRating ?? 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: ElevatedButton.icon(
        onPressed: () {
          _showReviewsDialog();
        },
        icon: Icon(Icons.rate_review),
        label: Text(
          reviewCount > 0
              ? 'View $reviewCount Review${reviewCount > 1 ? 's' : ''} (${averageRating.toStringAsFixed(1)} ⭐)'
              : 'No Reviews Yet',
        ),
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
    showDialog(
      context: context,
      builder: (context) => AccommodationReviewsDialog(
        accommodationId: widget.accommodationId,
        accommodationName: _accommodation!.name,
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
      final user = UserModel();
      final apiService =
          APIServiceNodeJS('https://api.tourease.me/api', user.id);

      // Get reviews for this accommodation
      final response = await apiService.get<Map<String, dynamic>>(
        path:
            '/reviews/item/ACCOMMODATION/${widget.accommodationId}?page=1&limit=50',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response['success'] == true) {
        setState(() {
          _reviews = response['data'] ?? [];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load reviews');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        padding: EdgeInsets.all(16.w),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.rate_review, size: 24.w),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Reviews',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            Text(
              widget.accommodationName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            SizedBox(height: 16.h),
            Divider(),

            // Reviews List
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _error.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 48.w, color: Colors.red),
                              SizedBox(height: 8.h),
                              Text('Error loading reviews'),
                              SizedBox(height: 8.h),
                              TextButton(
                                onPressed: _loadReviews,
                                child: Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _reviews.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.reviews_outlined,
                                      size: 48.w, color: Colors.grey),
                                  SizedBox(height: 8.h),
                                  Text('No reviews yet'),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Be the first to review!',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemCount: _reviews.length,
                              separatorBuilder: (context, index) => Divider(),
                              itemBuilder: (context, index) {
                                final review = _reviews[index];
                                return _buildReviewCard(review);
                              },
                            ),
            ),
          ],
        ),
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

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                child: Text(
                  reviewerName[0].toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.bold),
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
                      ),
                    ),
                    if (createdAt != null)
                      Text(
                        '${createdAt.day}/${createdAt.month}/${createdAt.year}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12.sp,
                        ),
                      ),
                  ],
                ),
              ),
              // Rating stars
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, size: 16.w, color: Colors.white),
                    SizedBox(width: 4.w),
                    Text(
                      rating.toString(),
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
          SizedBox(height: 8.h),
          Text(
            comment,
            style: TextStyle(fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}
