import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:zymm/features/membership/data/models/membership_model.dart';
import 'package:zymm/features/membership/presentation/viewmodel/membership_viewmodel.dart';

class MembershipRequestDetailScreen extends StatefulWidget {
  final MembershipModel membership;

  const MembershipRequestDetailScreen({
    super.key,
    required this.membership,
  });

  @override
  State<MembershipRequestDetailScreen> createState() =>
      _MembershipRequestDetailScreenState();
}

class _MembershipRequestDetailScreenState
    extends State<MembershipRequestDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MembershipViewModel>().getPlanDetails(widget.membership.planId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Membership Request'),
        centerTitle: true,
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
                    viewModel.errorMessage ?? 'Failed to load plan details',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => viewModel.getPlanDetails(widget.membership.planId),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final plan = viewModel.currentPlan;
          final dateFormat = DateFormat('MMM dd, yyyy');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: widget.membership.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: widget.membership.statusColor, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.membership.isPending
                            ? Icons.pending_actions
                            : widget.membership.isApproved
                                ? Icons.check_circle
                                : Icons.cancel,
                        color: widget.membership.statusColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.membership.statusText,
                        style: TextStyle(
                          color: widget.membership.statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Plan Details Card
                if (plan != null) ...[
                  _buildSectionTitle('Plan Details'),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.planName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            plan.planDesc,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            Icons.currency_rupee,
                            'Price',
                            plan.formattedPrice,
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            Icons.calendar_today,
                            'Duration',
                            plan.formattedDuration,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Membership Details Card
                _buildSectionTitle('Membership Details'),
                const SizedBox(height: 12),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                          Icons.badge,
                          'Membership ID',
                          '#${widget.membership.membershipId}',
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          Icons.person,
                          'User ID',
                          '#${widget.membership.userId}',
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          Icons.calendar_month,
                          'Start Date',
                          dateFormat.format(widget.membership.startDate.toLocal()),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          Icons.event_available,
                          'End Date',
                          dateFormat.format(widget.membership.endDate.toLocal()),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          Icons.access_time,
                          'Requested On',
                          dateFormat.format(widget.membership.createdAt.toLocal()),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          Icons.power_settings_new,
                          'Status',
                          widget.membership.isActive ? 'Active' : 'Inactive',
                        ),
                      ],
                    ),
                  ),
                ),

                // Action Buttons (only for pending requests)
                if (widget.membership.isPending) ...[
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: viewModel.state == MembershipViewState.submitting
                              ? null
                              : () => _rejectRequest(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.close, color: Colors.white),
                          label: const Text(
                            'Reject',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: viewModel.state == MembershipViewState.submitting
                              ? null
                              : () => _approveRequest(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text(
                            'Approve',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _approveRequest(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Approve Request'),
        content: const Text('Are you sure you want to approve this membership request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final viewModel = context.read<MembershipViewModel>();
    final success = await viewModel.approveMembershipRequest(widget.membership.membershipId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Membership approved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Return true to indicate refresh needed
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Failed to approve request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectRequest(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject Request'),
        content: const Text('Are you sure you want to reject this membership request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final viewModel = context.read<MembershipViewModel>();
    final success = await viewModel.rejectMembershipRequest(widget.membership.membershipId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Membership rejected!'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.pop(context, true); // Return true to indicate refresh needed
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Failed to reject request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

