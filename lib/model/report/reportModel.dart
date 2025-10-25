
class Report {
  int? id;
  final String reportableType;
  final String reportReason;
  final String description;
  final String reporterId;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? resolutionNotes; // For viewing resolved reports

  // Fields for identifying the reported content
  String? reportedUserId;
  int? transportationListingId;
  int? accommodationId;
  int? roomId;
  int? questionId;
  int? commentId;
  int? messageId;
  int? offerId;
  int? transportationBookingId;
  int? accommodationBookingId;

  Report({
    this.id,
    required this.reportableType,
    required this.reportReason,
    required this.description,
    required this.reporterId,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.resolutionNotes,
    this.reportedUserId,
    this.transportationListingId,
    this.accommodationId,
    this.roomId,
    this.questionId,
    this.commentId,
    this.messageId,
    this.offerId,
    this.transportationBookingId,
    this.accommodationBookingId,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      reportableType: json['reportableType'],
      reportReason: json['reportReason'],
      description: json['description'],
      reporterId: json['reporterId'],
      status: json['status'],
      resolutionNotes: json['resolutionNotes'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      // You can add the reported content IDs here if the API returns them
      reportedUserId: json['reportedUserId'],
      accommodationId: json['accommodationId'],
      // ... and so on for other IDs
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'reportableType': reportableType,
      'reportReason': reportReason,
      'description': description,
    };
    // Conditionally add the ID of the item being reported
    if (reportedUserId != null) data['reportedUserId'] = reportedUserId;
    if (transportationListingId != null) data['transportationListingId'] = transportationListingId;
    if (accommodationId != null) data['accommodationId'] = accommodationId;
    if (roomId != null) data['roomId'] = roomId;
    if (questionId != null) data['questionId'] = questionId;
    if (commentId != null) data['commentId'] = commentId;
    if (messageId != null) data['messageId'] = messageId;
    if (offerId != null) data['offerId'] = offerId;
    if (transportationBookingId != null) data['transportationBookingId'] = transportationBookingId;
    if (accommodationBookingId != null) data['accommodationBookingId'] = accommodationBookingId;
    return data;
  }

  @override
  String toString() {
    return 'Report{id: $id, type: $reportableType, reason: $reportReason, status: $status}';
  }
}