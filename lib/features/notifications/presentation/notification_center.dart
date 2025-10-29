import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:zymm/features/notifications/data/models/notification_model.dart';
import 'package:zymm/features/notifications/presentation/viewmodel/notification_viewmodel.dart';

class NotificationCenter extends StatefulWidget {
  const NotificationCenter({super.key});

  @override
  State<NotificationCenter> createState() => _NotificationCenterState();
}

class _NotificationCenterState extends State<NotificationCenter> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationViewModel>().fetchNotifications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Unread'),
          ],
        ),
      ),
      body: Consumer<NotificationViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.state == NotificationViewState.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (viewModel.state == NotificationViewState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.errorMessage ?? 'An error occurred',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => viewModel.fetchNotifications(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.fetchNotifications(),
            child: TabBarView(
              controller: _tabController,
              children: [
                // All Notifications Tab
                _buildNotificationList(
                  context,
                  viewModel,
                  viewModel.notifications,
                  'No notifications yet',
                ),
                // Unread Notifications Tab
                _buildNotificationList(
                  context,
                  viewModel,
                  viewModel.unreadNotifications,
                  'No unread notifications',
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Consumer<NotificationViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.unreadCount > 0) {
            return FloatingActionButton.extended(
              onPressed: () {
                _showMarkAllAsReadDialog(context, viewModel);
              },
              icon: const Icon(Icons.done_all),
              label: Text('Mark All as Read (${viewModel.unreadCount})'),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildNotificationList(
    BuildContext context,
    NotificationViewModel viewModel,
    List<NotificationModel> notifications,
    String emptyMessage,
  ) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return NotificationCard(
          notification: notification,
          isMarkingAsRead: viewModel.isMarkingAsRead(notification.notificationId),
          onMarkAsRead: notification.isRead
              ? null
              : () => viewModel.markAsRead(notification.notificationId),
        );
      },
    );
  }

  void _showMarkAllAsReadDialog(
    BuildContext context,
    NotificationViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Mark All as Read'),
          content: Text(
            'Are you sure you want to mark all ${viewModel.unreadCount} notifications as read?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                viewModel.markAllAsRead();
              },
              child: const Text('Mark All'),
            ),
          ],
        );
      },
    );
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final bool isMarkingAsRead;
  final VoidCallback? onMarkAsRead;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.isMarkingAsRead,
    this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: notification.isRead ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: notification.isRead 
              ? Colors.grey.shade300 
              : theme.primaryColor.withValues(alpha: 0.5),
          width: notification.isRead ? 1 : 2,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: notification.isRead 
              ? Colors.white 
              : theme.primaryColor.withValues(alpha: 0.05),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon, type badge, and date
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notification Type Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        notification.notificationType.iconEmoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title and metadata
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.notificationTitle,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: notification.isRead 
                                      ? FontWeight.w600 
                                      : FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: theme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Type Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getTypeColor(notification.notificationType).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            notification.notificationType.displayName,
                            style: TextStyle(
                              color: _getTypeColor(notification.notificationType),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Description
              Text(
                notification.notificationDesc,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),

              // Footer with date and mark as read button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date and Time
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${dateFormat.format(notification.createdOn)} at ${timeFormat.format(notification.createdOn)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  // Mark as Read Button
                  if (onMarkAsRead != null)
                    isMarkingAsRead
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : TextButton.icon(
                            onPressed: onMarkAsRead,
                            icon: const Icon(Icons.done, size: 16),
                            label: const Text(
                              'Mark as Read',
                              style: TextStyle(fontSize: 12),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          )
                  else if (notification.isRead)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Read',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(notificationType) {
    switch (notificationType.id) {
      case 1: // NotificationZymm
        return Colors.purple;
      case 2: // NotificationGeneralInfo
        return Colors.blue;
      case 3: // NotificationGymBroadcast
        return Colors.orange;
      case 4: // NotificationMembershipReq
        return Colors.teal;
      case 5: // NotificationMembershipRes
        return Colors.green;
      case 6: // NotificationFeedbackReceived
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }
}

