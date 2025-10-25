class ProfilePictureUpdateResponse {
  final String id;
  final String username;
  final String mediaUrls;

  ProfilePictureUpdateResponse({
    required this.id,
    required this.username,
    required this.mediaUrls,
  });

  factory ProfilePictureUpdateResponse.fromJson(Map<String, dynamic> json) {
    return ProfilePictureUpdateResponse(
      id: json['id'],
      username: json['username'],
      mediaUrls: json['mediaUrls'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'mediaUrls': mediaUrls,
    };
  }
}
