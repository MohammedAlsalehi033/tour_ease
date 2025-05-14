import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tour_ease/controller/chat/chat_bloc.dart';
import 'package:tour_ease/controller/chat/chat_event.dart';
import 'package:tour_ease/controller/chat/chat_state.dart';
import 'package:tour_ease/model/chat/chat.dart';
import 'package:tour_ease/model/userManagment/user.dart';
import 'package:tour_ease/view/chat/chatDetailsPage.dart';

class MessagesPage extends StatefulWidget {
  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(LoadChats());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if(state is ChatError) return Text(state.message);
        else if (state is ChatLoading) return Center(child: CircularProgressIndicator());
        else if (state is ChatsLoaded)  {
          return Scaffold(
            body: Builder(
              builder: (context) => ValueListenableBuilder(
                valueListenable: Theme.of(context).brightness == Brightness.dark
                    ? ValueNotifier(Brightness.dark)
                    : ValueNotifier(Brightness.light),
                builder: (context, value, child) {
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    itemCount: state.chats.length,
                    itemBuilder: (context, index) {
                      final chat = state.chats[index];
                      return _buildChatItem(context, chat);
                    },
                  );
                },
              ),
            ),
          );
        }
        else {

          return ElevatedButton(onPressed: () {
            context.read<ChatBloc>().add(LoadChats());

          },child: Text(state.toString()));
      }}
    );
  }

  Widget _buildChatItem(BuildContext context, Chat chat) {
    return ListTile(
      leading: CircleAvatar(
        // Use a default avatar if avatarUrl is empty
        backgroundImage: chat.avatarUrl.isNotEmpty
            ? NetworkImage(chat.avatarUrl)
            : null,
        child: chat.avatarUrl.isEmpty
            ? Text(chat.userName.isNotEmpty ? chat.userName[0].toUpperCase() : '?')
            : null,
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
              _formatTimestamp(chat.timestamp),
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
      onTap: ()async {
       await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              otherUserId: chat.partnerId,
              currentUserId: UserModel().id,
              apiBaseUrl: "http://10.0.2.2:300/api",
              otherUserAvatar: chat.avatarUrl,
              otherUserName: chat.userName,
            ),
          ),
        );

      },
    );
  }

  // Helper method to format timestamp in a user-friendly way
  String _formatTimestamp(String timestamp) {
    try {
      final DateTime dateTime = DateTime.parse(timestamp);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        // Today - show time
        return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
      } else if (difference.inDays == 1) {
        return "Yesterday";
      } else if (difference.inDays < 7) {
        return "${difference.inDays} days ago";
      } else {
        // More than a week ago - show date
        return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
      }
    } catch (e) {
      // If timestamp can't be parsed, return it as is
      return timestamp;
    }
  }
}