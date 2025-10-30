import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zymm/common/enums/user_role.dart';
import 'package:zymm/core/storage/storage_service.dart';
import 'package:zymm/features/attendance/presentation/view_employee_attendance_screen.dart';
import 'package:zymm/features/employee/presentation/viewmodel/employee_viewmodel.dart';

import '../../data/models/employee_model.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final int employeeId;

  const EmployeeDetailScreen({
    super.key,
    required this.employeeId,
  });

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  UserRole? _currentUserRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeViewModel>().getEmployeeById(widget.employeeId);
    });
  }

  Future<void> _loadUserRole() async {
    final roleId = await StorageService.instance.getRoleId();
    if (roleId != null) {
      setState(() {
        _currentUserRole = UserRole.fromId(roleId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Details'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Consumer<EmployeeViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.state == EmployeeViewState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.state == EmployeeViewState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.errorMessage ?? 'Failed to load employee details',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () =>
                        viewModel.getEmployeeById(widget.employeeId),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final employee = viewModel.currentEmployee;
          if (employee == null) {
            return const Center(child: Text('No employee data available'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header with Avatar
                Container(
                  width: double.infinity,
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
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      // Avatar
                      Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            employee.initials,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        employee.userName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Employee #${employee.employeeId}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: employee.isActive 
                              ? Colors.white.withValues(alpha: 0.2)
                              : Colors.red.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: employee.isActive ? Colors.white : Colors.red.shade300,
                          ),
                        ),
                        child: Text(
                          employee.isActive ? 'Active' : 'Inactive',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Employee Information Cards
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Employee Information',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // Employee ID
                      _buildInfoCard(
                        icon: Icons.badge,
                        title: 'Employee ID',
                        value: '#${employee.employeeId}',
                        iconColor: Colors.blue,
                      ),
                      const SizedBox(height: 12),

                      // Name
                      _buildInfoCard(
                        icon: Icons.person,
                        title: 'Name',
                        value: employee.userName,
                        iconColor: Colors.purple,
                      ),
                      const SizedBox(height: 12),

                      // Mobile
                      _buildInfoCard(
                        icon: Icons.phone,
                        title: 'Mobile',
                        value: employee.mobile,
                        iconColor: Colors.green,
                      ),
                      const SizedBox(height: 12),

                      // Email
                      if (employee.email != null && employee.email!.isNotEmpty)
                        _buildInfoCard(
                          icon: Icons.email,
                          title: 'Email',
                          value: employee.email!,
                          iconColor: Colors.orange,
                        ),
                      if (employee.email != null && employee.email!.isNotEmpty)
                        const SizedBox(height: 12),

                      // Gender
                      _buildInfoCard(
                        icon: Icons.wc,
                        title: 'Gender',
                        value: employee.gender,
                        iconColor: Colors.pink,
                      ),
                      const SizedBox(height: 12),

                      // Started Working
                      _buildInfoCard(
                        icon: Icons.calendar_today,
                        title: 'Started Working',
                        value: employee.formattedStartDateTime,
                        iconColor: Colors.indigo,
                      ),

                      const SizedBox(height: 24),

                      // Action Buttons Section
                      Text(
                        'Actions',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // View Attendance Button
                      _buildActionButton(
                        icon: Icons.access_time,
                        title: 'View Attendance',
                        subtitle: 'Check attendance records',
                        color: Colors.indigo,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewEmployeeAttendanceScreen(
                                userId: employee.userId,
                                employeeName: employee.userName,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      // Deactivate Employee Button - conditionally shown
                      if (_shouldShowDeactivateButton(employee))
                        _buildActionButton(
                          icon: Icons.block,
                          title: 'Deactivate Employee',
                          subtitle: 'Mark as inactive',
                          color: Colors.red,
                          isDanger: true,
                          onTap: () => _showDeactivateDialog(context, employee),
                        ),

                      // Activate Employee Button - conditionally shown for inactive employees
                      if (_shouldShowActivateButton(employee)) ...[
                        const SizedBox(height: 12),
                        _buildActionButton(
                          icon: Icons.check_circle,
                          title: 'Activate Employee',
                          subtitle: 'Mark as active',
                          color: Colors.green,
                          isDanger: false,
                          onTap: () => _showActivateDialog(context, employee),
                        ),
                      ],
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
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
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
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDanger ? Colors.red[50] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDanger ? Colors.red[200]! : Colors.grey[200]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDanger
                    ? Colors.red.withValues(alpha: 0.1)
                    : color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDanger ? Colors.red : color,
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDanger ? Colors.red[700] : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDanger ? Colors.red[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDanger ? Colors.red : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowDeactivateButton(EmployeeModel employee) {
    if (_currentUserRole == null) return false;
    
    // Don't show deactivate button if employee is already inactive
    if (!employee.isActive) return false;
    
    final employeeRole = UserRole.fromId(employee.roleId);
    
    // Owner can deactivate anyone
    if (_currentUserRole == UserRole.owner) {
      return true;
    }
    
    // Manager can deactivate employees but not other managers
    if (_currentUserRole == UserRole.manager) {
      return employeeRole != UserRole.manager;
    }
    
    // Other roles cannot deactivate
    return false;
  }

  bool _shouldShowActivateButton(EmployeeModel employee) {
    if (_currentUserRole == null) return false;
    
    // Only show activate button if employee is inactive
    if (employee.isActive) return false;
    
    final employeeRole = UserRole.fromId(employee.roleId);
    
    // Owner can activate anyone
    if (_currentUserRole == UserRole.owner) {
      return true;
    }
    
    // Manager can activate employees but not other managers
    if (_currentUserRole == UserRole.manager) {
      return employeeRole != UserRole.manager;
    }
    
    // Other roles cannot activate
    return false;
  }

  void _showDeactivateDialog(BuildContext context, EmployeeModel employee) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Deactivate Employee'),
          content: Text(
            'Are you sure you want to deactivate ${employee.userName}? They will no longer be able to access the system.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final viewModel = context.read<EmployeeViewModel>();
                final success = await viewModel.deactivateEmployee(employee.employeeId);
                
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${employee.userName} has been deactivated'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Go back to previous screen
                  Navigator.of(context).pop();
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        viewModel.errorMessage ?? 'Failed to deactivate employee',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Deactivate', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showActivateDialog(BuildContext context, EmployeeModel employee) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Activate Employee'),
          content: Text(
            'Are you sure you want to activate ${employee.userName}? They will be able to access the system again.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final viewModel = context.read<EmployeeViewModel>();
                final success = await viewModel.activateEmployee(employee.employeeId);
                
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${employee.userName} has been activated'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Go back to previous screen
                  Navigator.of(context).pop();
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        viewModel.errorMessage ?? 'Failed to activate employee',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Activate', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}


