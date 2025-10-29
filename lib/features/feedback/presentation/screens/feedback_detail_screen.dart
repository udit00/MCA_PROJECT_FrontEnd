import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:zymm/features/feedback/presentation/viewmodel/feedback_viewmodel.dart';

class FeedbackDetailScreen extends StatefulWidget {
  final int feedbackId;

  const FeedbackDetailScreen({super.key, required this.feedbackId});

  @override
  State<FeedbackDetailScreen> createState() => _FeedbackDetailScreenState();
}

class _FeedbackDetailScreenState extends State<FeedbackDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedbackViewModel>().getFeedbackById(widget.feedbackId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Details'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Consumer<FeedbackViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.state == FeedbackViewState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.state == FeedbackViewState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.errorMessage ?? 'Failed to load feedback',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => viewModel.getFeedbackById(widget.feedbackId),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final feedback = viewModel.currentFeedback;
          if (feedback == null) {
            return const Center(child: Text('Feedback not found'));
          }

          final dateFormat = DateFormat('EEEE, MMMM dd, yyyy');
          final timeFormat = DateFormat('hh:mm a');

          return SingleChildScrollView(
            child: Column(
              children: [
                // User Info Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      // User Avatar
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        backgroundImage: feedback.profilePic != null
                            ? NetworkImage(feedback.profilePic!)
                            : null,
                        child: feedback.profilePic == null
                            ? Text(
                                feedback.createdByName[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      
                      // User Name
                      Text(
                        feedback.createdByName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Date and Time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            dateFormat.format(feedback.createdAt),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            timeFormat.format(feedback.createdAt),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Rating Section
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rating Stars
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              'Rating',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(
                                    index < feedback.rating ? Icons.star : Icons.star_border,
                                    size: 40,
                                    color: index < feedback.rating ? Colors.amber : Colors.grey,
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.amber.shade200),
                              ),
                              child: Text(
                                '${feedback.rating} out of 5',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Comments Section
                      if (feedback.hasComments) ...[
                        const SizedBox(height: 32),
                        const Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            feedback.comments!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade800,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 32),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.comment_outlined,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No comments provided',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      
                      // Feedback ID (for reference)
                      const SizedBox(height: 32),
                      Center(
                        child: Text(
                          'Feedback ID: ${feedback.feedbackId}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
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
}

