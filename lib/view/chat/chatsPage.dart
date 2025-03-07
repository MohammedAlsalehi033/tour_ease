import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tour_ease/model/chat/chat.dart';
import 'package:tour_ease/view/chat/chatDetailsPage.dart';

class MessagesPage extends StatefulWidget {
  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  // Dummy chat data
  final List<Chat> chats = [
    Chat(
      userName: 'John Doe',
      lastMessage: 'Hey, are you available tomorrow?',
      timestamp: '10:30 AM',
      avatarUrl: 'https://picsum.photos/200/200?random=1',
      isUnread: true,
    ),
    Chat(
      userName: 'Jane Smith',
      lastMessage: 'I’ll send you the details soon.',
      timestamp: 'Yesterday',
      avatarUrl: 'https://picsum.photos/200/200?random=2',
    ),
    Chat(
      userName: 'Alice Johnson',
      lastMessage: 'Thanks for the update!',
      timestamp: '2 days ago',
      avatarUrl: 'https://picsum.photos/200/200?random=3',
    ),
    Chat(
      userName: 'Bob Brown',
      lastMessage: 'Let’s meet at 5 PM.',
      timestamp: '3 days ago',
      avatarUrl: 'https://picsum.photos/200/200?random=4',
      isUnread: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) => ValueListenableBuilder(
          valueListenable: Theme.of(context).brightness == Brightness.dark
              ? ValueNotifier(Brightness.dark)
              : ValueNotifier(Brightness.light),
          builder: (context, value, child) {
            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return _buildChatItem(context, chat);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, Chat chat) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(chat.avatarUrl),
        radius: 24.r,
      ),
      title: Text(
        chat.userName,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: chat.isUnread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        chat.lastMessage,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      trailing: SizedBox(
        width: 80, // Constrain width to a fixed value
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              chat.timestamp,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.6),
              ),
            ),
            if (chat.isUnread)
              Container(
                margin: EdgeInsets.only(top: 4.h),
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              userName: chat.userName,
              avatarUrl: chat.avatarUrl,
            ),
          ),
        );
      },
    );
  }
}
