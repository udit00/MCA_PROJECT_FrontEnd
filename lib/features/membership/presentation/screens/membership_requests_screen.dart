import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:zymm/features/membership/data/models/membership_model.dart';
import 'package:zymm/features/membership/presentation/screens/membership_request_detail_screen.dart';
import 'package:zymm/features/membership/presentation/viewmodel/membership_viewmodel.dart';

class MembershipRequestsScreen extends StatefulWidget {
  const MembershipRequestsScreen({super.key});

  @override
  State<MembershipRequestsScreen> createState() => _MembershipRequestsScreenState();
}

class _MembershipRequestsScreenState extends State<MembershipRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _currentFilter = 'P'; // Default to Pending

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MembershipViewModel>().getAllMemberships(_currentFilter);
    });
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) return;
    
    setState(() {
      switch (_tabController.index) {
        case 0:
          _currentFilter = 'P'; // Pending
          break;
        case 1:
          _currentFilter = 'A'; // Approved
          break;
        case 2:
          _currentFilter = 'R'; // Rejected
          break;
      }
    });
    context.read<MembershipViewModel>().getAllMemberships(_currentFilter);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Membership Requests'),
        centerTitle: true,
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: Consumer<MembershipViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.state == MembershipViewState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.state == MembershipViewState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.errorMessage ?? 'Failed to load requests',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => viewModel.getAllMemberships(_currentFilter),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.getAllMemberships(_currentFilter),
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMembershipsList(viewModel.allMemberships, 'pending'),
                _buildMembershipsList(viewModel.allMemberships, 'approved'),
                _buildMembershipsList(viewModel.allMemberships, 'rejected'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMembershipsList(List<MembershipModel> memberships, String type) {
    if (memberships.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No $type memberships',
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
      itemCount: memberships.length,
      itemBuilder: (context, index) {
        final membership = memberships[index];
        return MembershipCard(
          membership: membership,
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider(
                  create: (_) => MembershipViewModel(),
                  child: MembershipRequestDetailScreen(membership: membership),
                ),
              ),
            );
            // Refresh list if action was taken
            if (result == true && mounted) {
              context.read<MembershipViewModel>().getAllMemberships(_currentFilter);
            }
          },
        );
      },
    );
  }

}

class MembershipCard extends StatelessWidget {
  final MembershipModel membership;
  final VoidCallback onTap;

  const MembershipCard({
    super.key,
    required this.membership,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: membership.statusColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Membership #${membership.membershipId}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'User ID: ${membership.userId}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: membership.statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: membership.statusColor),
                    ),
                    child: Text(
                      membership.statusText,
                      style: TextStyle(
                        color: membership.statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Start: ${dateFormat.format(membership.startDate.toLocal())}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  const Spacer(),
                  Icon(Icons.event_available, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'End: ${dateFormat.format(membership.endDate.toLocal())}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Created: ${dateFormat.format(membership.createdAt.toLocal())}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


