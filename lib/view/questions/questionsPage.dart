import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tour_ease/model/question/questionModel.dart';


class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({super.key});
  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTag = "All";

  final List<String> _availableTags = [
    "All",
    "Islamabad",
    "Lahore",
    "Karachi",
    "Swat",
    "Hunza",
    "Neelum Valley",
    "Transportation",
    "Accommodation",
    "Food",
    "Safety",
    "Budget",
  ];

  // Sample questions data
  final List<Question> _questions = [
    Question(
      id: "1",
      title: "Best time to visit Hunza Valley?",
      description: "I'm planning a trip to Hunza Valley and would like to know the best season to visit for good weather and views.",
      authorName: "Asad Khan",
      authorAvatarUrl: "https://randomuser.me/api/portraits/men/1.jpg",
      timestamp: "2 hours ago",
      tags: ["Hunza", "Weather"],
      answers: 5,
      views: 124,
    ),
    Question(
      id: "2",
      title: "Transportation options from Islamabad to Lahore?",
      description: "What are the most convenient ways to travel from Islamabad to Lahore? Looking for both budget and comfortable options.",
      authorName: "Fatima Ahmed",
      authorAvatarUrl: "https://randomuser.me/api/portraits/women/2.jpg",
      timestamp: "Yesterday",
      tags: ["Transportation", "Islamabad", "Lahore"],
      answers: 8,
      views: 210,
    ),
    Question(
      id: "3",
      title: "Safe hotels in Karachi for family stay?",
      description: "Planning a family trip to Karachi. Can anyone recommend safe and family-friendly hotels in a good location?",
      authorName: "Omar Malik",
      authorAvatarUrl: "https://randomuser.me/api/portraits/men/3.jpg",
      timestamp: "3 days ago",
      tags: ["Karachi", "Accommodation", "Safety"],
      answers: 12,
      views: 345,
    ),
    Question(
      id: "4",
      title: "Best local food to try in Lahore?",
      description: "Visiting Lahore next month and want to try authentic local cuisine. Any suggestions for must-try dishes and restaurants?",
      authorName: "Zara Mahmood",
      authorAvatarUrl: "https://randomuser.me/api/portraits/women/4.jpg",
      timestamp: "1 week ago",
      tags: ["Lahore", "Food"],
      answers: 15,
      views: 467,
    ),
    Question(
      id: "5",
      title: "Budget accommodations in Swat Valley?",
      description: "Looking for affordable places to stay in Swat that are clean and have basic amenities. Any recommendations?",
      authorName: "Ali Hassan",
      authorAvatarUrl: "https://randomuser.me/api/portraits/men/5.jpg",
      timestamp: "2 weeks ago",
      tags: ["Swat", "Accommodation", "Budget"],
      answers: 7,
      views: 189,
    ),
  ];

  List<Question> get filteredQuestions {
    if (_selectedTag == "All" && _searchController.text.isEmpty) {
      return _questions;
    }

    return _questions.where((question) {
      bool matchesTag = _selectedTag == "All" || question.tags.contains(_selectedTag);
      bool matchesSearch = _searchController.text.isEmpty ||
          question.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          question.description.toLowerCase().contains(_searchController.text.toLowerCase());

      return matchesTag && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search questions...',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),

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
                            : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                        width: 0.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      selectedColor: Theme.of(context).colorScheme.primaryContainer,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                        fontSize: 14,
                      ),
                      elevation: 0,
                      pressElevation: 0,
                    )
                  );
                },
              ),
            ),

            // Questions List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(top: 8.h),
                itemCount: filteredQuestions.length,
                itemBuilder: (context, index) {
                  final question = filteredQuestions[index];
                  return _buildQuestionItem(context, question);
                },
              ),
            ),
          ],
        ),
      ),floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to ask question screen
        },
        child: Icon(Icons.add),
        tooltip: 'Ask a Question',
      ),
    );
  }

  Widget _buildQuestionItem(BuildContext context, Question question) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: InkWell(
        onTap: () {
          // Navigate to question details
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question header with author info
              Row(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(question.authorAvatarUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question.authorName,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          question.timestamp,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.question_answer_outlined,
                          size: 16.sp,
                          color: colorScheme.primary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          question.answers.toString(),
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
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

              // Question title and description
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

              // Question stats and tags
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: question.tags.map((tag) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
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
                      Icon(
                        Icons.visibility_outlined,
                        size: 16.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        question.views.toString(),
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
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
  }}