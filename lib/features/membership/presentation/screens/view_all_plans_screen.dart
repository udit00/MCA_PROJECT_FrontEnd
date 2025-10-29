import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zymm/common/enums/user_role.dart';
import 'package:zymm/core/storage/storage_service.dart';
import 'package:zymm/features/membership/data/models/plan_model.dart';
import 'package:zymm/features/membership/presentation/screens/upsert_plan_screen.dart';
import 'package:zymm/features/membership/presentation/viewmodel/membership_viewmodel.dart';

class ViewAllPlansScreen extends StatefulWidget {
  final int gymId;
  final String? gymName;

  const ViewAllPlansScreen({
    super.key,
    required this.gymId,
    this.gymName,
  });

  @override
  State<ViewAllPlansScreen> createState() => _ViewAllPlansScreenState();
}

class _ViewAllPlansScreenState extends State<ViewAllPlansScreen> {
  UserRole _userRole = UserRole.member;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadUserRole() async {
    final roleId = await StorageService.instance.getRoleId();
    if (roleId != null && mounted) {
      setState(() {
        _userRole = UserRole.fromId(roleId);
      });
    }
  }

  bool get _isOwnerOrManager =>
      _userRole == UserRole.owner || _userRole == UserRole.manager;

  Future<void> _loadData() async {
    final viewModel = context.read<MembershipViewModel>();
    // Only check pending requests for members
    if (!_isOwnerOrManager) {
      await viewModel.getPlanHistory();
    }
    // Then load plans
    await viewModel.getAllPlansByGymId(widget.gymId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gymName != null 
            ? '${widget.gymName} Plans' 
            : 'Membership Plans'),
        centerTitle: true,
        elevation: 2,
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
                    viewModel.errorMessage ?? 'Failed to load plans',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => viewModel.getAllPlansByGymId(widget.gymId),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final activePlans = viewModel.activePlans;

          if (activePlans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.card_membership,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No active plans available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later for new plans',
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
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: activePlans.length,
              itemBuilder: (context, index) {
                final plan = activePlans[index];
                
                if (_isOwnerOrManager) {
                  // Owner/Manager view - can edit plans
                  return PlanCard(
                    plan: plan,
                    isOwnerOrManager: true,
                    onEdit: () => _navigateToEditPlan(plan.planId),
                  );
                } else {
                  // Member view - can request plans
                  final hasRequested = viewModel.hasRequestedPlan(plan.planId);
                  return PlanCard(
                    plan: plan,
                    hasRequested: hasRequested,
                    onRequest: hasRequested ? null : () => _showRequestConfirmation(plan),
                    onCancel: hasRequested && viewModel.pendingPlanRequest != null
                        ? () => _cancelRequest(viewModel.pendingPlanRequest!.membershipId)
                        : null,
                  );
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: Consumer<MembershipViewModel>(
        builder: (context, viewModel, child) {
          // Owner/Manager: Show add plan FAB
          if (_isOwnerOrManager) {
            return FloatingActionButton(
              onPressed: () => _navigateToCreatePlan(),
              backgroundColor: Colors.green,
              child: const Icon(Icons.add, color: Colors.white),
            );
          }
          
          // Member: Show cancel request FAB if has pending request
          if (viewModel.hasPendingRequest && viewModel.pendingPlanRequest != null) {
            return FloatingActionButton.extended(
              onPressed: () => _cancelRequest(viewModel.pendingPlanRequest!.membershipId),
              icon: const Icon(Icons.close),
              label: const Text('Cancel Request'),
              backgroundColor: Colors.red,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showRequestConfirmation(PlanModel plan) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Request Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Do you want to request "${plan.planName}"?'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price: ${plan.formattedPrice}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Duration: ${plan.formattedDuration}'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _requestPlan(plan.planId);
              },
              child: const Text('Request'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelRequest(int membershipId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Request'),
          content: const Text('Are you sure you want to cancel this membership request?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final viewModel = context.read<MembershipViewModel>();
    final success = await viewModel.cancelMembershipRequest(membershipId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request cancelled successfully!'),
          backgroundColor: Colors.orange,
        ),
      );
      // Reload data
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Failed to cancel request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _requestPlan(int planId) async {
    final viewModel = context.read<MembershipViewModel>();
    final success = await viewModel.requestPlan(planId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plan request submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      // Reload data to update button states
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Failed to request plan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToCreatePlan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => MembershipViewModel(),
          child: UpsertPlanScreen(
            gymId: widget.gymId,
            planId: 0, // 0 for creating new plan
          ),
        ),
      ),
    ).then((_) => _loadData()); // Reload plans after returning
  }

  void _navigateToEditPlan(int planId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => MembershipViewModel(),
          child: UpsertPlanScreen(
            gymId: widget.gymId,
            planId: planId, // Existing plan ID for editing
          ),
        ),
      ),
    ).then((_) => _loadData()); // Reload plans after returning
  }
}

class PlanCard extends StatelessWidget {
  final PlanModel plan;
  final bool hasRequested;
  final VoidCallback? onRequest;
  final VoidCallback? onCancel;
  final bool isOwnerOrManager;
  final VoidCallback? onEdit;

  const PlanCard({
    super.key,
    required this.plan,
    this.hasRequested = false,
    this.onRequest,
    this.onCancel,
    this.isOwnerOrManager = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withValues(alpha: 0.1),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plan Name
              Row(
                children: [
                  Expanded(
                    child: Text(
                      plan.planName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Plan Description
              Text(
                plan.planDesc,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Price and Duration
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      icon: Icons.currency_rupee,
                      label: 'Price',
                      value: '₹${plan.planPrice}',
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoChip(
                      icon: Icons.calendar_today,
                      label: 'Duration',
                      value: '${plan.planDuration} days',
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Action Button based on role
              if (isOwnerOrManager)
                // Owner/Manager: Edit Plan Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text(
                      'Edit Plan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                )
              else if (hasRequested)
                // Member: Show pending status and cancel button
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade300, width: 2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.pending_actions, color: Colors.orange.shade700, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Request Pending',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: onCancel,
                        icon: const Icon(Icons.close),
                        label: const Text(
                          'Cancel Request',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                // Member: Request Plan Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onRequest,
                    icon: const Icon(Icons.send, color: Colors.white),
                    label: const Text(
                      'Request This Plan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

