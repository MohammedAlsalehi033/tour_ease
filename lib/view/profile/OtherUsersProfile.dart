import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tour_ease/components/profileAvatar.dart';
import 'package:tour_ease/model/userManagment/user.dart';
import 'package:tour_ease/view/chat/chatDetailsPage.dart';

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
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // REFINED: Extend the body behind the AppBar for the banner effect.
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // REFINED: A transparent AppBar blends with the header banner.
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Ensure back button is visible against the banner
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      body: AnimationLimiter(
        // NEW: A Stack layout to create the colored header banner effect.
        child: Stack(
          children: [
            // This is the colored header banner.
            Container(
              height: 200.h,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
              ),
            ),
            // This is the main content, centered on the page.
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
                      // REFINED: A larger avatar with a border to make it pop.
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
                      // NEW: A placeholder for a bio or user status for a more complete look.
                      Text(
                        "Member of TourEase Community",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 32.h),
                      // REFINED: A clear visual hierarchy for action buttons.
                      Row(
                        children: [
                          // Primary action: Chat
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                      currentUserId: UserModel().id,
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
                          // Secondary action: Report
                          OutlinedButton(
                            onPressed: () {
                              // TODO: Implement report functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Report feature coming soon!')),
                              );
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
    );
  }
}