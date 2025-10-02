import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tour_ease/controller/report/report_bloc.dart';
import 'package:tour_ease/controller/report/report_event.dart';
import 'package:tour_ease/controller/rideSharing/RideBooking/provider/booking_for_provider_bloc.dart';
import 'package:tour_ease/controller/rideSharing/RideBooking/ride_booking_bloc.dart';
import 'package:tour_ease/controller/rideSharing/RideBooking/ride_booking_event.dart';
import 'package:tour_ease/controller/rideSharing/RideBooking/traveler/booking_for_traveler_bloc.dart';
import 'package:tour_ease/model/reviews/review_model.dart';
import 'package:tour_ease/model/rideSharing/RideBooking/RideBookingRepo.dart';
import 'package:tour_ease/model/report/report_repository.dart';
import 'package:tour_ease/model/report/reportModel.dart';
import 'package:tour_ease/Services/ApiService.dart';
import 'package:tour_ease/model/userManagment/user.dart';

class SimpleCancelButton extends StatefulWidget {
  final String bookingId;
  final VoidCallback? onCancelled;
  final bool isCompact;

  const SimpleCancelButton({
    Key? key,
    required this.bookingId,
    this.onCancelled,
    this.isCompact = false,
  }) : super(key: key);

  @override
  State<SimpleCancelButton> createState() => _SimpleCancelButtonState();
}

class _SimpleCancelButtonState extends State<SimpleCancelButton> {
  bool _isLoading = false;

  Future<void> _showCancelDialog() async {
    final String? reason = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CancelDialog(),
    );

    if (reason != null) {
      await _cancelRide(reason);
    }
  }

  Future<void> _cancelRide(String reason) async {
    setState(() {
      _isLoading = true;
    });

    try {
      

      // Create automatic report
      final report = Report(
        reporterId: UserModel().id,
        reportableType: 'TRANSPORTATION_BOOKING',
        reportReason: 'Ride cancelled',
        description: reason.isNotEmpty ? reason : 'Ride was cancelled by user.',
        transportationBookingId: int.tryParse(widget.bookingId),
      );


      context.read<ReportBloc>().add(PostReport(report: report));      // Cancel the booking
      context.read<BookingBloc>().add(CancelBookingRequested(bookingId: widget.bookingId));
      context.read<BookingForProviderBloc>().add(FetchProviderBookingsRequested(UserModel().id.toString()));
      context.read<BookingForTravelerBloc>().add(FetchTravelerBookingsRequested(UserModel().id.toString()));
      if (mounted) {
        widget.onCancelled?.call();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ride cancelled successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel ride: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.isCompact) {
      return IconButton(
        onPressed: _isLoading ? null : _showCancelDialog,
        icon: _isLoading
            ? SizedBox(
                width: 16.w,
                height: 16.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.error),
                ),
              )
            : Icon(
                Icons.cancel_outlined,
                color: theme.colorScheme.error,
              ),
        tooltip: 'Cancel Ride',
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _showCancelDialog,
        icon: _isLoading
            ? SizedBox(
                width: 16.w,
                height: 16.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(Icons.cancel_outlined, size: 18.sp),
        label: Text(
          'Cancel Ride',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.error,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }
}

class _CancelDialog extends StatefulWidget {
  @override
  State<_CancelDialog> createState() => _CancelDialogState();
}

class _CancelDialogState extends State<_CancelDialog> {
  final TextEditingController _reasonController = TextEditingController();
  bool _isConfirmEnabled = false;

  @override
  void initState() {
    super.initState();
    _reasonController.addListener(() {
      setState(() {
        _isConfirmEnabled = _reasonController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
          SizedBox(width: 8.w),
          Text('Cancel Ride'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to cancel this ride? This action cannot be undone and may affect your account.',
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: 16.h),
          Text(
            'Please provide a reason for cancellation:',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          TextField(

            controller: _reasonController,
            maxLines: 3,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: 'e.g., Emergency came up, Change of plans, etc.',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.all(12.w),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Keep Ride'),
        ),
        ElevatedButton(
          onPressed: _isConfirmEnabled
              ? () => Navigator.of(context).pop(_reasonController.text.trim())
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: Colors.white,
          ),
          child: Text('Cancel Ride'),
        ),
      ],
    );
  }
}