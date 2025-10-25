import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Your Project's Imports (ensure these paths are correct for your project structure)
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:tour_ease/components/cards/accommodationCardForHomePage.dart';
import 'package:tour_ease/components/themeSwitch.dart';
import 'package:tour_ease/controller/userManagment/initialize.dart';
import 'package:tour_ease/controller/userManagment/authenticationManager.dart';
import 'package:tour_ease/controller/userManagment/userHelper.dart';
import 'package:tour_ease/model/userManagment/user.dart';
import 'package:tour_ease/view/NotifiactionScreen.dart';
import 'package:tour_ease/view/chat/chatsPage.dart';
import 'package:tour_ease/view/profile/profile.dart';
import 'package:tour_ease/view/questions/questionsPage.dart';
import 'package:tour_ease/view/rideSharing/RidebookingScreen.dart';
import 'package:tour_ease/view/tripPlanner/tripPlannerPage.dart';

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
    TripPlannerPage(),
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
          print('User ID still inconsistent after initialization, forcing sync...');
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
            Text('Preparing your experience...', style: Theme.of(context).textTheme.bodyLarge),
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
              Text('Initialization Failed', style: Theme.of(context).textTheme.headlineSmall),
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
          UserModel().id,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          Themeswitch(),
          IconButton(
            icon: Icon(Icons.notifications, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => NotifiactionScreen()));
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
          height: 70.h,
          items: [
            Icon(Icons.home, size: iconsSizeBottomBar, color: Theme.of(context).colorScheme.onPrimary),
            Icon(Icons.directions_car, size: iconsSizeBottomBar, color: Theme.of(context).colorScheme.onPrimary),
            Icon(Icons.card_travel, size: iconsSizeBottomBar, color: Theme.of(context).colorScheme.onPrimary),
            Icon(Icons.message, size: iconsSizeBottomBar, color: Theme.of(context).colorScheme.onPrimary),
            Icon(Icons.question_answer, size: iconsSizeBottomBar, color: Theme.of(context).colorScheme.onPrimary),
            Icon(Icons.person, size: iconsSizeBottomBar, color: Theme.of(context).colorScheme.onPrimary),
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
              Icon(Icons.cloud_off_rounded, size: 80.sp, color: Theme.of(context).colorScheme.secondary),
              SizedBox(height: 20.h),
              Text(
                'No Internet Connection',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
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


// AccommodationPage as provided in the original code
class AccommodationPage extends StatelessWidget {
  const AccommodationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 200.h,
              autoPlay: true,
              enlargeCenterPage: true,
              autoPlayInterval: const Duration(seconds: 3),
            ),
            items: [1, 2, 3, 4, 5].map((i) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 5.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(
                      'https://picsum.photos/800/400?random=$i',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 20.h,
                      left: 20.w,
                      child: Text(
                        'Featured Accommodation $i',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Popular Accommodations',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 10.h),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return AccommodationCard(index: index);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}