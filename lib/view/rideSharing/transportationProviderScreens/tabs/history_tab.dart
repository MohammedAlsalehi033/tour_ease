import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tour_ease/controller/rideSharing/RideBooking/provider/booking_for_provider_bloc.dart';
import 'package:tour_ease/model/userManagment/user.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BlocBuilder<BookingForProviderBloc, BookingForProviderState>(
      builder: (context, state) {
        if (state is BookingForProviderLoading) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        }
        
        if (state is BookingForProviderLoadFailure) {
          return _buildErrorState(context, state.error, textTheme, colorScheme);
        }
        
        if (state is BookingForProviderLoadSuccess) {
          final completedBookings = state.bookings
              .where((booking) => booking.status.toLowerCase() == "completed")
              .toList();
              
          if (completedBookings.isEmpty) {
            return _buildEmptyState(textTheme, colorScheme);
          }
          
          return _buildHistoryList(context, completedBookings, textTheme, colorScheme);
        }
        
        return Center(
          child: Text(
            'Loading history...',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String error,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
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
            error,
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              context.read<BookingForProviderBloc>().add(
                    FetchProviderBookingsRequested(UserModel().id),
                  );
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(TextTheme textTheme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64.sp,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            SizedBox(height: 24.h),
            Text(
              'No History Yet',
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Your completed rides will appear here',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    List<dynamic> bookings,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<BookingForProviderBloc>().add(
              FetchProviderBookingsRequested(UserModel().id),
            );
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _buildHistoryCard(booking, textTheme, colorScheme);
        },
      ),
    );
  }

  Widget _buildHistoryCard(
    dynamic booking,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    final formattedDate = DateFormat('MMM d, yyyy - HH:mm')
        .format(booking.createdAt.toLocal());
    
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking #${booking.id}',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'COMPLETED',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            
            if (booking.listing != null) ...[
              _buildInfoRow(
                Icons.location_on_outlined,
                'Route',
                '${booking.listing!.startLocationText} → ${booking.listing!.endLocationText}',
                textTheme,
                colorScheme,
              ),
              SizedBox(height: 8.h),
            ],
            
            _buildInfoRow(
              Icons.person_outline,
              'Traveler',
              booking.traveler?.username ?? 'Unknown',
              textTheme,
              colorScheme,
            ),
            SizedBox(height: 8.h),
            
            _buildInfoRow(
              Icons.event_note,
              'Completed on',
              formattedDate,
              textTheme,
              colorScheme,
            ),
            SizedBox(height: 8.h),
            
            _buildInfoRow(
              Icons.attach_money,
              'Earned',
              'PKR ${booking.totalPrice.toStringAsFixed(2)}',
              textTheme,
              colorScheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
