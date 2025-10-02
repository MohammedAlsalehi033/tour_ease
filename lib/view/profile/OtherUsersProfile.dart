import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // NEW: Import Bloc
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tour_ease/components/profileAvatar.dart';
import 'package:tour_ease/controller/report/report_bloc.dart';
import 'package:tour_ease/controller/report/report_event.dart';
import 'package:tour_ease/controller/report/report_state.dart';
import 'package:tour_ease/model/report/reportModel.dart'; // NEW: Import Report Model
import 'package:tour_ease/model/userManagment/user.dart';
import 'package:tour_ease/view/chat/chatDetailsPage.dart';
// NEW: Make sure you have an AuthBloc or similar to get the current user's ID
// import 'package:tour_ease/bloc/auth/auth_bloc.dart';

class OtherUserProfile extends StatefulWidget {
  final String? imageURL;
  final String userName;
  final String userId;

  const OtherUserProfile({
    super.key,
    this.imageURL,
    required this.userName,
    required this.userId,
  });

  @override
  State<OtherUserProfile> createState() => _OtherUserProfileState();
}

class _OtherUserProfileState extends State<OtherUserProfile> {
  // NEW: Method to show the report submission form
  void _showReportUserBottomSheet(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String? _reportReason;
    final _descriptionController = TextEditingController();
    final List<String> reportReasons = [
      'Inappropriate Behavior',
      'Spam or Scam',
      'Fake Profile',
      'Harassment',
      'Other'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the sheet to resize for the keyboard
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
            left: 24.w,
            right: 24.w,
            top: 24.h,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report ${widget.userName}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.h),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Reason for reporting',
                    border: OutlineInputBorder(),
                  ),
                  value: _reportReason,
                  items: reportReasons.map((String reason) {
                    return DropdownMenuItem<String>(
                      value: reason,
                      child: Text(reason),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _reportReason = newValue;
                    });
                  },
                  validator: (value) => value == null ? 'Please select a reason' : null,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Provide more details (optional)...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please provide a description.';
                    }
                    if (value.length < 10) {
                      return 'Description must be at least 10 characters long.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.h),
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // IMPORTANT: You need a reliable way to get the current user's ID.
                      // Using a Bloc (like AuthBloc) is the standard way.
                      // final String currentUserId = context.read<AuthBloc>().state.user.id;
                      const String currentUserId = "current-user-id-placeholder"; // Replace this!

                      final report = Report(
                        reportableType: 'USER',
                        reportReason: _reportReason!,
                        description: _descriptionController.text,
                        reporterId: currentUserId,
                        reportedUserId: widget.userId,
                      );

                      // Dispatch the event to the BLoC
                      context.read<ReportBloc>().add(PostReport(report: report));

                      Navigator.pop(bottomSheetContext); // Close the bottom sheet
                    }
                  },
                  child: const Text('Submit Report'),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // NEW: Wrap the Scaffold with a BlocListener to handle feedback
    return BlocListener<ReportBloc, ReportState>(
      listener: (context, state) {
        if (state is ReportPostSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Report submitted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
        } else if (state is ReportLoadFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('Failed to submit report: ${state.error}'),
                backgroundColor: colorScheme.error,
              ),
            );
        } else if (state is ReportLoadInProgress) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Submitting report...'),
              ),
            );
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: colorScheme.onPrimary),
        ),
        body: AnimationLimiter(
          child: Stack(
            children: [
              Container(
                height: 200.h,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 400),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(child: widget),
                      ),
                      children: [
                        ProfileAvatar(
                          imageURL: widget.imageURL,
                          userName: widget.userName,
                          radius: 60.r,
                          userId: widget.userId,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          widget.userName,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "Member of TourEase Community",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 32.h),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () {
                                  // This line `UserModel().id` is problematic.
                                  // You must get the *actual* current user's ID.
                                  // For now, I'm passing a placeholder. Fix this!
                                   String currentUserId = UserModel().id; // Replace with actual current user ID retrieval

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatPage(
                                        currentUserId: currentUserId,
                                        otherUserId: widget.userId,
                                        apiBaseUrl: 'http://10.0.2.2:300/api',
                                        otherUserName: widget.userName,
                                        otherUserAvatar: widget.imageURL ?? '',
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.chat_bubble_rounded),
                                label: const Text("Message"),
                                style: FilledButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  textStyle: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            OutlinedButton(
                              // UPDATED: Call the bottom sheet method on press
                              onPressed: () {
                                _showReportUserBottomSheet(context);
                              },
                              child: const Icon(Icons.flag_outlined),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.all(12.h),
                                side: BorderSide(color: colorScheme.outlineVariant),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}