import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tour_ease/components/profileAvatar.dart';
import 'package:tour_ease/controller/question/questionBloc.dart';
import 'package:tour_ease/controller/question/votes/votes_bloc.dart';
import 'package:tour_ease/model/userManagment/user.dart';
import 'package:tour_ease/model/question/questionModel.dart';
import 'package:tour_ease/view/questions/questionMaking.dart';
import 'package:tour_ease/view/questions/questionQetails.dart';

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({super.key});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTag = "All";
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<QuestionBloc>().add(FetchQuestions());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<QuestionBloc>().add(FetchQuestions(
            sort: 'newest',
          ));
    }
  }

  void _refreshQuestions() {
    print(UserModel().id);
    context.read<QuestionBloc>().add(FetchQuestions(
          refresh: true,
          sort: 'newest',
        ));
  }

  List<Question> get filteredQuestions {
    final state = context.read<QuestionBloc>().state;
    List<Question> questions = [];

    if (state is QuestionLoadSuccess) {
      questions = state.questions;
    }

    if (_selectedTag == "All" && _searchController.text.isEmpty) {
      return questions;
    }

    return questions.where((question) {
      bool matchesTag =
          _selectedTag == "All" || question.tags.contains(_selectedTag);
      bool matchesSearch = _searchController.text.isEmpty ||
          question.title
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ||
          question.description
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());

      return matchesTag && matchesSearch;
    }).toList();
  }

  void _handleVote(Question question, String newVoteType) {
    final currentUserId = UserModel().id;

    setState(() {
      question.votes?.removeWhere((vote) => vote['userId'] == currentUserId);

      question.votes?.add({
        'userId': currentUserId,
        'type': newVoteType,
      });

      // Update counts
      if (newVoteType == 'UPVOTE') {
        question.upvotes = question.upvotes! + 1;
        if (question.downvotes! > 0)
          question.downvotes = question.downvotes! - 1;
      } else {
        question.downvotes = question.downvotes! + 1;
        if (question.upvotes! > 0) question.upvotes = question.upvotes! - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<QuestionBloc, QuestionState>(
          builder: (context, state) {
            return Column(
              children: [
                // Search Bar
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search questions...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceVariant,
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),

                // Tags Filter
                SizedBox(
                  height: 50.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    itemCount: _availableTags.length,
                    itemBuilder: (context, index) {
                      final tag = _availableTags[index];
                      final isSelected = tag == _selectedTag;

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: ChoiceChip(
                          label: Text(tag),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedTag = tag;
                              });
                            }
                          },
                          backgroundColor: Colors.transparent,
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withOpacity(0.3),
                            width: 0.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          selectedColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.8),
                            fontWeight:
                                isSelected ? FontWeight.w500 : FontWeight.w400,
                            fontSize: 14,
                          ),
                          elevation: 0,
                          pressElevation: 0,
                        ),
                      );
                    },
                  ),
                ),

                // Questions List
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => _refreshQuestions(),
                    child: _buildQuestionList(state),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuestionMakingPage(),
              ));
        },
        child: const Icon(Icons.add),
        tooltip: 'Ask a Question',
      ),
    );
  }

  Widget _buildQuestionList(QuestionState state) {
    if (state is QuestionInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is QuestionLoadInProgress) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is QuestionLoadFailure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshQuestions,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is QuestionLoadSuccess && filteredQuestions.isEmpty) {
      return const Center(child: Text('No questions found'));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.only(top: 8.h),
      itemCount: _calculateItemCount(state),
      itemBuilder: (context, index) {
        if (index >= filteredQuestions.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _buildQuestionItem(context, filteredQuestions[index]);
      },
    );
  }

  int _calculateItemCount(QuestionState state) {
    if (state is QuestionLoadSuccess) {
      return state.hasReachedMax
          ? filteredQuestions.length
          : filteredQuestions.length + 1;
    }
    return filteredQuestions.length;
  }


  Widget _buildQuestionItem(BuildContext context, Question question) {
    final bloc = BlocProvider.of<VotesBloc>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Safer way to get user vote type to avoid null errors
    final userVote = question.votes?.firstWhere(
          (vote) => vote['userId'] == UserModel().id,
      orElse: () => <String, dynamic>{},
    );
    final userVoteType = userVote?['type'];


    // Logic to generate initials for the avatar fallback
    final initials = question.userName != null && question.userName!.isNotEmpty
        ? question.userName!.trim().split(' ').map((l) => l[0]).take(2).join().toUpperCase()
        : 'A'; // Anonymous

    // **ASSUMPTION**: Your Question model might have a userAvatarUrl field.
    // If not, it will gracefully fall back to showing initials.
    final avatarUrl = question.mediaUrls[0];

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      // **STYLE**: Subtle elevation and a fine border for a modern look
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.2), width: 1),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuestionDetailsPage(question: question),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // **IMPROVEMENT**: Using ListTile for a clean, aligned header.
              ListTile(
                contentPadding: EdgeInsets.zero,
              leading: ProfileAvatar(imageURL: avatarUrl, userName: question.userName!, radius: 20.r)

              // leading: CircleAvatar(
                //   backgroundColor: colorScheme.primaryContainer,
                //   backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                //   child: avatarUrl == null
                //       ? Text(initials, style: TextStyle(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold))
                //       : null,
                // )
                ,
                title: Text(
                    question.userName ?? "Anonymous",
                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)
                ),
                subtitle: Text(
                  // **IMPROVEMENT**: Nicer date formatting
                    "Asked on ${question.updatedAt.toString().substring(0, 10)}",
                    style: textTheme.bodySmall
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () { /* For future actions like report/share */ },
                ),
              ),
              SizedBox(height: 12.h),

              // **IMPROVEMENT**: More prominent title style
              Text(
                question.title,
                style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.3 // Better line spacing
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8.h),

              // **IMPROVEMENT**: More subtle description color
              Text(
                question.description,
                style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 16.h),

              // **IMPROVEMENT**: Using proper Chip widgets for tags
              if (question.tags.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: question.tags.map((tag) {
                      return Chip(
                        label: Text(tag),
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        labelStyle: textTheme.bodySmall,
                        backgroundColor: colorScheme.surfaceContainer,
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                ),

              Divider(height: 1.h),

              // **IMPROVEMENT**: A unified footer for all stats and actions
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Vote Buttons are now grouped
                    Row(
                      children: [
                        _buildVoteButton(
                          context: context,
                          icon: Icons.arrow_upward_rounded,
                          label: question.upvotes.toString(),
                          isSelected: userVoteType == 'UPVOTE',
                          onTap: () {
                            _handleVote(question, 'UPVOTE');
                            bloc.add(UpdateVote(question, true));
                          },
                        ),
                        SizedBox(width: 8.w),
                        _buildVoteButton(
                          context: context,
                          icon: Icons.arrow_downward_rounded,
                          label: question.downvotes.toString(),
                          isSelected: userVoteType == 'DOWNVOTE',
                          onTap: () {
                            _handleVote(question, 'DOWNVOTE');
                            bloc.add(UpdateVote(question, false));
                          },
                        ),
                      ],
                    ),
                    // Comment count is now here for consistency
                    Row(
                      children: [
                        Icon(Icons.mode_comment_outlined, size: 18.sp, color: colorScheme.onSurfaceVariant),
                        SizedBox(width: 6.w),
                        Text(
                          question.commentCount.toString(),
                          style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

// **IMPROVEMENT**: Helper widget for cleaner, reusable vote buttons.
// Place this method within your State class.
  Widget _buildVoteButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color selectedColor = colorScheme.primary;
    final Color unselectedColor = colorScheme.onSurfaceVariant;

    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: isSelected ? selectedColor : unselectedColor, size: 18.sp),
      label: Text(label, style: TextStyle(color: isSelected ? selectedColor : unselectedColor, fontWeight: FontWeight.bold)),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        // **IMPROVEMENT**: Visual feedback when a button is selected
        backgroundColor: isSelected ? selectedColor.withOpacity(0.1) : Colors.transparent,
      ),
    );
  }

  final List<String> _availableTags = [
    "All",
    "Islamabad",
    "Karachi",
    "Lahore",
    "Peshawar",
    "Quetta"
  ];
}
