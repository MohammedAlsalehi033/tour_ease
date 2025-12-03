import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tour_ease/view/tripPlanner/tripPlannerPage.dart';
import 'package:tour_ease/model/tripPlanner/tripPlannerModels.dart';
import 'package:tour_ease/controller/tripPlanner/tripPlannerBloc.dart';
import 'package:tour_ease/utils/currency_formatter.dart';
import 'package:intl/intl.dart';
import 'package:tour_ease/view/tripPlanner/saved_plan_details_page.dart';

class CurrentPlansPage extends StatefulWidget {
  final bool autoCreate;
  const CurrentPlansPage({Key? key, this.autoCreate = false}) : super(key: key);

  @override
  State<CurrentPlansPage> createState() => _CurrentPlansPageState();
}

class _CurrentPlansPageState extends State<CurrentPlansPage> {
  @override
  void initState() {
    super.initState();
    // Load saved plans when the page is opened
    // Defer the BLoC event until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripPlannerBloc>().add(const GetSavedPlans());
    });
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return DateFormat('MMM dd, yyyy').format(dt);
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: BlocBuilder<TripPlannerBloc, TripPlannerState>(
        builder: (context, state) {
          final isLoading = state.isLoading;
          final error = state.error;
          final savedPlans = state.savedPlans ?? [];
          print('Saved plans12: ${savedPlans.map((plan) => plan.toJson())}');

          return SafeArea(
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
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : error != null
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                                    SizedBox(height: 12.h),
                                    Text('Error loading plans', style: theme.textTheme.titleMedium),
                                    SizedBox(height: 8.h),
                                    Text(error, style: theme.textTheme.bodySmall),
                                    SizedBox(height: 16.h),
                                    ElevatedButton(
                                      onPressed: () => context.read<TripPlannerBloc>().add(const GetSavedPlans()),
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              )
                            : savedPlans.isEmpty
                                ? Center(
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
                                  )
                                : ListView.builder(
                                    itemCount: savedPlans.length,
                                    padding: EdgeInsets.only(bottom: 16.h),
                                    itemBuilder: (context, index) {
                                      final plan = savedPlans[index];
                                      return _buildPlanCard(plan, theme, colorScheme);
                                    },
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
                    icon: const Icon(Icons.add_rounded),
                    label: Text('Create new plan', style: theme.textTheme.labelLarge?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      backgroundColor: colorScheme.primary,
                    ),
                  ),

                  SizedBox(height: 12.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlanCard(SavedPlan plan, ThemeData theme, ColorScheme colorScheme) {
    final totalCost = plan.totalCost;
    final days = plan.endTime.difference(plan.startTime).inDays + 1;
    
    return Hero(
      tag: 'plan_${plan.id}',
      child: Card(
        margin: EdgeInsets.only(bottom: 16.h),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: InkWell(
          onTap: () {
            // Navigate to saved plan details page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SavedPlanDetailsPage(plan: plan),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.surface,
                  colorScheme.surfaceContainerHighest.withOpacity(0.3),
                ],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          plan.planName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: _getStatusColor(plan.status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: _getStatusColor(plan.status).withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          plan.status.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _getStatusColor(plan.status),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  if (plan.description != null && plan.description!.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Text(
                      plan.description!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  SizedBox(height: 16.h),
                  
                  // Route Info
                  Row(
                    children: [
                      Icon(
                        Icons.trip_origin_rounded,
                        size: 16.sp,
                        color: Colors.green,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          plan.startLocation,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 16.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          plan.endLocation,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Icon(
                        Icons.location_on_rounded,
                        size: 16.sp,
                        color: Colors.red,
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 12.h),
                  
                  // Stats Row
                  Row(
                    children: [
                      _buildStatChip(
                        icon: Icons.calendar_today_rounded,
                        label: '$days ${days == 1 ? 'day' : 'days'}',
                        color: Colors.blue,
                        theme: theme,
                      ),
                      SizedBox(width: 8.w),
                      _buildStatChip(
                        icon: Icons.people_rounded,
                        label: '${plan.numberOfTravelers}',
                        color: Colors.purple,
                        theme: theme,
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          CurrencyFormatter.formatPKR(totalCost),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  if (plan.tags != null && plan.tags!.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 6.h,
                      children: plan.tags!.take(3).map((tag) => Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getTagIcon(tag),
                              size: 12.sp,
                              color: colorScheme.onSecondaryContainer,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              tag,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
                  ],
                  
                  SizedBox(height: 8.h),
                  
                  // Date Info
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 14.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Created ${_formatDate(plan.createdAt.toIso8601String())}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14.sp,
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'booked':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'draft':
      default:
        return Colors.orange;
    }
  }

  IconData _getTagIcon(String tag) {
    final lower = tag.toLowerCase();
    if (lower.contains('auto')) return Icons.auto_awesome_rounded;
    if (lower.contains('booked')) return Icons.bookmark_rounded;
    if (lower.contains('favorite') || lower.contains('fav')) return Icons.favorite_rounded;
    if (lower.contains('urgent')) return Icons.priority_high_rounded;
    if (lower.contains('family')) return Icons.family_restroom_rounded;
    if (lower.contains('business')) return Icons.business_center_rounded;
    if (lower.contains('leisure')) return Icons.beach_access_rounded;
    return Icons.label_rounded;
  }
}
