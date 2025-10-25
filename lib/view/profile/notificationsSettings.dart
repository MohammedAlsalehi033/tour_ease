import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationsSettingsPage extends StatefulWidget {
  const NotificationsSettingsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsSettingsPage> createState() => _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  bool _rideNotifications = true;
  bool _offerNotifications = true;
  bool _messageNotifications = true;
  bool _promotionalNotifications = false;
  bool _emailNotifications = true;
  bool _pushNotifications = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ride Notifications
              _buildNotificationSection(
                theme,
                title: 'Ride Notifications',
                subtitle: 'Get notified about ride updates',
                children: [
                  _buildSwitchTile(
                    theme,
                    title: 'Ride Requests',
                    subtitle: 'New ride requests and updates',
                    value: _rideNotifications,
                    onChanged: (value) => setState(() => _rideNotifications = value),
                  ),
                  _buildSwitchTile(
                    theme,
                    title: 'Offer Updates',
                    subtitle: 'Counter offers and booking confirmations',
                    value: _offerNotifications,
                    onChanged: (value) => setState(() => _offerNotifications = value),
                  ),
                ],
              ),
              
              SizedBox(height: 24.h),
              
              // Communication
              _buildNotificationSection(
                theme,
                title: 'Communication',
                subtitle: 'Messages and chat notifications',
                children: [
                  _buildSwitchTile(
                    theme,
                    title: 'Messages',
                    subtitle: 'New messages from drivers/travelers',
                    value: _messageNotifications,
                    onChanged: (value) => setState(() => _messageNotifications = value),
                  ),
                ],
              ),
              
              SizedBox(height: 24.h),
              
              // Marketing
              _buildNotificationSection(
                theme,
                title: 'Marketing',
                subtitle: 'Promotional content and updates',
                children: [
                  _buildSwitchTile(
                    theme,
                    title: 'Promotional',
                    subtitle: 'Special offers and app updates',
                    value: _promotionalNotifications,
                    onChanged: (value) => setState(() => _promotionalNotifications = value),
                  ),
                ],
              ),
              
              SizedBox(height: 24.h),
              
              // Delivery Methods
              _buildNotificationSection(
                theme,
                title: 'Delivery Methods',
                subtitle: 'How you want to receive notifications',
                children: [
                  _buildSwitchTile(
                    theme,
                    title: 'Push Notifications',
                    subtitle: 'Receive notifications on your device',
                    value: _pushNotifications,
                    onChanged: (value) => setState(() => _pushNotifications = value),
                  ),
                  _buildSwitchTile(
                    theme,
                    title: 'Email Notifications',
                    subtitle: 'Receive notifications via email',
                    value: _emailNotifications,
                    onChanged: (value) => setState(() => _emailNotifications = value),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationSection(
    ThemeData theme, {
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        SizedBox(height: 16.h),
        ...children,
      ],
    );
  }

  Widget _buildSwitchTile(
    ThemeData theme, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: theme.colorScheme.primary,
      ),
    );
  }

  void _saveSettings() {
    // TODO: Implement API call to save notification settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification settings saved!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }
}
