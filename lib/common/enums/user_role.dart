/// User role enum that maps to backend role IDs
enum UserRole {
  owner(1),
  manager(2),
  staff(3),
  trainer(4),
  member(5);

  final int id;
  const UserRole(this.id);

  /// Get role from ID
  static UserRole fromId(int id) {
    switch (id) {
      case 1:
        return UserRole.owner;
      case 2:
        return UserRole.manager;
      case 3:
        return UserRole.staff;
      case 4:
        return UserRole.trainer;
      case 5:
        return UserRole.member;
      default:
        return UserRole.member; // Default to member if unknown
    }
  }

  /// Get role display name
  String get displayName {
    switch (this) {
      case UserRole.owner:
        return 'Owner';
      case UserRole.manager:
        return 'Manager';
      case UserRole.staff:
        return 'Staff';
      case UserRole.trainer:
        return 'Trainer';
      case UserRole.member:
        return 'Member';
    }
  }

  /// Check if role has admin privileges
  bool get isAdmin => this == UserRole.owner || this == UserRole.manager;

  /// Check if role is staff (including trainers)
  bool get isStaff => this == UserRole.staff || this == UserRole.trainer;

  /// Check if role is member
  bool get isMember => this == UserRole.member;
}


