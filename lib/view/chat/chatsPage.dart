import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tour_ease/components/profileAvatar.dart';
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
    return Scaffold(
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is ChatLoading) {
            return _buildLoadingShimmer();
          }
          if (state is ChatsLoaded) {
            if (state.chats.isEmpty) {
              return Center(
                child: Text(
                  'No messages yet.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }
            return _buildChatList(state.chats);
          }
          // Fallback state
          return Center(
            child: TextButton(
              onPressed: () => context.read<ChatBloc>().add(LoadChats()),
              child: const Text('Tap to retry'),
            ),
          );
        },
      ),
    );
  }

  /// Builds the list of chats with a subtle fade-in animation.
  Widget _buildChatList(List<Chat> chats) {
    return AnimationLimiter(
      child: ListView.builder(
        // Use padding for spacing instead of dividers for a cleaner look
        padding: EdgeInsets.symmetric(vertical: 8.h),
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 250), // Faster animation
            child: FadeInAnimation( // Simplified to just a fade
              child: _buildChatItem(context, chat),
            ),
          );
        },
      ),
    );
  }

  /// Builds a single, refined chat list item with a focus on typography.
  Widget _buildChatItem(BuildContext context, Chat chat) {
    final theme = Theme.of(context);
    final isUnread = chat.isUnread;

    return InkWell(
      onTap: () async {
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
        context.read<ChatBloc>().add(LoadChats());
      },
      // Give the InkWell some padding to increase tap area and visual spacing
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            ProfileAvatar(imageURL: chat.avatarUrl, userName: chat.userName, radius: 28.r, userId: chat.partnerId,),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.userName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      // Use font weight as the primary indicator for unread state
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      // Use opacity to de-emphasize read messages
                      color: theme.colorScheme.onSurface.withOpacity(isUnread ? 0.9 : 0.6),
                      fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTimestamp(chat.timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                SizedBox(height: 8.h),
                // The unread dot is now the main color accent
                if (isUnread)
                  Container(
                    height: 8.r,
                    width: 8.r,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                // Placeholder to maintain alignment
                  SizedBox(height: 8.r, width: 8.r),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the shimmer loading placeholder widget (still very effective).
  Widget _buildLoadingShimmer() {
    final theme = Theme.of(context);
    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
      highlightColor: theme.colorScheme.surface.withOpacity(0.5),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        itemCount: 8,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(radius: 28.r, backgroundColor: Colors.white),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 150.w, height: 16.h, color: Colors.white),
                    SizedBox(height: 8.h),
                    Container(width: double.infinity, height: 14.h, color: Colors.white),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to format timestamp (unchanged)
  String _formatTimestamp(String timestamp) {
    try {
      final DateTime dateTime = DateTime.parse(timestamp);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
      } else if (difference.inDays == 1) {
        return "Yesterday";
      } else {
        return "${dateTime.day}/${dateTime.month}";
      }
    } catch (e) {
      return timestamp;
    }
  }
}