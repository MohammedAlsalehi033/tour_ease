import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:tour_ease/components/themeSwitch.dart';

class HotelDetailsPage extends StatelessWidget {
  final int index;
  final String imageUrl;
  final String title;
  final String location;
  final String description;
  final String price;
  final String totalPrice;

  const HotelDetailsPage({
    Key? key,
    required this.index,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.description,
    required this.price,
    required this.totalPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [Themeswitch()],
        title: Text('Hotel Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Image Slider
            CarouselSlider(
              options: CarouselOptions(
                height: 250.h,
                autoPlay: false,
                enlargeCenterPage: true,
                autoPlayInterval: Duration(seconds: 3),
              ),
              items: [1, 2, 3, 4, 5].map((i) {
                return Hero(
                  tag: 'hotel-image-$index',
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: 250.h,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: Center(
                        child: Icon(Icons.image, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: Center(
                        child: Icon(Icons.broken_image, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            // Details Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Location
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    location,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 16.h),
                  // Description
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 24.h),
                  // Room Types (Horizontal Slider)
                  Text(
                    'Room Types',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 460.h, // Fixed height for the horizontal slider
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildRoomTypeCard(
                          context,
                          roomType: 'Standard Room',
                          price: '\$100/night',
                          features: ['1 Queen Bed', 'Free Wi-Fi', 'Breakfast Included'],
                        ),
                        SizedBox(width: 12.w),
                        _buildRoomTypeCard(
                          context,
                          roomType: 'Deluxe Room',
                          price: '\$150/night',
                          features: ['1 King Bed', 'Free Wi-Fi', 'Breakfast Included', 'Balcony'],
                        ),
                        SizedBox(width: 12.w),
                        _buildRoomTypeCard(
                          context,
                          roomType: 'Suite',
                          price: '\$250/night',
                          features: ['1 King Bed', 'Free Wi-Fi', 'Breakfast Included', 'Balcony', 'Living Area'],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // Facilities
                  Text(
                    'Facilities',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Facility Icons
                  Wrap(
                    spacing: 12.w,
                    runSpacing: 12.h,
                    children: [
                      _buildFacilityIcon(context, icon: Icons.wifi, label: 'Wi-Fi'),
                      _buildFacilityIcon(context, icon: Icons.pool, label: 'Swimming Pool'),
                      _buildFacilityIcon(context, icon: Icons.fitness_center, label: 'Gym'),
                      _buildFacilityIcon(context, icon: Icons.restaurant, label: 'Restaurant'),
                      _buildFacilityIcon(context, icon: Icons.local_parking, label: 'Parking'),
                      _buildFacilityIcon(context, icon: Icons.ac_unit, label: 'Air Conditioning'),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  // Price Section
                  Text(
                    'Price Details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        totalPrice,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomTypeCard(BuildContext context, {required String roomType, required String price, required List<String> features}) {
    return Container(
      width: 280.w,
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
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Gradient Background
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  Theme.of(context).colorScheme.primary.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roomType,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  price,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          // Features List
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...features.map((feature) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 16.w, color: Theme.of(context).colorScheme.primary),
                      SizedBox(width: 8.w),
                      Text(
                        feature,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),
          // Book Now Button
          Padding(
            padding: EdgeInsets.all(16.w),
            child: ElevatedButton(
              onPressed: () {
                // Handle booking logic
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
                textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: Text('Book Now'),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build facility icons
  Widget _buildFacilityIcon(BuildContext context, {required IconData icon, required String label}) {
    return Column(
      children: [
        Icon(icon, size: 24.w, color: Theme.of(context).colorScheme.primary),
        SizedBox(height: 4.h),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}