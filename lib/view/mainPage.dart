import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Your Project's Imports (ensure these paths are correct for your project structure)
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:math' as math;
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:tour_ease/components/cards/accommodationCardForHomePage.dart';
import 'package:tour_ease/components/themeSwitch.dart';
import 'package:tour_ease/controller/userManagment/initialize.dart';
import 'package:tour_ease/controller/userManagment/authenticationManager.dart';
import 'package:tour_ease/controller/userManagment/userHelper.dart';
import 'package:tour_ease/model/userManagment/user.dart';
import 'package:tour_ease/Services/accommodation/accommodation_service.dart';
import 'package:tour_ease/Services/ApiService.dart';
import 'package:tour_ease/view/accommodation/accommodation_details_page.dart';
import 'package:tour_ease/view/accommodation/room_booking_page.dart';
import 'package:tour_ease/view/accommodation/my_bookings_page.dart';
import 'package:tour_ease/model/accommodation/accommodation_model.dart';
import 'package:tour_ease/view/NotifiactionScreen.dart';
import 'package:tour_ease/view/chat/chatsPage.dart';
import 'package:tour_ease/view/profile/profile.dart';
import 'package:tour_ease/view/questions/questionsPage.dart';
import 'package:tour_ease/view/rideSharing/RidebookingScreen.dart';
import 'package:tour_ease/view/tripPlanner/tripPlannerPage.dart';
import 'package:tour_ease/view/tripPlanner/current_plans_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  double iconsSizeBottomBar = 20;

  late StreamSubscription<InternetConnectionStatus> _connectionSubscription;
  bool _isConnected = true;

  late Future<void> _initUserFuture;

  final List<Widget> _pages = [
    AccommodationPage(),
    RidebookingscreenTraveler(),
    // keep the Trip Planner index reserved for Current Plans
    CurrentPlansPage(),
    MessagesPage(),
    QuestionsScreen(
      userID: UserHelper.getCurrentUserId() ?? '',
    ),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();

    // Verify user authentication state on init
    _initUserFuture = _initializeUserSafely();

    _connectionSubscription = InternetConnectionChecker().onStatusChange.listen(
      (InternetConnectionStatus status) {
        final hasConnection = (status == InternetConnectionStatus.connected);
        if (_isConnected != hasConnection) {
          setState(() {
            _isConnected = hasConnection;
          });
        }
      },
    );
  }

  Future<void> _initializeUserSafely() async {
    try {
      // Check if user authentication is consistent
      if (!UserHelper.isUserIdConsistent()) {
        print('User ID inconsistency detected, syncing...');
        UserHelper.syncUserModel();
      }

      // Only initialize if user is properly authenticated
      if (UserHelper.isUserAuthenticated()) {
        await UserInitializer().initializeUser();

        // Double-check consistency after initialization
        if (!UserHelper.isUserIdConsistent()) {
          print(
              'User ID still inconsistent after initialization, forcing sync...');
          UserHelper.syncUserModel();
        }
      } else {
        throw Exception('User not properly authenticated');
      }
    } catch (e) {
      print('Error during user initialization: $e');
      // Try to sync user model as a fallback
      UserHelper.syncUserModel();
      rethrow;
    }
  }

  void _retryInitialization() {
    setState(() {
      _initUserFuture = _initializeUserSafely();
    });
  }

  @override
  void dispose() {
    _connectionSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(360, 800));
    return FutureBuilder(
      future: _initUserFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorScreen(snapshot.error);
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }

        return _buildMainScaffold();
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 20.h),
            Text('Preparing your experience...',
                style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(Object? error) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 70.sp),
              SizedBox(height: 20.h),
              Text('Initialization Failed',
                  style: Theme.of(context).textTheme.headlineSmall),
              SizedBox(height: 10.h),
              Text(
                'We couldn\'t load your data. Please check your connection and try again.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 30.h),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: _retryInitialization,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for the main app UI, shown on successful initialization
  Widget _buildMainScaffold() {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(
          'Hello ${UserModel().username.isNotEmpty ? UserModel().username : "User"}',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        actions: [
          Themeswitch(),
          IconButton(
            icon: Icon(Icons.notifications,
                color: Theme.of(context).iconTheme.color),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NotifiactionScreen()));
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _pages[_selectedIndex],
          if (!_isConnected) _buildOfflineScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.transparent,
        child: CurvedNavigationBar(
          index: _selectedIndex,
          // CurvedNavigationBar enforces height <= 75.0; clamp scaled height to that limit
          height: math.min(70.h, 75.0),
          items: [
            Icon(Icons.home,
                size: iconsSizeBottomBar,
                color: Theme.of(context).colorScheme.onPrimary),
            Icon(Icons.directions_car,
                size: iconsSizeBottomBar,
                color: Theme.of(context).colorScheme.onPrimary),
            Icon(Icons.card_travel,
                size: iconsSizeBottomBar,
                color: Theme.of(context).colorScheme.onPrimary),
            Icon(Icons.message,
                size: iconsSizeBottomBar,
                color: Theme.of(context).colorScheme.onPrimary),
            Icon(Icons.question_answer,
                size: iconsSizeBottomBar,
                color: Theme.of(context).colorScheme.onPrimary),
            Icon(Icons.person,
                size: iconsSizeBottomBar,
                color: Theme.of(context).colorScheme.onPrimary),
          ],
          color: Theme.of(context).colorScheme.primary,
          buttonBackgroundColor: Theme.of(context).colorScheme.secondary,
          backgroundColor: Colors.transparent,
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 300),
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }

  // Widget for the "No Internet" full-screen overlay
  Widget _buildOfflineScreen() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_rounded,
                  size: 80.sp, color: Theme.of(context).colorScheme.secondary),
              SizedBox(height: 20.h),
              Text(
                'No Internet Connection',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.h),
              Text(
                'Please check your internet connection and try again.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// New AccommodationPage with real data from backend
class AccommodationPage extends StatefulWidget {
  const AccommodationPage({super.key});

  @override
  State<AccommodationPage> createState() => _AccommodationPageState();
}

class _AccommodationPageState extends State<AccommodationPage> {
  List<dynamic> _accommodations = [];
  List<dynamic> _allRooms = [];
  bool _isLoading = true;
  String _error = '';

  // Filter controllers
  final TextEditingController _locationController = TextEditingController();
  double _minPrice = 0;
  double _maxPrice = 10000;
  double? _minRating;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final user = UserModel();
      // ACCOMMODATION FEATURE: Using deployed backend
      final apiService =
          APIServiceNodeJS('https://api.tourease.me/api', user.id);
      final accommodationService = AccommodationService(apiService);

      final accommodations = await accommodationService.getAllAccommodations(
        page: 1,
        pageSize: 50, // Get more accommodations to have enough rooms
        location: _locationController.text.isNotEmpty
            ? _locationController.text
            : null,
        // Don't filter by price at API level, we'll filter rooms instead
      );

      // Extract all rooms from all accommodations
      List<Map<String, dynamic>> allRooms = [];
      for (var accommodation in accommodations) {
        if (accommodation.rooms != null && accommodation.rooms!.isNotEmpty) {
          for (var room in accommodation.rooms!) {
            // Create room map with accommodation info
            allRooms.add({
              'room': room,
              'accommodation': accommodation,
            });
          }
        }
      }

      // Apply price filter on rooms
      if (_minPrice > 0 || _maxPrice < 10000) {
        allRooms = allRooms.where((item) {
          final room = item['room'] as Room;
          final price = room.pricePerNight;
          return price >= _minPrice && price <= _maxPrice;
        }).toList();
      }

      // Apply rating filter if set
      if (_minRating != null) {
        allRooms = allRooms.where((item) {
          final accommodation = item['accommodation'] as Accommodation;
          final rating = accommodation.averageRating ?? 0.0;
          return rating >= _minRating!;
        }).toList();
      }

      setState(() {
        _accommodations = accommodations;
        _allRooms = allRooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16.w,
            right: 16.w,
            top: 16.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        _locationController.clear();
                        _minPrice = 0;
                        _maxPrice = 10000;
                        _minRating = null;
                      });
                    },
                    child: Text('Clear All'),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Location Filter
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location (City/Address)',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Price Range
              Text(
                  'Price Range: \$${_minPrice.toInt()} - \$${_maxPrice.toInt()}'),
              RangeSlider(
                values: RangeValues(_minPrice, _maxPrice),
                min: 0,
                max: 10000,
                divisions: 100,
                labels: RangeLabels(
                  '\$${_minPrice.toInt()}',
                  '\$${_maxPrice.toInt()}',
                ),
                onChanged: (values) {
                  setModalState(() {
                    _minPrice = values.start;
                    _maxPrice = values.end;
                  });
                },
              ),
              SizedBox(height: 16.h),

              // Rating Filter
              DropdownButtonFormField<double?>(
                value: _minRating,
                decoration: InputDecoration(
                  labelText: 'Minimum Rating',
                  prefixIcon: Icon(Icons.star),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                items: [
                  DropdownMenuItem(value: null, child: Text('Any')),
                  DropdownMenuItem(value: 4.5, child: Text('4.5+ ⭐')),
                  DropdownMenuItem(value: 4.0, child: Text('4.0+ ⭐')),
                  DropdownMenuItem(value: 3.5, child: Text('3.5+ ⭐')),
                  DropdownMenuItem(value: 3.0, child: Text('3.0+ ⭐')),
                ],
                onChanged: (value) {
                  setModalState(() => _minRating = value);
                },
              ),
              SizedBox(height: 24.h),

              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _loadData();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text('Apply Filters'),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60.sp, color: Colors.red),
            SizedBox(height: 16.h),
            Text('Error: $_error'),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _loadData,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Filter Button Row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Accommodations & Rooms',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _showFilterDialog,
                        icon: Icon(Icons.filter_alt, size: 20.sp),
                        label: Text('Filters'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 10.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  // My Bookings Button (Full Width with Icon)
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyBookingsPage(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primary.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bookmark_rounded,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            'View My Bookings',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 14.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal Accommodations Scroll
            if (_accommodations.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  'Browse Accommodations',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                height: 240.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: _accommodations.length,
                  itemBuilder: (context, index) {
                    return _buildAccommodationCard(_accommodations[index]);
                  },
                ),
              ),
              SizedBox(height: 24.h),
            ],

            // Vertical Rooms Scroll
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'Available Rooms (${_allRooms.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            SizedBox(height: 12.h),

            if (_allRooms.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(32.w),
                  child: Column(
                    children: [
                      Icon(Icons.hotel_outlined,
                          size: 60.sp, color: Colors.grey),
                      SizedBox(height: 16.h),
                      Text(
                        'No rooms available',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Try adjusting your filters',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _allRooms.length,
                itemBuilder: (context, index) {
                  return _buildRoomCard(_allRooms[index]);
                },
              ),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAccommodationCard(Accommodation accommodation) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AccommodationDetailsPage(
              accommodationId: accommodation.id,
            ),
          ),
        );
      },
      child: Container(
        width: 280.w,
        margin: EdgeInsets.only(right: 16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: accommodation.mediaUrls.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: accommodation.mediaUrls.first,
                      width: double.infinity,
                      height: 140.h,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.image_not_supported),
                      ),
                    )
                  : Container(
                      height: 140.h,
                      color: Colors.grey[300],
                      child: Icon(Icons.hotel, size: 50.sp),
                    ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    accommodation.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 14.w, color: Colors.grey[600]),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          accommodation.location,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16.w),
                      SizedBox(width: 4.w),
                      Text(
                        accommodation.averageRating?.toStringAsFixed(1) ??
                            'N/A',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Spacer(),
                      if (accommodation.rooms != null &&
                          accommodation.rooms!.isNotEmpty)
                        Text(
                          '${accommodation.rooms!.length} rooms',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard(Map<String, dynamic> item) {
    final Room room = item['room'];
    final Accommodation accommodation = item['accommodation'];

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RoomBookingPage(
                accommodation: accommodation,
                room: room,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Room Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: room.mediaUrls.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: room.mediaUrls.first,
                        width: 100.w,
                        height: 100.w,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.image_not_supported),
                        ),
                      )
                    : Container(
                        width: 100.w,
                        height: 100.w,
                        color: Colors.grey[300],
                        child: Icon(Icons.bed, size: 40.sp),
                      ),
              ),
              SizedBox(width: 16.w),

              // Room Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      accommodation.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      room.roomType,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.people, size: 14.w, color: Colors.grey[600]),
                        SizedBox(width: 4.w),
                        Text(
                          '${room.capacity} guests',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        SizedBox(width: 12.w),
                        Icon(Icons.star, size: 14.w, color: Colors.amber),
                        SizedBox(width: 4.w),
                        Text(
                          accommodation.averageRating?.toStringAsFixed(1) ??
                              'N/A',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PKR ${room.pricePerNight.toStringAsFixed(0)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              'per night',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RoomBookingPage(
                                  accommodation: accommodation,
                                  room: room,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text('Book Now'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
