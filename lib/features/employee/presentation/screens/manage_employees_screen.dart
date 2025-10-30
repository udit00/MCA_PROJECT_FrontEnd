import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zymm/features/employee/data/models/employee_model.dart';
import 'package:zymm/features/employee/presentation/screens/employee_detail_screen.dart';
import 'package:zymm/features/employee/presentation/screens/register_employee_screen.dart';
import 'package:zymm/features/employee/presentation/viewmodel/employee_viewmodel.dart';
import 'package:zymm/features/home/presentation/home_screen.dart';

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

class _ManageEmployeesScreenState extends State<ManageEmployeesScreen> with RouteAware {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchEmployees();
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
    // Called when coming back to this screen
    developer.log('🔄 ManageEmployeesScreen: didPopNext - Refetching employees');
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    if (mounted) {
      await context.read<EmployeeViewModel>().getAllEmployeesByGymId(widget.gymId);
    }
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
                    onPressed: _fetchEmployees,
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
            onRefresh: _fetchEmployees,
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
    );
    // Note: Employees will automatically refresh via RouteAware.didPopNext()
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
    final isDeactivated = !employee.isActive;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDeactivated ? Colors.red : Colors.transparent,
          width: 2,
        ),
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
                  color: isDeactivated 
                      ? Colors.red.shade100 
                      : Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    employee.initials,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDeactivated 
                          ? Colors.red.shade700 
                          : Colors.blue.shade700,
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            employee.userName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDeactivated ? Colors.grey : Colors.black,
                            ),
                          ),
                        ),
                        if (isDeactivated)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red, width: 1),
                            ),
                            child: Text(
                              'INACTIVE',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          employee.mobile,
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
                          Icons.badge,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Employee #${employee.employeeId} • ${employee.gender}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

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

