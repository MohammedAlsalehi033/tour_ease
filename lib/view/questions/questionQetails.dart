import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tour_ease/components/profileAvatar.dart';
import 'package:tour_ease/controller/question/commets/comments_bloc.dart';
import 'package:tour_ease/controller/question/questionBloc.dart';
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

    return BlocListener<ReportBloc, ReportState>(
      listener: (context, state) {
        if (state is ReportPostSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Report submitted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
        } else if (state is ReportLoadFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('Failed to submit report: ${state.error}'),
                backgroundColor: theme.colorScheme.error,
              ),
            );
        } else if (state is ReportLoadInProgress) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Submitting report...')),
            );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Details"),
          scrolledUnderElevation: 2.0,
          shadowColor: theme.shadowColor,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 16.h),
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
                    Text(
                      '${widget.question.commentCount} Comment${widget.question.commentCount == 1 ? '' : 's'}',
                      style: textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.h),
                    BlocBuilder<CommentsBloc, CommentsState>(
                      builder: (context, state) {
                        return _buildCommentList(state, theme);
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
      ),
    );
  }

  Widget _buildQuestionCard(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final bool isOwner = widget.question.userId == UserModel().id;

    return Card(
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
                PopupMenuButton<String>(
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
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit_note_rounded),
                          title: Text('Edit'),
                        ),
                      ),
                    if (!isOwner)
                      const PopupMenuItem<String>(
                        value: 'report',
                        child: ListTile(
                          leading: Icon(Icons.flag_outlined),
                          title: Text('Report Question'),
                        ),
                      ),
                  ],
                  icon: Icon(Icons.more_vert,
                      color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Hero(
              tag: 'title_${widget.question.id}',
              child: Material(
                type: MaterialType.transparency,
                child: Text(
                  widget.question.title,
                  style: textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              widget.question.description,
              style: textTheme.bodyLarge
                  ?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.5),
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
    final userImage =
    widget.question.mediaUrls.isNotEmpty ? widget.question.mediaUrls[0] : null;

    return Row(
      children: [
        Hero(
          tag: 'avatar_${widget.question.id}',
          child: ProfileAvatar(
              userId: widget.question.userId,
              imageURL: userImage,
              userName: userName ?? '?',
              radius: 22.r),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userName ?? 'Anonymous',
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text(
                'Posted ${DateFormat.yMMMd().format(widget.question.createdAt!)}',
                style: textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
      runSpacing: 8.h,
      children: widget.question.tags
          .map((tag) => Chip(
        label: Text(tag),
        labelStyle: theme.textTheme.labelMedium
            ?.copyWith(color: theme.colorScheme.primary),
        backgroundColor:
        theme.colorScheme.primaryContainer.withOpacity(0.4),
        side: BorderSide.none,
      ))
          .toList(),
    );
  }

  Widget _buildInfoRow(ThemeData theme) {
    final color = theme.colorScheme.onSurfaceVariant;
    final style =
    theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: color);

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

  Widget _buildCommentList(CommentsState state, ThemeData theme) {
    final colorScheme = theme.colorScheme;

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

    if (state is CommentsLoaded) {
      return Container(
        constraints: BoxConstraints(maxHeight: 400.h),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: state.comments.length,
          separatorBuilder: (context, index) => Divider(
              height: 1.h,
              color: colorScheme.outlineVariant.withOpacity(0.3),
              indent: 16.w,
              endIndent: 16.w),
          itemBuilder: (context, index) {
            final comment = state.comments[index];
            return _buildCommentCard(comment, theme);
          },
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildCommentCard(CommentModel comment, ThemeData theme) {
    // UPDATED: Added a Row to contain the original content and the new menu button.
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileAvatar(
                  imageURL: comment.user.mediaUrls.isNotEmpty
                      ? comment.user.mediaUrls.first
                      : null,
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
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        DateFormat.yMMMd().format(comment.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                      SizedBox(height: 8.h),
                      Text(comment.content, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // NEW: PopupMenuButton for reporting comments.
          if (comment.user.userid != UserModel().id) // Users can't report their own comments
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'report') {
                  _showReportCommentBottomSheet(context, comment);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'report',
                  child: ListTile(
                    leading: Icon(Icons.flag_outlined),
                    title: Text('Report Comment'),
                  ),
                ),
              ],
              icon: Icon(Icons.more_vert,
                  size: 20.sp,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7)),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _commentController,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              hintText: 'Add a comment...',
              filled: true,
              fillColor: theme.colorScheme.surfaceContainer,
              contentPadding:
              EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        IconButton.filled(
          style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.primary),
          onPressed: _postComment,
          icon: Icon(Icons.send_rounded, color: theme.colorScheme.onPrimary),
          tooltip: 'Post Comment',
        ),
      ],
    );
  }
}

