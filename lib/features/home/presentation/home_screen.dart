import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zymm/common/enums/user_role.dart';
import 'package:zymm/features/attendance/presentation/attendance_screen.dart';
import 'package:zymm/features/attendance/presentation/viewmodel/attendance_viewmodel.dart';
import 'package:zymm/features/gym/presentation/screens/search_gyms_screen.dart';
import 'package:zymm/features/membership/presentation/screens/membership_requests_screen.dart';
import 'package:zymm/features/membership/presentation/viewmodel/membership_viewmodel.dart';
import 'package:zymm/features/notifications/presentation/notification_center.dart';
import 'package:zymm/features/notifications/presentation/viewmodel/notification_viewmodel.dart';
import 'package:zymm/core/storage/storage_service.dart';

class HomeScreen extends StatelessWidget {
  final UserRole userRole;

  const HomeScreen({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'ZYMM',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).primaryColor,
          actions: [
            // Notification Icon with Badge
            Consumer<NotificationViewModel>(
              builder: (context, notificationViewModel, child) {
                final unreadCount = notificationViewModel.unreadCount;
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationCenter(),
                          ),
                        );
                      },
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Center(
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () => _showProfileMenu(context),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Role Badge
                  _buildRoleBadge(context),
                  const SizedBox(height: 24),
                  
                  // Welcome Card
                  _buildWelcomeCard(context),
                  const SizedBox(height: 32),
                  
                  // Section Title
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Role-based Quick Actions
                  _buildQuickActions(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getRoleIcon(),
            size: 16,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            userRole.displayName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRoleIcon() {
    switch (userRole) {
      case UserRole.owner:
        return Icons.business_center;
      case UserRole.manager:
        return Icons.admin_panel_settings;
      case UserRole.staff:
        return Icons.badge;
      case UserRole.trainer:
        return Icons.fitness_center;
      case UserRole.member:
        return Icons.person;
    }
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getRoleIcon(),
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getWelcomeMessage(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _getWelcomeSubtext(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getWelcomeMessage() {
    switch (userRole) {
      case UserRole.owner:
        return 'Business Dashboard';
      case UserRole.manager:
        return 'Management Panel';
      case UserRole.staff:
        return 'Staff Panel';
      case UserRole.trainer:
        return 'Trainer Dashboard';
      case UserRole.member:
        return 'Ready to workout?';
    }
  }

  String _getWelcomeSubtext() {
    switch (userRole) {
      case UserRole.owner:
        return 'Manage your gym operations';
      case UserRole.manager:
        return 'Oversee daily operations';
      case UserRole.staff:
        return 'Handle front desk tasks';
      case UserRole.trainer:
        return 'Manage your clients';
      case UserRole.member:
        return 'Let\'s make today count!';
    }
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = _getActionsForRole(context);
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: actions.map((action) {
        return _buildQuickActionCard(
          context,
          icon: action['icon'] as IconData,
          title: action['title'] as String,
          subtitle: action['subtitle'] as String,
          color: action['color'] as Color,
          onTap: action['onTap'] as VoidCallback,
        );
      }).toList(),
    );
  }

  List<Map<String, dynamic>> _getActionsForRole(BuildContext context) {
    switch (userRole) {
      case UserRole.owner:
        return [
          // TODO: Add conditional logic for Manage gyms vs Gym card based on gym count
          {
            'icon': Icons.business,
            'title': 'Manage Gyms',
            'subtitle': 'View all gyms',
            'color': Colors.blue,
            'onTap': () {}, // TODO: Navigate to manage gyms
          },
          {
            'icon': Icons.badge,
            'title': 'Manage Employees',
            'subtitle': 'Staff & trainers',
            'color': Colors.purple,
            'onTap': () {}, // TODO: Navigate to employees
          },
          {
            'icon': Icons.pending_actions,
            'title': 'Membership Requests',
            'subtitle': 'Pending approvals',
            'color': Colors.orange,
            'onTap': () async {
              final gymId = await StorageService.instance.getGymId();
              if (gymId != null && context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                      create: (_) => MembershipViewModel(),
                      child: MembershipRequestsScreen(gymId: gymId),
                    ),
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No gym associated with your account'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          },
          {
            'icon': Icons.people,
            'title': 'Manage Members',
            'subtitle': 'All members',
            'color': Colors.green,
            'onTap': () {}, // TODO: Navigate to members
          },
          {
            'icon': Icons.card_membership,
            'title': 'Manage Plans',
            'subtitle': 'Membership plans',
            'color': Colors.teal,
            'onTap': () {}, // TODO: Navigate to plans
          },
          {
            'icon': Icons.attach_money,
            'title': 'Pending Fees',
            'subtitle': 'Upcoming payments',
            'color': Colors.red,
            'onTap': () {}, // TODO: Navigate to fees
          },
        ];

      case UserRole.manager:
        return [
          {
            'icon': Icons.access_time,
            'title': 'Attendance',
            'subtitle': 'My attendance',
            'color': Colors.indigo,
            'onTap': () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                    create: (_) => AttendanceViewModel(),
                    child: const AttendanceScreen(),
                  ),
                ),
              );
            },
          },
          // TODO: Add conditional logic for Manage gyms vs Gym card based on gym count
          {
            'icon': Icons.business,
            'title': 'Manage Gyms',
            'subtitle': 'View all gyms',
            'color': Colors.blue,
            'onTap': () {}, // TODO: Navigate to manage gyms
          },
          {
            'icon': Icons.badge,
            'title': 'Manage Employees',
            'subtitle': 'Staff & trainers',
            'color': Colors.purple,
            'onTap': () {}, // TODO: Navigate to employees
          },
          {
            'icon': Icons.pending_actions,
            'title': 'Membership Requests',
            'subtitle': 'Pending approvals',
            'color': Colors.orange,
            'onTap': () async {
              final gymId = await StorageService.instance.getGymId();
              if (gymId != null && context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                      create: (_) => MembershipViewModel(),
                      child: MembershipRequestsScreen(gymId: gymId),
                    ),
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No gym associated with your account'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          },
          {
            'icon': Icons.people,
            'title': 'Manage Members',
            'subtitle': 'All members',
            'color': Colors.green,
            'onTap': () {}, // TODO: Navigate to members
          },
          {
            'icon': Icons.card_membership,
            'title': 'Manage Plans',
            'subtitle': 'Membership plans',
            'color': Colors.teal,
            'onTap': () {}, // TODO: Navigate to plans
          },
          {
            'icon': Icons.attach_money,
            'title': 'Pending Fees',
            'subtitle': 'Upcoming payments',
            'color': Colors.red,
            'onTap': () {}, // TODO: Navigate to fees
          },
        ];

      case UserRole.staff:
        return [
          {
            'icon': Icons.access_time,
            'title': 'Attendance',
            'subtitle': 'My attendance',
            'color': Colors.indigo,
            'onTap': () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                    create: (_) => AttendanceViewModel(),
                    child: const AttendanceScreen(),
                  ),
                ),
              );
            },
          },
        ];

      case UserRole.trainer:
        return [
          {
            'icon': Icons.access_time,
            'title': 'Attendance',
            'subtitle': 'My attendance',
            'color': Colors.indigo,
            'onTap': () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                    create: (_) => AttendanceViewModel(),
                    child: const AttendanceScreen(),
                  ),
                ),
              );
            },
          },
          {
            'icon': Icons.people,
            'title': 'Check Members',
            'subtitle': 'View members',
            'color': Colors.green,
            'onTap': () {}, // TODO: Navigate to members
          },
          {
            'icon': Icons.chat,
            'title': 'Chat with Members',
            'subtitle': 'Messages',
            'color': Colors.blue,
            'onTap': () {}, // TODO: Navigate to chat
          },
        ];

      case UserRole.member:
        return [
          {
            'icon': Icons.access_time,
            'title': 'Attendance',
            'subtitle': 'My attendance',
            'color': Colors.indigo,
            'onTap': () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                    create: (_) => AttendanceViewModel(),
                    child: const AttendanceScreen(),
                  ),
                ),
              );
            },
          },
          {
            'icon': Icons.fitness_center,
            'title': 'Current Gym',
            'subtitle': 'My gym details',
            'color': Colors.blue,
            'onTap': () {      },
          },
          {
            'icon': Icons.search,
            'title': 'Search Gyms',
            'subtitle': 'Find nearby gyms',
            'color': Colors.green,
            'onTap': () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchGymsScreen(),
                ),
              );
            },
          },
          {
            'icon': Icons.chat,
            'title': 'Chat with Trainer',
            'subtitle': 'Messages',
            'color': Colors.orange,
            'onTap': () {}, // TODO: Navigate to chat
          },
        ];
    }
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: color,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('My Attendance'),
              subtitle: const Text('View attendance records'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                      create: (_) => AttendanceViewModel(),
                      child: const AttendanceScreen(),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              subtitle: const Text('View and edit profile'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to profile
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await StorageService.instance.clearAllOnLogout();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
