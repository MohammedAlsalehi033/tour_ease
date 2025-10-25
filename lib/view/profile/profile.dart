import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tour_ease/components/profileAvatar.dart';
import 'package:tour_ease/model/userManagment/user.dart';
import 'package:tour_ease/view/auth.dart';
import 'package:tour_ease/view/profile/rideHistory.dart';
import 'package:tour_ease/view/profile/updateProfilePicture.dart';
import 'package:tour_ease/view/profile/notificationsSettings.dart';
import 'package:tour_ease/view/profile/privacySettings.dart';
import 'package:tour_ease/view/profile/helpSupport.dart';

class ProfilePage extends StatefulWidget {




  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: SingleChildScrollView(
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
              // Safe Space at the Bottom
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
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UpdateProfilePicturePage(),
                ),
              );
              if (result == true) {
                // Refresh the profile if picture was updated
                setState(() {});
              }
            },
            child: Stack(
              children: [
                ProfileAvatar(
                  imageURL: UserModel().mediaUrls.isNotEmpty ? UserModel().mediaUrls[0] : null,
                  userName: UserModel().username, 
                  radius: 50.r,
                  userId: UserModel().id, 
                  clickable: false,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surface,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 16.sp,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            UserModel().username,
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsSettingsPage(),
              ),
            );
          },
        ),
        _buildSettingItem(
          context,
          icon: Icons.car_repair,
          title: 'Ride History',
          onTap: () {
Navigator.push(context, MaterialPageRoute(builder: (context) => RideHistory(),));
          },
        ),
        _buildSettingItem(
          context,
          icon: Icons.lock,
          title: 'Privacy',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PrivacySettingsPage(),
              ),
            );
          },
        ),
        _buildSettingItem(
          context,
          icon: Icons.color_lens,
          title: 'Theme',
          onTap: () {
            _showThemeDialog(context);
          },
        ),
        _buildSettingItem(
          context,
          icon: Icons.help,
          title: 'Help & Support',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HelpSupportPage(),
              ),
            );
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
        onPressed: () async {
           await FirebaseAuth.instance.signOut();
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AuthScreen(),));
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

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Light Theme'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement theme switching
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Light theme selected'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark Theme'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement theme switching
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Dark theme selected'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_mode),
              title: const Text('System Default'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement theme switching
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('System theme selected'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}