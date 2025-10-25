import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tour_ease/components/profileAvatar.dart';
import 'package:tour_ease/controller/question/commets/comments_bloc.dart';
import 'package:tour_ease/controller/report/report_bloc.dart';
import 'package:tour_ease/controller/report/report_event.dart';
import 'package:tour_ease/controller/report/report_state.dart';
import 'package:tour_ease/model/report/reportModel.dart';
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
      final currentUser = UserModel();

      context.read<CommentsBloc>().add(PostComment(CommentModel(
          id: DateTime.now().millisecondsSinceEpoch.toInt(),
          questionId: widget.question.id!,
          content: commentText,
          createdAt: DateTime.now(),
          user: OtherUserModel(
              mediaUrls: [],
              userid: currentUser.id,
              userName: currentUser.username))));

      _commentController.clear();
      FocusScope.of(context).unfocus();
      
      // Don't show immediate success message, let the state handle it
      // _fetchComments(); // Removed to avoid unnecessary API call
      // context.read<QuestionBloc>().add(FetchQuestions()); // Only update if needed
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Comment cannot be empty.'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        ),
      );
    }
  }

  void _showReportQuestionBottomSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String? reportReason;
    final descriptionController = TextEditingController();
    final List<String> reportReasons = [
      'Spam or Advertisement',
      'Inappropriate or Offensive Content',
      'Off-Topic or Irrelevant',
      'Plagiarism',
      'Other'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
            left: 24.w,
            right: 24.w,
            top: 24.h,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report Question',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.h),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Reason for reporting',
                    border: OutlineInputBorder(),
                  ),
                  value: reportReason,
                  items: reportReasons.map((String reason) {
                    return DropdownMenuItem<String>(
                      value: reason,
                      child: Text(reason),
                    );
                  }).toList(),
                  onChanged: (newValue) =>
                      setState(() => reportReason = newValue),
                  validator: (value) =>
                  value == null ? 'Please select a reason' : null,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Provide more details...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please provide a description.';
                    }
                    if (value.length < 10) {
                      return 'Description must be at least 10 characters long.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.h),
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final report = Report(
                        reportableType: 'QUESTION',
                        reportReason: reportReason!,
                        description: descriptionController.text,
                        reporterId: UserModel().id,
                        questionId: widget.question.id,
                      );

                      context.read<ReportBloc>().add(PostReport(report: report));
                      Navigator.pop(bottomSheetContext);
                    }
                  },
                  child: const Text('Submit Report'),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        );
      },
    );
  }

  // NEW: Method to show the report submission form for a comment
  void _showReportCommentBottomSheet(
      BuildContext context, CommentModel comment) {
    final formKey = GlobalKey<FormState>();
    String? reportReason;
    final descriptionController = TextEditingController();
    final List<String> reportReasons = [
      'Spam',
      'Inappropriate or Offensive',
      'Harassment',
      'Other'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
            left: 24.w,
            right: 24.w,
            top: 24.h,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report Comment',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.h),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Reason for reporting',
                    border: OutlineInputBorder(),
                  ),
                  value: reportReason,
                  items: reportReasons.map((String reason) {
                    return DropdownMenuItem<String>(
                      value: reason,
                      child: Text(reason),
                    );
                  }).toList(),
                  onChanged: (newValue) =>
                      setState(() => reportReason = newValue),
                  validator: (value) =>
                  value == null ? 'Please select a reason' : null,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Provide more details...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please provide a description.';
                    }
                    if (value.length < 10) {
                      return 'Description must be at least 10 characters long.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.h),
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final report = Report(
                        reportableType: 'COMMENT',
                        reportReason: reportReason!,
                        description: descriptionController.text,
                        reporterId: UserModel().id,
                        commentId: comment.id,
                      );
                      context.read<ReportBloc>().add(PostReport(report: report));
                      Navigator.pop(bottomSheetContext);
                    }
                  },
                  child: const Text('Submit Report'),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return MultiBlocListener(
      listeners: [
        BlocListener<ReportBloc, ReportState>(
          listener: (context, state) {
            if (state is ReportPostSuccess) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: const Text('Report submitted successfully!'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                );
            } else if (state is ReportLoadFailure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text('Failed to submit report: ${state.error}'),
                    backgroundColor: theme.colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                );
            } else if (state is ReportLoadInProgress) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: const Text('Submitting report...'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                );
            }
          },
        ),
        BlocListener<CommentsBloc, CommentsState>(
          listener: (context, state) {
            if (state is CommentsPostError) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(state.error),
                    backgroundColor: theme.colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    action: SnackBarAction(
                      label: 'Retry',
                      onPressed: () => _postComment(),
                      textColor: Colors.white,
                    ),
                  ),
                );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: const Text("Question Details"),
          scrolledUnderElevation: 0,
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          elevation: 0,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            _fetchComments();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      Row(
                        children: [
                          Icon(
                            Icons.forum_rounded,
                            size: 20.sp,
                            color: theme.colorScheme.primary,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '${widget.question.commentCount} Comment${widget.question.commentCount == 1 ? '' : 's'}',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      BlocBuilder<CommentsBloc, CommentsState>(
                        builder: (context, state) {
                          return _buildCommentList(state, theme);
                        },
                      ),
                      SizedBox(height: 16.h),
                      _buildCommentInput(theme),
                    ],
                  ),
                ),
                // Add bottom padding for better UX
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final bool isOwner = widget.question.userId == UserModel().id;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildUserInfo(theme)),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => QuestionEditingPage(
                                    question: widget.question)));
                      } else if (value == 'report') {
                        _showReportQuestionBottomSheet(context);
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<String>>[
                      if (isOwner)
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit_rounded, color: colorScheme.primary),
                            title: const Text('Edit'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      if (!isOwner)
                        PopupMenuItem<String>(
                          value: 'report',
                          child: ListTile(
                            leading: Icon(Icons.flag_rounded, color: colorScheme.error),
                            title: const Text('Report Question'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                    ],
                    icon: Icon(Icons.more_vert_rounded,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.8)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Hero(
              tag: 'title_${widget.question.id}',
              child: Material(
                type: MaterialType.transparency,
                child: Text(
                  widget.question.title,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    height: 1.3,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                widget.question.description,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
            ),
            if (widget.question.tags.isNotEmpty) ...[
              SizedBox(height: 20.h),
              _buildTagsSection(theme),
            ],
            SizedBox(height: 24.h),
            Container(
              height: 1.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.outline.withOpacity(0.1),
                    colorScheme.outline.withOpacity(0.3),
                    colorScheme.outline.withOpacity(0.1),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            _buildInfoRow(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(ThemeData theme) {
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final userName = widget.question.userName;
    final userImage =
    widget.question.mediaUrls.isNotEmpty ? widget.question.mediaUrls[0] : null;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Hero(
            tag: 'avatar_${widget.question.id}',
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: ProfileAvatar(
                  userId: widget.question.userId,
                  imageURL: userImage,
                  userName: userName ?? '?',
                  radius: 24.r),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName ?? 'Anonymous',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 14.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Posted ${DateFormat.yMMMd().format(widget.question.createdAt!)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.local_offer_rounded,
              size: 16.sp,
              color: colorScheme.primary,
            ),
            SizedBox(width: 8.w),
            Text(
              'Tags',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: widget.question.tags
              .map((tag) => Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.primaryContainer.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              tag,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildInfoRow(ThemeData theme) {
    final color = theme.colorScheme.onSurfaceVariant.withOpacity(0.8);
    final style = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.bold,
      color: color,
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.thumb_up_rounded,
            value: widget.question.upvotes,
            color: theme.colorScheme.primary,
            style: style,
          ),
          Container(
            width: 1.w,
            height: 24.h,
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
          _buildStatItem(
            icon: Icons.thumb_down_rounded,
            value: widget.question.downvotes,
            color: theme.colorScheme.error,
            style: style,
          ),
          Container(
            width: 1.w,
            height: 24.h,
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
          _buildStatItem(
            icon: Icons.forum_rounded,
            value: widget.question.commentCount,
            color: theme.colorScheme.tertiary,
            style: style,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required int? value,
    required Color color,
    required TextStyle? style,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18.sp, color: color),
        SizedBox(width: 6.w),
        Text('${value ?? 0}', style: style),
      ],
    );
  }

  Widget _buildCommentList(CommentsState state, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    if (state is CommentsInitial || state is CommentsLoading) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: colorScheme.primary),
              SizedBox(height: 16.h),
              Text(
                'Loading comments...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state is CommentsPosting) {
      // Show existing comments with a posting indicator
      return Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            margin: EdgeInsets.only(bottom: 8.h),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 16.w,
                  height: 16.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Posting your comment...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          _buildCommentListContent(state.comments, theme),
        ],
      );
    }

    if (state is CommentsError || state is CommentsPostError) {
      final error = state is CommentsError ? state.error : (state as CommentsPostError).error;
      return Center(
        child: Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48.sp,
                color: colorScheme.error,
              ),
              SizedBox(height: 16.h),
              Text(
                'Error loading comments',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                error,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                onPressed: () => _fetchComments(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is CommentsLoaded && state.comments.isEmpty) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(48.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 64.sp,
                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              SizedBox(height: 16.h),
              Text(
                'No comments yet',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Be the first to comment!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state is CommentsLoaded) {
      return _buildCommentListContent(state.comments, theme);
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildCommentListContent(List<CommentModel> comments, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return Container(
      constraints: BoxConstraints(maxHeight: 400.h),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(8.w),
        itemCount: comments.length,
        separatorBuilder: (context, index) => Divider(
          height: 16.h,
          color: colorScheme.outlineVariant.withOpacity(0.2),
          indent: 16.w,
          endIndent: 16.w,
        ),
        itemBuilder: (context, index) {
          final comment = comments[index];
          return _buildCommentCard(comment, theme);
        },
      ),
    );
  }

  Widget _buildCommentCard(CommentModel comment, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final isCurrentUser = comment.user.userid == UserModel().id;
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isCurrentUser 
          ? colorScheme.primaryContainer.withOpacity(0.3)
          : colorScheme.surfaceContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isCurrentUser 
            ? colorScheme.primary.withOpacity(0.2)
            : colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: ProfileAvatar(
              imageURL: comment.user.mediaUrls.isNotEmpty
                  ? comment.user.mediaUrls.first
                  : null,
              userName: comment.user.userName.isNotEmpty ? comment.user.userName : '?',
              radius: 20.r,
              userId: comment.user.userid,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        comment.user.userName.isNotEmpty ? comment.user.userName : 'Anonymous',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isCurrentUser 
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (isCurrentUser)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'You',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 12.sp,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      DateFormat.yMMMd().add_jm().format(comment.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  width: double.infinity,
                  child: Text(
                    comment.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Report button for non-current user comments
          if (!isCurrentUser)
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'report') {
                    _showReportCommentBottomSheet(context, comment);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'report',
                    child: ListTile(
                      leading: Icon(Icons.flag_rounded, color: colorScheme.error),
                      title: const Text('Report Comment'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: 18.sp,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return BlocBuilder<CommentsBloc, CommentsState>(
      builder: (context, state) {
        final isPosting = state is CommentsPosting;
        
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: ProfileAvatar(
                      userId: UserModel().id,
                      imageURL: null, // Current user avatar
                      userName: UserModel().username.isNotEmpty ? UserModel().username : 'You',
                      radius: 18.r,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      maxLines: null,
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      enabled: !isPosting,
                      decoration: InputDecoration(
                        hintText: isPosting ? 'Posting comment...' : 'Write a thoughtful comment...',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                        ),
                        filled: true,
                        fillColor: colorScheme.surface.withOpacity(0.7),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12.h,
                          horizontal: 16.w,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(
                            color: colorScheme.primary.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                      ),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: isPosting ? null : _postComment,
                      icon: isPosting
                          ? SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : Icon(
                              Icons.send_rounded,
                              color: colorScheme.onPrimary,
                              size: 20.sp,
                            ),
                      tooltip: isPosting ? 'Posting...' : 'Post Comment',
                    ),
                  ),
                ],
              ),
              if (isPosting) ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 14.w,
                        height: 14.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Posting your comment...',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

