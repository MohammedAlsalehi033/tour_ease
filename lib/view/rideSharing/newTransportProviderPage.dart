import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tab_container/tab_container.dart';
import 'package:tour_ease/controller/rideSharing/transportationProvider/transporation_provider_bloc.dart';
import 'package:tour_ease/model/userManagment/transportationProvider.dart';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tour_ease/model/userManagment/user.dart';

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
    context
        .read<TransporationProviderBloc>()
        .add(FetchCurrentTransportationProviderData());
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16.r),
          ),
        ),
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
                tabEdge: TabEdge.left,
                tabCurve: Curves.fastEaseInToSlowEaseOut,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    ),
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.95, end: 1.0)
                          .animate(animation),
                      child: child,
                    ),
                  );
                },
                tabs: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline,
                          size: 20.sp, color: colorScheme.primary),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_car,
                          size: 20.sp, color: colorScheme.primary),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add,
                          size: 20.sp, weight: 2, color: colorScheme.primary),
                    ],
                  ),
                ],
                children: [
                  _buildProviderDetailsTab(
                      provider, textTheme, dateFormat, colorScheme),
                  _buildRideRequestsTab(textTheme, colorScheme),
                  _buildRideRequestsTab(textTheme, colorScheme),
                ],
              );
            } else {
              return Text("wating for admin apporvel");
            }
          }

          return const Center(
              child: Text('Loading Transportation Provider Data...'));
        },
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context,
      TransportationProviderdataError state,
      TextTheme textTheme,
      ColorScheme colorScheme) {
    return state.error == "Exception: Transportation provider not found" ? TransportationProviderForm() : Center(
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

  Widget _buildProviderDetailsTab(TransportationProviderModel provider,
      TextTheme textTheme, DateFormat dateFormat, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProviderDetailsContent(provider, textTheme, dateFormat),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildProviderDetailsContent(TransportationProviderModel provider,
      TextTheme textTheme, DateFormat dateFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Provider ID: ${provider.providerId}',
            style: textTheme.titleLarge),
        SizedBox(height: 16.h),
        Text('Vehicle Type: ${provider.vehicleType}',
            style: textTheme.titleMedium),
        SizedBox(height: 8.h),
        Text('Seats Available: ${provider.seatsAvailable}',
            style: textTheme.titleMedium),
        SizedBox(height: 8.h),
        Text('Account Status: ${provider.accountStatus}',
            style: textTheme.titleMedium),
        SizedBox(height: 8.h),
        Text('Created At: ${dateFormat.format(provider.createdAt)}',
            style: textTheme.bodyMedium),
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
            title: Text('Traveler: ${request['traveler']}',
                style: textTheme.titleMedium),
            subtitle: Text(
                'From: ${request['pickup']} To: ${request['destination']}'),
            trailing: Text(request['status']!),
          ),
        );
      },
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onTapCamera,
                icon: Icon(Icons.camera_alt_outlined),
                label: Text("Camera"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  side: BorderSide(color: theme.colorScheme.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                  width: 60, height: 60, margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2))),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(file.path), fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: theme.colorScheme.surface, child: Center(child: Icon(Icons.error_outline, color: theme.colorScheme.error, size: 24)));
                      },
                    ),
                  ),
                );
              },
            ),
          )
              : Container(
            height: 60, width: double.infinity, padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(color: theme.colorScheme.surfaceVariant.withOpacity(0.5), borderRadius: BorderRadius.circular(8), border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2))),
            child: Align(alignment: Alignment.centerLeft, child: Text("No media selected", style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
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
      child: Row( // Main row
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Wrap title in Flexible to allow text wrapping and prevent pushing controls
          Flexible(
            child: Text(
                title,
                style: theme.textTheme.titleMedium
            ),
          ),
          SizedBox(width: 8), // Add some space between title and controls
          // Counter controls row
          Row(
            mainAxisSize: MainAxisSize.min, // Take only needed space
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: theme.colorScheme.primary),
                onPressed: value > 1 ? onDecrease : null, // Disable if value is 1
                visualDensity: VisualDensity.compact, // Reduce padding slightly
                padding: EdgeInsets.zero, // Remove default padding if needed
              ),
              SizedBox(width: 4), // Reduced space
              Text('$value', style: theme.textTheme.headlineSmall),
              SizedBox(width: 4), // Reduced space
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: theme.colorScheme.primary),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: theme.colorScheme.primary)),
                filled: true, fillColor: theme.colorScheme.surfaceVariant,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),

            ),
            SizedBox(height: 24),
            _buildCounterTile(
              title: "Seats Available",
              value: _seatsAvailable,
              onDecrease: () => setState(() => _seatsAvailable = (_seatsAvailable > 1) ? _seatsAvailable - 1 : 1),
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
                  context.read<TransporationProviderBloc>().add(CreateTransportationProvider(TransportationProviderModel(UserModel().id,[],[],_vehicleTypeController.text,_seatsAvailable,"",DateTime.now()) , _licenseMedia!, _vehicleMedia!));
                },
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                child: Text("Submit"),
              ),
            ),
            SizedBox(height: 16), // Add some padding at the bottom inside scroll view
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