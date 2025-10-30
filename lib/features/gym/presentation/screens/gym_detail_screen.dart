import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zymm/features/feedback/presentation/screens/all_feedbacks_screen.dart';
import 'package:zymm/features/feedback/presentation/screens/create_feedback_screen.dart';
import 'package:zymm/features/gym/presentation/screens/edit_gym_screen.dart';
import 'package:zymm/features/gym/presentation/viewmodel/gym_viewmodel.dart';
import 'package:zymm/features/membership/presentation/screens/view_all_plans_screen.dart';

import '../../../feedback/presentation/viewmodel/feedback_viewmodel.dart';
import '../../../membership/presentation/viewmodel/membership_viewmodel.dart';

class GymDetailScreen extends StatefulWidget {
  final int gymId;
  final bool isManaging; // true if owner/manager is viewing their own gym

  const GymDetailScreen({
    super.key,
    required this.gymId,
    this.isManaging = false,
  });

  @override
  State<GymDetailScreen> createState() => _GymDetailScreenState();
}

class _GymDetailScreenState extends State<GymDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GymViewModel>().getGymById(widget.gymId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GymViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.state == GymViewState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.state == GymViewState.error) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Gym Details'),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      viewModel.errorMessage ?? 'Failed to load gym data',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => viewModel.getGymById(widget.gymId),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final gym = viewModel.selectedGym;
          if (gym == null) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Gym Details'),
              ),
              body: const Center(child: Text('Gym not found')),
            );
          }

          return CustomScrollView(
            slivers: [
              // App Bar with Gym Name
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    gym.gymName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 3.0,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.fitness_center,
                        size: 80,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating Summary
                    if (gym.averageRating != null && gym.totalFeedbacks != null)
                      _buildRatingSummary(gym, context),

                    // Contact Information
                    _buildSection(
                      context,
                      title: 'Contact Information',
                      icon: Icons.contact_phone,
                      child: Column(
                        children: [
                          _buildInfoRow(
                            icon: Icons.phone,
                            label: 'Phone',
                            value: gym.contactNo,
                            onTap: () => _makePhoneCall(gym.contactNo),
                          ),
                          if (gym.officialEmail != null)
                            _buildInfoRow(
                              icon: Icons.email,
                              label: 'Email',
                              value: gym.officialEmail!,
                              onTap: () => _sendEmail(gym.officialEmail!),
                            ),
                        ],
                      ),
                    ),

                    // Location
                    _buildSection(
                      context,
                      title: 'Location',
                      icon: Icons.location_on,
                      child: Column(
                        children: [
                          _buildInfoRow(
                            icon: Icons.home,
                            label: 'Address',
                            value: gym.gymAddress,
                          ),
                          _buildInfoRow(
                            icon: Icons.location_city,
                            label: 'City',
                            value: gym.city,
                          ),
                          _buildInfoRow(
                            icon: Icons.map,
                            label: 'State',
                            value: gym.state,
                          ),
                        ],
                      ),
                    ),

                    // Statistics
                    _buildSection(
                      context,
                      title: 'Statistics',
                      icon: Icons.bar_chart,
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          if (gym.trainersCount != null)
                            _buildStatChip(
                              icon: Icons.fitness_center,
                              label: 'Trainers',
                              value: '${gym.trainersCount}',
                              color: Colors.blue,
                            ),
                          if (gym.staffCount != null)
                            _buildStatChip(
                              icon: Icons.badge,
                              label: 'Staff',
                              value: '${gym.staffCount}',
                              color: Colors.purple,
                            ),
                          if (gym.managersCount != null)
                            _buildStatChip(
                              icon: Icons.admin_panel_settings,
                              label: 'Managers',
                              value: '${gym.managersCount}',
                              color: Colors.orange,
                            ),
                          if (gym.activePlans != null)
                            _buildStatChip(
                              icon: Icons.card_membership,
                              label: 'Active Plans',
                              value: '${gym.activePlans}',
                              color: Colors.green,
                            ),
                        ],
                      ),
                    ),

                    // Action Buttons
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Show different buttons based on whether user is managing
                          if (widget.isManaging) ...[
                            // Edit Gym Button (for owners/managers)
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  // Navigate to Edit Gym Screen
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChangeNotifierProvider(
                                        create: (_) => GymViewModel(),
                                        child: EditGymScreen(gymId: gym.gymId),
                                      ),
                                    ),
                                  );
                                  // Refresh gym data if changes were made
                                  if (result == true && mounted) {
                                    context.read<GymViewModel>().getGymById(widget.gymId);
                                  }
                                },
                                icon: const Icon(Icons.edit, color: Colors.white),
                                label: const Text(
                                  'Edit Gym Details',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ] else ...[
                            // View Membership Plans (for members)
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChangeNotifierProvider(
                                        create: (_) => MembershipViewModel(),
                                        child: ViewAllPlansScreen(
                                          gymId: gym.gymId,
                                          gymName: gym.gymName,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.card_membership, color: Colors.white),
                                label: const Text(
                                  'View Membership Plans',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Rate This Gym Button (for members)
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChangeNotifierProvider(
                                        create: (_) => FeedbackViewModel(),
                                        child: CreateFeedbackScreen(
                                          gymId: gym.gymId,
                                        ),
                                      ),
                                    ),
                                  );
                                  // Refresh gym data if feedback was submitted
                                  if (result == true && mounted) {
                                    context.read<GymViewModel>().getGymById(widget.gymId);
                                  }
                                },
                                icon: const Icon(Icons.star, color: Colors.white),
                                label: const Text(
                                  'Rate This Gym',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // View All Reviews Button (for both)
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChangeNotifierProvider(
                                      create: (_) => FeedbackViewModel(),
                                      child: AllFeedbacksScreen(
                                        gymId: gym.gymId,
                                        gymName: gym.gymName,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.rate_review,
                                color: Theme.of(context).primaryColor,
                              ),
                              label: Text(
                                'View All Reviews',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRatingSummary(gym, BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade400,
            Colors.amber.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Average Rating
          Column(
            children: [
              Text(
                '${gym.averageRating}',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < (gym.averageRating ?? 0).round()
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.white,
                    size: 20,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(width: 24),

          // Reviews Count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${gym.totalFeedbacks} Reviews',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap "View All Reviews" to see what members say',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey.shade600),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
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

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }
}

