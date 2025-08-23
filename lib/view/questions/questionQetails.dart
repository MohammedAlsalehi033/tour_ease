import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tour_ease/components/profileAvatar.dart';
import 'package:tour_ease/controller/question/commets/comments_bloc.dart';
import 'package:tour_ease/controller/question/questionBloc.dart';
import 'package:tour_ease/model/userManagment/user.dart';
import 'package:tour_ease/model/otherUser/otherUserModel.dart';
import 'package:tour_ease/model/question/comments/commentModel.dart';
import 'package:tour_ease/model/question/questionModel.dart';
import 'package:tour_ease/view/questions/questionEditing.dart';

class QuestionDetailsPage extends StatefulWidget {
  final Question question;

  const QuestionDetailsPage({super.key, required this.question});

  @override
  State<QuestionDetailsPage> createState() => _QuestionDetailsPageState();
}

class _QuestionDetailsPageState extends State<QuestionDetailsPage> {
  // --- ALL LOGIC IS UNCHANGED ---
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  void _fetchComments({bool refresh = true}) {
    context.read<CommentsBloc>().add(FetchComments(
      page: 1,
      question: widget.question,
      limit: 10,
      refresh: refresh,
      sort: 'newest',
    ));
  }

  void _postComment() async {
    final commentText = _commentController.text.trim();
    if (commentText.isNotEmpty) {
      context.read<CommentsBloc>().add(PostComment(CommentModel(
          id: DateTime.now().millisecondsSinceEpoch.toInt(),
          questionId: widget.question.id!,
          content: commentText,
          createdAt: DateTime.now(),
          user: OtherUserModel(
              mediaUrls: [],
              userid: UserModel().id,
              userName: UserModel().username))));
      _commentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment posted successfully.')),
      );

      _fetchComments();
      context.read<QuestionBloc>().add(FetchQuestions());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment cannot be empty.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      // DESIGN: A cleaner, more standard AppBar.
      appBar: AppBar(
        title: const Text("Details"),
        scrolledUnderElevation: 2.0, // Subtle shadow on scroll
        shadowColor: theme.shadowColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // DESIGN: Added horizontal padding to the card itself for better spacing from screen edges.
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _buildQuestionCard(theme),
            ),
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.question.commentCount} Comment${widget.question.commentCount == 1 ? '' : 's'}',
                    // DESIGN: Aligned typography with modern standards.
                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.h),
                  BlocBuilder<CommentsBloc, CommentsState>(
                    builder: (context, state) {
                      return _buildCommentList(state, theme, _fetchComments);
                    },
                  ),
                  SizedBox(height: 16.h),
                  _buildCommentInput(theme),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      // DESIGN: Using Card for better semantics and consistent styling.
      elevation: 2.0,
      shadowColor: colorScheme.shadow.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildUserInfo(theme)),
                if (widget.question.userId == UserModel().id)
                // DESIGN: Using a more standard IconButton for the edit action.
                  IconButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => QuestionEditingPage(question: widget.question)));
                    },
                    icon: Icon(Icons.edit_note_rounded, color: colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              widget.question.title,
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            Text(
              widget.question.description,
              style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.5),
            ),
            if (widget.question.tags.isNotEmpty) ...[
              SizedBox(height: 16.h),
              _buildTagsSection(theme),
            ],
            SizedBox(height: 20.h),
            Divider(color: colorScheme.outlineVariant.withOpacity(0.5)),
            SizedBox(height: 8.h),
            _buildInfoRow(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(ThemeData theme) {
    final textTheme = theme.textTheme;
    final userName = widget.question.userName;
    final userImage = widget.question.mediaUrls.isNotEmpty ? widget.question.mediaUrls[0] : null;

    return Row(
      children: [
        ProfileAvatar(userId: widget.question.userId,imageURL: userImage, userName: userName ?? '?', radius: 22.r),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userName ?? 'Anonymous', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              // DESIGN: Slightly more readable date format and subtle style.
              Text(
                'Posted ${DateFormat.yMMMd().format(widget.question.createdAt!)}',
                style: textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection(ThemeData theme) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h, // DESIGN: Increased vertical spacing for wrapped tags.
      children: widget.question.tags.map((tag) => Chip(
        label: Text(tag),
        // DESIGN: Using theme colors for a more cohesive look.
        labelStyle: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary),
        backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.4),
        side: BorderSide.none,
      )).toList(),
    );
  }

  Widget _buildInfoRow(ThemeData theme) {
    final color = theme.colorScheme.onSurfaceVariant;
    final style = theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: color);

    // DESIGN: Using MainAxisAlignment.spaceAround for more robust and even spacing.
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.thumb_up_alt_outlined, size: 18.sp, color: color),
          SizedBox(width: 8.w),
          Text('${widget.question.upvotes}', style: style),
        ]),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.thumb_down_alt_outlined, size: 18.sp, color: color),
          SizedBox(width: 8.w),
          Text('${widget.question.downvotes}', style: style),
        ]),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.mode_comment_outlined, size: 18.sp, color: color),
          SizedBox(width: 8.w),
          Text('${widget.question.commentCount}', style: style),
        ]),
      ],
    );
  }

  Widget _buildCommentList(CommentsState state, ThemeData theme, void Function() refreshQuestions) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (state is CommentsInitial || state is CommentsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is CommentsError) {
      return Center(child: Text('Error: ${state.error}'));
    }

    if (state is CommentsLoaded && state.comments.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48.0),
          child: Text('Be the first to comment!'),
        ),
      );
    }

    // Original Structure Unchanged: Fixed-height container with a ListView
    return Container(
      height: 300.h,
      decoration: BoxDecoration(
        // DESIGN: Added a subtle background color to the comment list area.
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: state is CommentsLoaded ? state.comments.length : 0,
        separatorBuilder: (context, index) => Divider(
            height: 1.h,
            color: colorScheme.outlineVariant.withOpacity(0.3),
            indent: 16.w, // DESIGN: Indent divider
            endIndent: 16.w),
        itemBuilder: (context, index) {
          if (state is CommentsLoaded) {
            final comment = state.comments[index];
            return _buildCommentCard(comment, theme);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCommentCard(CommentModel comment, ThemeData theme) {
    return Padding(
      // DESIGN: Refined padding for better alignment and breathing room.
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileAvatar(
            imageURL: comment.user.mediaUrls.isNotEmpty ? comment.user.mediaUrls.first : null,
            userName: comment.user.userName ?? '?',
            radius: 20.r,
            userId: comment.user.userid,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.user.userName ?? 'Anonymous',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.h),
                Text(
                  DateFormat.yMMMd().format(comment.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                SizedBox(height: 8.h),
                Text(comment.content, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(ThemeData theme) {
    // DESIGN: A complete visual overhaul of the comment input field for a modern look.
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _commentController,
            maxLines: null, // Allows field to grow
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              hintText: 'Add a comment...',
              filled: true,
              fillColor: theme.colorScheme.surfaceContainer,
              contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        IconButton.filled(
          style: IconButton.styleFrom(backgroundColor: theme.colorScheme.primary),
          onPressed: _postComment,
          icon: Icon(Icons.send_rounded, color: theme.colorScheme.onPrimary),
          tooltip: 'Post Comment',
        ),
      ],
    );
  }
}