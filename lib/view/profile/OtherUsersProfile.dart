import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tour_ease/components/profileAvatar.dart';
import 'package:tour_ease/model/userManagment/user.dart';

class OtherUserProfile extends StatefulWidget {
  final String? imageURL;
  final String userName;
  final String? userId;

  const OtherUserProfile({super.key, this.imageURL, required this.userName, this.userId});

  @override
  State<OtherUserProfile> createState() => _OtherUserProfileState();
}

class _OtherUserProfileState extends State<OtherUserProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),


      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Section
              _buildUserProfileSection(context),
              SizedBox(height: 24.h),


              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

  // User Profile Section
  Widget _buildUserProfileSection(BuildContext context) {
    return Center(
      child: Column(
        children: [
          ProfileAvatar(imageURL: widget.imageURL, userName:widget.userName , radius: 50.r,userId: UserModel().id, clickable: true,),
          SizedBox(height: 16.h),
          Text(
            UserModel().email,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            UserModel().email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  // Settings Section
  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        _buildSettingItem(
          context,
          icon: Icons.notifications,
          title: 'Notifications',
          onTap: () {
            // Navigate to notifications settings
          },
        ),
        _buildSettingItem(
          context,
          icon: Icons.lock,
          title: 'Privacy',
          onTap: () {
            // Navigate to privacy settings
          },
        ),
        _buildSettingItem(
          context,
          icon: Icons.color_lens,
          title: 'Theme',
          onTap: () {
            // Navigate to theme settings
          },
        ),
        _buildSettingItem(
          context,
          icon: Icons.help,
          title: 'Help & Support',
          onTap: () {
            // Navigate to help & support
          },
        ),
      ],
    );
  }

  // Setting Item
  Widget _buildSettingItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        trailing: Icon(Icons.arrow_forward_ios, size: 16.w),
        onTap: onTap,
      ),
    );
  }


}