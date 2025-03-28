import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tab_container/tab_container.dart';
import 'package:tour_ease/controller/rideSharing/transportationProvider/transporation_provider_bloc.dart';
import 'package:tour_ease/model/userManagment/transportationProvider.dart';

class NewTransportationProviderPage extends StatefulWidget {
  const NewTransportationProviderPage({super.key});

  @override
  State<NewTransportationProviderPage> createState() =>
      _NewTransportationProviderPageState();
}

class _NewTransportationProviderPageState extends State<NewTransportationProviderPage>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    context.read<TransporationProviderBloc>().add(FetchCurrentTransportationProviderData());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transportation Provider Details'),
      ),
      body: BlocBuilder<TransporationProviderBloc, TransporationProviderState>(
        builder: (context, state) {
          if (state is TransportationProviderdataLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: colorScheme.primary,
              ),
            );
          }

          if (state is TransportationProviderdataError) {
            return _buildErrorState(context, state, textTheme, colorScheme);
          }

          if (state is TransportationProviderdataLoaded) {
            final provider = state.transportationProviderModel;

            if (provider.accountStatus.toLowerCase() == 'active') {
              return TabContainer(
                color: colorScheme.surface,
                selectedTextStyle: textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                unselectedTextStyle: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),

                borderRadius: BorderRadius.circular(16.w),
                tabEdge: TabEdge.top,
                tabCurve: Curves.fastEaseInToSlowEaseOut,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    ),
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                      child: child,
                    ),
                  );
                },
                tabs: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, size: 20.sp, color: colorScheme.primary),
                      SizedBox(width: 8.w),
                      Text('Provider Details'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_car, size: 20.sp, color: colorScheme.primary),
                      SizedBox(width: 8.w),
                      Text('Ride Requests'),
                    ],
                  ),
                ],
                children: [
                  _buildProviderDetailsTab(provider, textTheme, dateFormat, colorScheme),
                  _buildRideRequestsTab(textTheme, colorScheme),
                ],
              );

            } else {
              return SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: _buildProviderDetailsContent(provider, textTheme, dateFormat),
              );
            }
          }

          return const Center(child: Text('Loading Transportation Provider Data...'));
        },
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context, TransportationProviderdataError state, TextTheme textTheme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: colorScheme.error,
          ),
          SizedBox(height: 16.h),
          Text(
            'Something went wrong',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.error,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            state.error,
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              context.read<TransporationProviderBloc>().add(FetchCurrentTransportationProviderData());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderDetailsTab(
      TransportationProviderModel provider,
      TextTheme textTheme,
      DateFormat dateFormat,
      ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProviderDetailsContent(provider, textTheme, dateFormat),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Create Listing button pressed')),
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 48.h),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: const Text('Create New Listing'),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderDetailsContent(
      TransportationProviderModel provider,
      TextTheme textTheme,
      DateFormat dateFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Provider ID: ${provider.providerId}', style: textTheme.titleLarge),
        SizedBox(height: 16.h),
        Text('Vehicle Type: ${provider.vehicleType}', style: textTheme.titleMedium),
        SizedBox(height: 8.h),
        Text('Seats Available: ${provider.seatsAvailable}', style: textTheme.titleMedium),
        SizedBox(height: 8.h),
        Text('Account Status: ${provider.accountStatus}', style: textTheme.titleMedium),
        SizedBox(height: 8.h),
        Text('Created At: ${dateFormat.format(provider.createdAt)}', style: textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildRideRequestsTab(TextTheme textTheme, ColorScheme colorScheme) {
    final dummyRequests = [
      {
        'id': 'R001',
        'traveler': 'John Doe',
        'pickup': 'City Center',
        'destination': 'Airport',
        'time': '2023-06-15 14:30',
        'status': 'Pending'
      },
      {
        'id': 'R002',
        'traveler': 'Jane Smith',
        'pickup': 'University',
        'destination': 'Train Station',
        'time': '2023-06-16 09:15',
        'status': 'Pending'
      },
      {
        'id': 'R003',
        'traveler': 'Robert Johnson',
        'pickup': 'Hotel Grand',
        'destination': 'Beach Resort',
        'time': '2023-06-17 11:00',
        'status': 'Accepted'
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: dummyRequests.length,
      itemBuilder: (context, index) {
        final request = dummyRequests[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16.h),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.w),
          ),
          child: ListTile(
            title: Text('Traveler: ${request['traveler']}', style: textTheme.titleMedium),
            subtitle: Text('From: ${request['pickup']} To: ${request['destination']}'),
            trailing: Text(request['status']!),
          ),
        );
      },
    );
  }
}
