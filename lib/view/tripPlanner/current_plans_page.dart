import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tour_ease/view/tripPlanner/tripPlannerPage.dart';
import 'package:tour_ease/view/tripPlanner/TripResultsPage.dart';

class CurrentPlansPage extends StatefulWidget {
  final bool autoCreate;
  const CurrentPlansPage({Key? key, this.autoCreate = false}) : super(key: key);

  @override
  State<CurrentPlansPage> createState() => _CurrentPlansPageState();
}

class _CurrentPlansPageState extends State<CurrentPlansPage> {

 

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 8.h),
              Text(
                'Current plans',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              Text(
                'Here you can access your saved or active trip plans. Create a new plan to start the trip planning flow.',
                style: theme.textTheme.bodyLarge,
              ),
              SizedBox(height: 24.h),

              // Placeholder: empty list
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.map_outlined, size: 64.sp, color: colorScheme.onSurfaceVariant),
                      SizedBox(height: 12.h),
                      Text('No plans yet', style: theme.textTheme.titleMedium),
                      SizedBox(height: 8.h),
                      Text('Tap below to create your first trip plan.', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ),

              // CTA buttons
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to Trip Planner flow (create new plan)
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const TripPlannerPage()),
                  );
                },
                icon: Icon(Icons.add_rounded),
                label: Text('Create new plan', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  backgroundColor: colorScheme.primary,
                ),
              ),

              SizedBox(height: 12.h),

             
            ],
          ),
        ),
      ),
    );
  }
}
