import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit profile page
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            _buildUserProfileSection(context),
            SizedBox(height: 24.h),
            // Settings Section
            _buildSettingsSection(context),
            SizedBox(height: 24.h),
            // Logout Button
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  // User Profile Section
  Widget _buildUserProfileSection(BuildContext context) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 60.r,
            backgroundImage: NetworkImage('https://picsum.photos/200/200?random=1'),
          ),
          SizedBox(height: 16.h),
          Text(
            'John Doe',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Software Developer',
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

  // Logout Button
  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Handle logout
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Theme.of(context).colorScheme.onError,
          textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        child: Text('Logout'),
      ),
    );
  }
}