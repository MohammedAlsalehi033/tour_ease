import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tour_ease/controller/chat/chat_bloc.dart';
import 'package:tour_ease/controller/chat/chat_event.dart';
import 'package:tour_ease/controller/chat/chat_state.dart';
import 'package:tour_ease/model/chat/chatRepo.dart';
import 'package:tour_ease/model/chat/message.dart';

class ChatPage extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final String apiBaseUrl;
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



    // Load messages
    context.read<ChatBloc>().add(LoadMessages(widget.otherUserId));
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    context.read<ChatBloc>().add(SendMessage(
      content: _messageController.text.trim(),
      receiverId: widget.otherUserId,
    ));

    _messageController.clear();

    // Scroll to bottom after a short delay to ensure the UI has updated
    Future.delayed(Duration(milliseconds: 100), _scrollToBottom);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
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

            SizedBox(width: 8.w),
            Text(widget.otherUserName),
          ],
        ),
        elevation: 1,
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatLoaded) {
            Future.delayed(Duration(milliseconds: 100), _scrollToBottom);
          }

          if (state is ChatError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Messages list
              Expanded(
                child: _buildMessagesList(state),
              ),

              // Message input
              _buildMessageInputField(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessagesList(ChatState state) {
    if (state is ChatLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (state is ChatError && (state is! ChatLoaded && state is! MessageSending)) {
      return Center(child: Text('Error: ${state.message}'));
    } else {
      List<Message> messages = [];

      if (state is ChatLoaded) {
        messages = state.messages;
      } else if (state is MessageSending) {
        messages = state.messages;
      }

      if (messages.isEmpty) {
        return Center(child: Text('No messages yet'));
      }

      return ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return _buildMessageBubble(context, message);
        },
      );
    }
  }

  Widget _buildMessageBubble(BuildContext context, Message message) {
    final theme = Theme.of(context);
    final isMe = message.senderId == widget.currentUserId;

    // Format timestamp
    final timestamp = DateTime.now();
    final now = DateTime.now();
    String formattedTime;

    if (timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day) {
      // Today, show only time
      formattedTime = "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}";
    } else {
      // Not today, show date and time
      formattedTime = "${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}";
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
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

  Widget _buildMessageInputField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
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
              icon: Icon(Icons.send),
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}