import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../model/accommodation/accommodation_model.dart';
import '../../model/userManagment/user.dart';
import '../../Services/stripe_service.dart';
import '../../Services/ApiService.dart';
import '../../view/chat/chatDetailsPage.dart';
import '../../controller/chat/messages_bloc.dart';
import '../../model/chat/chatRepo.dart';
import '../../controller/userManagment/JWTController.dart';

class RoomBookingPage extends StatefulWidget {
  final Accommodation accommodation;
  final Room room;

  const RoomBookingPage({
    Key? key,
    required this.accommodation,
    required this.room,
  }) : super(key: key);

  @override
  _RoomBookingPageState createState() => _RoomBookingPageState();
}

class _RoomBookingPageState extends State<RoomBookingPage> {
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  bool _isProcessing = false;

  int get numberOfNights {
    if (_checkInDate == null || _checkOutDate == null) return 0;
    return _checkOutDate!.difference(_checkInDate!).inDays;
  }

  double get totalPrice {
    return widget.room.pricePerNight * numberOfNights;
  }

  Future<void> _selectCheckInDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _checkInDate = picked;
        if (_checkOutDate != null && _checkOutDate!.isBefore(_checkInDate!)) {
          _checkOutDate = null;
        }
      });
    }
  }

  Future<void> _selectCheckOutDate() async {
    if (_checkInDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select check-in date first')),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate!.add(Duration(days: 1)),
      firstDate: _checkInDate!.add(Duration(days: 1)),
      lastDate: _checkInDate!.add(Duration(days: 30)),
    );

    if (picked != null) {
      setState(() => _checkOutDate = picked);
    }
  }

  Future<void> _proceedToPayment() async {
    if (_checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select check-in and check-out dates')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Get user info
      final user = UserModel();
      if (user.id.isEmpty || user.email.isEmpty) {
        throw Exception('User not logged in');
      }

      // Process Stripe payment first (NO booking created yet)
      // Use a temporary ID for payment tracking
      final tempBookingId = 0; // Temporary ID, payment intent will be the actual reference
      
      final paymentResult = await StripeService.instance.makePayment(
        amount: totalPrice,
        currency: 'usd',
        bookingId: tempBookingId,
        customerEmail: user.email,
        user: user,
      );

      if (paymentResult['success'] == true) {
        // Payment successful, NOW create the booking with confirmed status
        final paymentIntentId = paymentResult['paymentIntentId'];
        final bookingId = await _createConfirmedBooking(paymentIntentId);

        if (mounted) {
          // Show success dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 30.sp),
                  SizedBox(width: 10.w),
                  Text('Booking Confirmed!'),
                ],
              ),
              content: Text(
                'Your payment was successful and your booking has been confirmed.\n\n'
                'Booking ID: $bookingId\n'
                'Total Paid: \$${totalPrice.toStringAsFixed(2)}',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Return to previous page
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      } else if (paymentResult['cancelled'] == true) {
        // Payment was cancelled by user - NO booking was created, so no duplicates!
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment cancelled - No booking was created'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        // Payment failed - NO booking was created
        final errorMessage = paymentResult['error'] ?? 'Payment failed';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// Create a confirmed booking directly after successful payment
  /// This ensures bookings only exist in the database after payment is complete
  Future<int> _createConfirmedBooking(String paymentIntentId) async {
    try {
      final user = UserModel();
      final apiService =
          APIServiceNodeJS('https://api.tourease.me/api', user.id);

      final response = await apiService.post<Map<String, dynamic>>(
        path: '/accommodation-bookings/create-confirmed',
        body: {
          'travelerId': user.id,
          'roomId': widget.room.id,
          'checkInDate': _checkInDate!.toIso8601String(),
          'checkOutDate': _checkOutDate!.toIso8601String(),
          'totalPrice': totalPrice,
          'paymentId': paymentIntentId,
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response['success'] == true) {
        print('✅ Confirmed booking created successfully: ${response['message']}');
        return response['data']['id'] as int;
      } else {
        throw Exception('Failed to create confirmed booking');
      }
    } catch (e) {
      print('❌ Error creating confirmed booking: $e');
      rethrow;
    }
  }

  Future<void> _makePhoneCall() async {
    // Use actual accommodation contact number
    final contactNumber = widget.accommodation.provider?.contactNumber ?? '';
    
    if (contactNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Contact number not available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Convert Pakistani local format (03XX) to international format (+923XX)
    String phoneNumber = contactNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // If it starts with 0, replace with +92 (Pakistan country code)
    if (phoneNumber.startsWith('0')) {
      phoneNumber = '+92' + phoneNumber.substring(1);
    }
    // If it doesn't have + prefix, add it
    else if (!phoneNumber.startsWith('+')) {
      phoneNumber = '+92$phoneNumber';
    }
    
    final Uri phoneUri = Uri.parse('tel:$phoneNumber');
    
    try {
      // Use external application mode to launch phone dialer
      final launched = await launchUrl(
        phoneUri,
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch phone dialer'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching dialer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    try {
      final currentUser = UserModel();
      final providerId = widget.accommodation.provider?.providerId;
      final providerName = widget.accommodation.provider?.accommodationName ?? 'Accommodation Provider';

      if (providerId == null || currentUser.id.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to start conversation')),
        );
        return;
      }

      // Get Firebase JWT token for authentication
      final jwtToken = await getFirebaseIdToken();
      if (jwtToken == null || jwtToken.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication required. Please log in again.')),
        );
        return;
      }

      // Get media URL safely
      String mediaUrl = '';
      if (widget.accommodation.provider?.mediaUrls != null && 
          widget.accommodation.provider!.mediaUrls.isNotEmpty) {
        mediaUrl = widget.accommodation.provider!.mediaUrls[0];
      }

      // Create ChatService with proper APIService instance
      // Use the deployed backend URL (not localhost)
      final deployedBackendUrl = "https://api.tourease.me";
      // APIService needs root URL only (ChatService adds /api in its methods)
      final apiService = APIServiceNodeJS(deployedBackendUrl, jwtToken);
      final chatService = ChatService(
        apiBaseUrl: deployedBackendUrl,  // Socket connection uses root URL
        currentUserId: currentUser.id,
        apiService: apiService,
      );

      // Navigate to ChatPage with MessagesBloc provider
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => MessagesBloc(
              chatService: chatService,
              currentUserId: currentUser.id,
            ),
            child: ChatPage(
              currentUserId: currentUser.id,
              otherUserId: providerId,
              apiBaseUrl: "$deployedBackendUrl/api",
              otherUserName: providerName,
              otherUserAvatar: mediaUrl,
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Room'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageGallery(),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAccommodationHeader(),
                  SizedBox(height: 16.h),
                  _buildRoomInfo(),
                  SizedBox(height: 16.h),
                  _buildDateSelection(),
                  SizedBox(height: 16.h),
                  _buildPriceSummary(),
                  SizedBox(height: 20.h),
                  _buildPaymentButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    final images = widget.room.mediaUrls.isNotEmpty
        ? widget.room.mediaUrls
        : (widget.accommodation.mediaUrls.isNotEmpty
            ? widget.accommodation.mediaUrls
            : []);

    if (images.isEmpty) {
      return Container(
        height: 200.h,
        color: Colors.grey[300],
        child: Center(
          child: Icon(Icons.hotel, size: 40.sp, color: Colors.grey[600]),
        ),
      );
    }

    return SizedBox(
      height: 200.h,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl: images[index],
            height: 200.h,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[300],
              child: Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[300],
              child: Icon(Icons.error, size: 30.sp),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccommodationHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.accommodation.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Icon(Icons.location_on, size: 16.sp, color: Colors.red),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                widget.accommodation.location,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _makePhoneCall,
                icon: Icon(Icons.phone, size: 16.sp),
                label: Text('Call', style: TextStyle(fontSize: 13.sp)),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _sendMessage,
                icon: Icon(Icons.message, size: 16.sp),
                label: Text('Message', style: TextStyle(fontSize: 13.sp)),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoomInfo() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Room Details',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Divider(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.room.roomType,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(Icons.people,
                            size: 14.sp, color: Colors.grey[600]),
                        SizedBox(width: 4.w),
                        Text('${widget.room.capacity} guests',
                            style: TextStyle(fontSize: 12.sp)),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${widget.room.pricePerNight.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'per night',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Dates',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    label: 'Check-in',
                    date: _checkInDate,
                    onTap: _selectCheckInDate,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _buildDateField(
                    label: 'Check-out',
                    date: _checkOutDate,
                    onTap: _selectCheckOutDate,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontSize: 11.sp),
            ),
            SizedBox(height: 3.h),
            Text(
              date != null ? DateFormat('MMM dd').format(date) : 'Select',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight:
                        date != null ? FontWeight.w500 : FontWeight.normal,
                    fontSize: 12.sp,
                    color: Colors.black, // Changed to black for better visibility
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Price per night', style: TextStyle(fontSize: 12.sp)),
                Text('\$${widget.room.pricePerNight.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 12.sp)),
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Number of nights', style: TextStyle(fontSize: 12.sp)),
                Text('$numberOfNights', style: TextStyle(fontSize: 12.sp)),
              ],
            ),
            Divider(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '\$${totalPrice.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _proceedToPayment,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        child: _isProcessing
            ? SizedBox(
                height: 16.h,
                width: 16.h,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                'Proceed to Payment',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
