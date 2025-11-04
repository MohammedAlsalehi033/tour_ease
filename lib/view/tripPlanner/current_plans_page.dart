import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tour_ease/view/tripPlanner/tripPlannerPage.dart';
import 'package:tour_ease/Services/tripPlanner/saved_plans_service.dart';
import 'package:tour_ease/model/tripPlanner/saved_plan_models.dart';
import 'package:tour_ease/utils/currency_formatter.dart';
import 'package:intl/intl.dart';

class CurrentPlansPage extends StatefulWidget {
  final bool autoCreate;
  const CurrentPlansPage({Key? key, this.autoCreate = false}) : super(key: key);

  @override
  State<CurrentPlansPage> createState() => _CurrentPlansPageState();
}

class _CurrentPlansPageState extends State<CurrentPlansPage> {
  List<SavedPlan> _savedPlans = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSavedPlans();
  }

  Future<void> _loadSavedPlans() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await SavedPlansService.getSavedPlans(limit: 20);
      setState(() {
        _savedPlans = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                                SizedBox(height: 12.h),
                                Text('Error loading plans', style: theme.textTheme.titleMedium),
                                SizedBox(height: 8.h),
                                Text(_error!, style: theme.textTheme.bodySmall),
                                SizedBox(height: 16.h),
                                ElevatedButton(
                                  onPressed: _loadSavedPlans,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : _savedPlans.isEmpty
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
                                itemCount: _savedPlans.length,
                                padding: EdgeInsets.only(bottom: 16.h),
                                itemBuilder: (context, index) {
                                  final plan = _savedPlans[index];
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

  Widget _buildPlanCard(SavedPlan plan, ThemeData theme, ColorScheme colorScheme) {
    final totalCost = plan.planData?['tripSummary']?['estimatedTotalCost']?['total'] ?? 0.0;
    
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to plan details or trip results with saved plan data
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening plan: ${plan.planName}')),
          );
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      plan.planName,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: _getStatusColor(plan.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      plan.status.toUpperCase(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(plan.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16.sp, color: colorScheme.onSurfaceVariant),
                  SizedBox(width: 4.w),
                  Text(
                    '${plan.startLocation} → ${plan.endLocation}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 16.sp, color: colorScheme.onSurfaceVariant),
                  SizedBox(width: 4.w),
                  Text(
                    '${_formatDate(plan.startTime)} - ${_formatDate(plan.endTime)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(Icons.people_outline, size: 16.sp, color: colorScheme.onSurfaceVariant),
                  SizedBox(width: 4.w),
                  Text(
                    '${plan.numberOfTravelers} travelers',
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    CurrencyFormatter.formatPKR(totalCost),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (plan.tags != null && plan.tags!.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  children: plan.tags!.take(3).map((tag) => Chip(
                    label: Text(tag, style: theme.textTheme.bodySmall),
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
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
}
