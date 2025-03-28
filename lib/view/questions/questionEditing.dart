import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tour_ease/controller/question/questionBloc.dart';
import 'package:tour_ease/model/userManagment/user.dart';
import 'package:tour_ease/model/question/questionModel.dart';

class QuestionEditingPage extends StatefulWidget {
  final Question question;
  const QuestionEditingPage({Key? key, required this.question})
      : super(key: key);

  @override
  _QuestionEditingPageState createState() => _QuestionEditingPageState();
}

class _QuestionEditingPageState extends State<QuestionEditingPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<String> _availableTags = [
    "All",
    "Islamabad",
    "Karachi",
    "Lahore",
    "Peshawar",
    "Quetta"
  ];
  List<String> _selectedTags = [];

  @override
  void initState() {
    _titleController.text = widget.question.title;
    _descriptionController.text = widget.question.description;
    _selectedTags = widget.question.tags;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Ask a Question', style: textTheme.titleLarge),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                  fontSize: 22.sp,
                ),
                decoration: InputDecoration(
                  hintText: 'What is your question?',
                  hintStyle: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                    fontSize: 22.sp,
                  ),
                  border: InputBorder.none,
                ),
                cursorColor: colorScheme.primary,
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: TextFormField(
                  controller: _descriptionController,
                  maxLines: null,
                  expands: true,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontSize: 16.sp,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Describe your question in more detail...',
                    hintStyle: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 16.sp,
                    ),
                    border: InputBorder.none,
                  ),
                  cursorColor: colorScheme.primary,
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                'Select relevant tags',
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              SizedBox(
                height: 40.h, // Adjusted height
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w), // Reduced padding
                  itemCount: _availableTags.length,
                  itemBuilder: (context, index) {
                    final tag = _availableTags[index];
                    final isSelected = _selectedTags.contains(tag);

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: ChoiceChip(
                        label: Text(tag, style: TextStyle(fontSize: 14.sp)),

                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              if (!_selectedTags.contains(tag)) {
                                _selectedTags.add(tag);
                              }
                            } else {
                              _selectedTags.remove(tag);
                            }
                            print(
                                'Selected Tags: $_selectedTags'); // For debugging
                          });
                        },
                        backgroundColor: Colors.transparent,
                        side: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.3),
                          width: 0.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        selectedColor: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withOpacity(0.8), // Slightly reduced opacity
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h), // Adjusted padding
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.8),
                          fontWeight:
                              isSelected ? FontWeight.w500 : FontWeight.w400,
                          fontSize: 14.sp,
                        ),
                        elevation: 0,
                        pressElevation: 0,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: BlocBuilder<QuestionBloc, QuestionState>(
                  builder: (context, state) {
                    return BlocBuilder<QuestionBloc, QuestionState>(
  builder: (context, state) {

    if(state is QuestionLoadInProgress){
      return ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.grey,
          foregroundColor:  Colors.grey,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          textStyle: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            fontSize: 16.sp,
          ),
        ),
        child: const Text('Post Question'),
      );
    }
    else if (state is QuestionLoadFailure){
      return Text(state.error);
    }
    return ElevatedButton(
                      onPressed: () {

                        context.read<QuestionBloc>().add(EditQuestion(
                            question: Question(mediaUrls: [],
                              id: widget.question.id,
                                title: _titleController.text,
                                description: _descriptionController.text,
                                userId: UserModel().id,
                                tags: _selectedTags)));
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        textStyle: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                          fontSize: 16.sp,
                        ),
                      ),
                      child: const Text('Post Question'),
                    );
  },
);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
