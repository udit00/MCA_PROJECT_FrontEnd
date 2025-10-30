import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zymm/features/employee/data/models/employee_model.dart';
import 'package:zymm/features/employee/presentation/screens/employee_detail_screen.dart';
import 'package:zymm/features/employee/presentation/screens/register_employee_screen.dart';
import 'package:zymm/features/employee/presentation/viewmodel/employee_viewmodel.dart';

class ManageEmployeesScreen extends StatefulWidget {
  final int gymId;
  final String? gymName;

  const ManageEmployeesScreen({
    super.key,
    required this.gymId,
    this.gymName,
  });

  @override
  State<ManageEmployeesScreen> createState() => _ManageEmployeesScreenState();
}

class _ManageEmployeesScreenState extends State<ManageEmployeesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeViewModel>().getAllEmployeesByGymId(widget.gymId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gymName != null
            ? '${widget.gymName} - Employees'
            : 'Manage Employees'),
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
                    viewModel.errorMessage ?? 'Failed to load employees',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () =>
                        viewModel.getAllEmployeesByGymId(widget.gymId),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.employees.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No employees yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first employee using the + button',
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
            onRefresh: () => viewModel.getAllEmployeesByGymId(widget.gymId),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.employees.length,
              itemBuilder: (context, index) {
                final employee = viewModel.employees[index];
                return EmployeeCard(
                  employee: employee,
                  onTap: () => _navigateToEmployeeDetail(employee.employeeId),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToRegisterEmployee(),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Employee'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _navigateToRegisterEmployee() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegisterEmployeeScreen(),
      ),
    ).then((_) {
      // Reload employees after returning
      if (mounted) {
        context.read<EmployeeViewModel>().getAllEmployeesByGymId(widget.gymId);
      }
    });
  }

  void _navigateToEmployeeDetail(int employeeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => EmployeeViewModel(),
          child: EmployeeDetailScreen(employeeId: employeeId),
        ),
      ),
    );
  }
}

class EmployeeCard extends StatelessWidget {
  final EmployeeModel employee;
  final VoidCallback onTap;

  const EmployeeCard({
    super.key,
    required this.employee,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'E${employee.employeeId}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Employee Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Employee #${employee.employeeId}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'User ID: ${employee.userId}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Started: ${employee.formattedStartDate}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow Icon
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
}

