class FeedbackModel {
  final int feedbackId;
  final int rating;
  final String? comments;
  final int gymId;
  final int createdBy;
  final String createdByName;
  final String? profilePic;
  final DateTime createdAt;

  FeedbackModel({
    required this.feedbackId,
    required this.rating,
    this.comments,
    required this.gymId,
    required this.createdBy,
    required this.createdByName,
    this.profilePic,
    required this.createdAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      feedbackId: json['feedbackId'] as int,
      rating: json['rating'] as int,
      comments: json['comments'] as String?,
      gymId: json['gymId'] as int,
      createdBy: json['createdBy'] as int,
      createdByName: json['createdByName'] as String,
      profilePic: json['profilePic'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feedbackId': feedbackId,
      'rating': rating,
      'comments': comments,
      'gymId': gymId,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'profilePic': profilePic,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Check if feedback has comments
  bool get hasComments => comments != null && comments!.isNotEmpty;
}

