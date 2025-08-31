import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// ANIMATION: Import the animation package
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tour_ease/components/debouncer.dart';
import 'package:tour_ease/components/profileAvatar.dart';
import 'package:tour_ease/controller/question/questionBloc.dart';
import 'package:tour_ease/controller/question/votes/votes_bloc.dart';
import 'package:tour_ease/model/userManagment/user.dart';
import 'package:tour_ease/model/question/questionModel.dart';
import 'package:tour_ease/view/questions/questionMaking.dart';
import 'package:tour_ease/view/questions/questionQetails.dart';

class QuestionsScreen extends StatefulWidget {
  final String userID;
  const QuestionsScreen({super.key, required this.userID});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  // --- ALL LOGIC REMAINS UNCHANGED ---
  final TextEditingController _searchController = TextEditingController();
  String _selectedTag = "All";
  final _scrollController = ScrollController();
  final _debouncer = Debouncer(milliseconds: 500);

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
    _debouncer.dispose();
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

    // Find the user's existing vote, if any.
    final existingVoteIndex = question.votes?.indexWhere((vote) => vote['userId'] == currentUserId) ?? -1;
    String? previousVoteType;

    if (existingVoteIndex != -1) {
      previousVoteType = question.votes?[existingVoteIndex]['type'];
    }

    setState(() {
      // Case 1: User is canceling their vote (e.g., tapping upvote when it's already upvoted)
      if (previousVoteType == newVoteType) {
        question.votes?.removeAt(existingVoteIndex);
        if (newVoteType == 'UPVOTE') {
          question.upvotes = question.upvotes! - 1;
        } else {
          question.downvotes = question.downvotes! - 1;
        }
      }
      // Case 2: User is changing their vote (e.g., from downvote to upvote)
      else if (previousVoteType != null) {
        question.votes?[existingVoteIndex]['type'] = newVoteType; // Update the vote type
        if (newVoteType == 'UPVOTE') {
          question.upvotes = question.upvotes! + 1;
          question.downvotes = question.downvotes! - 1;
        } else { // newVoteType is 'DOWNVOTE'
          question.downvotes = question.downvotes! + 1;
          question.upvotes = question.upvotes! - 1;
        }
      }
      // Case 3: User is casting a new vote
      else {
        question.votes?.add({'userId': currentUserId, 'type': newVoteType});
        if (newVoteType == 'UPVOTE') {
          question.upvotes = question.upvotes! + 1;
        } else {
          question.downvotes = question.downvotes! + 1;
        }
      }
    });

    // You can now adjust your BLoC event if needed,
    // though the existing one might work fine as the backend should handle the logic.
    // The key is that the local (optimistic) UI update is now correct.
  }


  @override
  Widget build(BuildContext context) {
    print("currentUser1: ${UserModel().id}");
    print(widget.userID + "-----------------------");
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<QuestionBloc, QuestionState>(
          builder: (context, state) {
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w).copyWith(bottom: 8.h, top: 12.h),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search questions...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainer,
                          contentPadding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 20.w),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.r),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                         _debouncer.run(() {
                           setState(() {
                             context.read<QuestionBloc>().add(SearchQuestions(query: value));
                           });
                         },);

                        },
                        onSubmitted: (value) {
                          setState(() {});
                        },
                      ),
                      SizedBox(height: 12.h),
                      SizedBox(
                        height: 40.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
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
                                    setState(() => _selectedTag = tag);
                                  }
                                },
                                backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                                selectedColor: Theme.of(context).colorScheme.primary,
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => QuestionMakingPage()));
        },
        child: const Icon(Icons.add),
        tooltip: 'Ask a Question',
      ),
    );
  }

  Widget _buildQuestionList(QuestionState state) {
    if (state is QuestionInitial || state is QuestionLoadInProgress) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is QuestionLoadFailure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _refreshQuestions, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (state is QuestionLoadSuccess && filteredQuestions.isEmpty) {
      return const Center(child: Text('No questions found'));
    }

    // ANIMATION: Wrap the ListView.builder in an AnimationLimiter.
    return AnimationLimiter(
      child: ListView.builder(
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

          // ANIMATION: Wrap each item in animation widgets.
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildQuestionItem(context, filteredQuestions[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  int _calculateItemCount(QuestionState state) {
    if (state is QuestionLoadSuccess) {
      return state.hasReachedMax ? filteredQuestions.length : filteredQuestions.length + 1;
    }
    return filteredQuestions.length;
  }

  Widget _buildQuestionItem(BuildContext context, Question question) {
    final bloc = BlocProvider.of<VotesBloc>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final userVote = question.votes?.firstWhere((vote) => vote['userId'] == UserModel().id, orElse: () => {});
    final userVoteType = userVote?['type'];
    final avatarUrl = question.mediaUrls.isNotEmpty ? question.mediaUrls[0] : null;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.2), width: 1),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => QuestionDetailsPage(question: question)));
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ProfileAvatar(imageURL: avatarUrl, userName: question.userName ?? '?', radius: 20.r,userId: question.userId,),
                title: Text(question.userName ?? "Anonymous", style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  "Asked on ${question.updatedAt.toString().substring(0, 10)}",
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant.withOpacity(0.8)),
                ),
                trailing: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
              ),
              SizedBox(height: 12.h),
              Text(
                question.title,
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, height: 1.3),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8.h),
              Text(
                question.description,
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (question.tags.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 16.h),
                  child: Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: question.tags.map((tag) => Chip(
                      label: Text(tag),
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      labelStyle: textTheme.bodySmall,
                      backgroundColor: colorScheme.surfaceContainer,
                      side: BorderSide.none,
                    )).toList(),
                  ),
                ),
              Divider(height: 32.h),
              Padding(
                padding: EdgeInsets.only(top: 0.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildVoteButton(
                          context: context,
                          icon: userVoteType == 'UPVOTE' ? Icons.thumb_up_alt_rounded : Icons.thumb_up_alt_outlined,
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
                          icon: userVoteType == 'DOWNVOTE' ? Icons.thumb_down_alt_rounded : Icons.thumb_down_alt_outlined,
                          label: question.downvotes.toString(),
                          isSelected: userVoteType == 'DOWNVOTE',
                          onTap: () {
                            _handleVote(question, 'DOWNVOTE');
                            bloc.add(UpdateVote(question, false));
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.mode_comment_outlined, size: 18.sp, color: colorScheme.onSurfaceVariant),
                        SizedBox(width: 6.w),
                        Text(
                          question.commentCount.toString(),
                          style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
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

  Widget _buildVoteButton({required BuildContext context, required IconData icon, required String label, required bool isSelected, required VoidCallback? onTap}) {
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
        backgroundColor: isSelected ? selectedColor.withOpacity(0.1) : Colors.transparent,
      ),
    );
  }

  final List<String> _availableTags = ["All", "Islamabad", "Karachi", "Lahore", "Peshawar", "Quetta"];
}