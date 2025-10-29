class UpsertPlanRequestModel {
  final int planId;
  final String planName;
  final String planDesc;
  final int planPrice;
  final int planDuration;
  final int gymId;
  final bool isActive;
  final String userAgent;
  final String appVersion;

  UpsertPlanRequestModel({
    required this.planId,
    required this.planName,
    required this.planDesc,
    required this.planPrice,
    required this.planDuration,
    required this.gymId,
    required this.isActive,
    required this.userAgent,
    required this.appVersion,
  });

  Map<String, dynamic> toJson() {
    return {
      'planId': planId,
      'planName': planName,
      'planDesc': planDesc,
      'planPrice': planPrice,
      'planDuration': planDuration,
      'gymId': gymId,
      'isActive': isActive,
      'userAgent': userAgent,
      'appVersion': appVersion,
    };
  }

  /// Check if this is a create operation (planId = 0)
  bool get isCreate => planId == 0;

  /// Check if this is an update operation (planId > 0)
  bool get isUpdate => planId > 0;
}

