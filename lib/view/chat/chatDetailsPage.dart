import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// We no longer need the old ChatBloc here, only the new MessagesBloc
import 'package:tour_ease/controller/chat/messages_bloc.dart';
import 'package:tour_ease/model/chat/message.dart';

class ChatPage extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final String apiBaseUrl; // This might not be needed if your ChatService handles it
  final String otherUserName;
  final String otherUserAvatar;

  const ChatPage({
    Key? key,
    required this.currentUserId,
    required this.otherUserId,
    required this.apiBaseUrl,
    required this.otherUserName,
    required this.otherUserAvatar,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Dispatch the event to load initial messages
    context.read<MessagesBloc>().add(LoadMessages(otherUserId: widget.otherUserId));
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    // FIXED: Use named parameters for the event as defined in messages_event.dart
    context.read<MessagesBloc>().add(SendMessage(
      content: content,
      receiverId: widget.otherUserId,
    ));

    _messageController.clear();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // You can add back the CircleAvatar if you have the image URL
            // CircleAvatar(
            //   backgroundImage: NetworkImage(widget.otherUserAvatar),
            // ),
            SizedBox(width: 8.w),
            Text(widget.otherUserName),
          ],
        ),
        elevation: 1,
      ),
      // Use BlocConsumer to both rebuild the UI and listen for side-effects
      body: BlocConsumer<MessagesBloc, MessagesState>(
        listener: (context, state) {
          // Scroll to bottom every time the list of messages is successfully updated
          if (state is MessagesLoaded) {
            Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
          }
          // Show an error message if something goes wrong
          if (state is MessagesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: _buildMessagesList(state),
              ),
              _buildMessageInputField(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessagesList(MessagesState state) {
    // The builder's logic is now much cleaner
    if (state is MessagesLoaded) {
      if (state.messages.isEmpty) {
        return const Center(child: Text('No messages yet. Start the conversation!'));
      }
      return ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        itemCount: state.messages.length,
        itemBuilder: (context, index) {
          final message = state.messages[index];
          return _buildMessageBubble(context, message);
        },
      );
    } else if (state is MessagesLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is MessagesError) {
      return Center(child: Text('Error: ${state.message}'));
    } else {
      // For MessagesInitial state
      return const Center(child: Text('Loading chat...'));
    }
  }

  Widget _buildMessageBubble(BuildContext context, Message message) {
    final theme = Theme.of(context);
    final isMe = message.senderId == widget.currentUserId;

    // MAJOR FIX: Parse the message's actual timestamp, don't use DateTime.now()
    // Use tryParse for safety against malformed date strings.
    final timestamp = DateTime.tryParse(message.createdAt) ?? DateTime.now();
    final now = DateTime.now();
    String formattedTime;

    if (timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day) {
      // Today: Show only time (e.g., 17:11)
      formattedTime = "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}";
    } else {
      // Not today: Show date and time (e.g., 31/8 17:11)
      formattedTime =
      "${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}";
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        // ... (rest of your styling is good)
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: isMe
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isMe
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              formattedTime,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isMe
                    ? theme.colorScheme.onPrimary.withOpacity(0.7)
                    : theme.colorScheme.onSurface.withOpacity(0.6),
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // No changes needed here, this part is perfect.
  Widget _buildMessageInputField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              // ... styling
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            // ... styling
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send),
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}