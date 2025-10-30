import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zymm/common/enums/user_role.dart';
import 'package:zymm/core/storage/storage_service.dart';
import 'package:zymm/features/home/presentation/home_screen.dart';
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

class _ViewAllPlansScreenState extends State<ViewAllPlansScreen> with RouteAware {
  UserRole? _currentUserRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes
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
    _loadData();
  }

  Future<void> _loadUserRole() async {
    final roleId = await StorageService.instance.getRoleId();
    if (roleId != null && mounted) {
      setState(() {
        _currentUserRole = UserRole.fromId(roleId);
      });
    }
  }

  Future<void> _loadData() async {
    final viewModel = context.read<MembershipViewModel>();
    
    final isManagerOrOwner = _currentUserRole == UserRole.owner || 
                            _currentUserRole == UserRole.manager;
    
    if (isManagerOrOwner) {
      // Owners/Managers: Get ALL plans (active + inactive) without needing gymId
      await viewModel.getAllPlansForManagement();
    } else {
      // Members: First check if user has pending request
      await viewModel.getPlanHistory();
      // Then load only active plans
      await viewModel.getAllPlansByGymId(widget.gymId);
    }
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

          final isManagerOrOwner = _currentUserRole == UserRole.owner || 
                                  _currentUserRole == UserRole.manager;
          
          // For managers/owners, show all plans; for members, show only active plans
          final plansToShow = isManagerOrOwner 
              ? viewModel.plans 
              : viewModel.activePlans;

          if (plansToShow.isEmpty) {
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
              itemCount: plansToShow.length,
              itemBuilder: (context, index) {
                final plan = plansToShow[index];
                final hasRequested = viewModel.hasRequestedPlan(plan.planId);
                
                return PlanCard(
                  plan: plan,
                  hasRequested: hasRequested,
                  isManagerOrOwner: isManagerOrOwner,
                  onRequest: hasRequested ? null : () => _showRequestConfirmation(plan),
                  onCancel: hasRequested && viewModel.pendingPlanRequest != null
                      ? () => _cancelRequest(viewModel.pendingPlanRequest!.membershipId)
                      : null,
                  onEdit: isManagerOrOwner ? () => _navigateToEditPlan(plan) : null,
                  onDeactivate: isManagerOrOwner && plan.isActive 
                      ? () => _showDeactivateDialog(plan) 
                      : null,
                  onActivate: isManagerOrOwner && !plan.isActive 
                      ? () => _showActivateDialog(plan) 
                      : null,
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
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

  void _navigateToEditPlan(PlanModel plan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => MembershipViewModel(),
          child: UpsertPlanScreen(
            gymId: widget.gymId,
            planId: plan.planId,
          ),
        ),
      ),
    );
    // Screen will auto-refresh via RouteAware when we come back
  }

  void _navigateToCreatePlan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => MembershipViewModel(),
          child: UpsertPlanScreen(gymId: widget.gymId),
        ),
      ),
    );
    // Screen will auto-refresh via RouteAware when we come back
  }

  void _showDeactivateDialog(PlanModel plan) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Deactivate Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to deactivate "${plan.planName}"?'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Deactivated plans will not be visible to members.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
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
                _deactivatePlan(plan.planId);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Deactivate', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showActivateDialog(PlanModel plan) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Activate Plan'),
          content: Text('Do you want to activate "${plan.planName}"? It will become visible to members.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _activatePlan(plan.planId);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Activate', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deactivatePlan(int planId) async {
    final viewModel = context.read<MembershipViewModel>();
    final success = await viewModel.deactivatePlan(planId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plan deactivated successfully!'),
          backgroundColor: Colors.orange,
        ),
      );
      // Reload data to refresh the list
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Failed to deactivate plan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _activatePlan(int planId) async {
    final viewModel = context.read<MembershipViewModel>();
    final success = await viewModel.activatePlan(planId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plan activated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      // Reload data to refresh the list
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Failed to activate plan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildFloatingActionButton() {
    final isManagerOrOwner = _currentUserRole == UserRole.owner || 
                            _currentUserRole == UserRole.manager;

    if (isManagerOrOwner) {
      // Show "Add Plan" button for managers and owners
      return FloatingActionButton.extended(
        onPressed: _navigateToCreatePlan,
        icon: const Icon(Icons.add),
        label: const Text('Add Plan'),
        backgroundColor: Colors.blue,
      );
    }

    // Show "Cancel Request" button for members with pending requests
    return Consumer<MembershipViewModel>(
      builder: (context, viewModel, child) {
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
    );
  }
}

class PlanCard extends StatelessWidget {
  final PlanModel plan;
  final bool hasRequested;
  final bool isManagerOrOwner;
  final VoidCallback? onRequest;
  final VoidCallback? onCancel;
  final VoidCallback? onEdit;
  final VoidCallback? onDeactivate;
  final VoidCallback? onActivate;

  const PlanCard({
    super.key,
    required this.plan,
    required this.hasRequested,
    required this.isManagerOrOwner,
    this.onRequest,
    this.onCancel,
    this.onEdit,
    this.onDeactivate,
    this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    final isInactive = !plan.isActive;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isInactive && isManagerOrOwner
            ? const BorderSide(color: Colors.red, width: 3)
            : BorderSide.none,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isInactive && isManagerOrOwner
                ? [
                    Colors.red.withValues(alpha: 0.05),
                    Colors.white,
                  ]
                : [
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
              // Plan Name with Status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      plan.planName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isInactive && isManagerOrOwner
                            ? Colors.grey.shade600
                            : Colors.black,
                      ),
                    ),
                  ),
                  if (isManagerOrOwner)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: plan.isActive
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        plan.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: plan.isActive ? Colors.green : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else if (plan.isActive)
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

              // Action Buttons - Different for Managers/Owners vs Members
              if (isManagerOrOwner)
                // Buttons for managers and owners
                Column(
                  children: [
                    // Edit button
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
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Activate/Deactivate button
                    if (plan.isActive)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: onDeactivate,
                          icon: const Icon(Icons.block),
                          label: const Text(
                            'Deactivate Plan',
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
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: onActivate,
                          icon: const Icon(Icons.check_circle, color: Colors.white),
                          label: const Text(
                            'Activate Plan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                  ],
                )
              else if (hasRequested)
                // Cancel request for members with pending requests
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
                // Request plan for members without pending requests
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




