class PlanModel {
  final int planId;
  final String? planBanner;
  final String planName;
  final String planDesc;
  final int planPrice;
  final int planDuration;
  final int gymId;
  final bool isActive;
  final int createdBy;
  final DateTime createdAt;

  PlanModel({
    required this.planId,
    this.planBanner,
    required this.planName,
    required this.planDesc,
    required this.planPrice,
    required this.planDuration,
    required this.gymId,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      planId: json['planId'] as int,
      planBanner: json['planBanner'] as String?,
      planName: json['planName'] as String,
      planDesc: json['planDesc'] as String,
      planPrice: json['planPrice'] as int,
      planDuration: json['planDuration'] as int,
      gymId: json['gymId'] as int,
      isActive: json['isActive'] as bool,
      createdBy: json['createdBy'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planId': planId,
      'planBanner': planBanner,
      'planName': planName,
      'planDesc': planDesc,
      'planPrice': planPrice,
      'planDuration': planDuration,
      'gymId': gymId,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Get price formatted as currency
  String get formattedPrice => '₹$planPrice';

  /// Get duration with unit
  String get formattedDuration => '$planDuration days';

  /// Create empty plan for new creation
  factory PlanModel.empty(int gymId, int createdBy) {
    return PlanModel(
      planId: 0,
      planBanner: null,
      planName: '',
      planDesc: '',
      planPrice: 0,
      planDuration: 30,
      gymId: gymId,
      isActive: true,
      createdBy: createdBy,
      createdAt: DateTime.now(),
    );
  }
}

