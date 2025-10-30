import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:zymm/features/membership/data/models/plan_model.dart';
import 'package:zymm/features/membership/presentation/viewmodel/membership_viewmodel.dart';

class PlanDetailScreen extends StatefulWidget {
  final int planId;

  const PlanDetailScreen({
    super.key,
    required this.planId,
  });

  @override
  State<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<PlanDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MembershipViewModel>().getPlanDetails(widget.planId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Details'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Consumer<MembershipViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.state == MembershipViewState.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (viewModel.state == MembershipViewState.error) {
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
                    viewModel.errorMessage ?? 'Failed to load plan details',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => viewModel.getPlanDetails(widget.planId),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final plan = viewModel.currentPlan;

          if (plan == null) {
            return const Center(
              child: Text('Plan not found'),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with gradient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white,
                          ),
                        ),
                        child: const Text(
                          'Your Plan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        plan.planName,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.currency_rupee,
                            color: Colors.white,
                            size: 32,
                          ),
                          Text(
                            NumberFormat('#,##0').format(plan.planPrice),
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '/ ${plan.planDuration} days',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Plan Details Section
                      _buildSectionTitle('Plan Information'),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        icon: Icons.calendar_today,
                        title: 'Duration',
                        value: '${plan.planDuration} days',
                        iconColor: Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        icon: Icons.attach_money,
                        title: 'Price',
                        value: '₹${NumberFormat('#,##0').format(plan.planPrice)}',
                        iconColor: Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        icon: Icons.description,
                        title: 'Description',
                        value: plan.planDesc,
                        iconColor: Colors.orange,
                      ),
                      const SizedBox(height: 24),

                      // Benefits Section
                      _buildSectionTitle('What\'s Included'),
                      const SizedBox(height: 16),
                      _buildBenefitItem(
                        icon: Icons.fitness_center,
                        text: 'Access to all gym equipment',
                      ),
                      const SizedBox(height: 12),
                      _buildBenefitItem(
                        icon: Icons.groups,
                        text: 'Group fitness classes',
                      ),
                      const SizedBox(height: 12),
                      _buildBenefitItem(
                        icon: Icons.shower,
                        text: 'Locker room access',
                      ),
                      const SizedBox(height: 12),
                      _buildBenefitItem(
                        icon: Icons.water_drop,
                        text: 'Complimentary water and towel',
                      ),
                      const SizedBox(height: 24),

                      // Additional Info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'This is your currently active membership plan. You can view your progress and remaining days on the home screen.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.green.shade700,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ),
        Icon(
          Icons.check_circle,
          color: Colors.green.shade600,
          size: 20,
        ),
      ],
    );
  }
}

