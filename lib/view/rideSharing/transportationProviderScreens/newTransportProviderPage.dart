import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tab_container/tab_container.dart';
import 'package:tour_ease/controller/rideSharing/RideBooking/provider/booking_for_provider_bloc.dart';
import 'package:tour_ease/controller/rideSharing/transportationProvider/transporation_provider_bloc.dart';
import 'package:tour_ease/model/userManagment/UserModelTempForNow.dart';
import 'package:tour_ease/model/userManagment/transportationProvider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tour_ease/model/userManagment/user.dart';
import 'package:tour_ease/view/rideSharing/transportationProviderScreens/TravelBookingForm.dart';
import 'package:tour_ease/view/rideSharing/transportationProviderScreens/providerProfile.dart';
import 'package:tour_ease/view/rideSharing/transportationProviderScreens/tabs/requests_tab.dart';
import 'package:tour_ease/view/rideSharing/transportationProviderScreens/tabs/history_tab.dart';
import 'package:tour_ease/view/rideSharing/transportationProviderScreens/widgets/active_bookings_view.dart';
import 'package:tour_ease/view/rideSharing/transportationProviderScreens/widgets/waiting_for_approval_view.dart';

class NewTransportationProviderPage extends StatefulWidget {
  const NewTransportationProviderPage({super.key});

  @override
  State<NewTransportationProviderPage> createState() =>
      _NewTransportationProviderPageState();
}

class _NewTransportationProviderPageState
    extends State<NewTransportationProviderPage> with TickerProviderStateMixin {
  
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    context
        .read<TransporationProviderBloc>()
        .add(FetchCurrentTransportationProviderData());

    context.read<BookingForProviderBloc>().add(FetchProviderBookingsRequested(UserModel().id));
  }

  void _refreshData() {
    if (mounted) {
      context
          .read<TransporationProviderBloc>()
          .add(FetchCurrentTransportationProviderData());

      context.read<BookingForProviderBloc>().add(FetchProviderBookingsRequested(UserModel().id));
    }
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transportation Provider'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16.r),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: BlocBuilder<TransporationProviderBloc, TransporationProviderState>(
        builder: (context, state) {
          if (state is TransportationProviderdataLoading) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          if (state is TransportationProviderdataError) {
            return _buildErrorState(context, state);
          }

          if (state is TransportationProviderdataLoaded) {
            final provider = state.transportationProviderModel;
            
            if (provider.accountStatus.toLowerCase() != 'active') {
              return const WaitingForApprovalView();
            }

            return BlocBuilder<BookingForProviderBloc, BookingForProviderState>(
              builder: (context, bookingState) {
                if (bookingState is BookingForProviderLoading) {
                  return Center(
                    child: CircularProgressIndicator(color: colorScheme.primary),
                  );
                }

                if (bookingState is BookingForProviderLoadFailure) {
                  return Center(child: Text(bookingState.error));
                }

                if (bookingState is BookingForProviderLoadSuccess) {
                  final hasActiveBookings = bookingState.bookings.any(
                    (booking) =>
                        booking.status.toLowerCase() == "pending" ||
                        booking.status.toLowerCase() == "accepted",
                  );

                  if (hasActiveBookings) {
                    return ActiveBookingsView(onRefresh: _refreshData);
                  }

                  return _buildTabsView(provider, textTheme, colorScheme);
                }

                return const Center(child: Text('Loading...'));
              },
            );
          }

          return const Center(child: Text('Loading Transportation Provider Data...'));
        },
      ),
    );
  }

  Widget _buildTabsView(
    TransportationProviderModel provider,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
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
      tabEdge: TabEdge.left,
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
        _buildTabHeader(Icons.directions_car, 'Requests', colorScheme),
        _buildTabHeader(Icons.add, 'Create', colorScheme),
        _buildTabHeader(Icons.person, 'Profile', colorScheme),
        _buildTabHeader(Icons.history, 'History', colorScheme),
      ],
      children: [
        const RequestsTab(),
        TravelBookingForm(travelerId: UserModel().id),
        TransportationProviderProfile(transportationProviderModel: provider),
        const HistoryTab(),
      ],
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    TransportationProviderdataError state,
  ) {
    if (state.error == "Exception: Transportation provider not found") {
      return TransportationProviderForm();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

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
              context
                  .read<TransporationProviderBloc>()
                  .add(FetchCurrentTransportationProviderData());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabHeader(IconData icon, String label, ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20.sp, color: colorScheme.primary),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }


}

class TransportationProviderForm extends StatefulWidget {
  @override
  _TransportationProviderFormState createState() =>
      _TransportationProviderFormState();
}

class _TransportationProviderFormState
    extends State<TransportationProviderForm> {
  final TextEditingController _vehicleTypeController = TextEditingController();
  int _seatsAvailable = 1;
  List<XFile>? _licenseMedia;
  List<XFile>? _vehicleMedia;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(bool isLicense, ImageSource source) async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        var limitedImages = images.length > 4 ? images.sublist(0, 4) : images;
        if (isLicense) {
          _licenseMedia = limitedImages;
        } else {
          _vehicleMedia = limitedImages;
        }
      });
    }
  }

  Widget _buildFileSelector({
    required String title,
    required List<XFile>? files,
    required VoidCallback onTapGallery,
    required VoidCallback onTapCamera,
    required ThemeData theme,
  }) {
    bool hasFiles = files != null && files.isNotEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            alignment: WrapAlignment.start, // Align buttons below title
            children: [
              OutlinedButton.icon(
                onPressed: onTapGallery,
                icon: Icon(Icons.photo_library_outlined),
                label: Text("Gallery"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  side: BorderSide(color: theme.colorScheme.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onTapCamera,
                icon: Icon(Icons.camera_alt_outlined),
                label: Text("Camera"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  side: BorderSide(color: theme.colorScheme.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          hasFiles
              ? SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      final file = files[index];
                      return Container(
                        width: 60,
                        height: 60,
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: theme.colorScheme.outline
                                    .withOpacity(0.2))),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(file.path),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                  color: theme.colorScheme.surface,
                                  child: Center(
                                      child: Icon(Icons.error_outline,
                                          color: theme.colorScheme.error,
                                          size: 24)));
                            },
                          ),
                        ),
                      );
                    },
                  ),
                )
              : Container(
                  height: 60,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.2))),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("No media selected",
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant))),
                ),
        ],
      ),
    );
  }

  Widget _buildCounterTile(
      {required String title,
      required int value,
      required VoidCallback onDecrease,
      required VoidCallback onIncrease,
      required ThemeData theme}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
      ),
      child: Row(
        // Main row
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Wrap title in Flexible to allow text wrapping and prevent pushing controls
          Flexible(
            child: Text(title, style: theme.textTheme.titleMedium),
          ),
          SizedBox(width: 8), // Add some space between title and controls
          // Counter controls row
          Row(
            mainAxisSize: MainAxisSize.min, // Take only needed space
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle_outline,
                    color: theme.colorScheme.primary),
                onPressed:
                    value > 1 ? onDecrease : null, // Disable if value is 1
                visualDensity: VisualDensity.compact, // Reduce padding slightly
                padding: EdgeInsets.zero, // Remove default padding if needed
              ),
              SizedBox(width: 4), // Reduced space
              Text('$value', style: theme.textTheme.headlineSmall),
              SizedBox(width: 4), // Reduced space
              IconButton(
                icon: Icon(Icons.add_circle_outline,
                    color: theme.colorScheme.primary),
                onPressed: onIncrease,
                visualDensity: VisualDensity.compact, // Reduce padding slightly
                padding: EdgeInsets.zero, // Remove default padding if needed
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _vehicleTypeController,
              decoration: InputDecoration(
                labelText: "Vehicle Type",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.5))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: theme.colorScheme.primary)),
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            SizedBox(height: 24),
            _buildCounterTile(
              title: "Seats Available",
              value: _seatsAvailable,
              onDecrease: () => setState(() => _seatsAvailable =
                  (_seatsAvailable > 1) ? _seatsAvailable - 1 : 1),
              onIncrease: () => setState(() => _seatsAvailable++),
              theme: theme,
            ),
            _buildFileSelector(
              title: "License Media (Max 4)",
              files: _licenseMedia,
              onTapGallery: () => _pickImage(true, ImageSource.gallery),
              onTapCamera: () => _pickImage(true, ImageSource.camera),
              theme: theme,
            ),
            _buildFileSelector(
              title: "Vehicle Media (Max 4)",
              files: _vehicleMedia,
              onTapGallery: () => _pickImage(false, ImageSource.gallery),
              onTapCamera: () => _pickImage(false, ImageSource.camera),
              theme: theme,
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<TransporationProviderBloc>().add(
                      CreateTransportationProvider(
                          TransportationProviderModel(
                              providerId: UserModel().id,
                              accountStatus: "",
                              createdAt: DateTime.now(),
                              licenseMmediaUrls: [],
                              vehicleMediaUrls: [],
                              seatsAvailable: _seatsAvailable,
                              user: UserModelTempForNow(
                                  id: UserModel().id,
                                  email: UserModel().email,
                                  username: "",
                                  mediaUrls: [],
                                  accountStatus: "",
                                  createdAt: DateTime.now()),
                              vehicleType: _vehicleTypeController.text),
                          _licenseMedia!,
                          _vehicleMedia!));
                },
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: Text("Submit"),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _vehicleTypeController.dispose();
    super.dispose();
  }
}
