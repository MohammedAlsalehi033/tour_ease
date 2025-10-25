class OtherUserModel {
  String userName;
  String userid;
  List<String> mediaUrls;

  OtherUserModel({
    this.userName = 'Guest',
    this.userid = 'unknown',
    this.mediaUrls = const [],
  });

  factory OtherUserModel.fromJson(Map<String, dynamic> json) {
    return OtherUserModel(
      userName: json['username'] as String? ?? 'Guest',
      userid: json['userid'] as String? ?? 'unknown',
      mediaUrls: (json['mediaUrls'] as List?)?.map((item) => item.toString()).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'userid': userid,
      'mediaUrls': mediaUrls,
    };
  }
}