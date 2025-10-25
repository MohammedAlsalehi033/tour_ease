import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({Key? key}) : super(key: key);

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FAQ Section
              _buildSection(
                theme,
                title: 'Frequently Asked Questions',
                children: [
                  _buildFAQItem(
                    theme,
                    question: 'How do I book a ride?',
                    answer: 'Search for rides using the filter page, select your preferred ride, and make a booking request.',
                  ),
                  _buildFAQItem(
                    theme,
                    question: 'How do I become a driver?',
                    answer: 'Go to the ride sharing page and tap the "+" button to register as a transportation provider.',
                  ),
                  _buildFAQItem(
                    theme,
                    question: 'How do I cancel a booking?',
                    answer: 'Go to your bookings page and select the booking you want to cancel. Follow the cancellation process.',
                  ),
                  _buildFAQItem(
                    theme,
                    question: 'What payment methods are accepted?',
                    answer: 'Currently, we support cash payments. Online payment options will be available soon.',
                  ),
                ],
              ),
              
              SizedBox(height: 32.h),
              
              // Contact Support
              _buildSection(
                theme,
                title: 'Contact Support',
                children: [
                  _buildContactItem(
                    theme,
                    icon: Icons.email,
                    title: 'Email Support',
                    subtitle: 'support@tourease.com',
                    onTap: () => _launchEmail(),
                  ),
                  _buildContactItem(
                    theme,
                    icon: Icons.phone,
                    title: 'Phone Support',
                    subtitle: '+92 300 123 4567',
                    onTap: () => _launchPhone(),
                  ),
                  _buildContactItem(
                    theme,
                    icon: Icons.chat,
                    title: 'Live Chat',
                    subtitle: 'Available 24/7',
                    onTap: () => _openLiveChat(),
                  ),
                ],
              ),
              
              SizedBox(height: 32.h),
              
              // Send Message
              _buildSendMessageSection(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    ThemeData theme, {
    required String title,
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
        SizedBox(height: 16.h),
        ...children,
      ],
    );
  }

  Widget _buildFAQItem(
    ThemeData theme, {
    required String question,
    required String answer,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: Text(
              answer,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.w,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSendMessageSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Send us a Message',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                TextField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: _messageController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _sendMessage,
                    child: const Text('Send Message'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _launchEmail() {
    // TODO: Implement email launch functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email: support@tourease.com'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _launchPhone() {
    // TODO: Implement phone launch functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Phone: +92 300 123 4567'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _openLiveChat() {
    // TODO: Implement live chat functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Live chat will be available soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _sendMessage() {
    if (_subjectController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both subject and message'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // TODO: Implement API call to send message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message sent successfully! We\'ll get back to you soon.'),
        backgroundColor: Colors.green,
      ),
    );
    
    _subjectController.clear();
    _messageController.clear();
  }
}
