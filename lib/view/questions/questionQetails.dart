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
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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
          id: 000,
          questionId: widget.question.id!,
          content: commentText,
          createdAt: DateTime.now(),
          user: OtherUserModel(
              mediaUrls: [],
              userid: UserModel().id,
              userName: UserModel().username))));
      _commentController.clear();
      _fetchComments();

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment cannot be empty.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: Text(
          "Question Details",
          style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onPrimary, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16.r),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuestionCard(theme),
            SizedBox(height: 24.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.question.commentCount} Comment${widget.question.commentCount == 1 ? '' : 's'}',
                  style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 20.sp,
                      color: colorScheme.onSurface),
                ),
                SizedBox(height: 16.h),
                BlocBuilder<CommentsBloc, CommentsState>(
                  builder: (context, state) {
                    return _buildCommentList(state, theme, _fetchComments);
                  },
                ),
                _buildCommentInput(theme),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.08),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserInfo(theme),
              SizedBox(height: 16.h),
              Text(
                widget.question.title,
                style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 12.h),
              Text(
                widget.question.description,
                style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.85), height: 1.5),
              ),
              if (widget.question.tags.isNotEmpty) ...[
                SizedBox(height: 16.h),
                _buildTagsSection(theme),
              ],
              SizedBox(height: 20.h),
              Divider(
                  height: 1.h, color: colorScheme.outlineVariant.withOpacity(0.5)),
              SizedBox(height: 12.h),
              _buildInfoRow(theme),
            ],
          ),
        ),
        Positioned(
          top: 16.w,
          right: 16.w,
          child: widget.question.userId == UserModel().id ? IconButton(onPressed:() {
Navigator.push(context, MaterialPageRoute(builder: (context) => QuestionEditingPage(question: widget.question,),));
          },icon: Icon(Icons.edit , size: 20.w, ),
            color: colorScheme.onSurface.withOpacity(0.6),

          ) : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildUserInfo(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final userName = widget.question.userName;
    final userImage = widget.question.mediaUrls[0];
    final formattedDate =
        DateFormat('MMM d, yyyy').format(widget.question.createdAt!);
    final formattedTime =
        DateFormat('h:mm a').format(widget.question.createdAt!);

    return Row(
      children: [
        ProfileAvatar(imageURL: userImage, userName: userName!, radius: 20.r),

        // CircleAvatar(
        //   radius: 20.r,
        //   backgroundColor: colorScheme.primaryContainer,
        //   child:  userImage.isEmpty ? Text(
        //     userName != null && userName.isNotEmpty
        //         ? userName[0].toUpperCase()
        //         : '?',
        //     style: textTheme.titleMedium
        //         ?.copyWith(color: colorScheme.onPrimaryContainer),
        //   ) : Image.network( userImage),
        // ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName!,
                style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Posted on $formattedDate at $formattedTime',
                style: textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Wrap(
      spacing: 8.w,
      runSpacing: 4.h,
      children: widget.question.tags
          .map((tag) => Chip(
                label: Text(tag),
                labelStyle:
                    textTheme.labelSmall?.copyWith(color: colorScheme.primary),
                backgroundColor:
                    colorScheme.primary.withOpacity(0.15), // Slightly darker
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.symmetric(
                    horizontal: 10.w, vertical: 4.h), // Slightly more padding
                side: BorderSide.none,
              ))
          .toList(),
    );
  }

  Widget _buildInfoRow(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(Icons.arrow_upward,
            size: 20.w, color: colorScheme.onSurfaceVariant),
        SizedBox(width: 8.w),
        Text(
          '${widget.question.upvotes}',
          style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant), // More prominent
        ),
        SizedBox(width: 24.w),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_downward,
                size: 20.w, color: colorScheme.onSurfaceVariant),
            SizedBox(width: 8.w),
            Text(
              '${widget.question.downvotes}',
              style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600), // More prominent
            ),
          ],
        ),
        const Spacer(),
        Icon(Icons.comment, size: 20.w, color: colorScheme.onSurfaceVariant),
        SizedBox(width: 8.w),
        Text(
          '${widget.question.commentCount}',
          style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant), // More prominent
        ),
      ],
    );
  }

  Widget _buildCommentList(
      CommentsState state, ThemeData theme, void Function() refreshQuestions) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (state is CommentsInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is CommentsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is CommentsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.error}',
                style: textTheme.bodyLarge?.copyWith(color: colorScheme.error)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: refreshQuestions,
              style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary),
              child: Text('Retry',
                  style: textTheme.labelLarge
                      ?.copyWith(color: colorScheme.onPrimary)),
            ),
          ],
        ),
      );
    }

    if (state is CommentsLoaded && state.comments.isEmpty) {
      return Center(
          child: Text('No comments yet. Be the first to comment!',
              style: textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant)));
    }

    return Container(height: 300.h,
      child: ListView.separated(

        shrinkWrap: true,
        padding: EdgeInsets.only(top: 8.h),
        itemCount: state is CommentsLoaded ? state.comments.length : 0,
        separatorBuilder: (context, index) => Divider(
            height: 1.h, color: colorScheme.outlineVariant.withOpacity(0.3)),
        itemBuilder: (context, index) {
          if (state is CommentsLoaded) {
            final comment = state.comments[index];
            return _buildCommentCard(comment, theme);
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildCommentCard(CommentModel comment, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final commentUserAvatar = comment.user.mediaUrls;

    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: 12.h, horizontal: 16.w), // Increased vertical padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileAvatar(imageURL: commentUserAvatar.first, userName: comment.user.userName, radius: 22.r)

          // CircleAvatar(
          //
          //   radius: 22.r, // Slightly larger avatar
          //   backgroundColor: colorScheme.primaryContainer,
          //   backgroundImage: commentUserAvatar.isNotEmpty ? NetworkImage(commentUserAvatar[0]) : null ,
          //   child: commentUserAvatar.isEmpty ? Text(
          //     comment.user.userName != null && comment.user.userName!.isNotEmpty
          //         ? comment.user.userName![0].toUpperCase()
          //         : '?',
          //     style: textTheme.titleMedium
          //         ?.copyWith(color: colorScheme.onPrimaryContainer),
          //   ):  null,
          // ),
          ,SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.user.userName ?? 'Anonymous',
                  style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface),
                ),
                SizedBox(height: 4.h),
                Text(
                  DateFormat('MMM d, yyyy \'at\' h:mm a')
                      .format(comment.createdAt), // More readable format
                  style: textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                SizedBox(height: 8.h),
                Text(
                  comment.content,
                  style: textTheme.bodyMedium
                      ?.copyWith(color: colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
      decoration: BoxDecoration(
        color: colorScheme
            .surface, // Use the surface color for a subtle background
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
            color: colorScheme.outlineVariant
                .withOpacity(0.2)), // Very light border
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              maxLines: 3,
              style:
                  textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                hintStyle: textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
                border: InputBorder.none,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
                enabledBorder: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.h, horizontal: 0),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          InkWell(
            onTap: _postComment,
            borderRadius: BorderRadius.circular(24.r),
            child: Padding(
              padding: EdgeInsets.all(10.w),
              child: Icon(
                Icons.send,
                color: colorScheme.primary,
                size: 24.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
