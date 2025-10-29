import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zymm/features/membership/data/models/upsert_plan_request_model.dart';
import 'package:zymm/features/membership/presentation/viewmodel/membership_viewmodel.dart';

class UpsertPlanScreen extends StatefulWidget {
  final int gymId;
  final int planId; // 0 for create, > 0 for update

  const UpsertPlanScreen({
    super.key,
    required this.gymId,
    this.planId = 0,
  });

  @override
  State<UpsertPlanScreen> createState() => _UpsertPlanScreenState();
}

class _UpsertPlanScreenState extends State<UpsertPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _planNameController = TextEditingController();
  final _planDescController = TextEditingController();
  final _planPriceController = TextEditingController();
  final _planDurationController = TextEditingController();
  
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.planId > 0) {
      // Fetch existing plan details for update
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadPlanDetails();
      });
    }
  }

  Future<void> _loadPlanDetails() async {
    final viewModel = context.read<MembershipViewModel>();
    await viewModel.getPlanDetails(widget.planId);
    
    if (viewModel.currentPlan != null && mounted) {
      final plan = viewModel.currentPlan!;
      setState(() {
        _planNameController.text = plan.planName;
        _planDescController.text = plan.planDesc;
        _planPriceController.text = plan.planPrice.toString();
        _planDurationController.text = plan.planDuration.toString();
        _isActive = plan.isActive;
      });
    }
  }

  @override
  void dispose() {
    _planNameController.dispose();
    _planDescController.dispose();
    _planPriceController.dispose();
    _planDurationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.planId > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(isUpdate ? 'Update Plan' : 'Create New Plan'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Consumer<MembershipViewModel>(
        builder: (context, viewModel, child) {
          // Show loading while fetching plan details
          if (isUpdate && 
              viewModel.state == MembershipViewState.loading && 
              viewModel.currentPlan == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show error if failed to load
          if (isUpdate && 
              viewModel.state == MembershipViewState.error && 
              viewModel.currentPlan == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.errorMessage ?? 'Failed to load plan',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadPlanDetails,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Plan Name
                    const Text(
                      'Plan Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _planNameController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Super 45',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter plan name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Plan Description
                    const Text(
                      'Plan Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _planDescController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Describe the plan benefits...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter plan description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Price and Duration Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Price (₹)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _planPriceController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: '3000',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  final price = int.tryParse(value);
                                  if (price == null || price <= 0) {
                                    return 'Invalid price';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Duration (days)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _planDurationController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: '30',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  final duration = int.tryParse(value);
                                  if (duration == null || duration <= 0) {
                                    return 'Invalid';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Active Status
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Plan Status',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _isActive 
                                      ? 'Active - Visible to users'
                                      : 'Inactive - Hidden from users',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isActive,
                            onChanged: (value) {
                              setState(() {
                                _isActive = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitPlan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isUpdate ? 'Update Plan' : 'Create Plan',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _submitPlan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final request = UpsertPlanRequestModel(
      planId: widget.planId,
      planName: _planNameController.text.trim(),
      planDesc: _planDescController.text.trim(),
      planPrice: int.parse(_planPriceController.text.trim()),
      planDuration: int.parse(_planDurationController.text.trim()),
      gymId: widget.gymId,
      isActive: _isActive,
      userAgent: 'Flutter',
      appVersion: '1.0.0',
    );

    final viewModel = context.read<MembershipViewModel>();
    final success = await viewModel.upsertPlan(request);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.planId > 0
                ? 'Plan updated successfully!'
                : 'Plan created successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Return true to indicate success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.errorMessage ?? 'Failed to save plan',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

