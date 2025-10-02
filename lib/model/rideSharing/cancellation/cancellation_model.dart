class CancellationReason {
  final String id;
  final String title;
  final String description;
  final bool requiresDetail;

  const CancellationReason({
    required this.id,
    required this.title,
    required this.description,
    this.requiresDetail = false,
  });

  static const List<CancellationReason> predefinedReasons = [
    CancellationReason(
      id: 'emergency',
      title: 'Emergency',
      description: 'Unexpected emergency situation',
      requiresDetail: true,
    ),
    CancellationReason(
      id: 'change_of_plans',
      title: 'Change of Plans',
      description: 'My plans have changed',
    ),
    CancellationReason(
      id: 'incorrect_booking',
      title: 'Incorrect Booking',
      description: 'I made a mistake in my booking',
      requiresDetail: true,
    ),
    CancellationReason(
      id: 'safety_concerns',
      title: 'Safety Concerns',
      description: 'I have safety concerns about this ride',
      requiresDetail: true,
    ),
    CancellationReason(
      id: 'vehicle_issue',
      title: 'Vehicle Issue',
      description: 'Problem with my vehicle (drivers only)',
      requiresDetail: true,
    ),
    CancellationReason(
      id: 'weather',
      title: 'Weather Conditions',
      description: 'Unsafe weather conditions',
    ),
    CancellationReason(
      id: 'other',
      title: 'Other',
      description: 'Other reason not listed',
      requiresDetail: true,
    ),
  ];

  static List<CancellationReason> getReasonsForRole(UserRole role) {
    if (role == UserRole.driver) {
      return predefinedReasons;
    } else {
      // Exclude vehicle issue for travelers
      return predefinedReasons.where((reason) => reason.id != 'vehicle_issue').toList();
    }
  }
}

enum UserRole { traveler, driver }

class CancellationRequest {
  final String bookingId;
  final String userId;
  final UserRole userRole;
  final CancellationReason reason;
  final String? additionalDetails;
  final DateTime timestamp;

  CancellationRequest({
    required this.bookingId,
    required this.userId,
    required this.userRole,
    required this.reason,
    this.additionalDetails,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'userRole': userRole.name,
      'reasonId': reason.id,
      'reasonTitle': reason.title,
      'additionalDetails': additionalDetails,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  String get formattedDescription {
    final baseDescription = reason.description;
    if (additionalDetails != null && additionalDetails!.isNotEmpty) {
      return '$baseDescription: $additionalDetails';
    }
    return baseDescription;
  }
}

class CancellationWarning {
  final String title;
  final String description;
  final List<String> consequences;
  final String actionText;

  const CancellationWarning({
    required this.title,
    required this.description,
    required this.consequences,
    required this.actionText,
  });

  static const CancellationWarning defaultWarning = CancellationWarning(
    title: 'Confirm Cancellation',
    description: 'Cancelling a ride affects trust on the platform. Continuous cancellations may lead to temporary or permanent account restrictions.',
    consequences: [
      'This affects your reliability score',
      'Other users may be impacted',
      'Repeated cancellations may result in penalties',
      'Your account could be temporarily restricted',
    ],
    actionText: 'Yes, Cancel Ride',
  );
}