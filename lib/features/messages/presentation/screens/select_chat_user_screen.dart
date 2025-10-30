import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zymm/common/enums/user_role.dart';
import 'package:zymm/core/storage/storage_service.dart';
import 'package:zymm/features/messages/data/models/chat_user_model.dart';
import 'package:zymm/features/messages/presentation/screens/chat_screen.dart';
import 'package:zymm/features/messages/presentation/viewmodel/messages_viewmodel.dart';

class SelectChatUserScreen extends StatefulWidget {
  const SelectChatUserScreen({super.key});

  @override
  State<SelectChatUserScreen> createState() => _SelectChatUserScreenState();
}

class _SelectChatUserScreenState extends State<SelectChatUserScreen> {
  UserRole? _currentUserRole;
  bool _isLoading = true;
  List<ChatUser> _users = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get current user role for display purposes
      final roleId = await StorageService.instance.getRoleId();
      if (roleId != null) {
        _currentUserRole = UserRole.fromId(roleId);
      }

      if (mounted) {
        await context.read<MessagesViewModel>().getAvailableChatUsers();
        final users = context.read<MessagesViewModel>().availableChatUsers;
        
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _openChat(ChatUser user) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => MessagesViewModel(),
          child: ChatScreen(
            userId: user.userId,
            userName: user.userName,
            userProfilePic: user.profilePic,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMember = _currentUserRole == UserRole.member;
    final title = isMember ? 'Select Trainer' : 'Select Member';
    final emptyMessage = isMember 
        ? 'No trainers available'
        : 'No members available';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _users.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_off_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            emptyMessage,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        return UserCard(
                          user: user,
                          onTap: () => _openChat(user),
                        );
                      },
                    ),
    );
  }
}

class UserCard extends StatelessWidget {
  final ChatUser user;
  final VoidCallback onTap;

  const UserCard({
    super.key,
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                backgroundImage: user.profilePic != null
                    ? NetworkImage(user.profilePic!)
                    : null,
                child: user.profilePic == null
                    ? Text(
                        user.initials,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.userName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.mobile,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

