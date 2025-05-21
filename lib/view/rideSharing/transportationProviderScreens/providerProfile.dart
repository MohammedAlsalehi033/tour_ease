import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tour_ease/controller/rideSharing/offers/offers_bloc.dart';
import 'package:tour_ease/controller/rideSharing/offers/offers_event.dart';
import 'package:tour_ease/controller/rideSharing/offers/offers_state.dart';
import 'package:tour_ease/model/rideSharing/offer/offerModel.dart';
import 'package:tour_ease/model/userManagment/transportationProvider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tour_ease/model/userManagment/user.dart';

class TransportationProviderProfile extends StatefulWidget {
  final TransportationProviderModel transportationProviderModel;
  const TransportationProviderProfile({super.key, required this.transportationProviderModel});

  @override
  State<TransportationProviderProfile> createState() => _TransportationProviderProfileState();
}

class _TransportationProviderProfileState extends State<TransportationProviderProfile> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final provider = widget.transportationProviderModel;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: _buildProfileHeader(provider, textTheme, colorScheme),
            ),
            SliverPersistentHeader(
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: colorScheme.primary,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: colorScheme.primary,
                  tabs: [
                    Tab(text: 'Profile'),
                    Tab(text: 'Active Listing'),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildProfileDetails(provider, theme),
            BlocBuilder<OfferBloc, OfferState>(
  builder: (context, state) {
    return _buildOffersList(context, state);
  },
),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(TransportationProviderModel provider, TextTheme textTheme, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        children: [
          // Profile picture
          CircleAvatar(
            radius: 36.r,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.directions_car_filled_rounded,
              size: 40.r,
              color: colorScheme.primary,
            ),
          ),
          SizedBox(height: 12.h),

          // Name and status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  provider.providerId, // Replace with actual name if available
                  style: textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: provider.accountStatus == 'Active'
                      ? Colors.green
                      : Colors.orange,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  provider.accountStatus,
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),

          // Vehicle type with icon - Fixed with Wrap to prevent overflow
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4.w,
            runSpacing: 4.h,
            children: [
              Icon(
                _getVehicleIcon(provider.vehicleType),
                color: Colors.white70,
                size: 16.sp,
              ),
              Text(
                provider.vehicleType,
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.airline_seat_recline_normal,
                color: Colors.white70,
                size: 16.sp,
              ),
              Text(
                "${provider.seatsAvailable} seats",
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails(TransportationProviderModel provider, ThemeData theme) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _buildInfoCard(
            theme,
            title: 'Account Information',
            items: [
              InfoItem(
                icon: Icons.badge_outlined,
                label: 'Provider ID',
                value: provider.providerId,
              ),
              InfoItem(
                icon: Icons.calendar_today,
                label: 'Member Since',
                value: dateFormat.format(provider.createdAt),
              ),
              InfoItem(
                icon: Icons.access_time,
                label: 'Registration Time',
                value: timeFormat.format(provider.createdAt),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildInfoCard(
            theme,
            title: 'Vehicle Information',
            items: [
              InfoItem(
                icon: _getVehicleIcon(provider.vehicleType),
                label: 'Vehicle Type',
                value: provider.vehicleType,
              ),
              InfoItem(
                icon: Icons.airline_seat_recline_normal,
                label: 'Total Seats',
                value: provider.seatsAvailable.toString(),
              ),
              // Add more vehicle details if available in your model
              InfoItem(
                icon: Icons.star_outline,
                label: 'Rating',
                value: '4.8 (124 trips)', // Dummy rating data
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildInfoCard(
            theme,
            title: 'Service Statistics',
            items: [
              InfoItem(
                icon: Icons.route,
                label: 'Total Trips',
                value: '48', // Dummy data
              ),
              InfoItem(
                icon: Icons.people_outline,
                label: 'Passengers Served',
                value: '203', // Dummy data
              ),
              InfoItem(
                icon: Icons.thumb_up_outlined,
                label: 'Satisfaction Rate',
                value: '97%', // Dummy data
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, {required String title, required List<InfoItem> items}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            ...items.map((item) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      item.icon,
                      size: 18.sp,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          item.value,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOffersList(BuildContext context, OfferState state) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (state is OfferLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is OffersLoaded) {
      final offers = state.offers;
      print(offers);
      return _buildOffersListView(offers, textTheme, colorScheme);
    } else if (state is SingleOfferLoaded) {
      // If we have a single offer, wrap it in a list for consistent rendering
      final offers = [state.offer];
      return _buildOffersListView(offers, textTheme, colorScheme);
    } else if (state is OfferError) {
      return Center(child: Text('Error: ${state.message} asdasdasdasdasdas'));
    } else {
      context.read<OfferBloc>().add(GetReceivedOffersEvent(userId: UserModel().id));
      return const Center(child: Text('No offers available'));
    }
  }

  Widget _buildOffersListView(List<OfferModel> offers, TextTheme textTheme, ColorScheme colorScheme) {
    final dateFormat = DateFormat('E, MMM d');

    return offers.isEmpty
        ? Center(child: Text('No offers found for this listing'))
        : ListView.builder(
      padding: EdgeInsets.all(12.w),
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final offer = offers[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Offer header with price and status
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Offer #${offer.id}',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          // Date/time row
                          Wrap(
                            spacing: 4.w,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14.sp,
                                color: Colors.grey[600],
                              ),
                              Text(
                                dateFormat.format(offer.createdAt),
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: _getStatusColor(offer.status, colorScheme),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        offer.status.toUpperCase(),
                        style: textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Price information
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        color: colorScheme.primary,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Price: ${offer.pricePerSeat}',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                // Offer details
                if (offer.message != null && offer.message!.isNotEmpty) ...[
                  Text(
                    'Notes:',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    offer.message!,
                    style: textTheme.bodyMedium,
                  ),
                  SizedBox(height: 12.h),
                ],

                // User information
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16.r,
                      child: Icon(Icons.person, size: 20.sp)
                          
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      offer.status,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // Action buttons if the offer is pending
                if (offer.status.toLowerCase() == 'pending') ...[
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Dispatch reject offer event
                          context.read<OfferBloc>().add(RejectOfferEvent(offer.id));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        child: Text('Reject'),
                      ),
                      SizedBox(width: 12.w),
                      ElevatedButton(
                        onPressed: () {
                          // Dispatch accept offer event
                          context.read<OfferBloc>().add(AcceptOfferEvent(offer.id));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        child: Text('Accept'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.amber;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return colorScheme.primary;
    }
  }

  Widget _buildDetailChip(IconData icon, String label, Color backgroundColor, Color iconColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: iconColor),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              color: iconColor,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getVehicleIcon(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'sedan':
        return Icons.directions_car;
      case 'suv':
        return Icons.directions_car;
      case 'van':
        return Icons.airport_shuttle;
      case 'bus':
        return Icons.directions_bus;
      case 'motorcycle':
        return Icons.motorcycle;
      default:
        return Icons.directions_car;
    }
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}

class InfoItem {
  final IconData icon;
  final String label;
  final String value;

  InfoItem({required this.icon, required this.label, required this.value});
}