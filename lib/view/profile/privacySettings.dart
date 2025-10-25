import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({Key? key}) : super(key: key);

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  bool _profileVisibility = true;
  bool _showPhoneNumber = false;
  bool _showEmail = false;
  bool _locationSharing = true;
  bool _dataAnalytics = true;
  bool _marketingEmails = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
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
              // Profile Visibility
              _buildPrivacySection(
                theme,
                title: 'Profile Visibility',
                subtitle: 'Control who can see your profile information',
                children: [
                  _buildSwitchTile(
                    theme,
                    title: 'Public Profile',
                    subtitle: 'Allow others to view your profile',
                    value: _profileVisibility,
                    onChanged: (value) => setState(() => _profileVisibility = value),
                  ),
                  _buildSwitchTile(
                    theme,
                    title: 'Show Phone Number',
                    subtitle: 'Display your phone number on profile',
                    value: _showPhoneNumber,
                    onChanged: (value) => setState(() => _showPhoneNumber = value),
                  ),
                  _buildSwitchTile(
                    theme,
                    title: 'Show Email',
                    subtitle: 'Display your email on profile',
                    value: _showEmail,
                    onChanged: (value) => setState(() => _showEmail = value),
                  ),
                ],
              ),
              
              SizedBox(height: 24.h),
              
              // Location & Data
              _buildPrivacySection(
                theme,
                title: 'Location & Data',
                subtitle: 'Manage location sharing and data usage',
                children: [
                  _buildSwitchTile(
                    theme,
                    title: 'Location Sharing',
                    subtitle: 'Share your location during rides',
                    value: _locationSharing,
                    onChanged: (value) => setState(() => _locationSharing = value),
                  ),
                  _buildSwitchTile(
                    theme,
                    title: 'Data Analytics',
                    subtitle: 'Help improve the app with usage data',
                    value: _dataAnalytics,
                    onChanged: (value) => setState(() => _dataAnalytics = value),
                  ),
                ],
              ),
              
              SizedBox(height: 24.h),
              
              // Marketing & Communications
              _buildPrivacySection(
                theme,
                title: 'Marketing & Communications',
                subtitle: 'Control promotional communications',
                children: [
                  _buildSwitchTile(
                    theme,
                    title: 'Marketing Emails',
                    subtitle: 'Receive promotional emails and offers',
                    value: _marketingEmails,
                    onChanged: (value) => setState(() => _marketingEmails = value),
                  ),
                ],
              ),
              
              SizedBox(height: 32.h),
              
              // Data Management
              _buildDataManagementSection(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacySection(
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

  Widget _buildDataManagementSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Management',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        _buildActionTile(
          theme,
          icon: Icons.download,
          title: 'Download My Data',
          subtitle: 'Get a copy of your personal data',
          onTap: _downloadData,
        ),
        _buildActionTile(
          theme,
          icon: Icons.delete_forever,
          title: 'Delete Account',
          subtitle: 'Permanently delete your account and data',
          onTap: _deleteAccount,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildActionTile(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? theme.colorScheme.error : theme.colorScheme.primary,
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: isDestructive ? theme.colorScheme.error : null,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.w,
          color: isDestructive ? theme.colorScheme.error : null,
        ),
        onTap: onTap,
      ),
    );
  }

  void _saveSettings() {
    // TODO: Implement API call to save privacy settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Privacy settings saved!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  void _downloadData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Data'),
        content: const Text('This will prepare a copy of your personal data. You will receive an email with the download link within 24 hours.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data download request submitted!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Request Download'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('This action cannot be undone. All your data will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion request submitted!'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}
