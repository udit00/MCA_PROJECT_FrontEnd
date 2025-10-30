/// Model for users available for chat
class ChatUser {
  final int userId;
  final String userName;
  final String mobile;
  final String? profilePic;

  ChatUser({
    required this.userId,
    required this.userName,
    required this.mobile,
    this.profilePic,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      userId: json['userId'] as int,
      userName: json['userName'] as String,
      mobile: json['mobile'] as String? ?? '',
      profilePic: json['profilePic'] as String?,
    );
  }

  String get initials {
    if (userName.isEmpty) return '?';
    final names = userName.trim().split(' ');
    if (names.length == 1) {
      return names[0][0].toUpperCase();
    }
    return (names[0][0] + names[names.length - 1][0]).toUpperCase();
  }
}

