import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zymm/features/membership/data/models/pending_fees_model.dart';
import 'package:zymm/features/membership/presentation/viewmodel/membership_viewmodel.dart';

class PendingFeesScreen extends StatefulWidget {
  const PendingFeesScreen({super.key});

  @override
  State<PendingFeesScreen> createState() => _PendingFeesScreenState();
}

class _PendingFeesScreenState extends State<PendingFeesScreen> {
  final Set<int> _selectedUserIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await context.read<MembershipViewModel>().getMembersWithPendingFees();
  }

  void _toggleSelection(int userId) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else {
        _selectedUserIds.add(userId);
      }
    });
  }

  void _selectAll() {
    final members = context.read<MembershipViewModel>().pendingFeesMembers;
    setState(() {
      _selectedUserIds.addAll(members.map((m) => m.userId));
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedUserIds.clear();
    });
  }

  Future<void> _sendNotifications() async {
    if (_selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one member'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Send Fee Reminders'),
          content: Text(
            'Send fee reminder notifications to ${_selectedUserIds.length} ${_selectedUserIds.length == 1 ? 'member' : 'members'}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Send', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final viewModel = context.read<MembershipViewModel>();
    final success = await viewModel.sendFeeReminders(_selectedUserIds.toList());

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fee reminders sent to ${_selectedUserIds.length} ${_selectedUserIds.length == 1 ? 'member' : 'members'}!'),
          backgroundColor: Colors.green,
        ),
      );
      _clearSelection();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Failed to send notifications'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Fees'),
        centerTitle: true,
        elevation: 2,
        actions: [
          if (_selectedUserIds.isNotEmpty)
            TextButton(
              onPressed: _clearSelection,
              child: const Text('Clear', style: TextStyle(color: Colors.white)),
            ),
        ],
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
                    viewModel.errorMessage ?? 'Failed to load pending fees',
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
            );
          }

          final members = viewModel.pendingFeesMembers;

          if (members.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.green.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No pending fees!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All memberships are up to date',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Summary header
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade50,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${members.length} ${members.length == 1 ? 'Member' : 'Members'} with Pending Fees',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_selectedUserIds.isNotEmpty)
                            Text(
                              '${_selectedUserIds.length} selected',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue.shade700,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (members.isNotEmpty && _selectedUserIds.length != members.length)
                      TextButton.icon(
                        onPressed: _selectAll,
                        icon: const Icon(Icons.select_all, size: 20),
                        label: const Text('Select All'),
                      ),
                  ],
                ),
              ),
              // Members list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      final isSelected = _selectedUserIds.contains(member.userId);
                      
                      return MemberCard(
                        member: member,
                        isSelected: isSelected,
                        onToggle: () => _toggleSelection(member.userId),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _selectedUserIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _sendNotifications,
              icon: const Icon(Icons.send),
              label: Text('Send to ${_selectedUserIds.length}'),
              backgroundColor: Colors.blue,
            )
          : null,
    );
  }
}

class MemberCard extends StatelessWidget {
  final PendingFeesModel member;
  final bool isSelected;
  final VoidCallback onToggle;

  const MemberCard({
    super.key,
    required this.member,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? Colors.blue
              : member.isExpired
                  ? Colors.red
                  : Colors.orange,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar with checkbox
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: member.isExpired
                        ? Colors.red.shade100
                        : Colors.orange.shade100,
                    child: member.profilePic != null && member.profilePic!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              member.profilePic!,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Text(
                                  member.initials,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: member.isExpired ? Colors.red : Colors.orange,
                                  ),
                                );
                              },
                            ),
                          )
                        : Text(
                            member.initials,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: member.isExpired ? Colors.red : Colors.orange,
                            ),
                          ),
                  ),
                  if (isSelected)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Member info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.userName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member.mobile,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          member.isExpired
                              ? Icons.error
                              : Icons.warning,
                          size: 16,
                          color: member.isExpired ? Colors.red : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            member.expiryMessage,
                            style: TextStyle(
                              fontSize: 13,
                              color: member.isExpired ? Colors.red : Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${member.planName} • ${member.formattedPrice}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Checkbox
              Checkbox(
                value: isSelected,
                onChanged: (_) => onToggle(),
                activeColor: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

