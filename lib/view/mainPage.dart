import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:tour_ease/components/cards/accommodationCardForHomePage.dart';
import 'package:tour_ease/components/themeSwitch.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // Pages corresponding to each tab
  final List<Widget> _pages = [
    AccommodationPage(),
    RideSharingPage(),
    TripsPage(),
    MessagesPage(),
    ProfilePage(),
  ];

  double iconsSizeBottomBar = 20;

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(360, 800));
    return Scaffold(extendBody: true,
      appBar: AppBar(
        title: Text(
          'TourEase',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [Themeswitch(),
          IconButton(
            icon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              // Add search functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              // Add notifications functionality
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        color: Colors.transparent, // Set the background color to transparent
        child: CurvedNavigationBar(
          index: _selectedIndex,
          height: 70.h,
          items: [
            Icon(Icons.home, size: iconsSizeBottomBar, color: Theme.of(context).colorScheme.onPrimary),
            Icon(Icons.directions_car, size: iconsSizeBottomBar, color: Theme.of(context).colorScheme.onPrimary),
            Icon(Icons.card_travel, size: iconsSizeBottomBar, color: Theme.of(context).colorScheme.onPrimary),
            Icon(Icons.message, size: iconsSizeBottomBar, color: Theme.of(context).colorScheme.onPrimary),
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
      )
    );
  }
}

// Placeholder pages for each tab
class AccommodationPage extends StatelessWidget {
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

          // Popular Accommodations
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
                    crossAxisCount: 1, // Adjust the number of columns
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                    childAspectRatio: 0.8, // Adjust the aspect ratio
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return AccommodationCard(index: index); // Use the custom card component
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

class RideSharingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Ride Sharing',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

class TripsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Trips',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

class MessagesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Messages',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Profile',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}