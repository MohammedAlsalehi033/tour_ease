import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../model/userManagment/user.dart';
import '../../Services/ApiService.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({Key? key}) : super(key: key);

  @override
  _MyBookingsPageState createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  List<dynamic> _bookings = [];
  List<dynamic> _filteredBookings = [];
  bool _isLoading = true;
  String _error = '';
  String _selectedFilter = 'all'; // all, confirmed, complete, checked out, cancelled, refunded

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final user = UserModel();
      if (user.id.isEmpty) {
        throw Exception('User not logged in');
      }

      // Using deployed backend for fetching bookings
      final apiService = APIServiceNodeJS('https://api.tourease.me/api', user.id);

      // The API returns either a Map with success/data or a List directly
      dynamic response;
      try {
        response = await apiService.get<dynamic>(
          path: '/accommodation-bookings/traveler/${user.id}',
          fromJson: (json) => json,
        );
      } catch (e) {
        print('API Error: $e');
        throw Exception('Failed to connect to server');
      }

      List<dynamic> bookingsList = [];
      
      // Handle different response formats
      if (response is Map<String, dynamic>) {
        if (response['success'] == true && response['data'] != null) {
          bookingsList = response['data'] as List<dynamic>;
        } else if (response['bookings'] != null) {
          bookingsList = response['bookings'] as List<dynamic>;
        } else {
          throw Exception(response['message'] ?? 'Failed to load bookings');
        }
      } else if (response is List) {
        bookingsList = response;
      } else {
        throw Exception('Unexpected response format');
      }

      // Debug: Print first booking to see structure
      if (bookingsList.isNotEmpty) {
        print('Sample booking data: ${bookingsList[0]}');
        print('Room data: ${bookingsList[0]['room']}');
        if (bookingsList[0]['room'] != null) {
          print('Accommodation data: ${bookingsList[0]['room']['accommodation']}');
        }
      }

      setState(() {
        _bookings = bookingsList;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading bookings: $e');
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    if (_selectedFilter == 'all') {
      _filteredBookings = _bookings;
    } else {
      _filteredBookings = _bookings
          .where((booking) =>
              booking['status'].toString().toLowerCase() == _selectedFilter)
          .toList();
    }
  }

  Future<void> _cancelBooking(int bookingId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28.sp),
            SizedBox(width: 10.w),
            Text('Cancel Booking'),
          ],
        ),
        content: Text(
          'Are you sure you want to cancel this booking and request a refund?\n\n'
          'This action cannot be undone.',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('No, Keep Booking'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Yes, Cancel & Refund'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );

    try {
      final user = UserModel();
      // Using deployed backend
      final apiService = APIServiceNodeJS('https://api.tourease.me/api', user.id);

      final response = await apiService.delete<Map<String, dynamic>>(
        path: '/accommodation-bookings/$bookingId/cancel-and-refund',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      // Close loading dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking cancelled. Refund request submitted.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        await _loadBookings(); // Reload bookings
      } else {
        throw Exception('Failed to cancel booking');
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _showReviewDialog(Map<String, dynamic> booking) async {
    final reviewController = TextEditingController();
    double rating = 5.0;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Review Your Stay'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking['room']?['accommodation']?['name'] ??
                      booking['room']?['accommodation']?['accommodationName'] ??
                      'Accommodation',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                ),
                SizedBox(height: 16.h),
                Text('Rating:', style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 8.h),
                Row(
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32.sp,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          rating = (index + 1).toDouble();
                        });
                      },
                    );
                  }),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: reviewController,
                  decoration: InputDecoration(
                    labelText: 'Write your review',
                    hintText: 'Share your experience...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  maxLines: 4,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (reviewController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please write a review'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                
                // Close dialog first
                Navigator.pop(context);
                
                // Submit review
                await _submitReview(
                  booking['id'],
                  booking['room']?['accommodationId'],
                  rating,
                  reviewController.text,
                );
              },
              child: Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReview(
    int bookingId,
    int? accommodationId,
    double rating,
    String reviewText,
  ) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );

    try {
      final user = UserModel();
      // Using deployed backend
      final apiService = APIServiceNodeJS('https://api.tourease.me/api', user.id);

      final response = await apiService.post<Map<String, dynamic>>(
        path: '/accommodation-bookings/$bookingId/review',
        body: {
          'accommodationId': accommodationId,
          'rating': rating,
          'comment': reviewText, // Changed from 'review' to 'comment'
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      // Close loading dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Review submitted successfully! Booking marked as complete.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        await _loadBookings(); // Reload to show updated status
      } else {
        throw Exception(response['message'] ?? 'Failed to submit review');
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  void _showBookingDetails(Map<String, dynamic> booking) {
    final status = booking['status']?.toString() ?? 'Unknown';
    final checkInDate = booking['checkInDate'] != null
        ? DateTime.parse(booking['checkInDate'])
        : null;
    final checkOutDate = booking['checkOutDate'] != null
        ? DateTime.parse(booking['checkOutDate'])
        : null;
    
    double totalPrice = 0.0;
    try {
      if (booking['totalPrice'] is String) {
        totalPrice = double.tryParse(booking['totalPrice']) ?? 0.0;
      } else if (booking['totalPrice'] is num) {
        totalPrice = (booking['totalPrice'] as num).toDouble();
      }
    } catch (e) {
      totalPrice = 0.0;
    }
    
    final accommodationName =
        booking['room']?['accommodation']?['name'] ?? 
        booking['accommodation']?['name'] ?? 
        booking['room']?['accommodation']?['accommodationName'] ?? 
        booking['accommodation']?['accommodationName'] ?? 'Unknown Accommodation';
    final roomType = booking['room']?['roomType'] ?? 'Room';
    final roomCapacity = booking['room']?['capacity'] ?? 'N/A';
    final location =
        booking['room']?['accommodation']?['location'] ?? 
        booking['accommodation']?['location'] ?? 'Unknown location';
    final description = booking['room']?['accommodation']?['description'] ?? 
        'No description available';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Booking Details',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(status),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                accommodationName,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 4.w),
                  Expanded(child: Text(location)),
                ],
              ),
              SizedBox(height: 16.h),
              
              _buildDetailRow('Room Type', roomType),
              _buildDetailRow('Capacity', '$roomCapacity guests'),
              _buildDetailRow('Booking ID', '#${booking['id']}'),
              
              SizedBox(height: 16.h),
              Divider(),
              SizedBox(height: 16.h),
              
              _buildDetailRow('Check-in', checkInDate != null 
                  ? DateFormat('MMM dd, yyyy').format(checkInDate) 
                  : 'N/A'),
              _buildDetailRow('Check-out', checkOutDate != null 
                  ? DateFormat('MMM dd, yyyy').format(checkOutDate) 
                  : 'N/A'),
              
              SizedBox(height: 16.h),
              Divider(),
              SizedBox(height: 16.h),
              
              Text(
                'Description',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 8.h),
              Text(description),
              
              SizedBox(height: 16.h),
              Divider(),
              SizedBox(height: 16.h),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  Text(
                    'PKR ${totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
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
              fontSize: 13.sp,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'checked out':
        return Colors.orange;
      case 'complete':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'refunded':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookings'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadBookings,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  SizedBox(width: 8.w),
                  _buildFilterChip('Confirmed', 'confirmed'),
                  SizedBox(width: 8.w),
                  _buildFilterChip('Checked Out', 'checked out'),
                  SizedBox(width: 8.w),
                  _buildFilterChip('Complete', 'complete'),
                  SizedBox(width: 8.w),
                  _buildFilterChip('Cancelled', 'cancelled'),
                  SizedBox(width: 8.w),
                  _buildFilterChip('Refunded', 'refunded'),
                ],
              ),
            ),
          ),
          Divider(height: 1),

          // Bookings List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 60.sp, color: Colors.red),
                            SizedBox(height: 16.h),
                            Text('Error: $_error'),
                            SizedBox(height: 16.h),
                            ElevatedButton(
                              onPressed: _loadBookings,
                              child: Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredBookings.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.hotel_outlined,
                                    size: 60.sp, color: Colors.grey),
                                SizedBox(height: 16.h),
                                Text(
                                  'No bookings found',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  _selectedFilter == 'all'
                                      ? 'You haven\'t made any bookings yet'
                                      : 'No $_selectedFilter bookings',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadBookings,
                            child: ListView.builder(
                              padding: EdgeInsets.all(16.w),
                              itemCount: _filteredBookings.length,
                              itemBuilder: (context, index) {
                                return _buildBookingCard(
                                    _filteredBookings[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
          _applyFilter();
        });
      },
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).textTheme.bodyMedium?.color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final status = booking['status']?.toString().toLowerCase() ?? 'unknown';
    final checkInDate = booking['checkInDate'] != null
        ? DateTime.parse(booking['checkInDate'])
        : null;
    final checkOutDate = booking['checkOutDate'] != null
        ? DateTime.parse(booking['checkOutDate'])
        : null;
    
    // Handle totalPrice as either String or number
    double totalPrice = 0.0;
    try {
      if (booking['totalPrice'] is String) {
        totalPrice = double.tryParse(booking['totalPrice']) ?? 0.0;
      } else if (booking['totalPrice'] is num) {
        totalPrice = (booking['totalPrice'] as num).toDouble();
      }
    } catch (e) {
      print('Error parsing totalPrice: $e');
      totalPrice = 0.0;
    }
    
    final accommodationName =
        booking['room']?['accommodation']?['name'] ?? 
        booking['accommodation']?['name'] ?? 
        booking['room']?['accommodation']?['accommodationName'] ?? 
        booking['accommodation']?['accommodationName'] ?? 'Unknown Accommodation';
    final roomType = booking['room']?['roomType'] ?? 'Room';
    final location =
        booking['room']?['accommodation']?['location'] ?? 
        booking['accommodation']?['location'] ?? 'Unknown location';

    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case 'confirmed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'checked out':
        statusColor = Colors.orange;
        statusIcon = Icons.logout;
        break;
      case 'complete':
        statusColor = Colors.blue;
        statusIcon = Icons.done_all;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'refunded':
        statusColor = Colors.purple;
        statusIcon = Icons.payment;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () => _showBookingDetails(booking),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    accommodationName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16.sp, color: statusColor),
                      SizedBox(width: 4.w),
                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Room type and location
            Row(
              children: [
                Icon(Icons.hotel, size: 16.sp, color: Colors.grey[600]),
                SizedBox(width: 6.w),
                Text(
                  roomType,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Icon(Icons.location_on, size: 16.sp, color: Colors.grey[600]),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    location,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Dates
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Check-in',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          checkInDate != null
                              ? DateFormat('MMM dd, yyyy').format(checkInDate)
                              : 'N/A',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward, color: Colors.grey[400]),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Check-out',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          checkOutDate != null
                              ? DateFormat('MMM dd, yyyy').format(checkOutDate)
                              : 'N/A',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            // Price and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'PKR ${totalPrice.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),

                // Action buttons based on status
                if (status == 'confirmed')
                  ElevatedButton.icon(
                    onPressed: () => _cancelBooking(booking['id']),
                    icon: Icon(Icons.cancel_outlined, size: 18.sp),
                    label: Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                    ),
                  )
                else if (status == 'checked out')
                  ElevatedButton.icon(
                    onPressed: () => _showReviewDialog(booking),
                    icon: Icon(Icons.rate_review, size: 18.sp),
                    label: Text('Review'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16.sp,
                    color: Colors.grey[400],
                  ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}
