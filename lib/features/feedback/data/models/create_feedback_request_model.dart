class CreateFeedbackRequestModel {
  final int rating;
  final String? comments;
  final int gymId;

  CreateFeedbackRequestModel({
    required this.rating,
    this.comments,
    required this.gymId,
  });

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comments': comments,
      'gymId': gymId,
    };
  }

  /// Validate rating is between 1 and 5
  bool get isValidRating => rating >= 1 && rating <= 5;
}

