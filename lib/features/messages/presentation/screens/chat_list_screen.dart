import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zymm/common/enums/user_role.dart';
import 'package:zymm/core/storage/storage_service.dart';
import 'package:zymm/features/home/presentation/home_screen.dart';
import 'package:zymm/features/messages/data/models/chat_participant_model.dart';
import 'package:zymm/features/messages/presentation/screens/chat_screen.dart';
import 'package:zymm/features/messages/presentation/screens/select_chat_user_screen.dart';
import 'package:zymm/features/messages/presentation/viewmodel/messages_viewmodel.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> with RouteAware {
  UserRole? _currentUserRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChatParticipants();
    });
  }

  Future<void> _loadUserRole() async {
    final roleId = await StorageService.instance.getRoleId();
    if (roleId != null && mounted) {
      setState(() {
        _currentUserRole = UserRole.fromId(roleId);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      homeScreenRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    homeScreenRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadChatParticipants();
  }

  Future<void> _loadChatParticipants() async {
    if (mounted) {
      await context.read<MessagesViewModel>().getChatParticipants();
    }
  }

  void _openChat(ChatParticipantModel participant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => MessagesViewModel(),
          child: ChatScreen(
            userId: participant.userId,
            userName: participant.userName,
            userProfilePic: participant.profilePic,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Consumer<MessagesViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.state == MessagesViewState.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (viewModel.state == MessagesViewState.error) {
            return Center(
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
                    viewModel.errorMessage ?? 'Failed to load messages',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadChatParticipants,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final participants = viewModel.participants;

          if (participants.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start chatting with your trainers!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadChatParticipants,
            child: ListView.builder(
              itemCount: participants.length,
              itemBuilder: (context, index) {
                final participant = participants[index];
                return ChatParticipantCard(
                  participant: participant,
                  onTap: () => _openChat(participant),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: _shouldShowFAB()
          ? FloatingActionButton.extended(
              onPressed: _navigateToSelectUser,
              icon: const Icon(Icons.message, color: Colors.white),
              label: Text(
                _getFABLabel(),
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Theme.of(context).primaryColor,
            )
          : null,
    );
  }

  bool _shouldShowFAB() {
    return _currentUserRole == UserRole.trainer || 
           _currentUserRole == UserRole.member;
  }

  String _getFABLabel() {
    if (_currentUserRole == UserRole.trainer) {
      return 'New Chat';
    } else if (_currentUserRole == UserRole.member) {
      return 'Chat with Trainer';
    }
    return 'New Chat';
  }

  void _navigateToSelectUser() {
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (_) => MessagesViewModel(),
            child: const SelectChatUserScreen(),
          ),
        ),
      );
    }
  }
}

class ChatParticipantCard extends StatelessWidget {
  final ChatParticipantModel participant;
  final VoidCallback onTap;

  const ChatParticipantCard({
    super.key,
    required this.participant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  backgroundImage: participant.profilePic != null
                      ? NetworkImage(participant.profilePic!)
                      : null,
                  child: participant.profilePic == null
                      ? Text(
                          participant.initials,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        )
                      : null,
                ),
                // Unread badge
                if (participant.hasUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        participant.unreadCount > 9
                            ? '9+'
                            : '${participant.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),

            // Message content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        participant.userName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: participant.hasUnread
                              ? FontWeight.bold
                              : FontWeight.w600,
                        ),
                      ),
                      Text(
                        participant.formattedTime,
                        style: TextStyle(
                          fontSize: 12,
                          color: participant.hasUnread
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade600,
                          fontWeight: participant.hasUnread
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    participant.lastMessageText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: participant.hasUnread
                          ? Colors.black87
                          : Colors.grey.shade600,
                      fontWeight: participant.hasUnread
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

