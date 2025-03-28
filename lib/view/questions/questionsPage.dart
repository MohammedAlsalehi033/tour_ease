import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tour_ease/controller/question/questionBloc.dart';
import 'package:tour_ease/controller/question/votes/votes_bloc.dart';
import 'package:tour_ease/model/auth/user.dart';
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

    final userVote = question.votes?.firstWhere(
      (vote) => vote['userId'] == UserModel().id,
      orElse: () => null,
    );
    final userVoteType = userVote?['type'];
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuestionDetailsPage(
                  question: question,
                ),
              ));
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      image:  DecorationImage(
                          image: NetworkImage(question.mediaUrls!.length > 0 ? question.mediaUrls!
                              .where((element) =>
                              element.contains("profilePicture"))
                              .first : "https://lh3.googleusercontent.com/a-/ALV-UjX8IbJfWUTnSn2_CXavbtKkli-sXoK4ShX4DlUjTbDehIafaZ0V=s64")) ,
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question.userName ?? "",
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          question.updatedAt.toString(),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.question_answer_outlined,
                          size: 16.sp,
                          color: colorScheme.inversePrimary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          question.commentCount.toString(),
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.inversePrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Divider
              Divider(height: 32.h),

              Text(
                question.title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8.h),
              Text(
                question.description,
                style: textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: question.tags.map((tag) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Text(
                            tag,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Row(
                    children: [
                      // Upvote Section
                      GestureDetector(
                        onTap: userVoteType != 'UPVOTE'
                            ? () {
                                _handleVote(question, 'UPVOTE');
                                bloc.add(UpdateVote(question, true));
                              }
                            : null,
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_upward,
                              size: 16.sp,
                              color: userVoteType == 'UPVOTE'
                                  ? colorScheme.primary
                                  : userVoteType == 'DOWNVOTE'
                                      ? colorScheme.onSurfaceVariant
                                          .withOpacity(0.5)
                                      : colorScheme.onSurfaceVariant,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              question.upvotes.toString(),
                              style: textTheme.bodyMedium?.copyWith(
                                color: userVoteType == 'UPVOTE'
                                    ? colorScheme.primary
                                    : userVoteType == 'DOWNVOTE'
                                        ? colorScheme.onSurfaceVariant
                                            .withOpacity(0.5)
                                        : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),
                      GestureDetector(
                        onTap: userVoteType != 'DOWNVOTE'
                            ? () {
                                _handleVote(question, 'DOWNVOTE');
                                bloc.add(UpdateVote(question, false));
                              }
                            : null,
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_downward,
                              size: 16.sp,
                              color: userVoteType == 'DOWNVOTE'
                                  ? colorScheme.primary
                                  : userVoteType == 'UPVOTE'
                                      ? colorScheme.onSurfaceVariant
                                          .withOpacity(0.5)
                                      : colorScheme.onSurfaceVariant,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              question.downvotes.toString(),
                              style: textTheme.bodyMedium?.copyWith(
                                color: userVoteType == 'DOWNVOTE'
                                    ? colorScheme.primary
                                    : userVoteType == 'UPVOTE'
                                        ? colorScheme.onSurfaceVariant
                                            .withOpacity(0.5)
                                        : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
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
