class GymModel {
  final int gymId;
  final String gymName;
  final String state;
  final String city;
  final String gymAddress;
  final String contactNo;
  final String? officialEmail;
  final int createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? locationLat;
  final String? locationLong;
  final int? averageRating;
  final int? totalFeedbacks;
  final int? trainersCount;
  final int? staffCount;
  final int? managersCount;
  final int? activePlans;

  GymModel({
    required this.gymId,
    required this.gymName,
    required this.state,
    required this.city,
    required this.gymAddress,
    required this.contactNo,
    this.officialEmail,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.locationLat,
    this.locationLong,
    this.averageRating,
    this.totalFeedbacks,
    this.trainersCount,
    this.staffCount,
    this.managersCount,
    this.activePlans,
  });

  factory GymModel.fromJson(Map<String, dynamic> json) {
    return GymModel(
      gymId: json['gymId'] as int,
      gymName: json['gymName'] as String,
      state: json['state'] as String,
      city: json['city'] as String,
      gymAddress: json['gymAddress'] as String,
      contactNo: json['contactNo'] as String,
      officialEmail: json['officialEmail'] as String?,
      createdBy: json['createdBy'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      locationLat: json['locationLat'] as String?,
      locationLong: json['locationLong'] as String?,
      averageRating: json['averageRating'] as int?,
      totalFeedbacks: json['totalFeedbacks'] as int?,
      trainersCount: json['trainersCount'] as int?,
      staffCount: json['staffCount'] as int?,
      managersCount: json['managersCount'] as int?,
      activePlans: json['activePlans'] as int?,
    );
  }

  /// Get full address string
  String get fullAddress => '$gymAddress, $city, $state';

  /// Check if gym has location data
  bool get hasLocation => locationLat != null && locationLong != null;

  /// Get rating as double (for star display)
  double get ratingAsDouble => averageRating?.toDouble() ?? 0.0;
}

